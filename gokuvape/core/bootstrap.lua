local REPO = shared.XDayoungXRepo or shared.GokuVapeRepo or "https://raw.githubusercontent.com/mickievely/xdayoungx/main"
local url = REPO:gsub("/+$", "") .. "/xdayoungx/core/bootstrap.lua?t=" .. tostring(os.time())
local src = game:HttpGet(url, true)
local fn, err = loadstring(src, "@xdayoungx/core/bootstrap.lua")
if not fn then error(err) end
fn()
