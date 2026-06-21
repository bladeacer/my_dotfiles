#!/usr/bin/env python3
"""Print existing calibrations from calibrations.json as JSON."""
import json, os, sys

paths = [
    os.path.join(os.path.dirname(os.path.abspath(__file__)),
                 ".config", "quickshell", "calibrations.json"),
    os.path.expanduser("~/.config/quickshell/calibrations.json"),
]

for p in paths:
    if os.path.exists(p):
        with open(p) as f:
            raw = f.read().strip()
            if raw:
                try:
                    print(json.dumps(json.loads(raw)))
                except json.JSONDecodeError:
                    print("{}")
            else:
                print("{}")
        sys.exit(0)

print("{}")
