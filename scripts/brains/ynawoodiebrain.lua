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
local ACTION_TIME = 0

local YnaWoodie = Class(Brain, function(self, inst)
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
    local time_since_pick = GetTime() - ACTION_TIME
	print(time_since_pick)
	
    if inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_CHOPPING_DIST*KEEP_CHOPPING_DIST and not GetClock():IsNight() and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and (inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "axe" or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "multitool_axe_pickaxe" or (inst.prefab == "ynawoodie" and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "ynalucy")) and time_since_pick < 2 then
		return true
	else
		ACTION_TIME = GetTime()
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
    return inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_CHOPPING_DIST*KEEP_CHOPPING_DIST and not GetClock():IsNight()
end

local function FindFoodAction(inst)
    local target = nil

	if inst.sg:HasStateTag("busy") then
		return
	end
    
    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end
    
    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    
    if not target and (not time_since_eat or time_since_eat > 1) then
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
        return BufferedAction(inst, target, ACTIONS.EAT)
    end

    if not target and (not time_since_eat or time_since_eat > 1) then
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
	if inst.sg:HasStateTag("busy") then
		return
	end

    local time_since_pick = GetTime() - ACTION_TIME
	
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
	
	if items and time_since_pick > 1 then
		local target = FindEntity(inst, SEE_FOOD_DIST, function(item) return has_value(items, item.prefab) and item.components.pickable and item.components.pickable:CanBePicked()
			end)
		if target then
			ACTION_TIME = GetTime()
			return BufferedAction(inst, target, ACTIONS.PICK)
		end
	end
end

local function PickUpItemAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end

    local time_since_pick = GetTime() - ACTION_TIME
    
    local items = {}
	for k = 1,inst.components.inventory.maxslots do
        local v = inst.components.inventory.itemslots[k]
        if v then
            table.insert(items, v.prefab)
        end
    end
	
	if items and time_since_pick > 1 then
		local target = FindEntity(inst, SEE_FOOD_DIST, function(item) return has_value(items, item.prefab) and item.growtime == nil end)
		if target then
			ACTION_TIME = GetTime()
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end		
	end
end

function YnaWoodie:OnStart()
       
    local root = 
		PriorityNode(
		{
			WhileNode(function() return self.inst.components.health.takingfiredamage end, "Panic",
				Panic(self.inst)),            
				
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
					
			IfNode(function() return self.inst.components.hunger:GetPercent() < .5 end, "IsStarving",
				DoAction(self.inst, FindFoodAction)),

			IfNode(function() return self.inst.components.follower.leader ~= nil and 
				self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_PICK_DIST*MAX_PICK_DIST end, "PickUp",
					DoAction(self.inst, PickUpItemAction)),
			
			IfNode(function() return self.inst.components.follower.leader ~= nil and 
				self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_PICK_DIST*MAX_PICK_DIST end, "Pick",		
					DoAction(self.inst, PickItemAction)),
					
			IfNode(function() return StartChoppingCondition(self.inst) end, "Chop", 
				WhileNode(function() return KeepChoppingAction(self.inst) end, "KeepChopping",
					LoopNode{ 
						DoAction(self.inst, FindTreeToChopAction)})),
							
			IfNode(function() return StartMiningCondition(self.inst) end, "Mine", 
				WhileNode(function() return KeepMiningAction(self.inst) end, "KeepMining",
					LoopNode{ 
						DoAction(self.inst, FindRockToMineAction )})),		
			
			IfNode(function() return
				self.inst.components.follower.leader ~= nil and (self.inst.components.followersitcommand and self.inst.components.followersitcommand:IsCurrentlyStaying() == false) or not self.inst.components.followersitcommand end, "FollowLeader",			
				Follow(self.inst, GetLeader, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
				
			FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
			
		}, .1)
    
    self.bt = BT(self.inst, root)

end

function YnaWoodie:OnInitializationComplete()
    ACTION_TIME = GetTime()
end

return YnaWoodie


