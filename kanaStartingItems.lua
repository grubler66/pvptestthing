-- kanaStartingItems - Release 2 - For tes3mp 0.7-alpha
-- Grant newly created characters some configurable starting items based on their race, class, skills, favored armor, and birthsign

--[[ INSTALLATION:
1) Save this file as "kanaStartingItems.lua" in server/scripts/custom
2) Add [ kanaStartingItems = require("custom.kanaStartingItems") ] to customScripts.lua
]]

--[[ NOTES:
Things this doesn't care about/support:
- Major skills
- Minor skills
- Beast race difference
- Random tables
- Any nuances of an item beyond the item and how many (so no partially-damaged items, or soulgems enchanted with a specific soul)
]]

local scriptConfig = {}
-- The skill level thresholds used to determine when to award items based on skill
-- By default they align to the minimum skill level that picking major/minor skills will give a character
scriptConfig.highSkillThreshold = 30
scriptConfig.lowSkillThreshold = 15

-- The following two options govern whether the player should be notified that they've been given extra items.
scriptConfig.informPlayers = true -- If true, players will be told that they've been given extra starting items
scriptConfig.message = "Extra items given based on your character." -- The message that they're given if informPlayers is true

-- The last remaining options are all configuration options that you can use to dictate what items players receive based on each category of criteria
-- Some examples are included for each, though you can edit/remove what you don't want
-- You'll need some knowledge about how lua tables work to make the edits, though you might be able to intuit what to do from the examples.

-- Items given to a player based on their race
scriptConfig.raceItems = {
	--[[["khajiit"] = {
		{refId = "ingred_moon_sugar_01", count = 3},
		{refId = "apparatus_a_spipe_01", count = 1},
	},]]
}

-- Items given to a player based on their class
-- Note that only non-custom classes are supported with this
scriptConfig.classItems = {
	--[[["thief"] = {
		{refId = "pick_apprentice_01", count = 1},
		{refId = "probe_apprentice_01", count = 1},
	},]]
}

