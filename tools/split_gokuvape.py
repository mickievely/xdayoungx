#!/usr/bin/env python3
"""Split monolithic gokuvape (1).lua into modular gokuvape/ folder structure."""

from __future__ import annotations

import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "gokuvape (1).lua"
OUT = ROOT / "gokuvape"


def read_source() -> list[str]:
    text = SOURCE.read_text(encoding="utf-8")
    return text.splitlines(keepends=True)


def parse_embed_table(lines: list[str]) -> dict[str, str]:
    start = None
    for i, line in enumerate(lines):
        if line.startswith("shared.GokuVapeEmbed"):
            start = i + 1
            break
    if start is None:
        raise RuntimeError("GokuVapeEmbed block not found")

    end = None
    for i in range(start, len(lines)):
        if lines[i].strip() == "}":
            rest = "".join(lines[i + 1 : i + 4])
            if "local isfile = isfile or function(file)" in rest:
                end = i
                break
    if end is None:
        raise RuntimeError("GokuVapeEmbed closing brace not found")

    section = "".join(lines[start:end])
    files: dict[str, str] = {}
    entry_re = re.compile(r"\['([^']+)'\]\s*=\s*(\[=*\[)")
    pos = 0

    while True:
        m = entry_re.search(section, pos)
        if not m:
            break

        path = m.group(1)
        open_delim = m.group(2)
        eq_count = len(open_delim[1:-1])
        close_delim = "]" + ("=" * eq_count) + "]"
        content_start = m.end()

        close_idx = section.find(close_delim, content_start)
        if close_idx == -1:
            raise RuntimeError(f"Unclosed embed entry: {path}")

        content = section[content_start:close_idx]
        if not content.endswith("\n"):
            content += "\n"
        files[path] = content
        pos = close_idx + len(close_delim)

    return files


def line_range_text(lines: list[str], start: int, end: int) -> str:
    # 1-based inclusive line numbers
    return "".join(lines[start - 1 : end])


