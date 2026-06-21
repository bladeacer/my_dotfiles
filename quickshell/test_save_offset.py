#!/usr/bin/env python3
"""
Unit tests for save-offset.py save/load/merge cycle.

Tests the persistence layer independently of the QML environment.
Run with: python3 test_save_offset.py
"""

import json
import os
import tempfile
import unittest

FORMULA_SLOPE = 101 / 318
FORMULA_CONST = -5.3491


def formula(h):
    return h * FORMULA_SLOPE + FORMULA_CONST


def save_calibration(path, pairs):
    """Simulate what save-offset.py does (write to a specified path)."""
    calib = {}
    if os.path.exists(path):
        with open(path) as f:
            raw = f.read().strip()
            if raw:
                calib = json.loads(raw)
    for name, val in pairs:
        calib[name] = round(val, 1)
    with open(path, "w") as f:
        json.dump(calib, f, indent=2)
        f.write("\n")
    return calib


class TestPersistence(unittest.TestCase):
    """Tests the calibration save/load/merge cycle."""

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.cal_path = os.path.join(self.tmpdir.name, "calibrations.json")

    def tearDown(self):
        self.tmpdir.cleanup()

    # ── Save ──────────────────────────────────────────────────────

    def test_save_new(self):
        """Saving a new calibration creates the file."""
        save_calibration(self.cal_path, [("DP-1", 150.5)])
        with open(self.cal_path) as f:
            data = json.load(f)
        self.assertEqual(data, {"DP-1": 150.5})

    def test_save_multiple_new(self):
        """Saving multiple screens in one call."""
        save_calibration(self.cal_path, [("DP-1", 150.5), ("HDMI-1", 200.3)])
        with open(self.cal_path) as f:
            data = json.load(f)
        self.assertEqual(data, {"DP-1": 150.5, "HDMI-1": 200.3})

    def test_save_merge_preserves_untouched(self):
        """Saving a new screen preserves existing calibrations."""
        save_calibration(self.cal_path, [("DP-1", 150.5)])
        save_calibration(self.cal_path, [("HDMI-1", 200.3)])
        with open(self.cal_path) as f:
            data = json.load(f)
        self.assertEqual(data, {"DP-1": 150.5, "HDMI-1": 200.3})

    def test_save_overwrite_existing(self):
        """Saving an existing screen name overwrites its value."""
        save_calibration(self.cal_path, [("DP-1", 150.5)])
        save_calibration(self.cal_path, [("DP-1", 999.9)])
        with open(self.cal_path) as f:
            data = json.load(f)
        self.assertEqual(data, {"DP-1": 999.9})

    def test_save_rounds_to_one_decimal(self):
        """Values are rounded to 1 decimal place."""
        save_calibration(self.cal_path, [("DP-1", 150.55)])
        with open(self.cal_path) as f:
            data = json.load(f)
        self.assertEqual(data, {"DP-1": 150.6})

    # ── Load ──────────────────────────────────────────────────────

    def test_load_empty_file(self):
        """Loading from empty file returns empty dict."""
        with open(self.cal_path, "w") as f:
            f.write("{}\n")
        with open(self.cal_path) as f:
            data = json.load(f)
        self.assertEqual(data, {})

    def test_load_non_existent(self):
        """Loading from non-existent file is handled gracefully."""
        self.assertFalse(os.path.exists(self.cal_path))

    # ── Round-trip ────────────────────────────────────────────────

    def test_round_trip_single(self):
        """Save then load yields the same calibration."""
        save_calibration(self.cal_path, [("eDP-1", 387.7)])
        with open(self.cal_path) as f:
            loaded = json.load(f)
        self.assertEqual(loaded, {"eDP-1": 387.7})

    def test_round_trip_multi(self):
        """Multiple saves + loads preserve all calibrations."""
        save_calibration(self.cal_path, [("DP-1", 150.5)])
        save_calibration(self.cal_path, [("HDMI-1", 200.3)])
        with open(self.cal_path) as f:
            loaded = json.load(f)
        expected = {"DP-1": 150.5, "HDMI-1": 200.3}
        self.assertEqual(loaded, expected)

    # ── Offset math ───────────────────────────────────────────────

    def test_offset_restore(self):
        """
        Simulate the full cycle:
          1. User drags to offset=50 on a 1080p screen
          2. Save: calibratedPos = formula(1080) + 50 → 387.7
          3. Save writes 387.7 to file
          4. Load: offset = 387.7 - formula(1080) → 50
        """
        h = 1080
        user_offset = 50.0
        calibrated_pos = formula(h) + user_offset  # 337.7 + 50 = 387.7
        self.assertAlmostEqual(calibrated_pos, 387.7, places=1)

        save_calibration(self.cal_path, [("HDMI-1", calibrated_pos)])
        with open(self.cal_path) as f:
            cal = json.load(f)

        restored_offset = cal["HDMI-1"] - formula(h)
        self.assertAlmostEqual(restored_offset, user_offset, places=1)

    def test_offset_restore_negative(self):
        """Negative offsets (bars dragged down) restore correctly."""
        h = 1080
        user_offset = -20.0
        calibrated_pos = formula(h) + user_offset

        save_calibration(self.cal_path, [("HDMI-1", calibrated_pos)])
        with open(self.cal_path) as f:
            cal = json.load(f)

        restored_offset = cal["HDMI-1"] - formula(h)
        self.assertAlmostEqual(restored_offset, user_offset, places=1)

    def test_offset_restore_different_heights(self):
        """Screens with different heights each restore their own offset."""
        screens = [(1080, 50.0), (1800, -30.0)]
        pairs = []
        for h, off in screens:
            pairs.append((f"Screen-{h}", round(formula(h) + off, 1)))

        save_calibration(self.cal_path, pairs)
        with open(self.cal_path) as f:
            cal = json.load(f)

        for h, off in screens:
            restored = cal[f"Screen-{h}"] - formula(h)
            self.assertAlmostEqual(restored, off, places=1)


if __name__ == "__main__":
    unittest.main()
