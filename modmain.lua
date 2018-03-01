PrefabFiles = {
	"followers",
	"followerskull", --skulls need RoG
	"ynalucy",
	"ynalighter",
	"ynabooks",
	"ynaabigail",
	"ynaabigail_flower",
}
 
local Assets =
{
}

local STRINGS = GLOBAL.STRINGS
local TUNING = GLOBAL.TUNING
local ACTIONS = GLOBAL.ACTIONS
local require = GLOBAL.require

--[[ADD SPEECH FOR CHARACTERS]]
STRINGS.CHARACTERS.YNAWILSON = require "speech_wilson"
STRINGS.CHARACTERS.YNAWAXWELL = require "speech_maxwell"
STRINGS.CHARACTERS.YNAWOLFGANG = require "speech_wolfgang"
STRINGS.CHARACTERS.YNAWX78 = require "speech_wx78"
STRINGS.CHARACTERS.YNAWILLOW = require "speech_willow"
STRINGS.CHARACTERS.YNAWENDY = require "speech_wendy"
STRINGS.CHARACTERS.YNAWOODIE = require "speech_woodie"
STRINGS.CHARACTERS.YNAWICKERBOTTOM = require "speech_wickerbottom"
STRINGS.CHARACTERS.WATHGRITHR = require "speech_wathgrithr"
STRINGS.CHARACTERS.WEBBER = require "speech_webber"
STRINGS.CHARACTERS.WALANI = require "speech_walani"
STRINGS.CHARACTERS.WARLY = require "speech_warly"
STRINGS.CHARACTERS.WILBUR = require "speech_wilbur"
STRINGS.CHARACTERS.WOODLEGS = require "speech_woodlegs"

-- [[ SITFOLLOWERCOMMAND BEGIN ]] -- 
STRINGS.ACTIONS.SITCOMMAND = "Order to Wait"
STRINGS.ACTIONS.SITCOMMAND_CANCEL = "Order to Follow"
STRINGS.ACTIONS.DROPCOMMAND = "Order to Drop items"

STRINGS.CHARACTERS.GENERIC.ANNOUNCE_SITCOMMAND = "Wait right here."
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_SITCOMMAND_CANCEL = "Okay, follow me."
STRINGS.CHARACTERS.GENERIC.ANNOUNCE_DROPCOMMAND = "Show me everything you have."
STRINGS.CHARACTERS.WX78.ANNOUNCE_SITCOMMAND = "STOP"
STRINGS.CHARACTERS.WX78.ANNOUNCE_SITCOMMAND_CANCEL = "FOLLOW"

ACTIONS.SITCOMMAND = GLOBAL.Action(2, true, true)
ACTIONS.SITCOMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.followersitcommand then
		act.doer.components.locomotor:Stop()
		act.doer.components.talker:Say(GLOBAL.GetString(act.doer.prefab, "ANNOUNCE_SITCOMMAND"))
		if not targ.components.unteleportable then 
			targ:AddComponent("unteleportable") 
		end
		targ.components.followersitcommand:SetStaying(true)
		targ.components.followersitcommand:RememberSitPos("currentstaylocation", GLOBAL.Point(targ.Transform:GetWorldPosition()))
		return true
	end
end
ACTIONS.SITCOMMAND.str = STRINGS.ACTIONS.SITCOMMAND
ACTIONS.SITCOMMAND.id = "SITCOMMAND"

ACTIONS.SITCOMMAND_CANCEL = GLOBAL.Action(2, true, true)
ACTIONS.SITCOMMAND_CANCEL.fn = function(act)
	local targ = act.target
	if targ and targ.components.followersitcommand then
		act.doer.components.locomotor:Stop()
		act.doer.components.talker:Say(GLOBAL.GetString(act.doer.prefab, "ANNOUNCE_SITCOMMAND_CANCEL"))
		targ:RemoveComponent("unteleportable")
		targ.components.followersitcommand:SetStaying(false)
		return true
	end
end
ACTIONS.SITCOMMAND_CANCEL.str = STRINGS.ACTIONS.SITCOMMAND_CANCEL
ACTIONS.SITCOMMAND_CANCEL.id = "SITCOMMAND_CANCEL"

