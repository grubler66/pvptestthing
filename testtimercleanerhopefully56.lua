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
currentMatch = testDMMatchSettings.VArena_dm--fort_dm

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
--timers may cause crashing when setting off

timer44 = tes3mp.CreateTimer("Three", time.seconds(5))
timer22 = tes3mp.CreateTimer("Reset", time.seconds(1))
timer23 = tes3mp.CreateTimer("Reset2", time.seconds(60))
timer33 = tes3mp.CreateTimer("warning1", time.minutes(2))  -- "1 Minute Left until fight starts!""
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
		if p ~= nil and p:IsLoggedIn() and Players[pid].data.mwTDM ~= nil then
			tes3mp.LogMessage(2, "++++ --PlayerInit: Assigning new matchId to player. ++++")
			Players[pid].data.mwTDM.matchId = matchId -- Set player's match ID to current match ID
			Players[pid].data.mwTDM.lives = 5
			Players[pid].data.mwTDM.inmatch = 1 
			Players[pid].data.mwTDM.inarena = 0
				testDM.PlayerInit2(p.pid)
				tes3mp.SendMessage(pid, color.Orange .. "NEW ROUND: " .. currentMatch.name .. "\nRested 10 hours.\n" .. color.Yellow .. "25 Gold added(or not).\nMatch duration: 8 minutes\n" .. color.Red .. "Fight starts in 3 minutes!\n" .. color.Orange .. "Get Ready!\n", false)
		end
	end
	timer0 = tes3mp.CreateTimer("EndIt", time.minutes(2))	-- Does nothing?
	tes3mp.RestartTimer(timer44, time.minutes(10))
	tes3mp.RestartTimer(timer1, time.minutes(3))
	tes3mp.RestartTimer(timer33, time.minutes(2))  -- warning1 "1 Minute Left until fight starts!"
	tes3mp.RestartTimer(timer4, time.minutes(7))
	tes3mp.RestartTimer(timertest, time.minutes(8))  -- Ends the round
		for pid, p in pairs(Players) do --this is for the uhhh teleportation into the round.. interesting... 
			if p ~= nil and p:IsLoggedIn() and Players[pid].data.mwTDM ~= nil then
				timerspawn = tes3mp.CreateTimerEx("PlayerIniti", time.seconds(180), "i", pid)
				tes3mp.RestartTimer(timerspawn, time.seconds(180))
			end
		end

end

function warning1()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. "1:00 Pre-Game Time \n", false)
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
	local timer11 = tes3mp.CreateTimer("Eleven2", time.seconds(59))
	tes3mp.StartTimer(timer11)
end

function One()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. "5:00 Round Start \n", false)
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
	timer6 = tes3mp.CreateTimer("Six2", time.seconds(50))
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
				tes3mp.SendMessage(pid, color.Red .. "1:00 Round Time \n", false)
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

function Six2()
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
				tes3mp.SendMessage(pid, color.Red .. ":10 \n" .. color.Pink .. "Stop talking to NPCs or you'll crash! \n", false)
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

function Eleven2(pid)
	for pid, p in pairs(Players) do -- Iterate through all players 
		if p ~= nil and p:IsLoggedIn() then
		tes3mp.SendMessage(pid, color.Red .. ":01 \n", false)
		end
		if p ~= nil and p:IsLoggedIn() and Players[pid].data.mwTDM ~= nil and Players[pid].data.mwTDM.inmatch == 1 then
			Players[pid].data.mwTDM.inarena = 1
		end
	end
end

function Reset(pid) --resets cells 
	local pid, p = next(Players)
	if p ~= nil and p:IsLoggedIn() then
        logicHandler.ResetCell(pid, "-6, -1")
        logicHandler.ResetCell(pid, "Pelagiad, Fort Pelagiad")
        logicHandler.ResetCell(pid, "Arkngthand, Deep Ore Passage")
    end
end


