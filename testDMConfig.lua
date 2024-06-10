-- file that determines server-wide behaviour

testDMConfig = {}

--------------------------
-- CONFIG/SETTINGS SECTION
--------------------------

-- already includes a lot of variables for functionality that is not yet implemented

-- 0 - random, 1 - rotation, 2 - player vote
testDMConfig.matchSelectionMethod = 1

-- all the matches that can be played on the server
testDMConfig.matchList = {"fort_dm", "cave_dm"}

-- Number of kills required for either team to win
testDMConfig.scoreLimit = 10

-- at which points to teams get notified about the score state
-- for example, both teams get notified if one team is 10, 5, 3, 2 or 1 point away from winning the match
testDMConfig.scoreNotifications = {10, 5, 3, 2, 1}

-- Determines if newly joined player will be put on the team with least players or if player will join the team that is stored in player file
testDMConfig.ensureTeamBalance = true

-- Determines whether players are allowed to manually switch teams
testDMConfig.canSwitchTeams = true

-- do players go to lobby between matches
testDMConfig.enableLobby = false
testDMConfig.lobbyTime = 30

-- spawn time in seconds
testDMConfig.spawnTime = 5

-- determines if players are allowed to wait
testDMConfig.allowWait = false

-- Names of the teams
-- (Change "color.Blue" and "...Brown" in --ProcessDeath)
testDMConfig.teamNames = {"Blue Team", "Brown Team"}

-- colours for teams
testDMConfig.teamColors = {color.RoyalBlue, color.SandyBrown}

-- Each team's  uniforms with format: {shirt, pants, shoes}
testDMConfig.teamUniforms = {{"expensive_shirt_02", "expensive_pants_02", "expensive_shoes_02"}, {"expensive_shirt_01", "expensive_pants_01", "expensive_shoes_01"}}

-- list of possible clothes to be selected from {shirts, pants, shoes}
testDMConfig.possibleClothing = {
{"common_shirt_01", "common_shirt_01_a", "common_shirt_01_e", "common_shirt_01_u", "common_shirt_01_z", "common_shirt_02", "common_shirt_02_h", "common_shirt_02_hh", "common_shirt_02_r", "common_shirt_02_rr", "common_shirt_02_t", "common_shirt_02_tt", "common_shirt_03", "common_shirt_03_b", "common_shirt_03_c", "common_shirt_04", "common_shirt_04_a", "common_shirt_04_b", "common_shirt_04_c", "common_shirt_05", "expensive_shirt_01", "expensive_shirt_01_a", "expensive_shirt_01_e", "expensive_shirt_01_u", "expensive_shirt_01_z", "expensive_shirt_02", "expensive_shirt_03", "extravagant_shirt_01", "extravagant_shirt_01_h", "extravagant_shirt_01_r", "extravagant_shirt_01_t", "extravagant_shirt_02"},
{"common_pants_01", "common_pants_01_a", "common_pants_01_e", "common_pants_01_u", "common_pants_01_z", "common_pants_02", "common_pants_03", "common_pants_03_b", "common_pants_03_c", "common_pants_04", "common_pants_04_b", "common_pants_05", "expensive_pants_01", "expensive_pants_01_a", "expensive_pants_01_e", "expensive_pants_01_u", "expensive_pants_01_z", "expensive_pants_02", "expensive_pants_03", "extravagant_pants_01", "extravagant_pants_02", "exquisite_pants_01"},
{"common_shoes_01", "common_shoes_02", "common_shoes_03", "common_shoes_04", "common_shoes_05", "expensive_shoes_01", "expensive_shoes_02", "expensive_shoes_03", "extravagant_shoes_01", "extravagant_shoes_02", "exquisite_shoes_01"}
}


-- list of default values
-- these are used when match does not specify it's own value
testDMConfig.defaultSettings = {

-- Number of kills required for either team to win
scoreToWin = 6,

-- Determines whether players are allowed to manually switch teams
canSwitchTeams = true,

-- Default spawn time in seconds
spawnTime = 5,

-- Names of the two teams
-- (Change "color.Blue" and "...Brown" in --ProcessDeath)
numberOfTeams = nil,

-- Starting inventory items for both teams
-- (You can add as many items as you want; simply follow the format {"reference ID", count, charge})
playerInventory =  {{}}


}
return testDMConfig