ACTIONS.DROPCOMMAND = GLOBAL.Action(2, true, true)
ACTIONS.DROPCOMMAND.fn = function(act)
	local targ = act.target
	if targ then
		act.doer.components.locomotor:Stop()
		act.doer.components.talker:Say(GLOBAL.GetString(act.doer.prefab, "ANNOUNCE_DROPCOMMAND"))

		targ.components.inventory:DropEverything()		
		return true
	end
end
ACTIONS.DROPCOMMAND.str = STRINGS.ACTIONS.DROPCOMMAND
ACTIONS.DROPCOMMAND.id = "DROPCOMMAND"

-- [[ WOODIE BEGIN ]] -- 
STRINGS.YNAWOODIE = {}
STRINGS.YNAWOODIE.HURT = "I'm dying."
STRINGS.YNAWOODIE.NOAXE = "I've already got Lucy."
		
STRINGS.NAMES.YNAWOODIE = "Woodie"

STRINGS.NAMES.YNALUCY = "Lucy the Axe"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUCY = "That's a prettier axe than I'm used to."

STRINGS.NAMES.YNAWOODIESKULL = "Woodie's skull."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YNAWOODIESKULL = "Poor Woodie... I must bury him."

-- [[ WILLOW BEGIN ]] -- 
STRINGS.NAMES.YNAWILLOW = "Willow"

STRINGS.NAMES.YNALIGHTER = "Willow's Lighter"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIGHTER = "It's her lucky lighter."

STRINGS.NAMES.YNAWILLOWSKULL = "Willow's skull."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YNAWILLOWSKULL = "Poor Willow... I must bury her."

-- [[ WOLFGANG BEGIN ]] -- 	
STRINGS.NAMES.YNAWOLFGANG = "Wolfgang"
STRINGS.NAMES.YNAWOLFGANGSKULL = "Wolfgang's skull."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YNAWOLFGANGSKULL = "Poor Wolfgang... I must bury him."

-- [[ WICKERBOTTOM BEGIN ]] -- 
STRINGS.NAMES.YNAWICKERBOTTOM = "Wickerbottom"
STRINGS.NAMES.YNAWICKERBOTTOMSKULL = "Wickerbottom's skull."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YNAWICKERBOTTOMSKULL = "Poor Wickerbottom... I must bury her."

STRINGS.NAMES.YNABOOK_BIRDS = "Birds of the World"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_BIRDS = "No point studying when I can just wing it."

STRINGS.NAMES.YNABOOK_BRIMSTONE = "The End is Nigh!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_BRIMSTONE = "The beginning was dull, but got better near the end."

STRINGS.NAMES.YNABOOK_SLEEP = "Sleepytime Stories"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_SLEEP = "Strange, it's just 500 pages of telegraph codes."

STRINGS.NAMES.YNABOOK_GARDENING = "Applied Horticulture"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_GARDENING = "I see no farm in reading that."

STRINGS.NAMES.YNABOOK_TENTACLES = "On Tentacles"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_TENTACLES = "Someone'll get suckered into reading this."

-- [[ WX78 BEGIN ]] -- 	
STRINGS.NAMES.YNAWX78 = "WX-78"
STRINGS.NAMES.YNAWX78SKULL = "WX-78's skull."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YNAWX78SKULL = "Poor WX-78... I must bury him."

-- [[ WES BEGIN ]] -- 	
STRINGS.NAMES.YNAWES = "Wes"
STRINGS.NAMES.YNAWESSKULL = "Wes's skull."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YNAWESSKULL = "Poor Wes... I must bury him."

-- [[ WENDY BEGIN ]] -- 	
STRINGS.NAMES.YNAWENDY = "Wendy"

STRINGS.NAMES.YNAABIGAIL_FLOWER = "Abigail's Flower"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ABIGAIL_FLOWER = 
		{ 
			GENERIC ="It's hauntingly beautiful.",
			LONG = "It hurts my soul to look at that thing.",
			MEDIUM = "It's giving me the creeps.",
			SOON = "Something is up with that flower!",
			HAUNTED_POCKET = "I don't think I should hang on to this.",
			HAUNTED_GROUND = "I'd die to find out what it does.",
		}
