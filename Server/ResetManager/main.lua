resetState = {
    inProgress = false,
    players = {},
    finalScores = {},
    settings = {
        maxResets = 0,
        spawnMode = false,
    }
}

function stopGame()
    -- print("THE SCORES")
    -- print(finalScoreboard)
    resetState = { 
        inProgress = false, 
        finalScores = {}, 
        players = {}, 
        settings = resetState.settings
    }
    message = "Game Over!! Relax. Crash as much as you want...."
    MP.SendChatMessage(-1, message)
end

function setMaxReset(max) 
    resetState.settings.maxResets = max
    -- maxResets = max
    initReset()
    message = "Max resets now "..max..". Reset count zero'd for all users."
    MP.SendChatMessage(-1, message)
end

function initReset()
    for ID,Player in pairs(MP.GetPlayers()) do
        if MP.IsPlayerConnected(ID) then
            resetState.players[Player] = { resets = 0, score = 0 }
        end
    end
end

function clearResets(player)
    resetState.players[player].resets = 0
end

function incrementResets(player)
    resetState.players[player].resets = resetState.players[player].resets + 1
    resetState.players[player].score = resetState.players[player].score - 10
    MP.SendChatMessage(-1, player.." docked 10 points for using up a reset")
    return resetState.players[player].resets
end

function preventResettersSpawningNewVehicles(player, vehicle)
    if resetState.inProgress then
        local playerName = MP.GetPlayerName(player)
        for i,v in ipairs(finalScoreboard) do
            if v == playerName then 
                resetState.players[playerName].score = resetState.players[playerName].score - 250
                MP.SendChatMessage(-1, playerName.." docked 250 points for attempting to spawn a vehicle")
                MP.SendChatMessage(player, "Naughty User!! No Spawns til game is done")
                MP.SendChatMessage(player, "Spectator mode only until game ends - hit tab button")
                return 1
            end
        end
    end
end

function maxResetsReached(player, vehicle)
    local playerName = MP.GetPlayerName(player)
    table.insert(resetState.finalScores, playerName)
    resetState.players[playerName].score = resetState.players[playerName].score - 100
    MP.RemoveVehicle(player, vehicle)
    MP.SendChatMessage(player, "No more resets allowed! You've used your "..resetState.settings.maxResets.." already.")
    if not spawnMode then 
        MP.SendChatMessage(player, "Spectator mode (hit tab)")
    else 
        MP.SendChatMessage(player, "Vehicle spawn allowed.")
    end
    MP.SendChatMessage(-1, playerName.." docked 100 points for using all resets")
end

function AnnoyUsersWhenReset(player, vehicle)
    if not resetState.inProgress then return end 
    local playerName = MP.GetPlayerName(player)
    local mr = resetState.settings.maxResets
    if resetState.players[playerName].resets > mr then
        maxResetsReached(player, vehicle)
    else 
        playerState = incrementResets(playerName)
        remaining = mr - playerState
        response = "You have " .. remaining .. " resets left."
        if remaining < 0 then 
            maxResetsReached(player, vehicle)
        else
            MP.SendChatMessage(player, response)
        end
    end
    local playerCount = 0
    for playerName, stats in pairs(resetState.players) do
        playerCount = playerCount + 1
    end
    print(playerCount, #resetState.players, #resetState.finalScores, #resetState.players - #resetState.finalScores)
    if playerCount - #resetState.finalScores == 1 then
        for userName, details in pairs(resetState.players) do
            MP.SendChatMessage(-1, userName.." scored "..details.score)
        end
        -- print(resetState.players)
        stopGame()
        
    end
    -- print("Scoreboard")
    -- print(resetState)
end

MP.RegisterEvent("onVehicleReset", "AnnoyUsersWhenReset")
MP.RegisterEvent("onVehicleSpawn","preventResettersSpawningNewVehicles")

dofile("Resources/Server/Sdm/lib/messaging.lua")
