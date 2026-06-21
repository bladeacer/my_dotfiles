use anyhow::Result;
use lookas::{
    analyzer::{FlowSpringParams, SpectrumAnalyzer},
    audio::{AudioController, AudioMode},
    buffer::SharedBuf,
    config::Config,
    dsp::{hann, prepare_fft_input_inplace},
    filterbank::{build_filterbank, FilterbankParams},
};
use realfft::num_complex::Complex;
use realfft::{RealFftPlanner, RealToComplex};
use std::io::{self, Write};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};

// ---------------------------------------------------------------------------
// Small helpers adapted from lookas::app (private there)
// ---------------------------------------------------------------------------

#[allow(clippy::arithmetic_side_effects)]
fn ring_cap(fft_size: usize) -> usize {
    ((48_000usize / 10).max(fft_size * 3))
        .max(fft_size * 6)
        .next_power_of_two()
}

struct NoiseGate {
    power_ema: f32,
    open: bool,
    below_s: f32,
    open_db: f32,
    close_db: f32,
    confirm_s: f32,
}

impl NoiseGate {
    fn new(gate_db: f32) -> Self {
        Self {
            power_ema: 0.0,
            open: false,
            below_s: 0.0,
            open_db: gate_db,
            close_db: (gate_db - 3.0).max(-80.0),
            confirm_s: 0.12,
        }
    }

    fn tick(&mut self, power: f32, dt_s: f32) {
        if self.power_ema == 0.0 {
            self.power_ema = power;
        } else {
            let tau = if power > self.power_ema { 0.012 } else { 0.22 };
            self.power_ema = lookas::dsp::ema_tc(self.power_ema, power, tau, dt_s);
        }
        let power_db = 10.0 * self.power_ema.max(1e-12).log10();
        if self.open {
            if power_db < self.close_db {
                self.below_s += dt_s;
                if self.below_s >= self.confirm_s {
                    self.open = false;
                    self.below_s = 0.0;
                }
            } else {
                self.below_s = 0.0;
            }
        } else {
            self.below_s = 0.0;
            if power_db > self.open_db {
                self.open = true;
            }
        }
    }
}

fn compute_power(tail: &[f32], fft_size: usize) -> f32 {
    tail.iter().map(|&x| x * x).sum::<f32>() / fft_size as f32
}

fn compute_spectrum(
    tail: &[f32],
    window: &[f32],
    buf: &mut Vec<f32>,
    fft_out: &mut [Complex<f32>],
    fft: &Arc<dyn RealToComplex<f32>>,
    spec_pow: &mut [f32],
    half: usize,
    fft_size: usize,
) {
    prepare_fft_input_inplace(tail, window, buf);
    if fft.process(buf, fft_out).is_err() {
        return;
    }
    let norm_inv = 1.0 / ((fft_size as f32) * (fft_size as f32));
    for i in 0..half {
        let re = fft_out[i].re;
        let im = fft_out[i].im;
        spec_pow[i] = re.mul_add(re, im * im) * norm_inv;
    }
}

// ---------------------------------------------------------------------------

fn main() -> Result<()> {
    // ignore SIGPIPE so EPIPE is returned on write instead of killing us
    #[cfg(target_os = "linux")]
    unsafe {
        libc::signal(libc::SIGPIPE, libc::SIG_IGN);
    }

    let bars: usize = std::env::var("LOOKAS_BARS")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(77);

    let cfg = Config::load()?;
    let fft_size = cfg.fft_size;
    let half = fft_size / 2;
    let cap = ring_cap(fft_size);

    // --- audio capture ---
    let mic_shared = Arc::new(Mutex::new(SharedBuf::new(cap)));
    let sys_shared = Arc::new(Mutex::new(SharedBuf::new(cap)));
    let mut audio = AudioController::new();
    if audio
        .start(
            AudioMode::System,
            mic_shared.clone(),
            sys_shared.clone(),
        )
        .is_err()
    {
        audio.start(
            AudioMode::Mic,
            mic_shared.clone(),
            sys_shared.clone(),
        )?;
    }
    let sr = audio.info().sample_rate as f32;

    // --- FFT ---
    let mut planner = RealFftPlanner::<f32>::new();
    let fft = planner.plan_fft_forward(fft_size);
    let mut fft_buf = fft.make_input_vec();
    let mut fft_out = fft.make_output_vec();
    let mut spec_pow = vec![0.0; half];

    // --- analyzer ---
    let mut analyzer = SpectrumAnalyzer::new(half);
    analyzer.filters = build_filterbank(FilterbankParams {
        sr,
        fft_size,
        bands: bars,
        fmin: cfg.fmin,
        fmax: cfg.fmax,
    });
    analyzer.resize(bars);

    let mut gate = NoiseGate::new(cfg.gate_db);
    let window = hann(fft_size);
    let mut mic_tail = Vec::with_capacity(fft_size);
    let mut sys_tail = Vec::with_capacity(fft_size);
    let mut mix_buf = vec![0.0; fft_size];

    let target_dt = Duration::from_millis(cfg.frame_ms);
    let mut last = Instant::now();

    let stdout = io::stdout();
    let mut out = stdout.lock();
    let mut line = String::with_capacity(bars * 10);

    loop {
        // --- frame-rate governor ---
        let now = Instant::now();
        if let Some(sleep) = target_dt.checked_sub(now.duration_since(last)) {
            thread::sleep(sleep);
        }
        let now = Instant::now();
        let dt_s = now.duration_since(last).as_secs_f32();
        last = now;

        // --- read audio tail(s) ---
        let mic_ok = mic_shared
            .try_lock()
            .ok()
            .is_some_and(|b| b.copy_last_n_into(fft_size, &mut mic_tail));
        let sys_ok = sys_shared
            .try_lock()
            .ok()
            .is_some_and(|b| b.copy_last_n_into(fft_size, &mut sys_tail));

        let tail: Option<&[f32]> = match audio.mode() {
            AudioMode::Mic => mic_ok.then_some(&mic_tail),
            AudioMode::System => sys_ok.then_some(&sys_tail),
            AudioMode::Both => {
                if !mic_ok || !sys_ok {
                    None
                } else {
                    for i in 0..fft_size {
                        mix_buf[i] = (mic_tail[i] + sys_tail[i]) * 0.5;
                    }
                    Some(&mix_buf)
                }
            }
        };

        let Some(tail) = tail else {
            thread::sleep(Duration::from_millis(1));
            continue;
        };

        // --- signal processing pipeline ---
        gate.tick(compute_power(tail, fft_size), dt_s);
        compute_spectrum(
            tail, &window, &mut fft_buf, &mut fft_out, &fft,
            &mut spec_pow, half, fft_size,
        );

        analyzer.update_spectrum(&spec_pow, cfg.tau_spec, dt_s);
        analyzer.analyze_bands(dt_s, gate.open);
        analyzer.apply_flow_and_spring(
            &FlowSpringParams {
                flow_k: cfg.flow_k,
                spr_k: cfg.spr_k,
                spr_zeta: cfg.spr_zeta,
            },
            dt_s,
            gate.open,
        );

        // --- write bar heights to stdout ---
        line.clear();
        for v in &analyzer.bars_y {
            use std::fmt::Write;
            let _ = write!(line, "{:.6} ", v);
        }
        if writeln!(out, "{}", line.trim()).is_err() {
            break; // broken pipe
        }
    }

    audio.stop();
    Ok(())
}