STRINGS.NAMES.YNAABIGAIL = "Abigail"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ABIGAIL = "Awww, she has a cute little bow."

STRINGS.NAMES.YNAWENDYSKULL = "Wendy's skull."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YNAWENDYSKULL = "Poor Wendy... I must bury her."

-- [[ WILSON BEGIN ]] -- 	
STRINGS.NAMES.YNAWILSON = "Wilson"
STRINGS.NAMES.YNAWILSONSKULL = "Wilson's skull."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YNAWILSONSKULL = "Poor Wilson... I must bury him."

-- [[ SHARED OVERWRITES BEGIN ]] --
function addLightningStrikeToFollowers(inst)
	inst.DoLightningStrike = function(self, pos, ignoreRods)
		local rod = nil
		local player = nil
		if not ignoreRods then
			local rods = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 40, {"lightningrod"}, {"dead"})
			for k,v in pairs(rods) do -- Find nearby lightning rods, prioritize battery-charging rods and closer rods
				if not rod or (v.lightningpriority > rod.lightningpriority or GLOBAL.distsq(pos, Vector3(v.Transform:GetWorldPosition())) < GLOBAL.distsq(pos, GLOBAL.Vector3(rod.Transform:GetWorldPosition()))) then
					rod = v
				end
			end			
		end
		
		local followers = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 10, {"summonedbyplayer"})
		for k,v in pairs(followers) do 
			if not follower or GLOBAL.distsq(pos, GLOBAL.Vector3(v.Transform:GetWorldPosition())) < GLOBAL.distsq(pos, GLOBAL.Vector3(follower.Transform:GetWorldPosition())) then
				follower = v
			end
		end
		local rand = math.random()
		if rod then
			pos = GLOBAL.Vector3(rod.Transform:GetWorldPosition() )
		elseif follower and rand <= follower.components.playerlightningtarget:GetHitChance() then
			pos = GLOBAL.Vector3(follower.Transform:GetWorldPosition()) 
		elseif GLOBAL.GetPlayer().components.playerlightningtarget 
		  and rand <= GLOBAL.GetPlayer().components.playerlightningtarget:GetHitChance() then
			player = GLOBAL.GetPlayer()
			pos = GLOBAL.Vector3(GLOBAL.GetPlayer().Transform:GetWorldPosition() )
		end

		local lightning = GLOBAL.SpawnPrefab("lightning")
		lightning.Transform:SetPosition(pos:Get())

		if rod then
			rod:PushEvent("lightningstrike", {rod=rod})
		else
			if player then
				player.components.playerlightningtarget:DoStrike()
			elseif follower and rand <= follower.components.playerlightningtarget:GetHitChance() then
				follower.components.playerlightningtarget:DoStrike()
			end
			local ents = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 3)
			for k,v in pairs(ents) do 
				if not v:IsInLimbo() then
					if v.components.burnable and not v.components.fueled and not v.components.burnable.lightningimmune then
						v.components.burnable:Ignite()
					end
				end
			end
		end
	end
end
AddComponentPostInit("seasonmanager", addLightningStrikeToFollowers)

function adjustGuarantee(inst)
	inst.GuaranteeItems = function(self, items)

		self.inst:DoTaskInTime(0,function()
			for k,v in pairs(items) do
				local item = v
				
				local equipped = false
				for k,v in pairs (self.equipslots) do
					if v and v.prefab == item then
						equipped = true
					end
				end

				if self == GLOBAL.GetPlayer() and (equipped or self:Has(item, 1)) then
					for k,v in pairs(Ents) do
						if v.prefab == item and v.components.inventoryitem:GetGrandOwner() ~= GetPlayer() then
							v:Remove()
						end
					end
				else
					for k,v in pairs(GLOBAL.Ents) do
						if v.prefab == item then
							item = nil
							break
						end
					end
					if item then
						self:GiveItem(GLOBAL.SpawnPrefab(item))
					end
				end
			end
		end)
	end
