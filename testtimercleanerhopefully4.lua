time = require("time")
--Ask David: Why do I need to write relative path here while other scripts are happy just with filename?
testDMConfig = require("custom/testDMConfig")
testDMmaps = require("custom/testDMMaps")
testDMMatchSettings = require("custom/testDMMatchSettings")

--match, spawning, death, lives, respawning, items, rewards
testDM = {}

-- used for generation of random numbers
math.randomseed(os.time())

-- used to determine the way server handles the selection of next match
-- (0 = random, 1 = rotation, 2 = vote)
matchselectionmethod = testDMConfig.matchSelectionMethod

-- used as counter for match rotation
matchRotationIndex = 1

-- holds the data about the current match
currentMatch = testDMMatchSettings.balmora_dm

-- used to hold data about the next match
nextMatch = nil

-- unique identifier for match
matchId = nil

-- holds the list of all match-specific variables
matchSettings = nil

-- determines match mechanics
gameMode = nil

-- used to track the score for each team
teamScores = nil

-- used to track the number of players on each team
teamCounters = nil

-- tracks which player was the last one to get a score increase
lastScoringPlayer = nil

-- tracks which team was the last one to get a score increase
lastScoringTeam = nil

-----------------------------------------------------------------------------
timer44 = tes3mp.CreateTimer("Three", time.seconds(5))
timer22 = tes3mp.CreateTimer("Reset", time.seconds(5))
timer33 = tes3mp.CreateTimer("warning1", time.minutes(4))  -- "1 Minute Left until fight starts!""
timer4 = tes3mp.CreateTimer("Four", time.minutes(7))
timer1 = tes3mp.CreateTimer("One", time.minutes(3))
timertest = tes3mp.CreateTimer("EndIt", time.minutes(8))
----------------------------------------------------------------------------------------

-- Starts the match with the currently existing configuration
-- This does not change any configuration. All the changes to configuration are done in EndMatch(), which gets called at the end of each match
testDM.MatchInit = function() -- Starts new match, resets matchId, controls map rotation, and clears teams
	matchId = os.date("%y%m%d%H%M%S") -- Later used in TeamHandler to determine whether to reset character
	if nextMatch ~= nil then
		currentMatch = nextMatch
	end
	-- Handle match data
	-- Load default settings
	matchSettings = testDMConfig.defaultSettings
	-- Check if any match settings override the default settings and apply them
	for key,value in pairs(matchSettings) do
		-- check if custom value exists
		if currentMatch[key] ~= nil then
			-- override the default value
			matchSettings[key] = currentMatch[key]
			tes3mp.LogMessage(2, "++++ Setting " .. key .. " to value " .. currentMatch[key] .. " ++++")
		end
	end
	-- set game mode variable
	gameMode = currentMatch.gameMode
	-- reset match stats
	lastScoringPlayer = 0
	lastScoringTeam = 0
	-- if game mode is team-based, then handle team data
	if gameMode == "tdm" or gameMode == "ctf" then
		numberOfTeams = currentMatch.numberOfTeams
		-- reset team stats
		teamScores = {}
		teamCounters = {}
		for teamIndex=1,numberOfTeams do
			teamScores[teamIndex] = 0
			teamCounters[teamIndex] = 0
		end
	end
	--tes3mp.LogMessage(2, currentMatch.name)
	tes3mp.LogMessage(2, "++++ local MatchInit: Starting a new " .. currentMatch.name .. " match with ID " .. matchId .. " ++++")
	for pid, p in pairs(Players) do -- Iterate through all players and start assigning teams
		if p ~= nil and p:IsLoggedIn() then
			tes3mp.LogMessage(2, "++++ --PlayerInit: Assigning new matchId to player. ++++")
			Players[pid].data.mwTDM.matchId = matchId -- Set player's match ID to current match ID
			Players[pid].data.mwTDM.lives = 4
			Players[pid].data.mwTDM.inmatch = 1 
				testDM.PlayerInit2(p.pid)
				tes3mp.SendMessage(pid, color.Orange .. "NEW ROUND: " .. currentMatch.name .. "\nRested 9 hours.\n" .. color.Yellow .. "25 Gold added(or not).\nMatch duration: 15 minutes\n" .. color.Red .. "Fight starts in 5 minutes!\n" .. color.Orange .. "Get Ready!\n", false)
		end
	end
	timer0 = tes3mp.CreateTimer("EndIt", time.minutes(2))	-- Does nothing?
	tes3mp.RestartTimer(timer44, time.minutes(10))
	tes3mp.RestartTimer(timer1, time.minutes(5))
	tes3mp.RestartTimer(timer33, time.minutes(2))  -- warning1 "1 Minute Left until fight starts!"
	tes3mp.RestartTimer(timer4, time.minutes(7))
	tes3mp.RestartTimer(timertest, time.minutes(8))  -- Ends the round
		for pid, p in pairs(Players) do --this is for the uhhh teleportation into the round.. interesting... 
			if p ~= nil and p:IsLoggedIn() then
				timerspawn = tes3mp.CreateTimerEx("PlayerIniti", time.seconds(180), "i", pid)
				tes3mp.RestartTimer(timerspawn, time.seconds(180))
			end
		end

end

function warning1()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. "1:00 \n", false)
		end
	end
	local timer6 = tes3mp.CreateTimer("Six", time.seconds(50))
	tes3mp.StartTimer(timer6)
	local timer7 = tes3mp.CreateTimer("Seven", time.seconds(55))
	tes3mp.StartTimer(timer7)
	local timer8 = tes3mp.CreateTimer("Eight", time.seconds(56))
	tes3mp.StartTimer(timer8)
	local timer9 = tes3mp.CreateTimer("Nine", time.seconds(57))
	tes3mp.StartTimer(timer9)
	local timer10 = tes3mp.CreateTimer("Ten", time.seconds(58))
	tes3mp.StartTimer(timer10)
	local timer11 = tes3mp.CreateTimer("Eleven", time.seconds(59))
	tes3mp.StartTimer(timer11)
end

function One()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. "5:00 \n", false)
		end
	end
end

function Three()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. "5:00 \n", false)
		end
	end
end

