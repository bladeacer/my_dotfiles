#!/usr/bin/env python3
import configparser, json, os

def dump(path=None):
    if path is None:
        path = os.path.expanduser("~/.config/kdeglobals")
    if not os.path.exists(path):
        return "{}"

    cfg = configparser.ConfigParser()
    cfg.optionxform = str
    cfg.read(path)

    result = {}
    for section in [
        "Colors:Window",
        "Colors:Selection",
        "Colors:Header",
        "Colors:View",
        "Colors:Button",
    ]:
        if section in cfg:
            result[section] = dict(cfg[section])

    return json.dumps(result)


if __name__ == "__main__":
    print(dump())
