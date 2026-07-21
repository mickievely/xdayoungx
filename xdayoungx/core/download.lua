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

local function normalize(path)
	return path:gsub('\\', '/')
end

local function getRepoBase()
	if shared.XDayoungXRepo then
		return shared.XDayoungXRepo:gsub('/+$', '')
	end
	if isfile('xdayoungx/profiles/commit.txt') then
		local commit = readfile('xdayoungx/profiles/commit.txt'):gsub('%s+', '')
		if commit ~= '' and commit ~= 'local' then
			if commit:find('^https?://') then
				return commit:gsub('/+$', '')
			end
			return 'https://raw.githubusercontent.com/' .. commit
		end
	end
	return nil
end

function downloadFile(path, func)
	path = normalize(path)
	if isfile(path) then
		return (func or readfile)(path)
	end
	local repo = getRepoBase()
	if repo then
		local suc, res = pcall(function()
			return game:HttpGet(repo .. '/' .. path, true)
		end)
		if suc and res and res ~= '' and res ~= '404: Not Found' and not res:find('404: Not Found', 1, true) then
			local folder = path:match('^(.*)/[^/]+$')
			if folder and not isfolder(folder) then
				pcall(makefolder, folder)
			end
			if path:find('%.lua$') then
				pcall(writefile, path, res)
			end
			if func then
				return func(res)
			end
			return res
		end
	end
	if path:find('%.png$', 1, true) or path:find('%.jpg$', 1, true) or path:find('%.webp$', 1, true) then
		return ''
	end
	error('Missing file: ' .. path)
end

local hash = loadstring(downloadFile('xdayoungx/libraries/hash.lua'), 'hash')()

local prediction = loadstring(downloadFile('xdayoungx/libraries/prediction.lua'), 'prediction')()

entitylib = loadstring(downloadFile('xdayoungx/libraries/entity.lua'), 'entitylibrary')()