function Four()
	timer6 = tes3mp.CreateTimer("Six", time.seconds(50))
	tes3mp.StartTimer(timer6)
	timer7 = tes3mp.CreateTimer("Seven", time.seconds(55))
	tes3mp.StartTimer(timer7)
	timer8 = tes3mp.CreateTimer("Eight", time.seconds(56))
	tes3mp.StartTimer(timer8)
	timer9 = tes3mp.CreateTimer("Nine", time.seconds(57))
	tes3mp.StartTimer(timer9)
	timer10 = tes3mp.CreateTimer("Ten", time.seconds(58))
	tes3mp.StartTimer(timer10)
	timer11 = tes3mp.CreateTimer("Eleven", time.seconds(59))
	tes3mp.StartTimer(timer11)
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. "1:00 \n", false)
		end
	end
end

function Six()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. ":10 \n", false)
		end
	end
end

function Seven()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. ":05 \n", false)
		end
	end
end

function Eight()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. ":04 \n", false)
		end
	end
end

function Nine()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. ":03 \n", false)
		end
	end
end

function Ten()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. ":02 \n", false)
		end
	end
end

function Eleven()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. ":01 \n", false)
		end
	end
end

function Reset(pid)
	local pid, p = next(Players)
	if p ~= nil and p:IsLoggedIn() then
logicHandler.ResetCell(pid, "-6, -1")
--logicHandler.ResetCell(pid, "Pelagiad, Fort Pelagiad")
--logicHandler.ResetCell(pid, "Arkngthand, Weepingbell Hall")
--logicHandler.ResetCell(pid, "Mzahnch")
--logicHandler.ResetCell(pid, "Galom Daeus, Entry")
--logicHandler.ResetCell(pid, "Dagoth Ur, Outer Facility")
--logicHandler.ResetCell(pid, "Nchardumz")
--logicHandler.ResetCell(pid, "Nchardumz Lower Level")
	
end
end


