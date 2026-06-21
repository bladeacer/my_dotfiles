#!/usr/bin/env python3
"""
Save per-screen calibration to calibrations.json.

Called from calibrate.qml via Process with arguments:
  save-offset.py <screen_name> <bottom_margin> [<screen_name> <bottom_margin> ...]

Each pair is (screen_name, bottom_margin_px).
Merges with existing calibrations (untouched screens preserved).
"""

import json, os, sys

CAL_FILE_DEV = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    ".config", "quickshell", "calibrations.json")
CAL_FILE_HOME = os.path.expanduser(
    "~/.config/quickshell/calibrations.json")


def find_file():
    for p in (CAL_FILE_DEV, CAL_FILE_HOME):
        if os.path.exists(p):
            return p
    return CAL_FILE_DEV


def main():
    args = sys.argv[1:]
    if len(args) < 2 or len(args) % 2 != 0:
        print(f"Usage: {sys.argv[0]} <screen_name> <bottom_margin> [<name> <margin> ...]")
        sys.exit(1)

    pairs = [(args[i], float(args[i + 1]))
             for i in range(0, len(args), 2)]
    print(f"Screen pairs: {pairs}")

    path = find_file()
    calib = {}
    if os.path.exists(path):
        with open(path) as f:
            raw = f.read().strip()
            if raw:
                calib = json.loads(raw)

    for name, val in pairs:
        rounded = round(val, 1)
        if name in calib:
            print(f"  {name}: was {calib[name]:.1f} -> now {rounded}")
        else:
            print(f"  {name}: new calibration = {rounded}")
        calib[name] = rounded

    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(calib, f, indent=2)
        f.write("\n")

    print(f"Wrote {len(pairs)} calibration(s) to {path}")
    print("Done.")


if __name__ == "__main__":
    main()
