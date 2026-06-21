#!/usr/bin/env python3
"""
Spectrum Visualiser — Bottom-Margin Calibrator

Drag the bar-area rectangles on each screen until they line up with
your wallpaper guide.  Press Enter/S to save — the script computes
the linear formula and writes it directly into SpectrumVisualizer.qml.

Controls (click any overlay window first):
  Drag the blue bar area     move it up/down
  Tab                        cycle active screen
  ↑ / ↓                      nudge active screen by 1 px
  Shift+↑ / ↓                nudge by 10 px
  Enter / S                  save formula into QML and quit
  Escape                     discard
"""

import os, re, sys
from fractions import Fraction

from PyQt5.QtCore import Qt, QObject, QEvent
from PyQt5.QtGui import QColor, QFont, QPainter, QPen
from PyQt5.QtWidgets import QApplication, QMainWindow, QWidget

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_QML_PATH = os.path.join(
    _SCRIPT_DIR, ".config", "quickshell", "components", "SpectrumVisualizer.qml"
)
# Fallback: symlink target under $HOME
_HOME_QML = os.path.expanduser(
    "~/.config/quickshell/components/SpectrumVisualizer.qml"
)

# ---------------------------------------------------------------------------
# Reference heights & current best formula
# ---------------------------------------------------------------------------
H1, H2 = 1080, 1800
_slope = Fraction(181, 360)
_intercept = -294.0


def base_offset(h):
    return h * float(_slope) + _intercept


# ---------------------------------------------------------------------------
# Shared state: per-screen adjustments
# ---------------------------------------------------------------------------
class SharedState:
    def __init__(self):
        self.adjs = {}  # screen_height → pixel adjustment

    def offset_for(self, h):
        return base_offset(h) + self.adjs.get(h, 0.0)

    def set_adj(self, h, val):
        self.adjs[h] = round(val, 1)

    def get_adj(self, h):
        return self.adjs.get(h, 0.0)


state = SharedState()

