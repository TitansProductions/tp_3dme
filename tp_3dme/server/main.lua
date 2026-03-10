local API = exports.tp_libs:getAPI()
local activeMessages = {}

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  activeMessages = nil
end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterServerEvent('tp_3dme:server:display')
AddEventHandler('tp_3dme:server:display', function(text)
    local _source    = source
	local osTime     = os.time()

	if activeMessages[_source] == nil then 
		activeMessages[_source] = {}
	end
	
	table.insert(activeMessages[_source], {
		source  = _source,
		time    = tostring(osTime),
		text    = text,
    })

	local coords = GetEntityCoords(GetPlayerPed(_source))

	API.TriggerClientEventToCoordsOnly('tp_3dme:client:display', { 
		source  = _source,
		time    = tostring(osTime),
		text    = text, 
	}, coords, Config.DisplayDistance)

	for _, player in pairs (GetPlayers()) do 
		
        local targetCoords = GetEntityCoords(GetPlayerPed(tonumber(player)))
		local distance     = #(coords - targetCoords)

		if distance <= Config.DisplayDistance then

			local sentBy 

			if tonumber(player) == _source then 
				sentBy = '^4[ME]^7'
			else 
				sentBy = "^3" .. PlayerData.username .. "^7"
			end
	
			TriggerClientEvent('chatMessage', tonumber(player), sentBy,  { 255, 255, 255 }, text)

		end

	end

	Wait(Config.Duration)

	for index, message in pairs (activeMessages[_source]) do 

		if tostring(osTime) == tostring(message.time) then 

			table.remove(activeMessages[_source], index)
			
			API.TriggerClientEventToCoordsOnly('tp_3dme:client:remove', { 
				source  = _source,
				time    = tostring(osTime),
			}, coords, 120.0) -- farther distance in case a player went away within those seconds.
		
		end

	end

end)

