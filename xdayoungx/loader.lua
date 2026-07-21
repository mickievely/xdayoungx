if shared.vape then return end
shared.vapereload = true
repeat task.wait() until game:IsLoaded()
task.wait(0.5)

local REPO = "https://raw.githubusercontent.com/mickievely/xdayoungx/main"
shared.XDayoungXRepo = REPO
shared.GokuVapeRepo = REPO

local function del(path)
	if isfile and isfile(path) and delfile then
		pcall(delfile, path)
	end
end

for _, path in {"gokuvape.lua", "xdayoungx.lua", "gokuvape/core/download.lua"} do
	del(path)
end

local function go()
	loadstring(game:HttpGet(REPO .. "/load.lua?t=" .. tostring(os.time()), true))()
	return true
end

if not go() then
	task.spawn(function()
		for _ = 1, 30 do
			task.wait(2)
			if go() then break end
		end
	end)
end