# ---------------------------------------------------------------------------
# Canvas — one per screen, mouse-draggable
# ---------------------------------------------------------------------------
class CanvasWidget(QWidget):
    BAR_AREA_RATIO = 800.0 / 1800.0

    def __init__(self, screen_h, label, parent=None):
        super().__init__(parent)
        self.screen_h = screen_h
        self.label = label
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setMouseTracking(True)
        self._dragging = False
        self._drag_start_y = 0
        self._drag_start_adj = 0.0

    # ---- geometry helpers ----
    def _bar_rect(self, w, h, off):
        bottom_y = h - off
        ah = h * self.BAR_AREA_RATIO
        top_y = bottom_y - ah
        pad = w * 0.02
        return (int(pad), int(top_y), int(w - 2 * pad), int(ah))

    # ---- mouse ----
    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            w, h = self.width(), self.screen_h
            off = state.offset_for(h)
            rx, ry, rw, rh = self._bar_rect(w, h, off)
            if rx <= event.x() <= rx + rw and ry <= event.y() <= ry + rh:
                self._dragging = True
                self._drag_start_y = event.y()
                self._drag_start_adj = state.get_adj(h)
                self.setCursor(Qt.ClosedHandCursor)

    def mouseMoveEvent(self, event):
        if self._dragging:
            dy = event.y() - self._drag_start_y
            new_adj = self._drag_start_adj - dy  # drag up → larger offset
            h = self.screen_h
            state.set_adj(h, new_adj)
            self.parent().update()
            off = state.offset_for(h)
            print(f"\r  {self.label}: offset = {off:.1f} px"
                  f"  (adj = {new_adj:+.1f})  ", end="", flush=True)
        else:
            w, h = self.width(), self.screen_h
            off = state.offset_for(h)
            rx, ry, rw, rh = self._bar_rect(w, h, off)
            self.setCursor(Qt.OpenHandCursor
                           if rx <= event.x() <= rx + rw
                           and ry <= event.y() <= ry + rh
                           else Qt.ArrowCursor)

    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton and self._dragging:
            self._dragging = False
            self.setCursor(Qt.ArrowCursor)
            print()

    # ---- paint ----
    def paintEvent(self, _event):
        p = QPainter(self)
        p.setRenderHint(QPainter.Antialiasing)

        w, h = self.width(), self.screen_h
        off = state.offset_for(h)
        rx, ry, rw, rh = self._bar_rect(w, h, off)
        bl_y = int(h - off)

        p.fillRect(0, 0, w, h, QColor(0, 0, 0, 50))
        p.fillRect(rx, ry, rw, rh, QColor(132, 160, 198, 55))

        pen = QPen(QColor(132, 160, 198), 2)
        p.setPen(pen)
        p.drawRect(rx, ry, rw, rh)

        pen.setColor(QColor(226, 120, 120))
        pen.setWidth(4)
        p.setPen(pen)
        p.drawLine(rx + 4, bl_y, rx + rw - 4, bl_y)

        pen.setWidth(1)
        p.setPen(pen)
        for cx in (rx + rw // 3, rx + rw * 2 // 3):
            for dy in (-4, 4):
                p.drawLine(cx - 6, bl_y + dy, cx, bl_y)
                p.drawLine(cx + 6, bl_y + dy, cx, bl_y)

        p.setPen(QColor(198, 200, 209))
        font = QFont("monospace", 11)
        p.setFont(font)
        adj = state.get_adj(h)
        lines = [
            self.label,
            f"offset = {off:.1f} px  (adj = {adj:+.1f})",
            "[drag the bar, Enter to save]",
        ]
        for i, line in enumerate(lines):
            p.drawText(20, 30 + i * 18, line)


# ---------------------------------------------------------------------------
# Overlay window
# ---------------------------------------------------------------------------
class Overlay(QMainWindow):
    def __init__(self, screen_geom, label):
        super().__init__()
        self.screen_geom = screen_geom
        self.label = label
        self.setWindowTitle(f"Calibrate — {label}")
        self.setWindowFlags(
            Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
            | Qt.Tool | Qt.BypassWindowManagerHint
        )
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setAttribute(Qt.WA_ShowWithoutActivating)
        g = screen_geom
        self.setGeometry(g.x(), g.y(), g.width(), g.height())
        self._canvas = CanvasWidget(g.height(), label, self)
        self.setCentralWidget(self._canvas)
        self.showFullScreen()

    def refresh(self):
        self._canvas.update()

    def nudge(self, delta):
        h = self.screen_geom.height()
        state.set_adj(h, state.get_adj(h) + delta)
        off = state.offset_for(h)
        print(f"  {self.label}: offset = {off:.1f} px"
              f"  (adj = {state.get_adj(h):+.1f})")
        self.refresh()


# ---------------------------------------------------------------------------
# Keyboard filter
# ---------------------------------------------------------------------------
class KeyFilter(QObject):
    def __init__(self, overlays):
        super().__init__()
        self.overlays = overlays
        self._active_idx = 0

    @property
    def active(self):
        return self.overlays[self._active_idx] if self.overlays else None

    def refresh_all(self):
        for ov in self.overlays:
            ov.refresh()

    def _save(self):
        self.refresh_all()
        QApplication.processEvents()
        pairs = [(ov.screen_geom.height(),
                  state.offset_for(ov.screen_geom.height()))
                 for ov in self.overlays]
        pairs.sort()
        formula = compute_formula(pairs)
        if formula:
            write_qml(formula)
        QApplication.quit()

    def eventFilter(self, obj, event):
        if event.type() == QEvent.KeyPress:
            key = event.key()
            mod = event.modifiers()
            delta = 10 if (mod & Qt.ShiftModifier) else 1

            if key in (Qt.Key_Return, Qt.Key_Enter, Qt.Key_S):
                if key == Qt.Key_S and (mod & Qt.ControlModifier):
                    return False
                self._save()
                return True

            if key == Qt.Key_Escape:
                QApplication.quit()
                return True

            if key == Qt.Key_Tab:
                self._active_idx = (self._active_idx + 1) % len(self.overlays)
                print(f"  Active: {self.active.label}")
                return True

            if key in (Qt.Key_Up, Qt.Key_Down):
                step = delta if key == Qt.Key_Up else -delta
                if self.active:
                    self.active.nudge(step)
                return True

        return super().eventFilter(obj, event)


# ---------------------------------------------------------------------------
# Formula computation
# ---------------------------------------------------------------------------
def compute_formula(pairs):
    """Return the QML expression string or None."""
    print("\n=== ACCEPTED ===")
    print("  Heights and offsets:")
    for h, o in pairs:
        print(f"    height={h:5d}  offset={o:.2f}")

    if len(pairs) < 2:
        print("\n  Need at least 2 screens!")
        return None

    (h1, o1), (h2, o2) = pairs[0], pairs[-1]
    if h1 == h2:
        print("\n  Screens have same height!")
        return None

    m = Fraction(o2 - o1).limit_denominator() / Fraction(h2 - h1)
    b = Fraction(o1).limit_denominator() - h1 * m

    ms = m.limit_denominator(10000)
    bs = b.limit_denominator(10000)

    if float(bs) < 0:
        expr = (f"parent.height * {ms.numerator}/{ms.denominator}"
                f" - {abs(float(bs)):.4f}")
    else:
        expr = (f"parent.height * {ms.numerator}/{ms.denominator}"
                f" + {float(bs):.4f}")

    print(f"\n  Formula:  anchors.bottomMargin: {expr}")
    print(f"  = parent.height * {float(ms):.10f} {float(bs):+.10f}")

    for h, want in pairs:
        got = h * float(ms) + float(bs)
        ok = "✓" if abs(got - want) < 0.1 else "✗"
        print(f"  Verify: h={h:5d} → {got:.2f} (want {want:.2f})  {ok}")

    return f"anchors.bottomMargin: {expr}"


# ---------------------------------------------------------------------------
# Write formula into SpectrumVisualizer.qml
# ---------------------------------------------------------------------------
def write_qml(formula_line):
    # Try repo path first, fall back to home symlink
    for path in (_QML_PATH, _HOME_QML):
        if os.path.exists(path):
            target = path
            break
    else:
        print("\n  ✗ Could not find SpectrumVisualizer.qml!")
        print(f"    Tried:\n      {_QML_PATH}\n      {_HOME_QML}")
        return

    try:
        with open(target, "r") as f:
            content = f.read()
    except OSError as e:
        print(f"\n  ✗ Failed to read {target}: {e}")
        return

    # Replace the anchors.bottomMargin line
    new_content, count = re.subn(
        r"^\s+anchors\.bottomMargin:.*$",
        f"        {formula_line}",
        content,
        count=1,
        flags=re.MULTILINE,
    )

    if count == 0:
        print("\n  ✗ Could not find 'anchors.bottomMargin:' in the file!")
        return

    try:
        with open(target, "w") as f:
            f.write(new_content)
    except OSError as e:
        print(f"\n  ✗ Failed to write {target}: {e}")
        return

    print(f"\n  ✓ Wrote formula to {target}")
    print(f"  → {formula_line}")
    print("  Restart quickshell to see the change.")
    print()


# ---------------------------------------------------------------------------
# Entry
# ---------------------------------------------------------------------------
def main():
    app = QApplication(sys.argv)
    screens = app.screens()
    overlays = []

    for si, screen in enumerate(screens):
        g = screen.geometry()
        h = g.height()
        if abs(h - H1) <= 50:
            label = f"1080p (actual {h}px)"
        elif abs(h - H2) <= 50:
            label = f"1800p (actual {h}px)"
        else:
            label = f"{h}p"
        state.adjs[h] = 0.0
        ov = Overlay(g, f"Screen {si+1}: {label}")
        overlays.append(ov)

    if not overlays:
        print("No screens detected!")
        sys.exit(1)

    kf = KeyFilter(overlays)
    for ov in overlays:
        ov.installEventFilter(kf)

    print("=== CALIBRATOR ===")
    print("  Drag any blue bar area with the mouse to position it.")
    print("  Tab to cycle active screen, Up/Down to nudge.")
    print("  Enter / S    save formula into SpectrumVisualizer.qml")
    print("  Escape       discard")
    print()
    for ov in overlays:
        ov.show()
        h = ov.screen_geom.height()
        print(f"  {ov.label}: offset = {state.offset_for(h):.1f} px")

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
