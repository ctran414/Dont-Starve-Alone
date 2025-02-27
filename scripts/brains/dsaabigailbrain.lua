require "behaviours/follow"
require "behaviours/wander"


local AbigailBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MIN_FOLLOW = 4
local MAX_FOLLOW = 11
local MED_FOLLOW = 6
local MAX_WANDER_DIST = 10
local MAX_CHASE_TIME = 6

local function GetWendy()
    return TheSim:FindFirstEntityWithTag("wendy")
end

function AbigailBrain:OnStart()

    local root = PriorityNode(
    {
		ChaseAndAttack(self.inst, MAX_CHASE_TIME),
		IfNode(function() return GetWendy() end, "FollowWendy",
			Follow(self.inst, function() return GetWendy() end, MIN_FOLLOW, MED_FOLLOW, MAX_FOLLOW, true)),
		IfNode(function() return GetWendy() end, "WanderNearWendy",
			Wander(self.inst, function() return GetWendy() and Point(GetWendy().Transform:GetWorldPosition()) end , MAX_WANDER_DIST))   
    }, .5)
        
    self.bt = BT(self.inst, root)
         
end


return AbigailBrain