function EndIt() -- Ends the round and starts a new one? Maybe?
    --check every player and see who has the most lives, and if they have the most, then they won, and if it is a tie, then they tied
    --[[lifenumber = Players[pid].data.mwTDM.lives
    bestlifenumber = 0
    numberofbestlifepeople = 0]]
    local bestlifenumber = 0
    --local numberofplayerstied = 0
    local numberofbestlifepeople = 0
    for pid, p in pairs(Players) do
        local lifenumber = Players[pid].data.mwTDM.lives
        if lifenumber > bestlifenumber then
            bestlifenumber = lifenumber
        end
    end
    for pid, p in pairs(Players) do
	    local lifenumber = Players[pid].data.mwTDM.lives
        if lifenumber == bestlifenumber then 
            numberofbestlifepeople = numberofbestlifepeople + 1 
        end
    end
    for pid, p in pairs(Players) do
	    local nameon = Players[pid].data.login.name
	    local lifenumber = Players[pid].data.mwTDM.lives
        if lifenumber == bestlifenumber and numberofbestlifepeople > 1 and Players[pid].data.mwTDM.inmatch == 1 then
            if Players[pid].data.mwTDM.lives == bestlifenumber then
			    --numberofplayerstied = numberofplayerstied + 1
			    local amount = math.floor(50 / numberofbestlifepeople)
			    logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" ' ..amount)
                -- local nameon = Players[pid].data.login.name
		        for pid, p in pairs(Players) do
                tes3mp.SendMessage(pid, color.Yellow .. nameon .. " has tied at " .. bestlifenumber .. " lives!\n")
		    end
        end
        elseif lifenumber == bestlifenumber and numberofbestlifepeople == 1 and Players[pid].data.mwTDM.inmatch == 1 then
                --local nameon = Players[pid].data.login.name
		        logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 50')
            for pid, p in pairs(Players) do
                tes3mp.SendMessage(pid, color.Yellow .. nameon .. " has won with " .. bestlifenumber .. " lives! 50 gold prize to them!\n")
            end
        end
    end
	        --[[for pid, p in pairs(Players) do
		    if the lifenumber is greater than the bestlifenumber then
			the best lifenumber person gets a win
		    else if there are more than 1 best life person then 
			they each get a tie
		    end
	        end]]
	    if testDMConfig.matchSelectionMethod == 0 then
		    -- TODO: find a way to remove the possibility of repeating the just-played match
		    randomMatchIndex = math.random(1, #testDMConfig.matchList)
		    nextMatch = testDMConfig.matchList[randomMatchIndex]
		    elseif testDMConfig.matchSelectionMethod == 1 then
			-- go to the first match if there are no further matches
			matchRotationIndex = matchRotationIndex + 1
			if matchRotationIndex == 0 or matchRotationIndex > #testDMConfig.matchList then
			matchRotationIndex = 1
		    end
		    local nextMatchIndex = testDMConfig.matchList[matchRotationIndex]
		    nextMatch = testDMMatchSettings[nextMatchIndex]
	    end
	    for pid, p in pairs(Players) do
		        --Players[pid].data.mwTDM.lives
		    if Players[pid].data.mwTDM.inmatch == 1 then
		        amount = 10 * Players[pid].data.mwTDM.lives
		        logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" amount')
		    end
	    end
		for pid, p in pairs(Players) do
		    local Gold = { refId = "gold_001", count = 25, charge = -1}
		    if Players[pid].data.mwTDM.status == 1 and Players[pid].data.mwTDM.inmatch == 1 then
			    --table.insert(Players[pid].data.inventory, Gold)
			    logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 50')
			    local nameon = Players[pid].data.login.name
			    tes3mp.SendMessage(pid, color.Yellow .. "Added 50 gold for surviving, plus 10 for each life left!\n")
		     elseif Players[pid].data.mwTDM.status == 0 then
				tes3mp.LogMessage(2, "++++ Got pid: ", pid)
				if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
					Players[pid]:SaveStatsDynamic(packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic"))
					tes3mp.LogMessage(2, "++++ Respawning pid: ", pid)
					tes3mp.Resurrect(pid, 0)
					tes3mp.SetHealthCurrent(pid, 1)
					tes3mp.SendStatsDynamic(pid)
					testDM.PlayerInit(pid)
				end
		    end
	    end
	    testDM.MatchInit()
		tes3mp.RestartTimer(timer22, time.seconds(5))
--[[		local pid, p = next(Players)
			if p ~= nil and p:IsLoggedIn() then
		logicHandler.ResetCell(pid, "Arkngthand, Weepingbell Hall")
		logicHandler.ResetCell(pid, "Mzahnch")
		logicHandler.ResetCell(pid, "Galom Daeus, Entry")
		logicHandler.ResetCell(pid, "Dagoth Ur, Outer Facility")
		logicHandler.ResetCell(pid, "Nchardumz")
		logicHandler.ResetCell(pid, "Nchardumz Lower Level")
			
		end]]
end

testDM.PlayerInit2 = function(pid)
	tes3mp.LogMessage(2, "++++ Initialising PID ", pid)
	testDM.JSONCheck(pid) -- Check if player has TDM info added to their JSON file -- from what I see in fuction, this doesn't just check, this makes sure that there is data to work with
	tes3mp.LogMessage(2, "++++ --PlayerInit: Checking matchId of player " .. Players[pid].data.login.name .. " against matchId #" .. matchId .. ". ++++")
	-- Check player's last matchId to determine whether to reset their character
	if Players[pid].data.mwTDM.matchId == matchId then
		tes3mp.SendMessage(pid, color.LightBlue .. "You are in the current match.\n")
		tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is the same. ++++")
		testDM.PlayerSpawner(pid)
	else -- Player's latest match ID doesn't equal that of current match
		--logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 25') -- maybe this was where we had the 25 gold for all people? even if they didn't survive?
		Players[pid].data.mwTDM.inmatch = 0
		tes3mp.SendMessage(pid, color.LightBlue .. "You are not in the current match.\n")
		testDM.PlayerSpawner3(pid)
		for pid, p in pairs(Players) do -- Iterate through all players and start assigning teams
			if p ~= nil and p:IsLoggedIn() then
			end
		end
		if Players[pid].data.mwTDM.matchId == nil then
			-- New character so no need to wipe it
		else -- Character was created prior to current match so we reset it
			tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is different -- Calling ResetCharacter(). ++++")
			--testDM.ResetCharacter(pid) -- Reset character
		end
		--tes3mp.LogMessage(2, "++++ --PlayerInit: Assigning new matchId to player. ++++")
		--Players[pid].data.mwTDM.matchId = matchId -- Set player's match ID to current match ID
		-- handle team assigment only for the first time in a match (so that team-sorting logic does not happen at every respawn)
		if gameMode == "tdm" or gameMode == "ctf" then
			testDM.TeamHandler(pid)
		end
	end
end

testDM.PlayerIniti2 = function(pid) -- Used for Onplayerfinishlogin?
	if Players[pid] ~= nil then
	    tes3mp.LogMessage(2, "++++ Initialising PID ", pid)
	    testDM.JSONCheck(pid) -- Check if player has TDM info added to their JSON file -- from what I see in fuction, this doesn't just check, this makes sure that there is data to work with
	    tes3mp.LogMessage(2, "++++ --PlayerInit: Checking matchId of player " .. Players[pid].data.login.name .. " against matchId #" .. matchId .. ". ++++")
	    -- Check player's last matchId to determine whether to reset their character
	    if Players[pid].data.mwTDM.matchId == matchId and Players[pid].data.mwTDM.inmatch == 1 then
		    Players[pid].data.mwTDM.inmatch = 1
		    tes3mp.SendMessage(pid, color.LightBlue .. "You are in the current match.\n")
		    tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is the same. ++++")
		    testDM.PlayerSpawner2(pid)
	    else -- Player's latest match ID doesn't equal that of current match
		    --logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 25')
	    	Players[pid].data.mwTDM.inmatch = 0
		    tes3mp.SendMessage(pid, color.LightBlue .. "You are not in the current match.\n")
		    Players[pid].data.mwTDM.lives = 5
		    testDM.PlayerSpawner(pid)
		    for pid, p in pairs(Players) do -- Iterate through all players and start assigning teams	
			if p ~= nil and p:IsLoggedIn() then
			end
		end
		if Players[pid].data.mwTDM.matchId == nil then
			-- New character so no need to wipe it
		else -- Character was created prior to current match so we reset it
			tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is different -- Calling ResetCharacter(). ++++")
			--testDM.ResetCharacter(pid) -- Reset character
		end
        --	tes3mp.LogMessage(2, "++++ --PlayerInit: Assigning new matchId to player. ++++")
        --	Players[pid].data.mwTDM.matchId = matchId -- Set player's match ID to current match ID
		-- handle team assigment only for the first time in a match (so that team-sorting logic does not happen at every respawn)
		if gameMode == "tdm" or gameMode == "ctf" then
			testDM.TeamHandler(pid)
		end
	end
    else
    end
end

function PlayerIniti(pid) --Used for teleportation into the round.
	if Players[pid] ~= nil then
	    tes3mp.LogMessage(2, "++++ Initialising PID ", pid)
	    testDM.JSONCheck(pid) -- Check if player has TDM info added to their JSON file -- from what I see in fuction, this doesn't just check, this makes sure that there is data to work with
	    tes3mp.LogMessage(2, "++++ --PlayerInit: Checking matchId of player " .. Players[pid].data.login.name .. " against matchId #" .. matchId .. ". ++++")
	    -- Check player's last matchId to determine whether to reset their character
	    if Players[pid].data.mwTDM.matchId == matchId then
	    	tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is the same. ++++")
		    testDM.PlayerSpawner2(pid)
	    else -- Player's latest match ID doesn't equal that of current match
		    --logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 25')
		    Players[pid].data.mwTDM.lives = 5
		    testDM.PlayerSpawner(pid)
		    for pid, p in pairs(Players) do -- Iterate through all players and start assigning teams
			    if p ~= nil and p:IsLoggedIn() then
			end
		end
		if Players[pid].data.mwTDM.matchId == nil then
			-- New character so no need to wipe it
		else -- Character was created prior to current match so we reset it
			tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is different -- Calling ResetCharacter(). ++++")
			--testDM.ResetCharacter(pid) -- Reset character
		end
            --		tes3mp.LogMessage(2, "++++ --PlayerInit: Assigning new matchId to player. ++++")
            --		Players[pid].data.mwTDM.matchId = matchId -- Set player's match ID to current match ID
		    -- handle team assigment only for the first time in a match (so that team-sorting logic does not happen at every respawn)
		    if gameMode == "tdm" or gameMode == "ctf" then
			    testDM.TeamHandler(pid)
		    end
	    end
    else
    end
end

-- make player ready to be spawned in game
testDM.PlayerInit = function(pid)
	tes3mp.LogMessage(2, "++++ Initialising PID ", pid)
	testDM.JSONCheck(pid) -- Check if player has TDM info added to their JSON file -- from what I see in fuction, this doesn't just check, this makes sure that there is data to work with
	tes3mp.LogMessage(2, "++++ --PlayerInit: Checking matchId of player " .. Players[pid].data.login.name .. " against matchId #" .. matchId .. ". ++++")
	-- Check player's last matchId to determine whether to reset their character (if the player came from the same match)
	if Players[pid].data.mwTDM.matchId == matchId and Players[pid].data.mwTDM.inmatch == 1 then
		tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is the same. ++++")
		testDM.PlayerSpawner2(pid)
	else -- Player's latest match ID doesn't equal that of current match (if the player came from another match)
		--logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 150')
		Players[pid].data.mwTDM.lives = 5
		testDM.PlayerSpawner(pid)
		for pid, p in pairs(Players) do -- Iterate through all players and start assigning teams
			if p ~= nil and p:IsLoggedIn() then
			end
		end
		if Players[pid].data.mwTDM.matchId == nil then
			-- New character so no need to wipe it
		else -- Character was created prior to current match so we reset it
			tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is different -- Calling ResetCharacter(). ++++")
			--testDM.ResetCharacter(pid) -- Reset character
		end
            --		tes3mp.LogMessage(2, "++++ --PlayerInit: Assigning new matchId to player. ++++")
            --		Players[pid].data.mwTDM.matchId = matchId -- Set player's match ID to current match ID
		    -- handle team assigment only for the first time in a match (so that team-sorting logic does not happen at every respawn)
		if gameMode == "tdm" or gameMode == "ctf" then
			    testDM.TeamHandler(pid)
		end
	end
end

-- display the state of the game appropriately for each game mode
--[[testDM.ShowScore = function(pid)

	-- handle score display for deathmatch
	if gameMode ==  "dm" then

		local playerList = ""
		local newline = ""
		for pid, p in pairs(Players) do 
			if p:IsLoggedIn() and p.data.mwTDM ~= nil then
				tes3mp.LogMessage(2, "++++ local ShowScore: Adding player " .. p.data.login.name .. ". ++++")
				playerList = playerList .. newline .. p.data.login.name .. " | K: " .. p.data.mwTDM.kills .. " | D: " .. p.data.mwTDM.deaths
				-- this removes the leading newline for first entry but sets it for all following entries
				newline = "\n"
			end
		end
		tes3mp.MessageBox(pid, -1, playerList)

	-- handle score display for team deathmatch and capture the flag
	elseif gameMode == "tdm" or gameMode == "ctf" then

		-- clear values from previous lookup
		local teamLists = {}
		for teamIndex=1,numberOfTeams do
			teamLists[teamIndex] = 0
		end
		
		tes3mp.LogMessage(2, "++++ local ListTeams: Building list of teams + players. ++++")
		local teamList = ""
		
		for teamIndex=1,numberOfTeams do
			teamLists[teamIndex] = testDMConfig.teamColors[teamIndex] .. testDMConfig.teamNames[teamIndex] .. " (" .. teamCounters[teamIndex] .. ") " .. color.Yellow .."| Score: " .. teamScores[teamIndex]
			for pid, p in pairs(Players) do 
				
				if p:IsLoggedIn() and p.data.mwTDM ~= nil then
					
					if p.data.mwTDM.team == teamIndex then
						tes3mp.LogMessage(2, "++++ local ListTeams: Adding player " .. p.data.login.name .. " to " .. testDMConfig.teamNames[teamIndex] .. ". ++++")
						teamLists[teamIndex] = teamLists[teamIndex] .. "\n" .. p.data.login.name .. ": " .. p.data.mwTDM.kills
					end
				end
			end
			-- sup dawg, heard you like teams. And maybe some lists
			teamList = teamList .. teamLists[teamIndex]
			-- append seperator if there are more teams to be displayed
			if teamIndex ~= numberOfTeams then
				teamList = teamList .. "\n---------------\n"
			end
		end
		
		-- TODO: find better format to display teams
		-- the "list" interface would probably be better, as it can be easily closed instead of being displayed for a fixed amout of time
		tes3mp.MessageBox(pid, -1, teamList)
	end
end]]

testDM.OnDeathTimeExpiration2 = function(pid)
	tes3mp.LogMessage(2, "++++ Got pid: ", pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		Players[pid]:SaveStatsDynamic()
		tes3mp.LogMessage(2, "++++ Respawning pid: ", pid)
		tes3mp.Resurrect(pid, 0)
		tes3mp.SetHealthCurrent(pid, 1)
		tes3mp.SendStatsDynamic(pid)
		testDM.PlayerInit2(pid)
	end
	if aliveCounter == 1 then
		testDM.MatchInit()
	elseif aliveCounter == 0 then
		testDM.MatchInit()
	end
end

testDM.OnDeathTimeExpiration = function(pid)
	if Players[pid].data.mwTDM.status ~= 1 then
	    tes3mp.SendMessage(pid, color.Pink .. "Resurrected\n")
	    tes3mp.LogMessage(2, "++++ Got pid: ", pid)
	    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid].data.mwTDM.lives > -1 and Players[pid].data.mwTDM.inmatch == 1 then
	    	Players[pid]:SaveStatsDynamic(packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic"))
	    	tes3mp.LogMessage(2, "++++ Respawning pid: ", pid)
	    	tes3mp.Resurrect(pid, 0)
	    	tes3mp.SetHealthCurrent(pid, 1)
	    	tes3mp.SendStatsDynamic(pid)
	    	testDM.PlayerInit(pid)
        elseif Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid].data.mwTDM.lives > -1 then
	        Players[pid]:SaveStatsDynamic(packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic"))
	        tes3mp.LogMessage(2, "++++ Respawning pid: ", pid)
	        tes3mp.Resurrect(pid, 0)
	        tes3mp.SetHealthCurrent(pid, 1)
	        tes3mp.SendStatsDynamic(pid)
	        testDM.PlayerInit(pid)
	    end
	    local alivecount = 0
	    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid].data.mwTDM.lives <= -1 then
	    	for pid, p in pairs(Players) do
	    		if Players[pid].data.mwTDM.status == 1 then
	    			alivecount = alivecount + 1
	    		end
	    		tes3mp.SendMessage(pid, color.Yellow .. "Number of players left alive is " .. alivecount .. "\n")
	    	end
	    	if alivecount == 1 or 0 then
	    		EndIt()
	    	end
	    end
    else
    end
end

testDM.OnPlayerEndCharGen = function(pid)
	if Players[pid] ~= nil then
		tes3mp.LogMessage(2, "++++ Newly created: ", pid)
		BasePlayer:EndCharGen(pid)
	end
end

testDM.EndCharGen = function(pid) -- happens at End of "charactergeneration"?
    Players[pid]:SaveLogin()
    Players[pid]:SaveCharacter()
    Players[pid]:SaveClass(packetReader.GetPlayerPacketTables(pid, "PlayerClass"))
    Players[pid]:SaveStatsDynamic(packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic"))
    Players[pid]:SaveEquipment(packetReader.GetPlayerPacketTables(pid, "PlayerEquipment"))
    Players[pid]:SaveIpAddress()
    Players[pid]:CreateAccount()
	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 150')
	--logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddSpell "balynas_soothing_balm"')
	logicHandler.RunConsoleCommandOnPlayer(pid, 'AddTopic, "transport to Mournhold"')
	logicHandler.RunConsoleCommandOnPlayer(pid, 'SetJournalIndex, "TR_DBAttack", 60')
	--logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test chitin dagger" 1')
	--logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 100')
	testDM.PlayerInit(pid)
end

testDM.JSONCheck = function(pid)
	tes3mp.LogMessage(2, "++++ --JSONCheck: Checking player JSON file for " .. Players[pid].data.login.name .. ". ++++")
	if Players[pid].data.mwTDM == nil then
		tdmInfo = {}
		tdmInfo.matchId = ""
		tdmInfo.status = 1 -- 1 = alive
		tdmInfo.lives = 5
		tdmInfo.inmatch = 0
		tdmInfo.team = 0
		tdmInfo.kills = 0
		tdmInfo.deaths = 0
		tdmInfo.spree = 0
		tdmInfo.spawnSeconds = spawnTime
		tdmInfo.totalKills = 0
		tdmInfo.totalDeaths = 0
		tdmInfo.DMOutfit = {} -- used to hold data about player's outfit in non-team games
		Players[pid].data.mwTDM = tdmInfo
		Players[pid]:Save()
	end
end

conditionMet = nil

-- TODO: properly seperate handling for deathmatch and team deathmatch   
-- Update player kills/deaths and team scores

testDM.ProcessDeath = function(pid)
	lives = Players[pid].data.mwTDM.lives
	Players[pid].data.mwTDM.lives = lives - 1
	Players[pid].data.mwTDM.status = 0
	lifeCounter = 0
	aliveCounter = 0
	for pid, p in pairs(Players) do
		if Players[pid].data.mwTDM.lives > -1 and Players[pid].data.mwTDM.status == 1 then
			aliveCounter = aliveCounter + 1
		end
	end
	for pid, p in pairs(Players) do
	   if Players[pid].data.mwTDM.lives > -1 then
		   lifeCounter = lifeCounter + 1
	   end
   end
		if lifeCounter == 1 then
			local Gold = { refId = "gold_001", count = 25, charge = -1}
			for pid, p in pairs(Players) do
				if Players[pid].data.mwTDM.status == 1 then
					logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 25')
						--table.insert(Players[pid].data.inventory, Gold)
					local nameon = Players[pid].data.login.name
					for pid, p in pairs(Players) do
					tes3mp.SendMessage(pid, color.Yellow .. nameon .. " has won! Dispensing reward...\n")
					end
				elseif Players[pid].data.mwTDM.status == 0 then
					timer = tes3mp.CreateTimerEx("OnDeathTimeExpiration", time.seconds(5), "is", pid, Players[pid].accountName)
					tes3mp.StartTimer(timer)
				end
			end
		end
		if lifeCounter > 1 then
			tes3mp.SendMessage(pid, color.Green .. "Fixed?\n")
			timer = tes3mp.CreateTimerEx("OnDeathTimeExpiration", time.seconds(5), "is", pid, Players[pid].accountName)
			tes3mp.StartTimer(timer)
		end
	if lifeCounter == 0 then
		for pid, p in pairs(Players) do
			--if Players[pid].data.mwTDM.status == 1 then
			--table.insert(Players[pid].data.inventory, Gold)
			local nameon = Players[pid].data.login.name
			tes3mp.SendMessage(pid, color.Yellow .. "Nobody won. Starting new round...\n")
			--end
			timer = tes3mp.CreateTimerEx("OnDeathTimeExpiration", time.seconds(5), "is", pid, Players[pid].accountName)
			tes3mp.StartTimer(timer)
		end
	else
	end
	Players[pid].data.mwTDM.status = 0	-- Player is dead and not safe for teleporting
	Players[pid].data.mwTDM.deaths = Players[pid].data.mwTDM.deaths + 1
	Players[pid].data.mwTDM.totalDeaths = Players[pid].data.mwTDM.totalDeaths + 1	--things that were maybe used in the original version that I was piggy backing off of and stealing from, 
	--but may not be used in this currently, because they may not have worked well in the original, and I didn't know how to fix them
	--might be usable later???
	Players[pid].data.mwTDM.spree = 0
	local deathReason = tes3mp.GetDeathReason(pid)
	local nameo = Players[pid].data.login.name
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
			tes3mp.SendMessage(pid, color.Yellow .. nameo .. " has died. " .. lives .. " lives left.\n")
		end
	end
	local scoreChange = 0	
	local message = ""
	-- use silver (light grey) for names in deathmatch but then override this variable in case of team-based game mode
	local playerNameColor = color.Silver
	tes3mp.LogMessage(1, "Original death reason was " .. deathReason)
	if deathReason == Players[pid].data.login.name then
		-- leading space because this will be part of a constructed message
		deathReason = " committed suicide"
		if addSpawnDelay == true then
			Players[pid].data.mwTDM.spawnSeconds = Players[pid].data.mwTDM.spawnSeconds + spawnDelay
		end
	else
		local playerKiller = deathReason
		for pid2, player in pairs(Players) do
			-- leading space because this will be part of a constructed message
			deathReason = " was killed by " .. playerNameColor .. playerKiller
			break
		end
	end
	-- player kills affect team score only in team deathmatch
	if gameMode == "tdm" then
		teamScores[killerTeam] = teamScores[killerTeam] + scoreChange
	end
end

-- Called from local PlayerInit to reset characters for each new match
testDM.ResetCharacter = function(pid) -- may not be used currently, from original version, we don't reset characters in this version
	-- Reset mwTDM info
	Players[pid].data.mwTDM.kills = 0
	Players[pid].data.mwTDM.deaths = 0
	Players[pid].data.mwTDM.spree = 0
	--Players[pid].data.mwTDM.spawnSeconds = spawnTime
	
	-- Reset player level
	--[[Players[pid].data.stats.level = playerLevel
	Players[pid].data.stats.levelProgress = 0]]
	
	-- Reset player attributes
	--[[for name in pairs(Players[pid].data.attributes) do
		Players[pid].data.attributes[name] = playerAttributes
	end]]

	--Players[pid].data.attributes.Speed = playerSpeed
	--[[Players[pid].data.attributes.Luck = playerLuck
	
	-- Reset player skills
	for name in pairs(Players[pid].data.skills) do
		Players[pid].data.skills[name] = playerSkills
		Players[pid].data.skillProgress[name] = 0
	end


	Players[pid].data.skills.Acrobatics = playerAcrobatics

	
	Players[pid].data.skills.Marksman = playerMarksman
	
	for name in pairs(Players[pid].data.attributeSkillIncreases) do
		Players[pid].data.attributeSkillIncreases[name] = 0
	end

	-- Reset player stats
	Players[pid].data.stats.healthBase = playerHealth
	Players[pid].data.stats.healthCurrent = playerHealth
	Players[pid].data.stats.magickaBase = playerMagicka
	Players[pid].data.stats.magickaCurrent = playerMagicka
	Players[pid].data.stats.fatigueBase = playerFatigue
	Players[pid].data.stats.fatigueCurrent = playerFatigue
	
	-- Reload player with reset information
	Players[pid]:Save()
	Players[pid]:LoadLevel()
	Players[pid]:LoadAttributes()
	Players[pid]:LoadSkills()
	Players[pid]:LoadStatsDynamic()]]
end

testDM.OnTimerExpiration = function() --not sure if used any more
	testDM.EndMatch()
end

function HealthRegen(pid) --health regen resting similator for respawning
    local Result = Players[pid].data.stats.healthCurrent + (Players[pid].data.attributes.Endurance.base * 0.1 ) * 9--[[8]]
    local something = (Result >= Players[pid].data.stats.healthBase)
	tes3mp.SendMessage(pid, color.Blue .. "Rested\n")
   if something then
        tes3mp.SetHealthCurrent(pid, Players[pid].data.stats.healthBase)
   else
        tes3mp.SetHealthCurrent(pid, Result)
   end
        tes3mp.SendStatsDynamic(pid)
end

function MagickaRegen(pid) --magicka regen resting simulator for respawning
	local var1 = Players[pid].data.stats.magickaCurrent
	local var2 = Players[pid].data.stats.magickaBase
	local var3 = Players[pid].data.attributes.Intelligence.base
	local Result = var1 + (var3 * 0.15 ) * 9--[[8]]
	local something = (Result >= var2)
	if something then
	    tes3mp.SetMagickaCurrent(pid, var2)
	else
	    tes3mp.SetMagickaCurrent(pid, Result)
	end
        tes3mp.SendStatsDynamic(pid)
end

function FatigueRegen(pid) --fatigue regen resting simulator for respawning
    local Result = Players[pid].data.stats.fatigueBase
    local something = (Result >= Players[pid].data.stats.healthBase)
    tes3mp.SetFatigueCurrent(pid, Result)
    tes3mp.SendStatsDynamic(pid)
end

function Hpotions(pid) --adds and refills health potions
	if Players[pid] ~= nil then
	    local potionCount = getPlayerItemCount(pid, "test p_restore_health_s")
	    if potionCount == 1 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test p_restore_health_s" 1')
	    elseif potionCount == 0 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test p_restore_health_s" 2')
	    elseif potionCount >= 2 then
	    	return
	    end
    end
end

function Mpotions(pid) --adds and refills magicka potions
	if Players[pid] ~= nil then
	    local potionCount = getPlayerItemCount(pid, "test p_restore_magicka_s")
	    if potionCount == 1 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test p_restore_magicka_s" 1')
	    elseif potionCount == 0 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test p_restore_magicka_s" 2')
	    elseif potionCount >= 2 then
	    	return
	    end
    end
end

function Fpotions(pid) --adds and refills fatigue potions
	if Players[pid] ~= nil then
	    local potionCount = getPlayerItemCount(pid, "test p_restore_fatigue_s")
	    if potionCount == 1 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test p_restore_fatigue_s" 1')
	    elseif potionCount == 0 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test p_restore_fatigue_s" 2')
	    elseif potionCount >= 2 then
	    	return
	    end
    end
end

function Rpotions(pid) -- adds and refills spell absorb potions
	if Players[pid] ~= nil then
	    local potionCount = getPlayerItemCount(pid, "test p_reflection_s")
	    if potionCount == 1 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test p_reflection_s" 1')
	    elseif potionCount == 0 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test p_reflection_s" 2')
	    elseif potionCount >= 2 then
	    	return
	    end
    end
end

function PotionRefill(pid)
	Hpotions(pid)
	Mpotions(pid)
	Fpotions(pid)
	Rpotions(pid)
end

function PotionRemovalR(pid)
	
	if Players[pid] ~= nil then
	    local potionCount = getPlayerItemCount(pid, "test p_reflection_s")
		local potionCount2 = getPlayerItemCount(pid, "test p_restore_fatigue_s")
		local potionCount3 = getPlayerItemCount(pid, "test p_restore_magicka_s")
		local potionCount4 = getPlayerItemCount(pid, "test p_restore_health_s")
	    --if potionCount == 1 then
	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_reflection_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_fatigue_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_magicka_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_health_s" 2')
	end

	
end

function PotionRemovalF(pid)
	
	if Players[pid] ~= nil then
	    local potionCount = getPlayerItemCount(pid, "test p_reflection_s")
		local potionCount2 = getPlayerItemCount(pid, "test p_restore_fatigue_s")
		local potionCount3 = getPlayerItemCount(pid, "test p_restore_magicka_s")
		local potionCount4 = getPlayerItemCount(pid, "test p_restore_health_s")
	    --if potionCount == 1 then
--	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_reflection_s" 2')
			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_fatigue_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_magicka_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_health_s" 2')
	end

	
end

function PotionRemovalM(pid)
	
	if Players[pid] ~= nil then
	    local potionCount = getPlayerItemCount(pid, "test p_reflection_s")
		local potionCount2 = getPlayerItemCount(pid, "test p_restore_fatigue_s")
		local potionCount3 = getPlayerItemCount(pid, "test p_restore_magicka_s")
		local potionCount4 = getPlayerItemCount(pid, "test p_restore_health_s")
	    --if potionCount == 1 then
--	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_reflection_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_fatigue_s" 2')
			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_magicka_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_health_s" 2')
	end

	
end

function PotionRemovalH(pid)
	
	if Players[pid] ~= nil then
	    local potionCount = getPlayerItemCount(pid, "test p_reflection_s")
		local potionCount2 = getPlayerItemCount(pid, "test p_restore_fatigue_s")
		local potionCount3 = getPlayerItemCount(pid, "test p_restore_magicka_s")
		local potionCount4 = getPlayerItemCount(pid, "test p_restore_health_s")
	    --if potionCount == 1 then
--	    	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_reflection_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_fatigue_s" 2')
--			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_magicka_s" 2')
			logicHandler.RunConsoleCommandOnPlayer(pid, 'player->removeitem "test p_restore_health_s" 2')
	end

	
end

function PotionRemoval(pid)
	if Players[pid] ~= nil then
		PotionRemovalR(pid)
		PotionRemovalF(pid)
		PotionRemovalM(pid)
		PotionRemovalH(pid)
	end
end

function RespawnResting(pid)--"resting" regeneration functions.
	HealthRegen(pid)--"resting" regeneration functions. Could maybe make a single function that will do all this instead of using all these words?
	if Players[pid].data.character.birthsign ~= "wombburned" then --regen magicka only if player isn't atronach
		MagickaRegen(pid)
	else
	end
	FatigueRegen(pid)
end

function getPlayerItemCount(pid, itemid) --used in the potion-refilling functions
		local itemLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, itemid, -1)
		if itemLoc then
			return Players[pid].data.inventory[itemLoc].count
		else
			return 0
		end
end

testDM.PlayerSpawner3 = function(pid) --used in Playerinit2 for when NOT in the current match
	Players[pid].data.mwTDM.status = 1
	math.random(1, 4) -- Improves RNG? LUA's random isn't great
	math.random(1, 4) 
	randomLocationIndex = math.random(1, 4) --not really used in this function, because it is just sending to one location
	local possibleSpawnLocations = {}
	if gameMode == "dm" then
		-- spawns player in any of map's possible locations, regardless of which team it belongs to
		randomTeamIndex = math.random(1, 2)
		possibleSpawnLocations = currentMatch.map.teamSpawnLocations[randomTeamIndex]
		tes3mp.LogMessage(2, "++++ Spawning player at team ".. randomTeamIndex .. " spawnpoint #" .. randomLocationIndex .. " ++++")
	else
		-- find which team player belongs to and set spawn location to one of team's possible locations
		for teamIndex=1,numberOfTeams do
			if Players[pid].data.mwTDM.team == teamIndex then
				possibleSpawnLocations = currentMatch.map.teamSpawnLocations[teamIndex]
				tes3mp.LogMessage(2, "++++ Spawning player at team ".. teamIndex .. " spawnpoint #" .. randomLocationIndex .. " ++++")
			end
		end
	end
	tes3mp.SetCell(pid, "Pelagiad, Fort Pelagiad")
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, 2233.9094238281, 362.85528564453, 129)
	tes3mp.SetRot(pid, 0, -2.479984998703)
	tes3mp.SendPos(pid)
	local birth = Players[pid].data.character.birthsign.wombburned
	RespawnResting(pid)--"resting" regeneration functions.
	--do the level up thing if the level progress is 10 or more. Could maybe make a function for this too?
	if Players[pid].data.stats.levelProgress >= 10 then 
    	logicHandler.RunConsoleCommandOnPlayer(pid, 'EnableLevelUpMenu')
	else
	end
	--PotionRemoval(pid)
end

testDM.playerauthentified = function() --used for "has joined the game!", if that makes sense
	OnPlayerAuthentified()
end

-- determines player's spawn location
testDM.PlayerSpawner = function(pid)
	Players[pid].data.mwTDM.status = 1
	math.random(1, 4) -- Improves RNG? LUA's random isn't great
	math.random(1, 4) 
	randomLocationIndex = math.random(1, 4)
	local possibleSpawnLocations = {}
	if gameMode == "dm" then
		-- spawns player in any of map's possible locations, regardless of which team it belongs to
		randomTeamIndex = math.random(1, 2)
		possibleSpawnLocations = currentMatch.map.teamSpawnLocations[randomTeamIndex]
		tes3mp.LogMessage(2, "++++ Spawning player at team ".. randomTeamIndex .. " spawnpoint #" .. randomLocationIndex .. " ++++")
	else
		-- find which team player belongs to and set spawn location to one of team's possible locations
		for teamIndex=1,numberOfTeams do
			if Players[pid].data.mwTDM.team == teamIndex then
				possibleSpawnLocations = currentMatch.map.teamSpawnLocations[teamIndex]
				tes3mp.LogMessage(2, "++++ Spawning player at team ".. teamIndex .. " spawnpoint #" .. randomLocationIndex .. " ++++")
			end
		end
	end
	tes3mp.SetCell(pid, "Pelagiad, Fort Pelagiad")
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, 2233.9094238281, 362.85528564453, 129)
	tes3mp.SetRot(pid, 0, -2.479984998703)
	tes3mp.SendPos(pid)
	--[[tes3mp.SetCell(pid, possibleSpawnLocations[randomLocationIndex][1])
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, possibleSpawnLocations[randomLocationIndex][2], possibleSpawnLocations[randomLocationIndex][3], possibleSpawnLocations[randomLocationIndex][4])
	tes3mp.SetRot(pid, 0, possibleSpawnLocations[randomLocationIndex][5])
	tes3mp.SendPos(pid)]]
	RespawnResting(pid)--"resting" regeneration functions.
	if Players[pid].data.stats.levelProgress >= 10 then
    	logicHandler.RunConsoleCommandOnPlayer(pid, 'EnableLevelUpMenu')
	else
	end
	--PotionRemoval(pid)