-- Items given to a player based on their high skills (as determined by scriptConfig.highSkillThreshold)
-- Note that if a character's skill is deemed as a "high skill", it ISN'T also counted as a low skill
scriptConfig.highSkillItems = {
	--["acrobatics"] = {
--		{refId = "hoptoad ring", count = 1},

["axe"] = {
		{refId = "test chitin war axe", count = 1},
}, 

["shortblade"] = {
		{refId = "imperial shortsword", count = 1},
},

["bluntweapon"] = {
		{refId = "iron mace", count = 1},
},

["longblade"] = {
		{refId = "iron broadsword", count = 1},
},

["spear"] = {
		{refId = "test chitin spear", count = 1},
	},

	["marksman"] = {
		{refId = "test chitin short bow", count = 1},
		{refId = "test chitin arrow", count = 30},
	},


	["armorer"] = {
		{refId = "hammer_repair", count = 1},
	},


["security"] = {
		{refId = "amulet of locking", count = 1},
		
},

--[[["sneak"] = {
	{refId = "chameleon ring", count = 1},
},]]

["alchemy"] = {
	{refId = "apparatus_a_mortar_01", count = 1},
},

["block"] = {
	{refId = "test netch_leather_shield", count = 1},
},

}

-- Items given to a player based on their low skills (as determined by scriptConfig.lowSkillThreshold)
-- Note that if a character's skill is deemed as a "low skill", it ISN'T also counted as a high skill
scriptConfig.lowSkillItems = {
	["marksman"] = {
		{refId = "test chitin throwing star", count = 5},
	},

	["block"] = {
		{refId = "test netch_leather_shield", count = 1},
	},

	["bluntweapon"] = {
		{refId = "iron club", count = 1},
	},

	["axe"] = {
		{refId = "test chitin war axe", count = 1},
	},

	["spear"] = {
		{refId = "test chitin spear", count = 1},
	},

	["lightarmor"] = {
		{refId = "test chitin cuirass", count = 1},
		--{refId = "chitin pauldron - left", count = 1},
		--{refId = "chitin pauldron - right", count = 1},
	},

	["heavyarmor"] = {
		{refId = "iron_greaves", count = 1},
		--{refId = "iron_bracer_left", count = 1},
		--{refId = "iron_bracer_right", count = 1},
	},

	["mediumarmor"] = {
		{refId = "test imperial_chain_greaves", count = 1},
	},

}

-- Items given to a player based on their highest armor skill.
-- Note that if two skills are equal, the highest armor skill is picked arbitrarily
-- Armor skills are: heavyarmor, mediumarmor, lightarmor, unarmored
scriptConfig.armorItems = {
	["heavyarmor"] = {
		{refId = "iron_cuirass", count = 1},
		--{refId = "iron_greaves", count = 1},
	},

	["lightarmor"] = {
		{refId = "test chitin cuirass", count = 1},
		--{refId = "chitin greaves", count = 1},
	},

	["mediumarmor"] = {
		{refId = "test imperial_chain_cuirass", count = 1},
		--{refId = "imperial_chain_greaves", count = 1},
	},

}

-- Items given to players based on their birthsign
scriptConfig.birthsignItems = {
	--[[["wombburned"] = {
		{refId = "p_restore_magicka_c", count = 3},
	},]]
}

-- General items are given to every player
scriptConfig.generalItems = {
{refId = "gold_001", count = 150},
{refId = "test chitin dagger", count = 1},

--{refId = "light_com_candle_10_128", count = 1},
--{refId = "Potion_Cyro_Whiskey_01", count = 1},
--{refId = "pick_apprentice_01", count = 1},
--{refId = "ring_keley", count = 1},

}

---------------------------------------------------------------------------------------
local Methods = {}

local RaceItems = {}
local ClassItems = {}
local HighSkillItems = {}
local LowSkillItems = {}
local ArmorItems = {}
local BirthsignItems = {}
local GeneralItems = {}

inventoryHelper = require("inventoryHelper")
-------------
Methods.RegisterRacialItem = function(raceId, itemRefId, count)
	local raceId = string.lower(raceId)
	
	-- Create main table if it doesn't exist
	if RaceItems[raceId] == nil then RaceItems[raceId] = {} end
	
	table.insert(RaceItems[raceId], {refId = itemRefId, count = (count or 1)})
end

Methods.RegisterClassItem = function(className, itemRefId, count)
	local className = string.lower(className)
	
	-- Create main table if it doesn't exist
	if ClassItems[className] == nil then ClassItems[className] = {} end
	
	table.insert(ClassItems[className], {refId = itemRefId, count = (count or 1)})
end


Methods.RegisterHighSkillItem = function(skillName, itemRefId, count)
	local skillName = string.lower(skillName)
	
	-- Create main table if it doesn't exist
	if HighSkillItems[skillName] == nil then HighSkillItems[skillName] = {} end
	
	table.insert(HighSkillItems[skillName], {refId = itemRefId, count = (count or 1)})
end

Methods.RegisterLowSkillItem = function(skillName, itemRefId, count)
	local skillName = string.lower(skillName)
	
	-- Create main table if it doesn't exist
	if LowSkillItems[skillName] == nil then LowSkillItems[skillName] = {} end
	
	table.insert(LowSkillItems[skillName], {refId = itemRefId, count = (count or 1)})
end

Methods.RegisterArmorItem = function(armorType, itemRefId, count)
	local armorType = string.lower(armorType)
	
	-- Create main table if it doesn't exist
	if ArmorItems[armorType] == nil then ArmorItems[armorType] = {} end
	
	table.insert(ArmorItems[armorType], {refId = itemRefId, count = (count or 1)})
end

Methods.RegisterBirthsignItem = function(birthsignId, itemRefId, count)
	local birthsignId = string.lower(birthsignId)
	
	-- Create main table if it doesn't exist
	if BirthsignItems[birthsignId] == nil then BirthsignItems[birthsignId] = {} end
	
	table.insert(BirthsignItems[birthsignId], {refId = itemRefId, count = (count or 1)})
end

Methods.RegisterGeneralItem = function(itemRefId, count)
	table.insert(GeneralItems, {refId = itemRefId, count = (count or 1)})
end

-------------
local function addItem(pid, refId, count)
	local inventory = Players[pid].data.inventory
	
	inventoryHelper.addItem(inventory, refId, (count or 1), -1, -1, "")
end

Methods.OnCharacterCreated = function(eventStatus, pid)
	local gaveItems = false --Used to detemine if the script has given the player any items

	-- Add racial items
	local playerRace = string.lower(Players[pid].data.character.race)
	
	if RaceItems[playerRace] ~= nil then
		for index, itemInfo in ipairs(RaceItems[playerRace]) do
			addItem(pid, itemInfo.refId, itemInfo.count)
		end
		
		gaveItems = true
	end
	
	-- Add class items
	local playerClass = string.lower(Players[pid].data.character.class)
	
	if playerClass ~= "custom" and ClassItems[playerClass] ~= nil then
		for index, itemInfo in ipairs(ClassItems[playerClass]) do
			addItem(pid, itemInfo.refId, itemInfo.count)
		end
		
		gaveItems = true
	end
	
	-- Do skill stuff
	local highSkills = {}
	local lowSkills = {}
	
	local bestArmorSkill
	local bestArmorSkillLevel = -1
	
	local armorSkills = {mediumarmor = true, heavyarmor = true, lightarmor = true, unarmored = true}
	
	for skillId, skillInfo in pairs(Players[pid].data.skills) do
		local skillId = string.lower(skillId)
		local level = skillInfo.base
		
		if level >= scriptConfig.highSkillThreshold then
			-- Skill is a high skill, add it to the list
			table.insert(highSkills, skillId)
		elseif level >= scriptConfig.lowSkillThreshold then
			-- Skill is a low skill, add it to the list
			table.insert(lowSkills, skillId)
		end
		
		-- Do checks to determine the best armor skill
		-- Check if is armor skill...
		if armorSkills[skillId] then 
			-- If it is, then determine if it's higher than the previously recorded one
			-- No tiebreakers
			if level > bestArmorSkillLevel then
				-- It's higher, so record it as the best so far
				bestArmorSkill = skillId
				bestArmorSkillLevel = level
			end
		end
	end
	
	-- Add high skill items
	for index, skillId in ipairs(highSkills) do
		if HighSkillItems[skillId] ~= nil then
			for index, itemInfo in ipairs(HighSkillItems[skillId]) do
				addItem(pid, itemInfo.refId, itemInfo.count)
			end
			
			gaveItems = true
		end
	end
	
	-- Add low skill items
	for index, skillId in ipairs(lowSkills) do
		if LowSkillItems[skillId] ~= nil then
			for index, itemInfo in ipairs(LowSkillItems[skillId]) do
				addItem(pid, itemInfo.refId, itemInfo.count)
			end
			
			gaveItems = true
		end
	end
	
	-- Add armor items
	-- The player's best armor skill was determined during the skill loop earlier
	if ArmorItems[bestArmorSkill] ~= nil and bestArmorSkillLevel >= 15 then
		for index, itemInfo in ipairs(ArmorItems[bestArmorSkill]) do
			addItem(pid, itemInfo.refId, itemInfo.count)

		end
	
		gaveItems = true
	end
	
	-- Add birthsign items
	local playerBirthsign = string.lower(Players[pid].data.character.birthsign)
	
	if BirthsignItems[playerBirthsign] ~= nil then
		for index, itemInfo in ipairs(BirthsignItems[playerBirthsign]) do
			addItem(pid, itemInfo.refId, itemInfo.count)
		end
		
		gaveItems = true
	end
	
	-- Add general items
	for index, itemInfo in ipairs(GeneralItems) do
		addItem(pid, itemInfo.refId, itemInfo.count)
		
		gaveItems = true
	end



	-- Update the player's inventory
	-- Note that we should really be using the item adding function, but there's no harm in being messy and doing it this way :P
	Players[pid]:LoadInventory()
	Players[pid]:LoadEquipment() -- Used to be required, otherwise the player spawns naked. Not sure if it's needed but I'm including it here just in case
	Players[pid]:SaveLogin()
    Players[pid]:SaveCharacter()
    Players[pid]:SaveClass(packetReader.GetPlayerPacketTables(pid, "PlayerClass"))
    Players[pid]:SaveStatsDynamic(packetReader.GetPlayerPacketTables(pid, "PlayerStatsDynamic"))
    Players[pid]:SaveEquipment(packetReader.GetPlayerPacketTables(pid, "PlayerEquipment"))
    Players[pid]:SaveIpAddress()
    Players[pid]:CreateAccount()
	--logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "test chitin dagger" 1')
	--logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "Gold_001" 100')
	testDM.PlayerInit2(pid)
	Players[pid]:Save()
	--[[Hpotions(pid)
	Mpotions(pid)
	Fpotions(pid)]]
	if bestArmorSkillLevel < 21 --[[and Players[pid].data.skills.unarmored.base < 21]] then
	--logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "first barrier belt" 1')
	end
	-- Send the player a message that they've been given some extra starting items, if configured to do so
	if scriptConfig.informPlayers and gaveItems then
		tes3mp.SendMessage(pid, scriptConfig.message .. "\n")
	end
	--[[local nameon = Players[pid].data.login.name
	for pid, p in pairs(Players) do -- Iterate through all players and start assigning teams
		if p ~= nil and p:IsLoggedIn() then

				tes3mp.SendMessage(pid, color.Yellow .. nameon .. " has joined the game! \n", false)
		end
	end]]

end

-----------------------------------------------------------------------

--[[function Hpotions(pid)
	
	getPlayerItemCount(pid, "p_restore_health_s")

	if getPlayerItemCount(pid,"p_restore_health_s") == 1 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "p_restore_health_s" 1')
	elseif getPlayerItemCount(pid,"p_restore_health_s") == 0 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "p_restore_health_s" 2')
	elseif getPlayerItemCount(pid,"p_restore_health_s") >= 2 then
		return
	end
end

function Mpotions(pid)
	
	getPlayerItemCount(pid, "p_restore_magicka_s")

	if getPlayerItemCount(pid,"p_restore_magicka_s") == 1 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "p_restore_magicka_s" 1')
	elseif getPlayerItemCount(pid,"p_restore_magicka_s") == 0 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "p_restore_magicka_s" 2')
	elseif getPlayerItemCount(pid,"p_restore_magicka_s") >= 2 then
		return
	end
end

function Fpotions(pid)
	
	getPlayerItemCount(pid, "p_restore_fatigue_s")

	if getPlayerItemCount(pid,"p_restore_fatigue_s") == 1 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "p_restore_fatigue_s" 1')
	elseif getPlayerItemCount(pid,"p_restore_fatigue_s") == 0 then
		logicHandler.RunConsoleCommandOnPlayer(pid, 'player->AddItem "p_restore_fatigue_s" 2')
	elseif getPlayerItemCount(pid,"p_restore_fatigue_s") >= 2 then
		return
	end
end]]


	 function getPlayerItemCount(pid, itemid)
		local itemLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, itemid, -1)
		
		if itemLoc then
			return Players[pid].data.inventory[itemLoc].count
		else
			return 0
		end
	end