function EndIt() -- Ends the round and starts a new one? Maybe?
    --check every player and see who has the most lives, and if they have the most, then they won, and if it is a tie, then they tied
    local bestlifenumber = 0
    local numberofbestlifepeople = 0
    for pid, p in pairs(Players) do
		if p ~= nil and p:IsLoggedIn() and Players[pid].data.mwTDM ~= nil then
        local lifenumber = Players[pid].data.mwTDM.lives
        if lifenumber > bestlifenumber then
            bestlifenumber = lifenumber
        end
	end
    end
    for pid, p in pairs(Players) do
		if p ~= nil and p:IsLoggedIn() and Players[pid].data.mwTDM ~= nil then
	    local lifenumber = Players[pid].data.mwTDM.lives
        if lifenumber == bestlifenumber then 
            numberofbestlifepeople = numberofbestlifepeople + 1 
        end
	end
    end
    for pid, p in pairs(Players) do
		if p ~= nil and p:IsLoggedIn() and Players[pid].data.mwTDM ~= nil then
	    local nameon = Players[pid].data.login.name
	    local lifenumber = Players[pid].data.mwTDM.lives
        if lifenumber == bestlifenumber and numberofbestlifepeople > 1 and Players[pid].data.mwTDM.inarena == 1 then
            if Players[pid].data.mwTDM.lives == bestlifenumber then
			    local amount = math.floor(50 / numberofbestlifepeople)
			    logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" ' ..amount)
		        for pid, p in pairs(Players) do
                tes3mp.SendMessage(pid, color.Yellow .. nameon .. " has tied at " .. bestlifenumber .. " lives!\n")
		    end
        end
        elseif lifenumber == bestlifenumber and numberofbestlifepeople == 1 and Players[pid].data.mwTDM.inarena == 1 then
		        logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 50')
            for pid, p in pairs(Players) do
                tes3mp.SendMessage(pid, color.Yellow .. nameon .. " has won with " .. bestlifenumber .. " lives! 50 gold prize to them!\n")
            end
        end
	end
    end
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
			if p ~= nil and p:IsLoggedIn() and Players[pid].data.mwTDM ~= nil then
		    if Players[pid].data.mwTDM.inarena == 1 then
		        amount = 10 * Players[pid].data.mwTDM.lives
		        logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" amount')
		    end
		end
	    end
		for pid, p in pairs(Players) do
			if p ~= nil and p:IsLoggedIn() and Players[pid].data.mwTDM ~= nil then
		    local Gold = { refId = "gold_001", count = 25, charge = -1}
		    if Players[pid].data.mwTDM.status == 1 and Players[pid].data.mwTDM.inarena == 1 then
			    logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 50')
			    local nameon = Players[pid].data.login.name
			    tes3mp.SendMessage(pid, color.Yellow .. "Added 50 gold for surviving, plus 10 for each life left!\n")
		     elseif Players[pid].data.mwTDM.status == 0 then
				tes3mp.SendMessage(pid, color.LightGreen .. "elseif...\n")
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
	    end
	    testDM.MatchInit()
		tes3mp.RestartTimer(timer22, time.seconds(1))

end

testDM.PlayerInit2 = function(pid) --used in matchinit
    AttributeHealing(pid)
	if Players[pid] ~= nil then
		tes3mp.SendMessage(pid, color.Green .. "PlayerInit2\n")
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
		end
	end
end


