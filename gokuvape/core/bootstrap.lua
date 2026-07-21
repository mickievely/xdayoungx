shared.GokuVapeErrors = shared.GokuVapeErrors or {}
local function gokuLogError(source, err)
	local msg = os.date('%X') .. ' | ' .. tostring(source) .. ' | ' .. tostring(err)
	table.insert(shared.GokuVapeErrors, msg)
	warn('[xdayoungx] ' .. msg)
	if setclipboard then
		pcall(setclipboard, table.concat(shared.GokuVapeErrors, '\n'))
	end
end
shared.gokuLogError = gokuLogError

pcall(function()
	local scriptContext = cloneref and cloneref(game:GetService('ScriptContext')) or game:GetService('ScriptContext')
	scriptContext.Error:Connect(function(msg, trace)
		gokuLogError('runtime', msg .. (trace and ('\n' .. trace) or ''))
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
	'gokuvape', 'gokuvape/core', 'gokuvape/games', 'gokuvape/profiles',
	'gokuvape/assets', 'gokuvape/libraries', 'gokuvape/guis', 'gokuvape/assets/new'
} do
	if not isfolder(folder) then
		pcall(makefolder, folder)
	end
end

local function installAutoexec()
	local loaderPath = 'gokuvape/loader.lua'
	if isfile(loaderPath) then
		local loader = readfile(loaderPath)
		for _, path in {
			'autoexec/xdayoungx.lua', 'AutoExec/xdayoungx.lua',
			'../autoexec/xdayoungx.lua', '../AutoExec/xdayoungx.lua',
			'autoexec/gokuvape.lua', 'AutoExec/gokuvape.lua',
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

shared.GokuVapeRun = function()
	shared.GokuVapeRepo = shared.GokuVapeRepo or REPO
	if isfile('xdayoungx.lua') then
		loadstring(readfile('xdayoungx.lua'))()
		return true
	end
	if shared.GokuVapeRepo then
		loadstring(game:HttpGet(shared.GokuVapeRepo .. '/xdayoungx.lua', true))()
		return true
	end
	return false
end

if not isfile('gokuvape/profiles/gui.txt') then
	writefile('gokuvape/profiles/gui.txt', 'new')
end
if not isfile('gokuvape/profiles/commit.txt') then
	writefile('gokuvape/profiles/commit.txt', REPO)
elseif readfile('gokuvape/profiles/commit.txt'):gsub('%s+', '') == 'local' then
	writefile('gokuvape/profiles/commit.txt', REPO)
end

local loadstring = function(...)
	local res, err = loadstring(...)
	if err then
		gokuLogError('loadstring', err)
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
	if shared.GokuVapeRepo then
		teleportScript = teleportScript .. 'shared.GokuVapeRepo = "' .. shared.GokuVapeRepo .. '"\n'
	elseif REPO then
		teleportScript = teleportScript .. 'shared.GokuVapeRepo = "' .. REPO .. '"\n'
	end
	if shared.VapeCustomProfile then
		teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
	end
	local boot = 'repeat task.wait() until game:IsLoaded() task.wait(1) '
	if isfile('xdayoungx.lua') then
		return teleportScript .. boot .. 'loadstring(readfile("xdayoungx.lua"))()'
	end
	if shared.GokuVapeRepo then
		return teleportScript .. boot .. 'loadstring(game:HttpGet("' .. shared.GokuVapeRepo .. '/xdayoungx.lua", true))()'
	end
	return teleportScript .. boot .. 'if shared.GokuVapeRun then shared.GokuVapeRun() end'
end

shared.gokuQueueTeleport = function(extra)
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

local function reloadGokuvape()
	if shared.GokuVapeReloading then return end
	shared.GokuVapeReloading = true
	task.defer(function()
		task.wait(1)
		repeat task.wait() until game:IsLoaded()
		if shared.vape then
			pcall(function()
				shared.vape:Uninject()
			end)
		end
		local ok, err = pcall(function()
			shared.GokuVapeRun()
		end)
		if not ok and err then
			gokuLogError('reload', err)
		end
		shared.GokuVapeReloading = nil
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
			shared.gokuQueueTeleport()
		end
	end))

	local lastPlaceId = game.PlaceId
	local lastJobId = game.JobId
	vape:Clean(game:GetPropertyChangedSignal('PlaceId'):Connect(function()
		if game.PlaceId ~= lastPlaceId then
			lastPlaceId = game.PlaceId
			if not shared.VapeIndependent then
				reloadGokuvape()
			end
		end
	end))
	task.spawn(function()
		while vape.Loaded do
			if game.JobId ~= lastJobId then
				lastJobId = game.JobId
				if not shared.VapeIndependent then
					reloadGokuvape()
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
