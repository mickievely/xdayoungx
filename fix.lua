-- xdayoungx fix (executor에 붙여넣기 1회)
-- 캐시 삭제 + autoexec 수정 + 즉시 실행
shared.XDayoungXRepo = "https://raw.githubusercontent.com/mickievely/xdayoungx/main"
shared.GokuVapeRepo = shared.XDayoungXRepo

local function del(p)
	if isfile and isfile(p) and delfile then pcall(delfile, p) end
end

for _, p in {
	"xdayoungx.lua", "gokuvape.lua", "load.lua",
	"gokuvape/core/download.lua", "gokuvape/core/bootstrap.lua",
	"autoexec/gokuvape.lua", "AutoExec/gokuvape.lua",
} do del(p) end

local autoexec = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/mickievely/xdayoungx/main/load.lua?t="..os.time(),true))()'
if writefile then
	pcall(function()
		if makefolder then pcall(makefolder, "autoexec") end
		writefile("autoexec/xdayoungx.lua", autoexec)
	end)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/mickievely/xdayoungx/main/load.lua?t=" .. os.time(), true))()