------------------------------------------------------------------------------------------------------------------

Methods.Init = function()
	-- Load all of the information that the user entered in the scriptconfig
	
	-- Race Items
	for raceId, itemList in pairs(scriptConfig.raceItems) do
		for index, itemInfo in ipairs(itemList) do
			Methods.RegisterRacialItem(raceId, itemInfo.refId, (itemInfo.count or 1))
		end
	end
	
	-- Class Items
	for classId, itemList in pairs(scriptConfig.classItems) do
		for index, itemInfo in ipairs(itemList) do
			Methods.RegisterClassItem(classId, itemInfo.refId, (itemInfo.count or 1))
		end
	end
	
	-- High Skill Items
	for skillId, itemList in pairs(scriptConfig.highSkillItems) do
		for index, itemInfo in ipairs(itemList) do
			Methods.RegisterHighSkillItem(skillId, itemInfo.refId, (itemInfo.count or 1))
		end
	end
	
	-- Low Skill Items
	for skillId, itemList in pairs(scriptConfig.lowSkillItems) do
		for index, itemInfo in ipairs(itemList) do
			Methods.RegisterLowSkillItem(skillId, itemInfo.refId, (itemInfo.count or 1))
		end
	end
	
	-- Birthsign Items
	for birthsignId, itemList in pairs(scriptConfig.birthsignItems) do
		for index, itemInfo in ipairs(itemList) do
			Methods.RegisterBirthsignItem(birthsignId, itemInfo.refId, (itemInfo.count or 1))
		end
	end
	
	-- Armor Items
	for armorTypeId, itemList in pairs(scriptConfig.armorItems) do
		for index, itemInfo in ipairs(itemList) do
			Methods.RegisterArmorItem(armorTypeId, itemInfo.refId, (itemInfo.count or 1))
		end
	end
	
	-- General Items
	for index, itemInfo in ipairs(scriptConfig.generalItems) do
		Methods.RegisterGeneralItem(itemInfo.refId, (itemInfo.count or 1))
	end
	
end
-------------
customEventHooks.registerHandler("OnServerPostInit", Methods.Init)
customEventHooks.registerHandler("OnPlayerEndCharGen", Methods.OnCharacterCreated)
-------------
return Methods