end

	--LastSpawn = []
	lastspawnlocation = 0
	spawnlocation = 1
	spawnlocationthing = 0
testDM.PlayerSpawner2 = function(pid) --Used to spawn the player in the fighting area. Used in multiple functions.
	local LastSpawn = {}
	Players[pid].data.mwTDM.status = 1
	--math.random(1, 4) -- Improves RNG? LUA's random isn't great
	--math.random(1, 4) 
	randomLocationIndex = math.random(1, 4)
	if LastSpawn[pid] == nil then
	  LastSpawn[pid] = randomLocationIndex
	else
	  if LastSpawn[pid] == randomLocationIndex then
		if randomLocationIndex == 4 then
		  randomLocationIndex = 1
		else  
		  randomLocationIndex = randomLocationIndex + 1
		end  
	  end
	end
	local possibleSpawnLocations = {}
	if gameMode == "dm" then
		-- spawns player in any of map's possible locations, regardless of which team it belongs to
		randomTeamIndex = math.random(1, 2)
		possibleSpawnLocations = currentMatch.map.teamSpawnLocations[1]
		tes3mp.LogMessage(2, "++++ Spawning player at team ".. randomTeamIndex .. " spawnpoint #" .. randomLocationIndex .. " ++++")
	else
		-- find which team player belongs to and set spawn location to one of team's possible locations
		for teamIndex=1,numberOfTeams do
			if Players[pid].data.mwTDM.team == teamIndex then
				possibleSpawnLocations = currentMatch.map.teamSpawnLocations[teamIndex]
				tes3mp.LogMessage(2, "++++ Spawning player at team ".. teamIndex .. " spawnpoint #" .. randomLocationIndex .. " ++++")
			end
		end
	end
	tes3mp.SetCell(pid, possibleSpawnLocations[spawnlocation][1])
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, possibleSpawnLocations[spawnlocation][2], possibleSpawnLocations[spawnlocation][3], possibleSpawnLocations[spawnlocation][4])
	tes3mp.SetRot(pid, 0, possibleSpawnLocations[spawnlocation][5])
	tes3mp.SendPos(pid)
	spawnlocation = spawnlocation + 1
	spawnlocationthing = spawnlocation
	if spawnlocation == 5 then
		spawnlocation = 1
	end
	--[[spawnlocation = spawnlocation + 1
	if spawnlocation == 5 then
		spawnlocation = 1
	else
	end]]
	--LastSpawn[pid] = 
	RespawnResting(pid)--"resting" regeneration functions.
	--refills potions
	--PotionRefill(pid)
	Players[pid].data.mwTDM.gm = 0
