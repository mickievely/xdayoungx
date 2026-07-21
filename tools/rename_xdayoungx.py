#!/usr/bin/env python3
"""Replace xdayoungx/Goku branding with xdayoungx across project files."""

from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKIP = {"gokuvape (1).lua", ".git"}

REPLACEMENTS = [
    ("shared.XDayoungXRepo", "shared.XDayoungXRepo"),
    ("XDayoungXReloading", "XDayoungXReloading"),
    ("XDayoungXErrors", "XDayoungXErrors"),
    ("XDayoungXRun", "XDayoungXRun"),
    ("xdayoungxQueueTeleport", "xdayoungxQueueTeleport"),
    ("reloadXDayoungX", "reloadXDayoungX"),
    ("xdayoungxLogError", "xdayoungxLogError"),
    ("xdayoungx/", "xdayoungx/"),
    ("xdayoungx\\", "xdayoungx\\"),
    ("-- xdayoungx:", "-- xdayoungx:"),
    ("autoexec/xdayoungx.lua", "autoexec/xdayoungx.lua"),
    ("AutoExec/xdayoungx.lua", "AutoExec/xdayoungx.lua"),
    ("getXDayoungXTier", "getXDayoungXTier"),
    ("xdayoungxKitRender", "xdayoungxKitRender"),
    ("xdayoungxKitIcon", "xdayoungxKitIcon"),
    ("[xdayoungx MODULE ISSUE]", "[xdayoungx MODULE ISSUE]"),
    ("split_xdayoungx", "split_xdayoungx"),
    ("XDayoungXEmbed", "XDayoungXEmbed"),
    ("saveXDayoungXCache", "saveXDayoungXCache"),
]


def should_process(path: Path) -> bool:
    if any(part in SKIP for part in path.parts):
        return False
    if path.name in SKIP:
        return False
    if path.suffix.lower() not in {".lua", ".md", ".txt", ".ps1", ".py", ".gitignore"}:
        return False
    return True


def main() -> None:
    changed = 0
    for path in ROOT.rglob("*"):
        if not path.is_file() or not should_process(path):
            continue
        text = path.read_text(encoding="utf-8")
        original = text
        for old, new in REPLACEMENTS:
            text = text.replace(old, new)
        if text != original:
            path.write_text(text, encoding="utf-8", newline="\n")
            changed += 1
            print(path.relative_to(ROOT))
    print(f"Updated {changed} files")


if __name__ == "__main__":
    main()