testDM.PlayerIniti2 = function(pid) -- Used for Onplayerfinishlogin?
--	tes3mp.SendMessage(pid, color.Green .. "PlayerIniti2\n")
AttributeHealing(pid)
	if Players[pid] ~= nil then
		tes3mp.SendMessage(pid, color.Green .. "PlayerIniti2\n")
	    tes3mp.LogMessage(2, "++++ Initialising PID ", pid)
	    testDM.JSONCheck(pid) -- Check if player has TDM info added to their JSON file -- from what I see in fuction, this doesn't just check, this makes sure that there is data to work with
	    tes3mp.LogMessage(2, "++++ --PlayerInit: Checking matchId of player " .. Players[pid].data.login.name .. " against matchId #" .. matchId .. ". ++++")
	    -- Check player's last matchId to determine whether to reset their character
	    if Players[pid].data.mwTDM.matchId == matchId and Players[pid].data.mwTDM.inmatch == 1  and Players[pid].data.mwTDM.inarena == 0 then
		    Players[pid].data.mwTDM.inmatch = 1
		    tes3mp.SendMessage(pid, color.LightBlue .. "You are in the current match.\n")
		    tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is the same. ++++")
		    testDM.PlayerSpawner(pid)
		elseif Players[pid].data.mwTDM.matchId == matchId and Players[pid].data.mwTDM.inmatch == 1 and Players[pid].data.mwTDM.inarena == 1 then

		    Players[pid].data.mwTDM.inmatch = 1
		    tes3mp.SendMessage(pid, color.LightBlue .. "You are in the current match.\n")
		    tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is the same. ++++")
		    testDM.PlayerSpawner2(pid)
	    else -- Player's latest match ID doesn't equal that of current match
	    	Players[pid].data.mwTDM.inmatch = 0
		    tes3mp.SendMessage(pid, color.LightBlue .. "You are not in the current match.\n")
		    Players[pid].data.mwTDM.lives = 1
		    testDM.PlayerSpawner(pid)
	end
end


function PlayerIniti(pid) --Used for teleportation into the round.
    AttributeHealing(pid)
	tes3mp.SendMessage(pid, color.Green .. "PlayerIniti\n")
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
end


