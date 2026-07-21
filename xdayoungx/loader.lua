if shared.vape then return end
shared.vapereload = true
repeat task.wait() until game:IsLoaded()
task.wait(0.5)
loadstring(game:HttpGet("https://raw.githubusercontent.com/mickievely/xdayoungx/main/load.lua?t=" .. tostring(os.time()), true))()
