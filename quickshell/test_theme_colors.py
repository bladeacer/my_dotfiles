#!/usr/bin/env python3
"""
Unit tests for KDE color scheme loading/parsing pipeline.

Tests the Python-side JSON generation (the inline script in shell.qml's
kdeThemeLoader/kdeThemeWatcher) and the QML-side applyKdeColors logic
(re-implemented here to verify color mapping, derived alphas, and
edge cases without needing a QML runtime).
"""

import json
import os
import sys
import tempfile
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".config/quickshell"))
from dump_kdecolors import dump as _dump_path

KDE_SECTIONS = [
    "Colors:Window",
    "Colors:Selection",
    "Colors:Header",
    "Colors:View",
    "Colors:Button",
]


def _dump_kdeglobals(path):
    return _dump_path(path)


# ---------------------------------------------------------------------------
# QML-side: reify Theme.applyKdeColors in Python
# ---------------------------------------------------------------------------

class ThemeColors:
    """Mirrors the QML Theme singleton's color properties."""

    def __init__(self):
        self.bgNormal = None
        self.bgHeader = None
        self.bgAlt = None
        self.fgNormal = None
        self.fgMuted = None
        self.accentBlue = None
        self.accentGreen = None
        self.accentRed = None
        self.accentOrange = None
        self.accentPurple = None
        self.accentPink = None
        self.selectionBg = None
        self.widgetBg = None
        self.borderMain = None
        self.accentBlueDim = None
        self.borderSubdued = None
        self.accentRedDim = None
        self.accentBlueGhost = None
        self.fgGhost = None

    def apply_kde_colors(self, data):
        """Replicates Theme.applyKdeColors from QML exactly."""

        def parse_color(v):
            if not v:
                return None
            parts = v.split(",")
            if len(parts) != 3:
                return None
            try:
                return (
                    int(parts[0]) / 255.0,
                    int(parts[1]) / 255.0,
                    int(parts[2]) / 255.0,
                    1.0,
                )
            except ValueError:
                return None

        if "Colors:Window" in data:
            w = data["Colors:Window"]
            bg = parse_color(w.get("BackgroundNormal"))
            if bg:
                self.bgNormal = bg
                self.bgHeader = bg
            fg = parse_color(w.get("ForegroundNormal"))
            if fg:
                self.fgNormal = fg
            muted = parse_color(w.get("ForegroundInactive"))
            if muted:
                self.fgMuted = muted
            alt = parse_color(w.get("BackgroundAlternate"))
            if alt:
                self.bgAlt = alt
            accent = parse_color(w.get("DecorationFocus"))
            if accent:
                self.accentBlue = accent

        if "Colors:Selection" in data:
            s = data["Colors:Selection"]
            sel = parse_color(s.get("BackgroundNormal"))
            if sel:
                self.selectionBg = sel

        bg_norm = self.bgNormal or (0, 0, 0, 1.0)
        accent = self.accentBlue or (0, 0, 0, 1.0)
        self.widgetBg = (bg_norm[0], bg_norm[1], bg_norm[2], 0.92)
        self.borderMain = (accent[0], accent[1], accent[2], 0.18)

        self.accentBlueDim = (accent[0], accent[1], accent[2], 0.1)
        self.borderSubdued = (
            self.borderMain[0],
            self.borderMain[1],
            self.borderMain[2],
            0.3,
        )
        accent_red = self.accentRed or (226 / 255, 120 / 255, 120 / 255, 1.0)
        self.accentRedDim = (accent_red[0], accent_red[1], accent_red[2], 0.15)
        self.accentBlueGhost = (accent[0], accent[1], accent[2], 0.08)
        self.fgGhost = (1.0, 1.0, 1.0, 0.05)

    def rgba(self, name):
        return getattr(self, name, None)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

SAMPLE_KG = """[Colors:Window]
BackgroundAlternate=36,38,44
BackgroundNormal=25,29,40
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=111,118,133
ForegroundLink=209,199,242
ForegroundNormal=211,213,211
ForegroundVisited=122,184,254

[Colors:Selection]
BackgroundAlternate=108,83,168
BackgroundNormal=108,83,168
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=255,255,255
ForegroundLink=118,54,221
ForegroundNormal=255,255,255
ForegroundVisited=122,184,254

[Colors:Header]
BackgroundAlternate=36,38,44
BackgroundNormal=25,29,40
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=111,118,133
ForegroundLink=209,199,242
ForegroundNormal=211,213,211
ForegroundVisited=122,184,254

[Colors:View]
BackgroundAlternate=25,29,40
BackgroundNormal=20,22,28
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=111,118,133
ForegroundLink=146,110,228
ForegroundNormal=211,213,211
ForegroundVisited=122,184,254

[Colors:Button]
BackgroundAlternate=113,88,172
BackgroundNormal=36,38,44
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=111,118,133
ForegroundLink=209,199,242
ForegroundNormal=211,213,211
ForegroundVisited=122,184,254
"""