-- make player ready to be spawned in game
testDM.PlayerInit = function(pid)
	SkillUpdating(pid)
    AttributeHealing(pid)
	if Players[pid] ~= nil then
	tes3mp.SendMessage(pid, color.Green .. "PlayerInit\n")
	tes3mp.LogMessage(2, "++++ Initialising PID ", pid)
	testDM.JSONCheck(pid) -- Check if player has TDM info added to their JSON file -- from what I see in fuction, this doesn't just check, this makes sure that there is data to work with
	tes3mp.LogMessage(2, "++++ --PlayerInit: Checking matchId of player " .. Players[pid].data.login.name .. " against matchId #" .. matchId .. ". ++++")
	-- Check player's last matchId to determine whether to reset their character (if the player came from the same match)
	if Players[pid].data.mwTDM.matchId == matchId and Players[pid].data.mwTDM.inmatch == 1 and Players[pid].data.mwTDM.inarena == 0 then
		tes3mp.LogMessage(2, "++++ --PlayerInit: matchId is the same. ++++")
		testDM.PlayerSpawner(pid)
	elseif Players[pid].data.mwTDM.matchId == matchId and Players[pid].data.mwTDM.inmatch == 1 and Players[pid].data.mwTDM.inarena == 1 then
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
		tes3mp.SendMessage(pid, color.Green .. "OnDeathTimeExpiration\n")
	    tes3mp.LogMessage(2, "++++ Got pid: ", pid)
	    if Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid].data.mwTDM.lives > -1 and Players[pid].data.mwTDM.inmatch == 1 then
	    	Players[pid]:SaveStatsDynamic(packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic"))
	    	tes3mp.LogMessage(2, "++++ Respawning pid: ", pid)
	    	tes3mp.Resurrect(pid, 0)
			tes3mp.SendMessage(pid, color.Pink .. "Resurrected\n")
	    	tes3mp.SetHealthCurrent(pid, 1)
	    	tes3mp.SendStatsDynamic(pid)
	    	testDM.PlayerInit(pid)
        elseif Players[pid] ~= nil and Players[pid]:IsLoggedIn() and Players[pid].data.mwTDM.lives > -1 then
	        Players[pid]:SaveStatsDynamic(packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic"))
	        tes3mp.LogMessage(2, "++++ Respawning pid: ", pid)
	        tes3mp.Resurrect(pid, 0)
			tes3mp.SendMessage(pid, color.Pink .. "Resurrected\n")
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
		tdmInfo.intmultiplier = 0
		tdmInfo.int = Players[pid].data.attributes.Intelligence.base
		tdmInfo.magmult = 0
		tdmInfo.inarena = 0
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

testDM.MagickaMultipliers = function(pid)
	tes3mp.SendMessage(pid, color.LightGreen .. "MagickaMultipliers\n")
	if Players[pid].data.mwTDM.magmult == 1 then
	if Players[pid].data.character.birthsign == "wombburned" then
		multiplier = 3
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.birthsign == "fay" then
		multiplier = 1.5
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.birthsign == "elfborn" then
		multiplier = 2.5
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.race == "breton" then
		multiplier = 1.5
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.race == "breton" and Players[pid].data.character.birthsign == "wombburned" then
		multiplier = 3.5
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.race == "breton" and Players[pid].data.character.birthsign == "fay" then
		multiplier = 2
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.race == "breton" and Players[pid].data.character.birthsign == "elfborn" then
		multiplier = 3
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.race == "high elf" then
		multiplier = 2.5
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.race == "high elf" and Players[pid].data.character.birthsign == "elfborn" then
		multiplier = 4
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.race == "high elf" and Players[pid].data.character.birthsign == "fay" then
		multiplier = 3
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	elseif Players[pid].data.character.race == "high elf" and Players[pid].data.character.birthsign == "wombburned" then
		multiplier = 4.5
		intelligencetimesmultiplier = Players[pid].data.mwTDM.int * multiplier
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..intelligencetimesmultiplier)
	end
end
end

testDM.AntiMagickaMultipliers = function(pid)
	tes3mp.SendMessage(pid, color.Orange .. "AntiMagickaMultipliers\n")
	oldint = Players[pid].data.mwTDM.int
	logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIntelligence ' ..oldint)
    Players[pid].data.mwTDM.magmult = 0
end
--

function SkillUpdating(pid)
	tes3mp.SendMessage(pid, color.Pink .. "SkillUpdating\n")
	if Players[pid].data.skills.Block.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetBlock 30')
	--	Players[pid].data.skills.Block.base = 30
	else
	end
	if Players[pid].data.skills.Restoration.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetRestoration 30')
	else
	end
	if Players[pid].data.skills.Conjuration.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetConjuration 30')
	else
	end
	if Players[pid].data.skills.Marksman.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetMarksman 30')
	else
	end
	if Players[pid].data.skills.Mediumarmor.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetMediumarmor 30')
	else
	end
	if Players[pid].data.skills.Alteration.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetAlteration 30')
	else
	end
	if Players[pid].data.skills.Heavyarmor.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetHeavyarmor 30')
	else
	end
	if Players[pid].data.skills.Mercantile.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetMercantile 30')
	else
	end
	if Players[pid].data.skills.Shortblade.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetShortblade 30')
	else
	end
	if Players[pid].data.skills.Acrobatics.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetAcrobatics 30')
	else
	end
	if Players[pid].data.skills.Lightarmor.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetLightarmor 30')
	else
	end
	if Players[pid].data.skills.Longblade.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetLongblade 30')
	else
	end
	if Players[pid].data.skills.Axe.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetAxe 30')
	else
	end
	if Players[pid].data.skills.Enchant.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetEnchant 30')
	else
	end
	if Players[pid].data.skills.Destruction.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetDestruction 30')
	else
	end
	if Players[pid].data.skills.Athletics.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetAthletics 30')
	else
	end
	if Players[pid].data.skills.Illusion.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetIllusion 30')
	else
	end
	if Players[pid].data.skills.Mysticism.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetMysticism 30')
	else
	end
	if Players[pid].data.skills.Spear.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetSpear 30')
	else
	end
	if Players[pid].data.skills.Bluntweapon.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetBluntweapon 30')
	else
	end
	if Players[pid].data.skills.Handtohand.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetHandtohand 30')
	else
	end
	if Players[pid].data.skills.Unarmored.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetUnarmored 30')
	else
	end
	if Players[pid].data.skills.Speechcraft.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetSpeechcraft 30')
	else
	end
	if Players[pid].data.skills.Alchemy.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetAlchemy 30')
	else
	end
	if Players[pid].data.skills.Sneak.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetSneak 30')
	else
	end
	if Players[pid].data.skills.Security.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetSecurity 30')
	else
	end
--[[	if Players[pid].data.skills.Alchemy.base < 30 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->SetAlchemy 30')
	else
	end]]
end

--
testDM.ProcessDeath = function(pid)
	tes3mp.SendMessage(pid, color.Green .. "ProcessDeath\n")
	Players[pid].data.mwTDM.magmult = 1
	AttributeHealing(pid)
	testDM.MagickaMultipliers(pid) --multiplier for certain characters who lose magicka multipliers on death.
	lives = Players[pid].data.mwTDM.lives
	Players[pid].data.mwTDM.lives = lives - 1
	Players[pid].data.mwTDM.status = 0
	lifeCounter = 0
	aliveCounter = 0
	for pid, p in pairs(Players) do
		if Players[pid].data.mwTDM ~= nil and Players[pid].data.mwTDM.lives > -1 and Players[pid].data.mwTDM.status == 1 then
			aliveCounter = aliveCounter + 1
		end
	end
	for pid, p in pairs(Players) do
	   if Players[pid].data.mwTDM ~= nil and Players[pid].data.mwTDM.lives > -1 then
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
			local nameon = Players[pid].data.login.name
			tes3mp.SendMessage(pid, color.Yellow .. "Nobody won. Starting new round...\n")
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
end

testDM.OnTimerExpiration = function() --not sure if used any more
	testDM.EndMatch()
end

function HealthRegen(pid) --health regen resting similator for respawning
    local Result = Players[pid].data.stats.healthCurrent + (Players[pid].data.attributes.Endurance.base * 0.1 ) * 10--[[8]]
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

	local magcurrent = Players[pid].data.stats.magickaCurrent
	local magbase = Players[pid].data.stats.magickaBase
	local intbase = Players[pid].data.mwTDM.int --Players[pid].data.attributes.Intelligence.base
	local newmag = magcurrent + (intbase * 0.15 ) * 10--[[8]]
	local morethan = (newmag >= magbase)
	if morethan then
	    tes3mp.SetMagickaCurrent(pid, magbase)
	else
	    tes3mp.SetMagickaCurrent(pid, newmag)
	end
        tes3mp.SendStatsDynamic(pid)
end

function FatigueRegen(pid) --fatigue regen resting simulator for respawning
    local Result = Players[pid].data.stats.fatigueBase
    local something = (Result >= Players[pid].data.stats.healthBase)
    tes3mp.SetFatigueCurrent(pid, Result)
    tes3mp.SendStatsDynamic(pid)
end

-- SetAttributeDamage possibly used for potentially healing damaged attributes for the respawn healing functions...
function AttributeHealing(pid)
    tes3mp.SendMessage(pid, color.LightBlue .. "AttributeHealing\n")
	Strength = tes3mp.GetAttributeId("Strength")
	Intelligence = tes3mp.GetAttributeId("Intelligence")
	Willpower = tes3mp.GetAttributeId("Willpower")
	Agility = tes3mp.GetAttributeId("Agility")
	Speed = tes3mp.GetAttributeId("Speed")
	Endurance = tes3mp.GetAttributeId("Endurance")
	Personality = tes3mp.GetAttributeId("Personality")
	Luck = tes3mp.GetAttributeId("Luck")
	tes3mp.SetAttributeDamage(pid, Strength, 0)
	tes3mp.SetAttributeDamage(pid, Intelligence, 0)
	tes3mp.SetAttributeDamage(pid, Willpower, 0)
	tes3mp.SetAttributeDamage(pid, Agility, 0)
	tes3mp.SetAttributeDamage(pid, Speed, 0)
	tes3mp.SetAttributeDamage(pid, Endurance, 0)
	tes3mp.SetAttributeDamage(pid, Personality, 0)
	tes3mp.SetAttributeDamage(pid, Luck, 0)
	tes3mp.SendAttributes(pid)
end

function RespawnResting(pid)--"resting" regeneration functions.
	HealthRegen(pid)--"resting" regeneration functions. Could maybe make a single function that will do all this instead of using all these words?
	if Players[pid].data.character.birthsign ~= "wombburned" then --regen magicka only if player isn't atronach
		MagickaRegen(pid)
	else
	end
	FatigueRegen(pid)
	testDM.AntiMagickaMultipliers(pid)
end

testDM.PlayerSpawner3 = function(pid) --used in Playerinit2 for when NOT in the current match
	tes3mp.SendMessage(pid, color.Green .. "PlayerSpawner3\n")
	Players[pid].data.mwTDM.status = 1
    ---
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
		possibleSpawnLocations = testDMMaps.buyingarea.teamSpawnLocations[1]
		tes3mp.LogMessage(2, "++++ Spawning player at team ".. randomTeamIndex .. " spawnpoint #" .. randomLocationIndex .. " ++++")
	else
		-- find which team player belongs to and set spawn location to one of team's possible locations
		for teamIndex=1,numberOfTeams do
			if Players[pid].data.mwTDM.team == teamIndex then
				possibleSpawnLocations = testDMMaps.buyingarea.teamSpawnLocations[teamIndex]
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
    ---
	--[[math.random(1, 4) -- Improves RNG? LUA's random isn't great
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
	tes3mp.SetCell(pid, "Pelagiad, North Wall")
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, 1025.232, 781.309, -1657.201)
	tes3mp.SetRot(pid, 0, -2.479984998703)
	tes3mp.SendPos(pid)]]
	local birth = Players[pid].data.character.birthsign.wombburned
	RespawnResting(pid)
	--do the level up thing if the level progress is 10 or more. Could maybe make a function for this too?
	if Players[pid].data.stats.levelProgress >= 10 then 
    	logicHandler.RunConsoleCommandOnPlayer(pid, 'EnableLevelUpMenu')
	else
	end
	ResetMarkLocation(pid)
