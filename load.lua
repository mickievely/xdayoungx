-- xdayoungx Vape loader v3 (single entry)
-- https://github.com/mickievely/xdayoungx
local REPO = "https://raw.githubusercontent.com/mickievely/xdayoungx/main"
shared.XDayoungXRepo = REPO
shared.GokuVapeRepo = REPO

local function del(path)
	if isfile and isfile(path) and delfile then
		pcall(delfile, path)
	end
end

for _, path in {
	"gokuvape.lua",
	"xdayoungx.lua",
	"gokuvape/core/download.lua",
	"gokuvape/core/bootstrap.lua",
	"autoexec/gokuvape.lua",
	"AutoExec/gokuvape.lua",
} do
	del(path)
end

if shared.vape then shared.vape:Uninject() end
repeat task.wait() until game:IsLoaded()

local function normalizePath(path)
	path = path:gsub("\\", "/")
	return path:gsub("^gokuvape/", "xdayoungx/")
end

local function httpGet(url)
	local ok, res = pcall(function()
		return game:HttpGet(url, true)
	end)
	if ok and res and #res > 0 and not res:find("404: Not Found", 1, true) then
		return res
	end
	ok, res = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and res and #res > 0 and not res:find("404: Not Found", 1, true) then
		return res
	end
	if typeof(http_request) == "function" then
		ok, res = pcall(function()
			return http_request({ Url = url, Method = "GET" }).Body
		end)
		if ok and res and #res > 0 then
			return res
		end
	end
	if syn and syn.request then
		ok, res = pcall(function()
			return syn.request({ Url = url, Method = "GET" }).Body
		end)
		if ok and res and #res > 0 then
			return res
		end
	end
	return nil
end

local function loadRemote(path)
	path = normalizePath(path)
	local url = REPO .. "/" .. path .. "?t=" .. tostring(os.time())
	local res = httpGet(url)
	if not res then
		return nil
	end
	if writefile then
		local folder = path:match("^(.*)/[^/]+$")
		if folder and makefolder then
			pcall(makefolder, folder)
		end
		pcall(writefile, path, res)
	end
	return res
end

local function runFile(path)
	path = normalizePath(path)
	local src = loadRemote(path)
	if not src then
		error("Missing file: " .. path)
	end
	local fn, err = loadstring(src, "@" .. path)
	if not fn then
		error(err)
	end
	return fn()
end

runFile("xdayoungx/core/bootstrap.lua")
runFile("xdayoungx/core/download.lua")

local loadOk, loadErr = pcall(function()
	vape = runFile("xdayoungx/guis/main.lua")
	shared.vape = vape
	runFile("xdayoungx/games/universal.lua")
	local gameFileId = (game.GameId == 2619619496) and (game.PlaceId == 6872265039 and 6872265039 or 6872274481) or game.PlaceId
	if gameFileId == 6872274481 then
		runFile("xdayoungx/games/bedwars.lua")
	elseif gameFileId == 6872265039 then
		runFile("xdayoungx/games/lobby.lua")
	end
end)

if not loadOk then
	if shared.xdayoungxLogError then
		shared.xdayoungxLogError("load", loadErr)
	else
		warn("[xdayoungx] load error:", loadErr)
	end
	return
end

if finishLoading then
	finishLoading()
end
