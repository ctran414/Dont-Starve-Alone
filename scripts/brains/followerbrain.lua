require "behaviours/ynafollow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/ynafindlight"
require "behaviours/findheat"
require "behaviours/panic"

local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 10
local SEE_LIGHT_DIST = 20
local SEE_TREE_DIST = 10
local KEEP_CHOPPING_DIST = 15
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8
local SEE_FOOD_DIST = 10
local MAX_PICK_DIST = 10
local MAX_WANDER_DIST = 10

local Follower = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function StartChoppingCondition(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= SEE_TREE_DIST*SEE_TREE_DIST and not GetClock():IsNight() and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and (inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "axe" or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "multitool_axe_pickaxe" or (inst.prefab == "ynawoodie" and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "ynalucy"))
end

local function FindTreeToChopAction(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.CHOP and item.components.growable and item.components.growable.stage == 3 end)
	local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    if target then
        return BufferedAction(inst, target, ACTIONS.CHOP, invObject)
    end
end

local function KeepChoppingAction(inst)
    local time_since_last_action = GetTime() - inst.actionbuffer
	
    if inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_CHOPPING_DIST*KEEP_CHOPPING_DIST and not GetClock():IsNight() and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and (inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "axe" or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "multitool_axe_pickaxe" or (inst.prefab == "ynawoodie" and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "ynalucy")) and time_since_last_action <= 3 then
		return true
	else
		inst.actionbuffer = GetTime()
		return false
	end
end

local function StartMiningCondition(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= SEE_TREE_DIST*SEE_TREE_DIST and not GetClock():IsNight() and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and (inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "pickaxe" or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "multitool_axe_pickaxe")
end

local function FindRockToMineAction(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.MINE end)
	local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    if target then
        return BufferedAction(inst, target, ACTIONS.MINE, invObject)
    end
end

local function KeepMiningAction(inst)
	local time_since_last_action = GetTime() - inst.actionbuffer
	
    if inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_CHOPPING_DIST*KEEP_CHOPPING_DIST and not GetClock():IsNight() and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and (inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "pickaxe" or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "multitool_axe_pickaxe") and time_since_last_action <= 3 then
		return true
	else
		inst.actionbuffer = GetTime()
		return false
	end
end

local function FindFoodAction(inst)
print('food')
    local target = nil

	if inst.sg:HasStateTag("busy") then
		return
	end
    
    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end
    
    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    
    if not target and (not time_since_eat or time_since_eat > 2) then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) 
				if item:GetTimeAlive() < 8 then return false end
				if item.prefab == "mandrake" then return false end
				if not item:IsOnValidGround() then
					return false
				end
				return inst.components.eater:CanEat(item) 
			end)
    end
    if target then
		inst.actionbuffer = GetTime()
        return BufferedAction(inst, target, ACTIONS.EAT)
    end

    if not target and (not time_since_eat or time_since_eat > 2) then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) 
                if not item.components.shelf then return false end
                if not item.components.shelf.itemonshelf or not item.components.shelf.cantakeitem then return false end
                if not item:IsOnValidGround() then
                    return false
                end
                return inst.components.eater:CanEat(item.components.shelf.itemonshelf) 
            end)
    end

    if target then
		inst.actionbuffer = GetTime()
        return BufferedAction(inst, target, ACTIONS.TAKEITEM)
    end

end

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function PickItemAction(inst)
--print('pick')
	if inst.sg:HasStateTag("busy") then
		return
	end

    local time_since_last_action = GetTime() - inst.actionbuffer
	
	local items = {}
	for k = 1,inst.components.inventory.maxslots do
        local v = inst.components.inventory.itemslots[k]
        if v then
			if v.prefab == "cutgrass" then
				table.insert(items, "grass")
			elseif v.prefab == "cutreeds" then
				table.insert(items, "reeds")
			elseif v.prefab == "twigs" then
				table.insert(items, "sapling")
			end
        end
    end
	
	if items and time_since_last_action > 2 then
		local target = FindEntity(inst, SEE_FOOD_DIST, function(item) return has_value(items, item.prefab) and item.components.pickable and item.components.pickable:CanBePicked()
			end)
		if target then
			inst.actionbuffer = GetTime()
			return BufferedAction(inst, target, ACTIONS.PICK)
		end
	end
end

local function PickUpItemAction(inst)
--print('pickup')
	if inst.sg:HasStateTag("busy") then
		return
	end

    local time_since_last_action = GetTime() - inst.actionbuffer
	
	if inst.prefab == 'ynawoodie' and inst.components.inventory:Has('ynalucy',0) and not inst.components.beaverness:IsBeaver() then
		if time_since_last_action > 2 then
			local target = FindEntity(inst, SEE_TREE_DIST, function(item) return item.prefab == 'ynalucy' end)
			if target then
				inst.actionbuffer = GetTime()
				return BufferedAction(inst, target, ACTIONS.PICKUP)
			end
		end
	end
	
	if inst.prefab == 'ynawillow' and inst.components.inventory:Has('ynalighter',0) then
		if time_since_last_action > 2 then
			local target = FindEntity(inst, SEE_TREE_DIST, function(item) return item.prefab == 'ynalighter' end)
			if target then
				inst.actionbuffer = GetTime()
				return BufferedAction(inst, target, ACTIONS.PICKUP)
			end
		end
	end
	
	--print("pickuploop",time_since_last_action)
    local items = {}
	for k = 1,inst.components.inventory.maxslots do
        local v = inst.components.inventory.itemslots[k]
        if v then
            table.insert(items, v.prefab)
        end
    end
	
	if items and time_since_last_action > 2 then
		local target = FindEntity(inst, SEE_FOOD_DIST, function(item) return has_value(items, item.prefab) and item.growtime == nil end)
		if target then
			--print("pickup",target)
			inst.actionbuffer = GetTime()
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end		
	end