end

testDM.playerauthentified = function() --used for "has joined the game!", if that makes sense
	OnPlayerAuthentified()
end

-- determines player's spawn location
testDM.PlayerSpawner = function(pid)
	tes3mp.SendMessage(pid, color.Green .. "PlayerSpawner\n")
	local LastSpawn = {}
	Players[pid].data.mwTDM.status = 1
---

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
    possibleSpawnLocations = testDMMaps.buyingarea.teamSpawnLocations[1]
    tes3mp.LogMessage(2, "++++ Spawning player at team ".. randomTeamIndex .. " spawnpoint #" .. randomLocationIndex .. " ++++")
else
    -- find which team player belongs to and set spawn location to one of team's possible locations
    for teamIndex=1,numberOfTeams do
        if Players[pid].data.mwTDM.team == teamIndex then
            possibleSpawnLocations = testDMMaps.buyingarea.teamSpawnLocations[teamIndex]
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
    ---
    --[[
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
	tes3mp.SetCell(pid, "Pelagiad, North Wall")
	tes3mp.SendCell(pid)
	tes3mp.SetPos(pid, 1025.232, 781.309, -1657.201)
	tes3mp.SetRot(pid, 0, -2.479984998703)
	tes3mp.SendPos(pid)]]
	RespawnResting(pid)
	if Players[pid].data.stats.levelProgress >= 10 then
    	logicHandler.RunConsoleCommandOnPlayer(pid, 'EnableLevelUpMenu')
	else
	end
	ResetMarkLocation(pid)
