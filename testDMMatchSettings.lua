testDMmaps = require("custom/testDMMaps")

testDMMatchSettings = {}

-- deathmatch in Balmora
testDMMatchSettings.balmora_dm = {}
testDMMatchSettings.balmora_dm.name = "Balmora (deathmatch)"
testDMMatchSettings.balmora_dm.gameMode = "dm"
testDMMatchSettings.balmora_dm.map = testDMMaps.balmora
testDMMatchSettings.balmora_dm.scoreLimit = 10
testDMMatchSettings.balmora_dm.additionalEquipment = {}
testDMMatchSettings.balmora_dm.itemsOnMap = {}

return testDMMatchSettings