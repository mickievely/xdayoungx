-- xdayoungx Vape loader v2
-- https://github.com/mickievely/xdayoungx
local REPO = "https://raw.githubusercontent.com/mickievely/xdayoungx/main"
shared.XDayoungXRepo = REPO
shared.GokuVapeRepo = REPO

local function del(path)
	if isfile and isfile(path) and delfile then
		pcall(delfile, path)
	end
end

-- 구버전 캐시 제거
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

loadstring(game:HttpGet(REPO .. "/xdayoungx.lua?t=" .. tostring(os.time()), true))()