end

	--LastSpawn = []
	lastspawnlocation = 0
	spawnlocation = 1
	spawnlocationthing = 0

testDM.PlayerSpawner2 = function(pid) --Used to spawn the player in the fighting area. Used in multiple functions.
	tes3mp.SendMessage(pid, color.Green .. "PlayerSpawner2\n")
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
	RespawnResting(pid)
	ResetMarkLocation(pid)
	Players[pid].data.mwTDM.gm = 0
end
--

testDM.testPlayerSpawneridea = function(pid) --attempt to make a spawner for seperate buyin
	tes3mp.SendMessage(pid, color.Green .. "PlayerSpawner2\n")
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
	RespawnResting(pid)
	ResetMarkLocation(pid)
	Players[pid].data.mwTDM.gm = 0
end


--
testDM.PlayerSpawner0 = function(pid) --Attempt to make a thing that spawns players into personal merchant areas.
	tes3mp.SendMessage(pid, color.Green .. "PlayerSpawner2\n")
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
	RespawnResting(pid)
	ResetMarkLocation(pid)
	Players[pid].data.mwTDM.gm = 0
end
--

function ResetMarkLocation(pid)
cell = tes3mp.GetCell(pid)
posX = tes3mp.GetPosX(pid)
posY = tes3mp.GetPosY(pid)
posZ = tes3mp.GetPosZ(pid)
rotX = tes3mp.GetRotX(pid)
rotZ = tes3mp.GetRotZ(pid)
tes3mp.SetMarkCell(pid, cell)
tes3mp.SetMarkPos(pid, posX, posY, posZ)
tes3mp.SetMarkRot(pid, rotX, rotZ)
tes3mp.SendMarkLocation(pid)
end