end

-- this starts proces of determining variables for the next match
-- TODO: implement voting mechanic (for admin and for players)
-- TODO: figure out how to make this thing work with timer, so that players have 30 seconds to vote before next match starts
testDM.EndMatch = function()
	--voteTimer = tes3mp.CreateTimer("testDM.MatchInit", time.seconds(5))
	--tes3mp.StartTimer(voteTimer)
	-- determine which match will be played next round
	if testDMConfig.matchSelectionMethod == 0 then
		-- TODO: find a way to remove the possibility of repeating the just-played match
		randomMatchIndex = math.random(1, #testDMConfig.matchList)
		nextMatch = testDMConfig.matchList[randomMatchIndex]
	elseif testDMConfig.matchSelectionMethod == 1 then
		-- go to the first match if there are no further matches
		matchRotationIndex = matchRotationIndex + 1
		if matchRotationIndex == 0 or matchRotationIndex > #testDMConfig.matchList then
			matchRotationIndex = 1
		end
		local nextMatchIndex = testDMConfig.matchList[matchRotationIndex]
		nextMatch = testDMMatchSettings[nextMatchIndex]
	end
	EndIt()
end

testDM.AdminEndMatch = function(pid)
	if Players[pid]:IsAdmin() then
		testDM.EndMatch()
	end
end

testDM.lastspawn = function(pid) -- not sure what this is. seems to be a function from the original version, or no, it was made to try to figure out how to do spawn locations, and may not be needed at the moment.
	tes3mp.SendMessage(pid, color.Red .. "Lastpawn is " ..spawnlocation.. "\n")
end

-- custom validators
customEventHooks.registerValidator("OnPlayerDeath", function(eventStatus, pid)
	-- this makes it so that default resurrect for player does not happen but custom handler for player death does get executed
	return customEventHooks.makeEventStatus(false,true)
end)

--customEventHooks.triggerHandlers("OnDeathTimeExpiration", eventStatus, {pid})
customEventHooks.registerValidator("OnDeathTimeExpiration", function(eventStatus, pid)
	-- this makes it so that default resurrect for player does not happen but custom handler for player death does get executed
	return customEventHooks.makeEventStatus(false,true)
end)

customEventHooks.registerHandler("OnServerPostInit", function()
	testDM.MatchInit()
end)

customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
	if eventStatus.validCustomHandlers then --check if some other script made this event obsolete
		testDM.PlayerIniti2(pid)
	end
end)