end
AddComponentPostInit("inventory", adjustGuarantee)

function removeDistortionFromFollower(inst)
	inst.OnUpdate = function(self, dt)
		if self.inst:HasTag("player") then	
			local t = 1 - self:GetPercent()
			local b = 0
			local c = .2
			local d =1
			t = t / d
			local speed = -c * t * (t - 2) + b
			self.fxtime = self.fxtime + dt*speed
			
			GLOBAL.PostProcessor:SetEffectTime(self.fxtime)
		
			t = self:GetPercent()
			c = 1
			t = t / d
			local distortion_value = -c * t * (t - 2) + b
			GLOBAL.PostProcessor:SetDistortionFactor(distortion_value)
			GLOBAL.PostProcessor:SetDistortionRadii( 0.5, 0.685 )
		end

		if self.inst.components.health.invincible == true or self.inst.is_teleporting == true then
			return
		end
		
		self:Recalc(dt)	
	end
end
AddComponentPostInit("sanity", removeDistortionFromFollower)

function addFollowerDamageResist(inst)
	inst.CalcDamage = function(self, target, weapon, multiplier)
		if target:HasTag("alwaysblock") then
			return 0
		end
		local multiplier = multiplier or self.damagemultiplier or 1
		local bonus = self.damagebonus or 0
		if weapon then
			local weapondamage = 0
			if weapon.components.weapon.variedmodefn then
				local d = weapon.components.weapon.variedmodefn(weapon)
				weapondamage = d.damage        
			else
				weapondamage = weapon.components.weapon.damage
			end
			if not weapondamage then weapondamage = 0 end
			return weapondamage*multiplier + bonus
		end
		
		if target and (target:HasTag("player") or target:HasTag("summonedbyplayer")) then
			return self.defaultdamage * self.playerdamagepercent * multiplier + bonus
		end
		
		return self.defaultdamage * multiplier + bonus
	end
end
AddComponentPostInit("combat", addFollowerDamageResist)

function RemoveSelfBurn(inst)
	inst.components.weapon:SetAttackCallback(nil)
end
AddPrefabPostInit("torch", RemoveSelfBurn)

--overwrite GIVE action to have higher priority than attack=2
ACTIONS.GIVE.priority = 4

-- add tradable component to various gear
function AddTradable(inst)
	if not inst.components.tradable then
		inst:AddComponent("tradable")
	end
