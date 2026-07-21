shared.XDayoungXRepo = "https://raw.githubusercontent.com/mickievely/xdayoungx/main"
shared.GokuVapeRepo = shared.XDayoungXRepo
local url = "https://raw.githubusercontent.com/mickievely/xdayoungx/main/xdayoungx/core/download.lua?t=" .. tostring(os.time())
local src = game:HttpGet(url, true)
local fn, err = loadstring(src, "@xdayoungx/core/download.lua")
if not fn then error(err) end
fn()