customEventHooks.registerHandler("OnPlayerDeath", function(eventStatus, pid)
	if eventStatus.validCustomHandlers then --check if some other script made this event obsolete
		testDM.ProcessDeath(pid)
	end
end)

customEventHooks.registerHandler("OnDeathTimeExpiration", function(eventStatus, pid)
	if eventStatus.validCustomHandlers then --check if some other script made this event obsolete
		testDM.OnDeathTimeExpiration(pid)
	end
end)

customEventHooks.registerHandler("OnDeathTimeExpiration2", function(eventStatus, pid)
	if eventStatus.validCustomHandlers then --check if some other script made this event obsolete
		testDM.OnDeathTimeExpiration(pid)
	end
end)

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventstatus, pid)
	if Players[pid] ~= nil then
		tes3mp.LogMessage(2, "++++ Newly created: ", pid)
		testDM.EndCharGen(pid)

	end
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventstatus, pid)
	if Players[pid] ~= nil then
		local nameon = Players[pid].data.login.name
	for pid, p in pairs(Players) do -- Iterate through all players and start assigning teams
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Yellow .. nameon .. " has joined the game! \n", false)
		end
	end
	end
end)

customCommandHooks.registerCommand("lastspawn", testDM.lastspawn)
customCommandHooks.registerCommand("score", testDM.ShowScore)
customCommandHooks.registerCommand("forceend", testDM.AdminEndMatch)
customCommandHooks.registerCommand("end", testDM.EndMatch)
customCommandHooks.registerCommand("death", testDM.ProcessDeath)

return testDM