def write_file(rel_path: str, content: str) -> None:
    path = OUT / rel_path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8", newline="\n")


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"Missing source file: {SOURCE}")

    lines = read_source()
    embed_files = parse_embed_table(lines)

    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)

    # Extract embedded library files
    for rel, content in embed_files.items():
        if rel.startswith("gokuvape/"):
            rel = rel[len("gokuvape/") :]
        write_file(rel, content)

    bootstrap = '''shared.GokuVapeErrors = shared.GokuVapeErrors or {}
local function gokuLogError(source, err)
\tlocal msg = os.date('%X') .. ' | ' .. tostring(source) .. ' | ' .. tostring(err)
\ttable.insert(shared.GokuVapeErrors, msg)
\twarn('[gokuvape] ' .. msg)
\tif setclipboard then
\t\tpcall(setclipboard, table.concat(shared.GokuVapeErrors, '\\n'))
\tend
end
shared.gokuLogError = gokuLogError

pcall(function()
\tlocal scriptContext = cloneref and cloneref(game:GetService('ScriptContext')) or game:GetService('ScriptContext')
\tscriptContext.Error:Connect(function(msg, trace)
\t\tgokuLogError('runtime', msg .. (trace and ('\\n' .. trace) or ''))
\tend)
end)

local isfile = isfile or function(file)
\tlocal suc, res = pcall(function()
\t\treturn readfile(file)
\tend)
\treturn suc and res ~= nil and res ~= ''
end
local writefile = writefile or function() end
local makefolder = makefolder or function() end
local isfolder = isfolder or function(path)
\tlocal suc = pcall(function()
\t\treturn listfiles(path)
\tend)
\treturn suc
end

for _, folder in {
\t'gokuvape', 'gokuvape/core', 'gokuvape/games', 'gokuvape/profiles',
\t'gokuvape/assets', 'gokuvape/libraries', 'gokuvape/guis', 'gokuvape/assets/new'
} do
\tif not isfolder(folder) then
\t\tpcall(makefolder, folder)
\tend
end

local function installAutoexec()
\tlocal loaderPath = 'gokuvape/loader.lua'
\tif isfile(loaderPath) then
\t\tlocal loader = readfile(loaderPath)
\t\tfor _, path in {'autoexec/gokuvape.lua', 'AutoExec/gokuvape.lua', '../autoexec/gokuvape.lua', '../AutoExec/gokuvape.lua'} do
\t\t\tpcall(function()
\t\t\t\tlocal dir = path:match('^(.*)/[^/]+$')
\t\t\t\tif dir and not isfolder(dir) then
\t\t\t\t\tmakefolder(dir)
\t\t\t\tend
\t\t\t\twritefile(path, loader)
\t\t\tend)
\t\tend
\tend
end

installAutoexec()

shared.GokuVapeRun = function()
\tif isfile('gokuvape.lua') then
\t\tloadstring(readfile('gokuvape.lua'))()
\t\treturn true
\tend
\tif shared.GokuVapeRepo then
\t\tloadstring(game:HttpGet(shared.GokuVapeRepo .. '/gokuvape.lua', true))()
\t\treturn true
\tend
\treturn false
end

if not isfile('gokuvape/profiles/gui.txt') then
\twritefile('gokuvape/profiles/gui.txt', 'new')
end
if not isfile('gokuvape/profiles/commit.txt') then
\twritefile('gokuvape/profiles/commit.txt', 'local')
end

local loadstring = function(...)
\tlocal res, err = loadstring(...)
\tif err then
\t\tgokuLogError('loadstring', err)
\t\tif shared.vape then
\t\t\tshared.vape:CreateNotification('gokuvape', 'Failed to load : '..err, 30, 'alert')
\t\tend
\tend
\treturn res
end
local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj)
\treturn obj
end
local playersService = cloneref(game:GetService('Players'))

local function buildTeleportScript()
\tlocal teleportScript = 'shared.vapereload = true\\n'
\tif shared.GokuVapeRepo then
\t\tteleportScript = teleportScript .. 'shared.GokuVapeRepo = "' .. shared.GokuVapeRepo .. '"\\n'
\tend
\tif shared.VapeCustomProfile then
\t\tteleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\\n' .. teleportScript
\tend
\tlocal boot = 'repeat task.wait() until game:IsLoaded() task.wait(1) '
\tif isfile('gokuvape.lua') then
\t\treturn teleportScript .. boot .. 'loadstring(readfile("gokuvape.lua"))()'
\tend
\tif shared.GokuVapeRepo then
\t\treturn teleportScript .. boot .. 'loadstring(game:HttpGet("' .. shared.GokuVapeRepo .. '/gokuvape.lua", true))()'
\tend
\treturn teleportScript .. boot .. 'if shared.GokuVapeRun then shared.GokuVapeRun() end'
end

shared.gokuQueueTeleport = function(extra)
\tif shared.vape then
\t\tpcall(function()
\t\t\tshared.vape:Save()
\t\tend)
\tend
\tlocal script = buildTeleportScript()
\tif extra then
\t\tscript = script .. '\\n' .. extra
\tend
\tqueue_on_teleport(script)
end

local function reloadGokuvape()
\tif shared.GokuVapeReloading then return end
\tshared.GokuVapeReloading = true
\ttask.defer(function()
\t\ttask.wait(1)
\t\trepeat task.wait() until game:IsLoaded()
\t\tif shared.vape then
\t\t\tpcall(function()
\t\t\t\tshared.vape:Uninject()
\t\t\tend)
\t\tend
\t\tlocal ok, err = pcall(function()
\t\t\tshared.GokuVapeRun()
\t\tend)
\t\tif not ok and err then
\t\t\tgokuLogError('reload', err)
\t\tend
\t\tshared.GokuVapeReloading = nil
\tend)
end

function finishLoading()
\tlocal vape = shared.vape
\tif not vape then return end
\tvape:Load()
\ttask.spawn(function()
\t\trepeat
\t\t\tvape:Save()
\t\t\ttask.wait(10)
\t\tuntil not vape.Loaded
\tend)

\tlocal teleportedServers
\tvape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
\t\tif (not teleportedServers) and (not shared.VapeIndependent) then
\t\t\tteleportedServers = true
\t\t\tshared.gokuQueueTeleport()
\t\tend
\tend))

\tlocal lastPlaceId = game.PlaceId
\tlocal lastJobId = game.JobId
\tvape:Clean(game:GetPropertyChangedSignal('PlaceId'):Connect(function()
\t\tif game.PlaceId ~= lastPlaceId then
\t\t\tlastPlaceId = game.PlaceId
\t\t\tif not shared.VapeIndependent then
\t\t\t\treloadGokuvape()
\t\t\tend
\t\tend
\tend))
\ttask.spawn(function()
\t\twhile vape.Loaded do
\t\t\tif game.JobId ~= lastJobId then
\t\t\t\tlastJobId = game.JobId
\t\t\t\tif not shared.VapeIndependent then
\t\t\t\t\treloadGokuvape()
\t\t\t\tend
\t\t\tend
\t\t\ttask.wait(1)
\t\tend
\tend)

\tinstallAutoexec()

\tif not shared.vapereload then
\t\tif not vape.Categories then return end
\t\tif vape.Categories.Main.Options['GUI bind indicator'].Enabled then
\t\t\tvape:CreateNotification('gokuvape', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press ' .. table.concat(vape.Keybind, ' + ') .. ' to open GUI', 5)
\t\tend
\tend
end
'''
    download_block = line_range_text(lines, 13062, 13138)
    download_block = download_block.replace(
        "\tlocal embed = shared.GokuVapeEmbed and shared.GokuVapeEmbed[path]\n"
        "\tif embed then\n"
        "\t\tif func then\n"
        "\t\t\treturn func(embed)\n"
        "\t\tend\n"
        "\t\treturn embed\n"
        "\tend\n",
        "",
    )
    gui_block = line_range_text(lines, 13144, 20106)
    universal_block = line_range_text(lines, 20111, 27631)
    bedwars_block = line_range_text(lines, 27636, 58948)
    lobby_block = line_range_text(lines, 58952, 61069)

    write_file("core/bootstrap.lua", bootstrap)
    write_file("core/download.lua", download_block)
    write_file("guis/main.lua", gui_block)
    write_file("games/universal.lua", universal_block)
    write_file("games/bedwars.lua", bedwars_block)
    write_file("games/lobby.lua", lobby_block)

    entry = '''if shared.vape then shared.vape:Uninject() end
repeat task.wait() until game:IsLoaded()

-- GitHub raw URL (예: https://raw.githubusercontent.com/USER/REPO/main)
-- exploit 실행 전: shared.GokuVapeRepo = "https://raw.githubusercontent.com/USER/REPO/main"
shared.GokuVapeRepo = shared.GokuVapeRepo or nil

local function loadLocal(path)
\tpath = path:gsub("\\\\", "/")
\tif isfile and isfile(path) then
\t\treturn readfile(path)
\tend
\tif shared.GokuVapeRepo then
\t\tlocal url = shared.GokuVapeRepo:gsub("/+$", "") .. "/" .. path
\t\tlocal ok, res = pcall(function()
\t\t\treturn game:HttpGet(url, true)
\t\tend)
\t\tif ok and res and res ~= "" and not res:find("404: Not Found", 1, true) then
\t\t\tif writefile then pcall(writefile, path, res) end
\t\t\treturn res
\t\tend
\tend
\treturn nil
end

local function runFile(path)
\tlocal src = loadLocal(path)
\tif not src then
\t\terror("Missing file: " .. path)
\tend
\tlocal fn, err = loadstring(src, "@" .. path)
\tif not fn then
\t\terror(err)
\tend
\treturn fn()
end

runFile("gokuvape/core/bootstrap.lua")
runFile("gokuvape/core/download.lua")

local loadOk, loadErr = pcall(function()
\tvape = runFile("gokuvape/guis/main.lua")
\tshared.vape = vape

\trunFile("gokuvape/games/universal.lua")

\tlocal gameFileId = (game.GameId == 2619619496) and (game.PlaceId == 6872265039 and 6872265039 or 6872274481) or game.PlaceId
\tif gameFileId == 6872274481 then
\t\trunFile("gokuvape/games/bedwars.lua")
\telseif gameFileId == 6872265039 then
\t\trunFile("gokuvape/games/lobby.lua")
\tend
end)

if not loadOk then
\tif shared.gokuLogError then
\t\tshared.gokuLogError("load", loadErr)
\telse
\t\twarn("[gokuvape] load error:", loadErr)
\tend
\treturn
end

if finishLoading then
\tfinishLoading()
end
'''
    write_file("../gokuvape.lua", entry)

    loader = '''if shared.vape then return end
shared.vapereload = true
repeat task.wait() until game:IsLoaded()
task.wait(0.5)

local function go()
\tlocal isfile = isfile or function(file)
\t\tlocal ok, res = pcall(readfile, file)
\t\treturn ok and res ~= nil and res ~= ""
\tend
\tif isfile("gokuvape.lua") then
\t\tloadstring(readfile("gokuvape.lua"))()
\t\treturn true
\tend
\tif shared.GokuVapeRepo then
\t\tloadstring(game:HttpGet(shared.GokuVapeRepo .. "/gokuvape.lua", true))()
\t\treturn true
\tend
end

if not go() then
\ttask.spawn(function()
\t\tfor _ = 1, 30 do
\t\t\ttask.wait(2)
\t\t\tif go() then break end
\t\tend
\tend)
end
'''
    write_file("loader.lua", loader)

    profiles = OUT / "profiles"
    profiles.mkdir(parents=True, exist_ok=True)
    (profiles / "gui.txt").write_text("new\n", encoding="utf-8")
    (profiles / "commit.txt").write_text("local\n", encoding="utf-8")

    print(f"Extracted {len(embed_files)} embedded files")
    print(f"Output: {OUT}")
    print(f"Entry:  {ROOT / 'gokuvape.lua'}")


if __name__ == "__main__":
    main()
