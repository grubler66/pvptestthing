testDMmaps = require("custom/testDMMaps")

testDMMatchSettings = {}



-- deathmatch in an tomb
testDMMatchSettings.juno_dm = {}
testDMMatchSettings.juno_dm.name = "juno (deathmatch)"
testDMMatchSettings.juno_dm.gameMode = "dm"
testDMMatchSettings.juno_dm.map = testDMMaps.juno
testDMMatchSettings.juno_dm.scoreLimit = 10
testDMMatchSettings.juno_dm.additionalEquipment = {}
testDMMatchSettings.juno_dm.itemsOnMap = {}


-- deathmatch in an arena
testDMMatchSettings.VArena_dm = {}
testDMMatchSettings.VArena_dm.name = "VArena (deathmatch)"
testDMMatchSettings.VArena_dm.gameMode = "dm"
testDMMatchSettings.VArena_dm.map = testDMMaps.VArena
testDMMatchSettings.VArena_dm.scoreLimit = 10
testDMMatchSettings.VArena_dm.additionalEquipment = {}
testDMMatchSettings.VArena_dm.itemsOnMap = {}


-- deathmatch in a temple
testDMMatchSettings.Mtemple_dm = {}
testDMMatchSettings.Mtemple_dm.name = "Mtemple (deathmatch)"
testDMMatchSettings.Mtemple_dm.gameMode = "dm"
testDMMatchSettings.Mtemple_dm.map = testDMMaps.Mtemple
testDMMatchSettings.Mtemple_dm.scoreLimit = 10
testDMMatchSettings.Mtemple_dm.additionalEquipment = {}
testDMMatchSettings.Mtemple_dm.itemsOnMap = {}



-- deathmatch in a fort
testDMMatchSettings.fort_dm = {}
testDMMatchSettings.fort_dm.name = "fort (deathmatch)"
testDMMatchSettings.fort_dm.gameMode = "dm"
testDMMatchSettings.fort_dm.map = testDMMaps.fort
testDMMatchSettings.fort_dm.scoreLimit = 10
testDMMatchSettings.fort_dm.additionalEquipment = {}
testDMMatchSettings.fort_dm.itemsOnMap = {}

-- deathmatch in a cave
testDMMatchSettings.cave_dm = {}
testDMMatchSettings.cave_dm.name = "cave (deathmatch)"
testDMMatchSettings.cave_dm.gameMode = "dm"
testDMMatchSettings.cave_dm.map = testDMMaps.cave
testDMMatchSettings.cave_dm.scoreLimit = 10
testDMMatchSettings.cave_dm.additionalEquipment = {}
testDMMatchSettings.cave_dm.itemsOnMap = {}

return testDMMatchSettings