end
AddPrefabPostInit("axe", AddTradable)
AddPrefabPostInit("goldenaxe", AddTradable)
AddPrefabPostInit("armor_sanity", AddTradable)
AddPrefabPostInit("umbrella", AddTradable)
AddPrefabPostInit("grass_umbrella", AddTradable)
AddPrefabPostInit("hambat", AddTradable)
AddPrefabPostInit("spear", AddTradable)
AddPrefabPostInit("tentaclespike", AddTradable)
AddPrefabPostInit("nightsword", AddTradable)
AddPrefabPostInit("torch", AddTradable)
AddPrefabPostInit("armorwood", AddTradable)
AddPrefabPostInit("pickaxe", AddTradable)
AddPrefabPostInit("goldenpickaxe", AddTradable)
AddPrefabPostInit("blowdart_sleep", AddTradable)
AddPrefabPostInit("blowdart_fire", AddTradable)
AddPrefabPostInit("blowdart_pipe", AddTradable)
AddPrefabPostInit("boomerang", AddTradable)
AddPrefabPostInit("ice_projectile", AddTradable)
AddPrefabPostInit("fire_projectile", AddTradable)
AddPrefabPostInit("fishingrod", AddTradable)
AddPrefabPostInit("bugnet", AddTradable)
AddPrefabPostInit("hammer", AddTradable)
AddPrefabPostInit("shovel", AddTradable)
AddPrefabPostInit("goldenshovel", AddTradable)
AddPrefabPostInit("pitchfork", AddTradable)
AddPrefabPostInit("cane", AddTradable)
AddPrefabPostInit("armormarble", AddTradable)
AddPrefabPostInit("armorgrass", AddTradable)
AddPrefabPostInit("sweatervest", AddTradable)
AddPrefabPostInit("trunkvest_summer", AddTradable)
AddPrefabPostInit("trunkvest_winter", AddTradable)
AddPrefabPostInit("armorsnurtleshell", AddTradable)
AddPrefabPostInit("ynalighter", AddTradable)
AddPrefabPostInit("nightlight", AddTradable)
AddPrefabPostInit("batbat", AddTradable)
AddPrefabPostInit("ynalucy", AddTradable)
AddPrefabPostInit("bluegem", AddTradable)
AddPrefabPostInit("redgem", AddTradable)
AddPrefabPostInit("armorruins", AddTradable)
AddPrefabPostInit("armorslurper", AddTradable)
AddPrefabPostInit("multitool_axe_pickaxe", AddTradable)
AddPrefabPostInit("ruins_bat", AddTradable)
AddPrefabPostInit("log", AddTradable)
AddPrefabPostInit("cutreeds", AddTradable)
AddPrefabPostInit("bedroll_straw", AddTradable)
AddPrefabPostInit("bedroll_furry", AddTradable)
AddPrefabPostInit("dug_grass", AddTradable)
AddPrefabPostInit("dug_sapling", AddTradable)
AddPrefabPostInit("dug_berrybush", AddTradable)
AddPrefabPostInit("dug_berrybush2", AddTradable)
AddPrefabPostInit("raincoat", AddTradable)
AddPrefabPostInit("ynabook_sleep", AddTradable)
AddPrefabPostInit("ynabook_gardening", AddTradable)
AddPrefabPostInit("ynabook_brimstone", AddTradable)
AddPrefabPostInit("ynabook_birds", AddTradable)
AddPrefabPostInit("ynabook_tentacles", AddTradable)
AddPrefabPostInit("tentaclespots", AddTradable)
AddPrefabPostInit("poop", AddTradable)
AddPrefabPostInit("nightmarefuel", AddTradable)
AddPrefabPostInit("gears", AddTradable)
-- DLC
AddPrefabPostInit("spear_wathgrithr", AddTradable)
AddPrefabPostInit("beargervest", AddTradable)
AddPrefabPostInit("armordragonfly", AddTradable)

local function HearPanFlute(inst, musician, instrument)
	if inst.components.sleeper and not inst:HasTag('summonedbyplayer') then
	    inst.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME)
	end
end

function BlockFollowersFromSleep(inst)
	inst.components.instrument:SetOnHeardFn(HearPanFlute)
end
AddPrefabPostInit("panflute", BlockFollowersFromSleep)



-- overwrite getsavefollowers to ignore followers with unteleportable
GLOBAL.SaveIndex.GetSaveFollowers = function (self, doer)
	local followers = {}

	if doer.components.leader then
		for follower,v in pairs(doer.components.leader.followers) do
			if follower.components.followersitcommand and follower.components.followersitcommand.stay == false then
				local ent_data = follower:GetPersistData()
				table.insert(followers, {prefab = follower.prefab, data = follower:GetPersistData()})
				follower:Remove()
			elseif not follower.components.followersitcommand and not follower.components.unteleportable then
				local ent_data = follower:GetPersistData()
				table.insert(followers, {prefab = follower.prefab, data = follower:GetPersistData()})
				follower:Remove()
			end
		end
	end

	--special case for the chester_eyebone: look for inventory items with followers
	if doer.components.inventory then
		for k,item in pairs(doer.components.inventory.itemslots) do
			if item.components.leader then
				for follower,v in pairs(item.components.leader.followers) do
					local ent_data = follower:GetPersistData()
					table.insert(followers, {prefab = follower.prefab, data = follower:GetPersistData()})
					follower:Remove()
				end
			end
		end

		-- special special case, look inside equipped containers
		for k,equipped in pairs(doer.components.inventory.equipslots) do
			if equipped and equipped.components.container then
				local container = equipped.components.container
				for j,item in pairs(container.slots) do
					if item.components.leader then
						for follower,v in pairs(item.components.leader.followers) do
							local ent_data = follower:GetPersistData()
							table.insert(followers, {prefab = follower.prefab, data = follower:GetPersistData()})
							follower:Remove()
						end
					end
				end
			end
		end
	end

	if self.data~= nil and self.data.slots ~= nil and self.data.slots[self.current_slot] ~= nil then
	 	self.data.slots[self.current_slot].followers = followers
	end	
