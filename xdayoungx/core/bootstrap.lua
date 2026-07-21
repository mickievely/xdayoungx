shared.XDayoungXErrors = shared.XDayoungXErrors or {}
local function xdayoungxLogError(source, err)
	local msg = os.date('%X') .. ' | ' .. tostring(source) .. ' | ' .. tostring(err)
	table.insert(shared.XDayoungXErrors, msg)
	warn('[xdayoungx] ' .. msg)
	if setclipboard then
		pcall(setclipboard, table.concat(shared.XDayoungXErrors, '\n'))
	end
end
shared.xdayoungxLogError = xdayoungxLogError

pcall(function()
	local scriptContext = cloneref and cloneref(game:GetService('ScriptContext')) or game:GetService('ScriptContext')
	scriptContext.Error:Connect(function(msg, trace)
		xdayoungxLogError('runtime', msg .. (trace and ('\n' .. trace) or ''))
	end)
end)

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local writefile = writefile or function() end
local makefolder = makefolder or function() end
local isfolder = isfolder or function(path)
	local suc = pcall(function()
		return listfiles(path)
	end)
	return suc
end

local REPO = 'https://raw.githubusercontent.com/mickievely/xdayoungx/main'

for _, folder in {
	'xdayoungx', 'xdayoungx/core', 'xdayoungx/games', 'xdayoungx/profiles',
	'xdayoungx/assets', 'xdayoungx/libraries', 'xdayoungx/guis', 'xdayoungx/assets/new'
} do
	if not isfolder(folder) then
		pcall(makefolder, folder)
	end
end

local function installAutoexec()
	local loaderPath = 'xdayoungx/loader.lua'
	if isfile(loaderPath) then
		local loader = readfile(loaderPath)
		for _, path in {
			'autoexec/xdayoungx.lua', 'AutoExec/xdayoungx.lua',
			'../autoexec/xdayoungx.lua', '../AutoExec/xdayoungx.lua',
			'autoexec/xdayoungx.lua', 'AutoExec/xdayoungx.lua',
		} do
			pcall(function()
				local dir = path:match('^(.*)/[^/]+$')
				if dir and not isfolder(dir) then
					makefolder(dir)
				end
				writefile(path, loader)
			end)
		end
	end
end

installAutoexec()

shared.XDayoungXRun = function()
	shared.XDayoungXRepo = shared.XDayoungXRepo or REPO
	if isfile('xdayoungx.lua') then
		loadstring(readfile('xdayoungx.lua'))()
		return true
	end
	if shared.XDayoungXRepo then
		loadstring(game:HttpGet(shared.XDayoungXRepo .. '/xdayoungx.lua', true))()
		return true
	end
	return false
end

if not isfile('xdayoungx/profiles/gui.txt') then
	writefile('xdayoungx/profiles/gui.txt', 'new')
end
if not isfile('xdayoungx/profiles/commit.txt') then
	writefile('xdayoungx/profiles/commit.txt', REPO)
elseif readfile('xdayoungx/profiles/commit.txt'):gsub('%s+', '') == 'local' then
	writefile('xdayoungx/profiles/commit.txt', REPO)
end

local loadstring = function(...)
	local res, err = loadstring(...)
	if err then
		xdayoungxLogError('loadstring', err)
		if shared.vape then
			shared.vape:CreateNotification('xdayoungx', 'Failed to load : '..err, 30, 'alert')
		end
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function buildTeleportScript()
	local teleportScript = 'shared.vapereload = true\n'
	if shared.XDayoungXRepo then
		teleportScript = teleportScript .. 'shared.XDayoungXRepo = "' .. shared.XDayoungXRepo .. '"\n'
	elseif REPO then
		teleportScript = teleportScript .. 'shared.XDayoungXRepo = "' .. REPO .. '"\n'
	end
	if shared.VapeCustomProfile then
		teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
	end
	local boot = 'repeat task.wait() until game:IsLoaded() task.wait(1) '
	if isfile('xdayoungx.lua') then
		return teleportScript .. boot .. 'loadstring(readfile("xdayoungx.lua"))()'
	end
	if shared.XDayoungXRepo then
		return teleportScript .. boot .. 'loadstring(game:HttpGet("' .. shared.XDayoungXRepo .. '/xdayoungx.lua", true))()'
	end
	return teleportScript .. boot .. 'if shared.XDayoungXRun then shared.XDayoungXRun() end'
end

shared.xdayoungxQueueTeleport = function(extra)
	if shared.vape then
		pcall(function()
			shared.vape:Save()
		end)
	end
	local script = buildTeleportScript()
	if extra then
		script = script .. '\n' .. extra
	end
	queue_on_teleport(script)
end

local function reloadXDayoungX()
	if shared.XDayoungXReloading then return end
	shared.XDayoungXReloading = true
	task.defer(function()
		task.wait(1)
		repeat task.wait() until game:IsLoaded()
		if shared.vape then
			pcall(function()
				shared.vape:Uninject()
			end)
		end
		local ok, err = pcall(function()
			shared.XDayoungXRun()
		end)
		if not ok and err then
			xdayoungxLogError('reload', err)
		end
		shared.XDayoungXReloading = nil
	end)
end

function finishLoading()
	local vape = shared.vape
	if not vape then return end
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			shared.xdayoungxQueueTeleport()
		end
	end))

	local lastPlaceId = game.PlaceId
	local lastJobId = game.JobId
	vape:Clean(game:GetPropertyChangedSignal('PlaceId'):Connect(function()
		if game.PlaceId ~= lastPlaceId then
			lastPlaceId = game.PlaceId
			if not shared.VapeIndependent then
				reloadXDayoungX()
			end
		end
	end))
	task.spawn(function()
		while vape.Loaded do
			if game.JobId ~= lastJobId then
				lastJobId = game.JobId
				if not shared.VapeIndependent then
					reloadXDayoungX()
				end
			end
			task.wait(1)
		end
	end)

	installAutoexec()

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('xdayoungx', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press ' .. table.concat(vape.Keybind, ' + ') .. ' to open GUI', 5)
		end
	end
end