testDM.EndMatch = function()
	EndIt()
end

testDM.AdminEndMatch = function(pid)
	if Players[pid]:IsAdmin() then
		testDM.EndMatch()
	end
end

testDM.statuscheck = function(pid)
	status = Players[pid].data.mwTDM.status
	tes3mp.SendMessage(pid, color.Green ..status.. "\n")
end

testDM.healtest = function(pid)
	RespawnResting(pid)
end

testDM.resurrectcheck = function(pid)
	tes3mp.Resurrect(pid, 0)
end

testDM.oops = function(pid)
	testDM.PlayerInit(pid)
end

testDM.lastspawn = function(pid) -- not sure what this is. seems to be a function from the original version, or no, it was made to try to figure out how to do spawn locations, and may not be needed at the moment.
	tes3mp.SendMessage(pid, color.Red .. "Lastpawn is " ..spawnlocation.. "\n")
end

-- custom validators
customEventHooks.registerValidator("OnPlayerDeath", function(eventStatus, pid)
	-- this makes it so that default resurrect for player does not happen but custom handler for player death does get executed
	return customEventHooks.makeEventStatus(false,true)
end)

--[[customEventHooks.registerValidator("ProcessDeath", function(eventStatus, pid)
	-- this makes it so that default resurrect for player does not happen but custom handler for player death does get executed
	return customEventHooks.makeEventStatus(false,true)
end)]]

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

customCommandHooks.registerCommand("oops", testDM.oops)
customCommandHooks.registerCommand("resurrect", testDM.resurrectcheck)
customCommandHooks.registerCommand("status", testDM.statuscheck)
customCommandHooks.registerCommand("lastspawn", testDM.lastspawn)
customCommandHooks.registerCommand("score", testDM.ShowScore)
customCommandHooks.registerCommand("forceend", testDM.AdminEndMatch)
customCommandHooks.registerCommand("end", testDM.EndMatch)
customCommandHooks.registerCommand("death", testDM.ProcessDeath)


return testDM