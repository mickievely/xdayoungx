import re
from pathlib import Path

lines = Path(r"c:\Users\a0107\Downloads\배드워즈\gokuvape (1).lua").read_text(encoding="utf-8").splitlines(keepends=True)
start = end = None
for i, line in enumerate(lines):
    if line.startswith("shared.XDayoungXEmbed"):
        start = i + 1
    if start and line.strip() == "}" and "local isfile = isfile or function(file)" in "".join(lines[i + 1 : i + 4]):
        end = i
        break
section = "".join(lines[start:end])
entry_re = re.compile(r"\['([^']+)'\]\s*=\s*(\[=*\[)")
pos = 0
while True:
    m = entry_re.search(section, pos)
    if not m:
        break
    path = m.group(1)
    open_delim = m.group(2)
    eq = open_delim.count("=") - 1
    close = "]" + ("=" * eq) + "]"
    cs = m.end()
    ci = section.find(close, cs)
    print(f"{path}: len={ci - cs if ci >= 0 else -1}, close={close!r}")
    pos = ci + len(close) if ci >= 0 else len(section)
