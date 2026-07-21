local Client = loadstring(downloadFile('gokuvape/libraries/bedwars/client.lua'))()

local queueController = {
    Name = 'QueueController'
}

function queueController:joinQueue(queue: string)
    Client:Get('joinQueue'):SendToServer({
		['queueType'] = queue
	})
end

return queueController
