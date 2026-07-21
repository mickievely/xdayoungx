import re

samples = [
    "    ['gokuvape/libraries/bedwars/projectilemeta.lua'] = [=[local v18",
    "    ['gokuvape/libraries/bedwars/promise.lua'] = [=[-- Decompiled",
]

entry_re = re.compile(r"\['([^']+)'\]\s*=\s*(\[=*\[)")
for s in samples:
    m = entry_re.search(s)
    print(s)
    print("  path:", m.group(1))
    print("  open:", repr(m.group(2)))
    eq = m.group(2).count("=") - 1
    close = "]" + ("=" * eq) + "]"
    print("  close:", repr(close))
