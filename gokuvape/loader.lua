if shared.vape then return end
shared.vapereload = true
repeat task.wait() until game:IsLoaded()
task.wait(0.5)

local function go()
	local isfile = isfile or function(file)
		local ok, res = pcall(readfile, file)
		return ok and res ~= nil and res ~= ""
	end
	if isfile("gokuvape.lua") then
		loadstring(readfile("gokuvape.lua"))()
		return true
	end
	if shared.GokuVapeRepo then
		loadstring(game:HttpGet(shared.GokuVapeRepo .. "/gokuvape.lua", true))()
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
