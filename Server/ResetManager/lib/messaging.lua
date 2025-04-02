function startGame()
    initReset()
    resetState.inProgress = true
    message = "Drive Carefully. Only "..resetState.settings.maxResets.." vehicle resets allowed!"
    MP.SendChatMessage(-1, message)
end

function showHelp(playerID)
    MP.SendChatMessage(playerID, "Vehicle Reset Manager Plugin by sdm36.")
    MP.SendChatMessage(playerID, "Commands:")
    for command, arr in pairs(commands) do
        msg = "/rst "..command..": "..arr['tooltip']
        if arr['variable'] then 
            param = " ("..arr['variable'].."?): "
            if arr['required'] then 
                param = " ("..arr['variable'].."): "
            end
            msg = "/rst "..command..param..arr['tooltip']
        end
        MP.SendChatMessage(playerID, msg)
    end
end

function spawnToggle()
    resetState.settings.spawnMode = not resetState.settings.spawnMode
    MP.SendChatMessage(-1, "Vehicle spawn after using your resets toggled to "..resetState.settings.spawnMode)
end

commands = {['clear'] = {
        ["function"] = clearResets,
        ["tooltip"] = "Clears Resets for current user or provided userName (cheating)",
        ["variable"] = "username",
}, ['resets'] = {
    ["function"] = setMaxReset,
    ["tooltip"] = "Sets maximum number of resets.",
    ["variable"] = "number",
    ["required"] = true,
}, ['start'] = {
    ["function"] = startGame,
    ["tooltip"] = "Starts the game",
}, ['stop'] = {
    ["function"] = stopGame,
    ["tooltip"] = "Stops the game",
}, ['spawnToggle'] = {
    ["function"] = spawnToggle,
    ["tooltip"] = "Toggle vehicle spawn on/off after resets used up (default off)",
}}

function resetChatHandler(player_id, player_name, message)
    -- print('chattin '.. player_id.." an "..player_name.." bout: "..message)
	local msgStart = string.match(message,"[^%s]+")
	if msgStart == "/rst" then
		local commandstringraw = string.sub(message,string.len(msgStart)+2)
		local commandstring, space, variable = string.match(commandstringraw,"(%S+)(%s)(%S+)")
		local commandStringFinal = commandstring or commandstringraw
        if commandStringFinal == 'clear' then 
            if not resetState.inProgress then
                MP.SendChatMessage(player_id, "Game not running")
                return
            end
            local userToReset = player_name
            if variable then userToReset = variable end
            commands[commandStringFinal]['function'](userToReset)
            MP.SendChatMessage(-1, userToReset.." has cheated. They now have "..resetState.settings.maxResets.." resets available. Cheat!")
            -- print(userToReset.." is cheating ")
        elseif commandStringFinal == 'start' or  commandStringFinal == 'stop' or  commandStringFinal == 'spawnToggle' then
            if commandStringFinal == 'start' and resetState.inProgress then
                MP.SendChatMessage(player_id, "Game already running")
                -- guihooks.trigger('toastrMsg', {type = "error", title = "Error:", msg = "Game already running", config = {timeOut = 5000}}) 
            elseif commandStringFinal == 'stop' and not resetState.inProgress then
                MP.SendChatMessage(player_id, "Game not running")
            end
            print("what wtah "..commandStringFinal)
            commands[commandStringFinal]['function']()
        elseif commandStringFinal == 'resets' then
            if not variable then 
                MP.SendChatMessage(player_id, "New value not supplied")
                return 
            end
            commands[commandStringFinal]['function'](tonumber(variable))
            -- print('changing reset count to ' ..variable)
        elseif commandStringFinal == 'keir' and player_name == 'CoolKeir106' then
            clearResets(player_name)
            for ID,Player in pairs(MP.GetPlayers()) do
                if not player_name == Player then
                    incrementResets(Player)
                end
            end
            resetState.players.CoolKeir106.score = resetState.players.CoolKeir106.score + 250
        else
            showHelp(player_id)
            -- print('showing help')
        end
    end
end
MP.RegisterEvent("onChatMessage", "resetChatHandler")

MP.RegisterEvent("onPlayerJoining", "showHelp")