end

local function DigAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end

	local time_since_last_action = GetTime() - inst.actionbuffer
	--print('dig',time_since_last_action)
	local items = {}
	for k = 1,inst.components.inventory.maxslots do
		local v = inst.components.inventory.itemslots[k]
		if v then
			if v.prefab == "log" then
				table.insert(items, "evergreen")
				table.insert(items, "evergreen_sparse")
				table.insert(items, "deciduoustree")
			elseif v.prefab == "dug_grass" then
				table.insert(items, "grass")
			elseif v.prefab == "dug_sapling" then
				table.insert(items, "sapling")
			elseif v.prefab == "dug_berrybush" then
				table.insert(items, "berrybush")
			elseif v.prefab == "dug_berrybush2" then
				table.insert(items, "berrybush2")
			else
				table.insert(items, v.prefab)
			end
		end
	end
	
	if time_since_last_action > 3 then
		local target = FindEntity(inst, SEE_TREE_DIST, function(item) return has_value(items, item.prefab) and item.components.workable and item.components.workable.action == ACTIONS.DIG end)
		local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		
		if target then
			inst.actionbuffer = GetTime()
			return BufferedAction(inst, target, ACTIONS.DIG, invObject)
		end
	end
end

local function ReadAction(inst)
    local book = inst.components.inventory:FindItem(function(item) return item.prefab == inst.read end)
    if book then
		inst.read = nil
        return BufferedAction(inst, book, ACTIONS.READ)
    end
end

function Follower:OnStart()
       
    local root = 
		PriorityNode(
		{
			IfNode(function() return self.inst.read end, "Read",
				DoAction(self.inst, ReadAction)),
				
			WhileNode(function() return not self.inst.LightWatcher:IsInLight() end, "IsDark",
                FindLight(self.inst)),
					
            WhileNode(function() return ((self.inst.components.follower.leader ~= nil and 
				self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_CHASE_DIST*MAX_CHASE_DIST and self.inst.components.followersitcommand and 
				self.inst.components.followersitcommand:IsCurrentlyStaying() == false) or self.inst.components.follower.leader == nil) and
				(self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown()) end, "AttackMomentarily",
                ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),
			
			WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
                RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),
			
			IfNode(function() return self.inst.components.temperature:IsFreezing() end, "IsFreezing",
				WhileNode(function() return
					self.inst.components.temperature:GetCurrent() < 20 end, "StayWarm",
					FindHeat(self.inst))),
					
			--IfNode(function() return self.inst.components.hunger:GetPercent() < .5 end, "IsStarving",
			--	DoAction(self.inst, FindFoodAction)),
					
			WhileNode(function() return self.inst.components.follower.leader ~= nil and self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "shovel" and
				self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_PICK_DIST*MAX_PICK_DIST end, "Dig",		
					DoAction(self.inst, DigAction)),
					
			IfNode(function() return StartChoppingCondition(self.inst) end, "Chop", 
				WhileNode(function() return KeepChoppingAction(self.inst) end, "KeepChopping",
					LoopNode{ 
						DoAction(self.inst, FindTreeToChopAction)})),
							
			IfNode(function() return StartMiningCondition(self.inst) end, "Mine", 
				WhileNode(function() return KeepMiningAction(self.inst) end, "KeepMining",
					LoopNode{ 
						DoAction(self.inst, FindRockToMineAction )})),				
			
			IfNode(function() return self.inst.components.follower.leader ~= nil and 
				self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_PICK_DIST*MAX_PICK_DIST end, "PickUp",
					DoAction(self.inst, PickUpItemAction)),
			
			IfNode(function() return self.inst.components.follower.leader ~= nil and 
				self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_PICK_DIST*MAX_PICK_DIST end, "Pick",		
					DoAction(self.inst, PickItemAction)),
			
			IfNode(function() return
				self.inst.components.follower.leader ~= nil and (self.inst.components.followersitcommand and self.inst.components.followersitcommand:IsCurrentlyStaying() == false) or not self.inst.components.followersitcommand end, "FollowLeader",			
				Follow(self.inst, GetLeader, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
			
			--Wander(self.inst, function() return Point(GetPlayer().Transform:GetWorldPosition()) end , MAX_WANDER_DIST),
			
			FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
			
		}, .1)
    
    self.bt = BT(self.inst, root)

end

function Follower:OnInitializationComplete()
    --ACTION_TIME = GetTime()
end

return Follower


