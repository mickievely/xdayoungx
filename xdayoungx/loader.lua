if shared.vape then return end
shared.vapereload = true
repeat task.wait() until game:IsLoaded()
task.wait(0.5)

local REPO = "https://raw.githubusercontent.com/mickievely/xdayoungx/main"
shared.XDayoungXRepo = shared.XDayoungXRepo or REPO

local function go()
	local isfile = isfile or function(file)
		local ok, res = pcall(readfile, file)
		return ok and res ~= nil and res ~= ""
	end
	if isfile("xdayoungx.lua") then
		loadstring(readfile("xdayoungx.lua"))()
		return true
	end
	if shared.XDayoungXRepo then
		loadstring(game:HttpGet(shared.XDayoungXRepo .. "/xdayoungx.lua", true))()
		return true
	end
end

if not go() then
	task.spawn(function()
		for _ = 1, 30 do
			task.wait(2)
			if go() then break end
		end
	end)
end