def approx_color(a, b, rel=1e-6):
    """Compare two RGBA tuples."""
    if a is None or b is None:
        return False
    return all(abs(av - bv) <= rel for av, bv in zip(a, b))


# ===================================================================
# Tests: Python-side JSON generation
# ===================================================================


class TestPythonDump:
    def test_dump_includes_all_sections(self):
        with tempfile.NamedTemporaryFile(mode="w", suffix=".colors", delete=False) as f:
            f.write(SAMPLE_KG)
            tmp = f.name
        try:
            raw = _dump_kdeglobals(tmp)
            data = json.loads(raw)
            for sec in KDE_SECTIONS:
                assert sec in data, f"missing section {sec}"
        finally:
            os.unlink(tmp)

    def test_dump_preserves_key_case(self):
        with tempfile.NamedTemporaryFile(mode="w", suffix=".colors", delete=False) as f:
            f.write(SAMPLE_KG)
            tmp = f.name
        try:
            raw = _dump_kdeglobals(tmp)
            data = json.loads(raw)
            win = data["Colors:Window"]
            assert "BackgroundNormal" in win, "key cased incorrectly"
            assert "backgroundnormal" not in win, "case was lowercased"
        finally:
            os.unlink(tmp)

    def test_dump_values_are_strings(self):
        with tempfile.NamedTemporaryFile(mode="w", suffix=".colors", delete=False) as f:
            f.write(SAMPLE_KG)
            tmp = f.name
        try:
            raw = _dump_kdeglobals(tmp)
            data = json.loads(raw)
            for sec in KDE_SECTIONS:
                for k, v in data[sec].items():
                    assert isinstance(v, str), f"{sec}.{k} is not str: {v!r}"
                    parts = v.split(",")
                    assert len(parts) == 3
                    for p in parts:
                        assert 0 <= int(p) <= 255
        finally:
            os.unlink(tmp)

    def test_dump_empty_file(self):
        with tempfile.NamedTemporaryFile(mode="w", suffix=".colors", delete=False) as f:
            f.write("")
            tmp = f.name
        try:
            raw = _dump_kdeglobals(tmp)
            data = json.loads(raw)
            assert data == {}
        finally:
            os.unlink(tmp)

    def test_dump_missing_file(self):
        result = _dump_kdeglobals("/nonexistent/path/kdeglobals")
        data = json.loads(result)
        assert data == {}

    def test_dump_missing_sections(self):
        content = "[General]\nColorScheme=test\n"
        with tempfile.NamedTemporaryFile(mode="w", suffix=".colors", delete=False) as f:
            f.write(content)
            tmp = f.name
        try:
            raw = _dump_kdeglobals(tmp)
            data = json.loads(raw)
            assert data == {}
        finally:
            os.unlink(tmp)

    def test_dump_partial_sections(self):
        content = "[Colors:Window]\nBackgroundNormal=10,20,30\n[Other:Section]\nx=1\n"
        with tempfile.NamedTemporaryFile(mode="w", suffix=".colors", delete=False) as f:
            f.write(content)
            tmp = f.name
        try:
            raw = _dump_kdeglobals(tmp)
            data = json.loads(raw)
            assert "Colors:Window" in data
            assert "Colors:Selection" not in data
        finally:
            os.unlink(tmp)


# ===================================================================
# Tests: QML-side applyKdeColors logic
# ===================================================================


