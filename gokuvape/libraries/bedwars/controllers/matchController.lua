local Client = loadstring(downloadFile('gokuvape/libraries/bedwars/client.lua'))();
local vape = shared.vape;

local matchController = {
    Name = 'MatchController',
    matchState = 0,
}

function matchController:getMatchState()
    return self.matchState
end

local matchTimer = game:GetService('Players').LocalPlayer.PlayerGui:WaitForChild('TopBarAppGui'):WaitForChild('TopBarApp'):FindFirstChild('2'):FindFirstChild('5')
local seconds, lastSeconds = 0, 0

task.spawn(function()
	repeat task.wait()
		seconds = tonumber(matchTimer.Text:split(':')[2])
	until matchController.matchState == 2
end)

task.spawn(function()
	repeat lastSeconds = seconds task.wait() until seconds > lastSeconds

	matchController.matchState = 1;
	print(matchController.matchState)
end)

vape:Clean(Client:Get('MatchEndEvent'):Connect(function(winTable: {
		winningTeamId: number
	})

	matchController.matchState = 2;
	print(matchController.matchState)
end))

return matchController