end

-- if DLC is enabled, enable cover for skeletons and clones wearing cover during rain
if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then
	function modmoisturerate(inst)
		oldmoisturerate = inst.GetMoistureRate
		inst.GetMoistureRate = function(self)
			local oldfunction = oldmoisturerate(self)
			local x,y,z = self.inst.Transform:GetWorldPosition()
			local ents = GLOBAL.TheSim:FindEntities(x,y,z, 4, {'sheltercarrier'} )
			for k,v in pairs(ents) do 
				if v.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) and v.components.inventory:GetEquippedItem( GLOBAL.EQUIPSLOTS.HANDS).prefab == "umbrella" then
					oldfunction = 0
				end
				if v.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) and v.components.inventory:GetEquippedItem( GLOBAL.EQUIPSLOTS.HANDS).prefab == "grass_umbrella" then
					oldfunction = oldfunction * 0.5
				end
			end
			return oldfunction
    		end

	end
	AddComponentPostInit("moisture", modmoisturerate)
end

-- if DLC is enabled, enable cover for skeletons and clones wearing cover during summer
if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then
	function modtemperature(inst)
		oldgetinsulation = inst.GetInsulation
		inst.GetInsulation = function(self)
			local oldfunctionX, oldfunctionY = oldgetinsulation(self)

			local x,y,z = self.inst.Transform:GetWorldPosition()
			local ents = GLOBAL.TheSim:FindEntities(x,y,z, 4, {'sheltercarrier'} )
			for k,v in pairs(ents) do 
				if v.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) and v.components.inventory:GetEquippedItem( GLOBAL.EQUIPSLOTS.HANDS).prefab == "umbrella" then
					oldfunctionY = oldfunctionY + TUNING.INSULATION_MED
				end
				if v.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) and v.components.inventory:GetEquippedItem( GLOBAL.EQUIPSLOTS.HANDS).prefab == "grass_umbrella" then
					oldfunctionY = oldfunctionY + TUNING.INSULATION_MED
				end
			end
			return oldfunctionX, oldfunctionY
    		end

	end
	AddComponentPostInit("temperature", modtemperature)
end


-- wx78 check if covered by umbrella
function modhealthdelta(inst)
	oldhealthdelta = inst.DoDelta
	inst.DoDelta = function(self, amount, overtime, cause, ignore_invincible)
		if cause == "rain" then
			local x,y,z = self.inst.Transform:GetWorldPosition()
			local ents = TheSim:FindEntities(x,y,z, 4, {'sheltercarrier'} )
			for k,v in pairs(ents) do 
				if v.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) and v.components.inventory:GetEquippedItem( GLOBAL.EQUIPSLOTS.HANDS).prefab == "umbrella" then
					return
				end
			end
		end
		oldhealthdelta(self, amount, overtime, cause, ignore_invincible)
	end
end
AddComponentPostInit("health", modhealthdelta)

-- prevent summons told to stay from teleporting after player
function modteleportfollower(inst)
	inst.oldstartleash = inst.StartLeashing
	inst.StartLeashing = function(self)
		self:oldstartleash()
		self.inst:RemoveEventCallback("entitysleep", self.inst.portnearleader)

		self.inst.portnearleader2 = function(self)
			if not (self.components.followersitcommand and self.components.followersitcommand:IsCurrentlyStaying()) then
				self.portnearleader()
			end
		end
		self.inst:ListenForEvent("entitysleep", self.inst.portnearleader2)  
		 
	end
	inst.StopLeashing = function(self)
		if self.inst.portnearleader2 then 
			self.inst:RemoveEventCallback("entitysleep", self.inst.portnearleader2)
		end
	end
end

AddComponentPostInit("follower", modteleportfollower)