class TestApplyKdeColors:
    def test_apply_full_data(self):
        raw = _dump_kdeglobals_from_str(SAMPLE_KG)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        # Window bg (25,29,40)
        assert approx_color(theme.bgNormal, (25 / 255, 29 / 255, 40 / 255, 1.0))
        assert approx_color(theme.bgHeader, (25 / 255, 29 / 255, 40 / 255, 1.0))
        # Window fg (211,213,211)
        assert approx_color(theme.fgNormal, (211 / 255, 213 / 255, 211 / 255, 1.0))
        # Window fg inactive (111,118,133)
        assert approx_color(theme.fgMuted, (111 / 255, 118 / 255, 133 / 255, 1.0))
        # Window bg alt (36,38,44)
        assert approx_color(theme.bgAlt, (36 / 255, 38 / 255, 44 / 255, 1.0))
        # DecorationFocus (146,110,228) -> accentBlue
        assert approx_color(theme.accentBlue, (146 / 255, 110 / 255, 228 / 255, 1.0))
        # Selection bg (108,83,168)
        assert approx_color(
            theme.selectionBg, (108 / 255, 83 / 255, 168 / 255, 1.0)
        )

    def test_apply_missing_window_section(self):
        content = "[Colors:Selection]\nBackgroundNormal=10,20,30\n"
        raw = _dump_kdeglobals_from_str(content)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        assert theme.bgNormal is None  # no fallback
        assert theme.selectionBg is not None

    def test_apply_missing_selection_section(self):
        content = "[Colors:Window]\nBackgroundNormal=1,2,3\nForegroundNormal=4,5,6\n"
        raw = _dump_kdeglobals_from_str(content)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        assert theme.bgNormal is not None
        assert theme.selectionBg is None  # no selection section

    def test_apply_empty_data(self):
        theme = ThemeColors()
        theme.apply_kde_colors({})
        # bgNormal/fgNormal stay None; widgetBg/borderMain derived from
        # None fallback to black, so they are non-None
        assert theme.bgNormal is None
        assert theme.fgNormal is None
        assert theme.accentBlue is None

    def test_apply_preserves_fallback_accent_colors(self):
        """accentGreen/Red/Orange/Purple/Pink are readonly (never set by KDE)."""
        data = _dump_kdeglobals_from_str(SAMPLE_KG)
        theme = ThemeColors()
        theme.apply_kde_colors(data)
        assert theme.accentGreen is None
        assert theme.accentRed is None
        assert theme.accentOrange is None
        assert theme.accentPurple is None
        assert theme.accentPink is None

    def test_apply_invalid_rgb_string(self):
        """Malformed RGB values are silently ignored."""
        content = "[Colors:Window]\nBackgroundNormal=not,a,color\n"
        raw = _dump_kdeglobals_from_str(content)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        assert theme.bgNormal is None

    def test_apply_partial_rgb_string(self):
        content = "[Colors:Window]\nBackgroundNormal=10,20\n"
        raw = _dump_kdeglobals_from_str(content)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        assert theme.bgNormal is None

    def test_apply_out_of_range_rgb(self):
        """Values >255 are passed through (QML parseInt clips to 255 anyway)."""
        content = "[Colors:Window]\nBackgroundNormal=300,0,0\n"
        raw = _dump_kdeglobals_from_str(content)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        # In Python this won't clip, but QML's parseInt would clip to 255
        # We just verify it's set
        assert theme.bgNormal is not None


# ===================================================================
# Tests: Derived color computation
# ===================================================================


class TestDerivedColors:
    def test_widget_bg_alpha(self):
        raw = _dump_kdeglobals_from_str(SAMPLE_KG)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        # widgetBg should be bgNormal at alpha 0.92
        r, g, b, a = theme.widgetBg
        assert approx_color((r, g, b), (25 / 255, 29 / 255, 40 / 255))
        assert a == pytest.approx(0.92)

    def test_border_main_alpha(self):
        raw = _dump_kdeglobals_from_str(SAMPLE_KG)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        r, g, b, a = theme.borderMain
        assert approx_color((r, g, b), (146 / 255, 110 / 255, 228 / 255))
        assert a == pytest.approx(0.18)

    def test_accent_blue_dim(self):
        raw = _dump_kdeglobals_from_str(SAMPLE_KG)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        r, g, b, a = theme.accentBlueDim
        assert approx_color((r, g, b), (146 / 255, 110 / 255, 228 / 255))
        assert a == pytest.approx(0.1)

    def test_border_subdued(self):
        raw = _dump_kdeglobals_from_str(SAMPLE_KG)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        r, g, b, a = theme.borderSubdued
        assert approx_color((r, g, b), (146 / 255, 110 / 255, 228 / 255))
        assert a == pytest.approx(0.3)  # direct alpha, not multiplied by borderMain.a

    def test_accent_blue_ghost(self):
        raw = _dump_kdeglobals_from_str(SAMPLE_KG)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        r, g, b, a = theme.accentBlueGhost
        assert approx_color((r, g, b), (146 / 255, 110 / 255, 228 / 255))
        assert a == pytest.approx(0.08)

    def test_fg_ghost(self):
        raw = _dump_kdeglobals_from_str(SAMPLE_KG)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        assert approx_color(theme.fgGhost, (1.0, 1.0, 1.0, 0.05))


# ===================================================================
# Tests: Edge cases
# ===================================================================


class TestEdgeCases:
    def test_missing_background_normal_fallback_to_default(self):
        """When BackgroundNormal is missing, bgNormal stays None (no hardcoded fallback in test)."""
        content = "[Colors:Window]\nForegroundNormal=1,2,3\n"
        raw = _dump_kdeglobals_from_str(content)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        # No BackgroundNormal -> bgNormal stays None
        assert theme.bgNormal is None
        # But fgNormal was set
        assert theme.fgNormal is not None

    def test_missing_decoration_focus_fallback(self):
        """When DecorationFocus is missing, accentBlue stays None."""
        content = "[Colors:Window]\nBackgroundNormal=10,20,30\n"
        raw = _dump_kdeglobals_from_str(content)
        theme = ThemeColors()
        theme.apply_kde_colors(raw)
        assert theme.accentBlue is None


# ---------------------------------------------------------------------------
# Internal helper
# ---------------------------------------------------------------------------

def _dump_kdeglobals_from_str(content):
    """Write content to temp file, run _dump_kdeglobals, return parsed dict."""
    with tempfile.NamedTemporaryFile(mode="w", suffix=".colors", delete=False) as f:
        f.write(content)
        tmp = f.name
    try:
        raw = _dump_kdeglobals(tmp)
        return json.loads(raw)
    finally:
        os.unlink(tmp)
