require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/attackwall"

local ShadowWaxwellBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

--Images will help chop, mine and fight.

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 4
local MAX_FOLLOW_DIST = 6

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8

local KEEP_WORKING_DIST = 10
local SEE_WORK_DIST = 15

local function GetMaxwell()
    return TheSim:FindFirstEntityWithTag("waxwell")
end

local function HasStateTags(inst, tags)
    for k,v in pairs(tags) do
        if inst.sg:HasStateTag(v) then
            return true
        end
    end
end

local function KeepWorkingAction(inst, actiontags)
	local maxwell = GetMaxwell()
    return maxwell and maxwell:GetDistanceSqToInst(inst) <= KEEP_WORKING_DIST*KEEP_WORKING_DIST and 
    HasStateTags(maxwell, actiontags)
end

local function StartWorkingCondition(inst, actiontags)
	local maxwell = GetMaxwell()
    return maxwell and HasStateTags(maxwell, actiontags) and not HasStateTags(inst, actiontags)
end

local function FindObjectToWorkAction(inst, action)
    if inst.sg:HasStateTag("working") then
        return 
    end
	local maxwell = GetMaxwell()
	if maxwell == nil then
		return
	end
	
    local target = nil
    local notags = {"FX", "NOCLICK", "DECOR","INLIMBO"}
	if action == ACTIONS.HACK then
        target = FindEntity(maxwell, SEE_WORK_DIST, function(item) return item.components.hackable end, nil, notags)
    else
		target = FindEntity(maxwell, SEE_WORK_DIST, function(item) return item.components.workable and item.components.workable.action == action end, nil, notags)
	end
    if target then
        --print(GetTime(), target)
        return BufferedAction(inst, target, action)
    end
end

local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("waxwell", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:IsNear(target, KEEP_FACE_DIST) and not target:HasTag("notarget")
end

local function TagsMatch(inst)
    local leader = GetMaxwell()
    return leader and leader:HasTag("aquatic") == inst:HasTag("aquatic")
end

local function BoatAction(inst)
    local leader = GetMaxwell()

    if not leader then return end

    if leader:HasTag("aquatic") and not inst:HasTag("aquatic") then
		print('BoatAction',leader)
        --inst.boat is created in shadowwaxwell.lua through mountboat event
        if inst.boat then 
		print('inst.boat',inst.boat)
            return BufferedAction(inst, inst.boat, ACTIONS.MOUNT, nil, nil, nil, 100)
        end
    elseif not leader:HasTag("aquatic") and inst:HasTag("aquatic") then
        --Get off boat near leader
        local offset = FindGroundOffset(leader:GetPosition(), math.random() * 2*PI, 2, 36)
        if offset then
            local pos = leader:GetPosition() + offset
            return BufferedAction(inst, nil, ACTIONS.DISMOUNT, nil, pos, nil, 100)
        end
    end
end

function ShadowWaxwellBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return IsDLCEnabled(CAPY_DLC) and not TagsMatch(self.inst) end, "On Land",
            SequenceNode{
                WaitNode(0.5),
                DoAction(self.inst, function() return BoatAction(self.inst) end),
            }),
			
        ChaseAndAttack(self.inst, 5),
                  
        WhileNode(function() return StartWorkingCondition(self.inst, {"chopping", "prechop"}) and 
        KeepWorkingAction(self.inst, {"chopping", "prechop"}) end, "keep chopping",
            DoAction(self.inst, function() return FindObjectToWorkAction(self.inst, ACTIONS.CHOP) end)),

        WhileNode(function() return StartWorkingCondition(self.inst, {"mining", "premine"}) and 
        KeepWorkingAction(self.inst, {"mining", "premine"}) end, "keep mining",                   
            DoAction(self.inst, function() return FindObjectToWorkAction(self.inst, ACTIONS.MINE) end)),
			
        WhileNode(function() return StartWorkingCondition(self.inst, {"hacking", "prehack"}) and 
        KeepWorkingAction(self.inst, {"hacking", "prehack"}) end, "keep hacking",                   
            DoAction(self.inst, function() return FindObjectToWorkAction(self.inst, ACTIONS.HACK) end)),

        Follow(self.inst, function() return GetMaxwell() end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        IfNode(function() return GetMaxwell() end, "has leader",            
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),

    }, .25)
    
    self.bt = BT(self.inst, root)    
end

return ShadowWaxwellBrain