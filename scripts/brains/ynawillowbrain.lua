require "behaviours/ynafollow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/ynafindlight"
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

local YnaWillow = Class(Brain, function(self, inst)
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

local function FindHeatAction(inst)
    local target = FindEntity(inst, 30, function(item) return item.components.heater and item.components.heater:GetHeat(inst) > 0 end)
	
    if target then
		return BufferedAction(inst, target, ACTIONS.WALKTO, nil, nil, nil, 2.5)
	end
end

local function KeepChoppingAction(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_CHOPPING_DIST*KEEP_CHOPPING_DIST and not GetClock():IsNight()
end

local function StartChoppingCondition(inst)
    if inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= SEE_TREE_DIST*SEE_TREE_DIST
	--[[and inst.components.follower.leader.sg and inst.components.follower.leader.sg:HasStateTag("chopping")]] and not GetClock():IsNight() then
		if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "axe" then
			return true
		else
			local axe = inst.components.inventory:FindItem(function(item) return item.prefab == 'axe' end)
			if axe then
				inst.components.inventory:Equip(axe)	
				return true
			end
		end
	end
	return false
end

local function FindTreeToChopAction(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.CHOP and item.components.growable and item.components.growable.stage == 3 end)
	local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    if target then
        return BufferedAction(inst, target, ACTIONS.CHOP, invObject)
    end
end

function YnaWillow:OnStart()
       
    local root = 
		PriorityNode(
		{
			WhileNode(function() return self.inst.components.health.takingfiredamage or self.inst.components.sanity:GetPercent() == 0 end, "Panic",
				Panic(self.inst)),
					
			WhileNode(function() return not self.inst.LightWatcher:IsInLight() end, "IsDark",
                YnaFindLight(self.inst)),
				
            WhileNode(function() return ((self.inst.components.follower.leader ~= nil and 
				self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_CHASE_DIST*MAX_CHASE_DIST and self.inst.components.followersitcommand and 
				self.inst.components.followersitcommand:IsCurrentlyStaying() == false) or self.inst.components.follower.leader == nil) and
				(self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown()) end, "AttackMomentarily",
                ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),	
					
			WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
                RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),
			
			IfNode(function() return
					self.inst.components.temperature:IsFreezing() or self.inst.components.temperature:GetCurrent() < 5 end,
					"FindWarmth",
				DoAction(self.inst, FindHeatAction, "FindHeat", true )),  

			IfNode(function() return StartChoppingCondition(self.inst) end, "chop", 
					WhileNode(function() return KeepChoppingAction(self.inst) end, "keep chopping",
						LoopNode{ 
							DoAction(self.inst, FindTreeToChopAction )})),
			
			IfNode(function() return
					self.inst.components.follower.leader ~= nil and (self.inst.components.followersitcommand and self.inst.components.followersitcommand:IsCurrentlyStaying() == false) or not self.inst.components.followersitcommand end, "FollowLeader",			
				Follow(self.inst, GetLeader, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
				
			FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
			
		}, .1)
		
    self.bt = BT(self.inst, root)
end

function YnaWillow:OnInitializationComplete()

end

return YnaWillow


