if shared.vape then shared.vape:Uninject() end
repeat task.wait() until game:IsLoaded()

-- xdayoungx | https://github.com/xdayoungx/gokuvape
shared.GokuVapeRepo = shared.GokuVapeRepo or "https://raw.githubusercontent.com/xdayoungx/gokuvape/main"

local function loadLocal(path)
	path = path:gsub("\\", "/")
	if isfile and isfile(path) then
		return readfile(path)
	end
	if shared.GokuVapeRepo then
		local url = shared.GokuVapeRepo:gsub("/+$", "") .. "/" .. path
		local ok, res = pcall(function()
			return game:HttpGet(url, true)
		end)
		if ok and res and res ~= "" and not res:find("404: Not Found", 1, true) then
			if writefile then pcall(writefile, path, res) end
			return res
		end
	end
	return nil
end

local function runFile(path)
	local src = loadLocal(path)
	if not src then
		error("Missing file: " .. path)
	end
	local fn, err = loadstring(src, "@" .. path)
	if not fn then
		error(err)
	end
	return fn()
end

runFile("gokuvape/core/bootstrap.lua")
runFile("gokuvape/core/download.lua")

local loadOk, loadErr = pcall(function()
	vape = runFile("gokuvape/guis/main.lua")
	shared.vape = vape

	runFile("gokuvape/games/universal.lua")

	local gameFileId = (game.GameId == 2619619496) and (game.PlaceId == 6872265039 and 6872265039 or 6872274481) or game.PlaceId
	if gameFileId == 6872274481 then
		runFile("gokuvape/games/bedwars.lua")
	elseif gameFileId == 6872265039 then
		runFile("gokuvape/games/lobby.lua")
	end
end)

if not loadOk then
	if shared.gokuLogError then
		shared.gokuLogError("load", loadErr)
	else
		warn("[xdayoungx] load error:", loadErr)
	end
	return
end

if finishLoading then
	finishLoading()
end
