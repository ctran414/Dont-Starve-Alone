local SEE_DIST = 30
local SAFE_DIST = 2

DSAFindLight = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "DSAFindLight")
    self.inst = inst
    self.targ = nil
end)



function DSAFindLight:DBString()
    return string.format("Stay near light %s", tostring(self.targ))
end

function DSAFindLight:Visit()
    
    if self.status == READY then
	
        self:PickTarget()
		local light = self.inst.components.inventory:FindItem(function(item) return item.prefab == "torch" or item.prefab == "lantern" or item.prefab == "minerhat" or item.prefab == "dsalighter" end)
		if light then
			self.inst.components.inventory:Equip(light)
			self.status = SUCCESS
            return
		end
	
        self:PickTarget()
        self.status = RUNNING
    end
    
    if self.status == RUNNING then
       
        if self.targ and self.targ:HasTag("lightsource") then
            local dsq = self.inst:GetDistanceSqToInst(self.targ)
            if dsq >= SAFE_DIST*SAFE_DIST then
                self.inst.components.locomotor:RunInDirection(self.inst:GetAngleToPoint(Point(self.targ.Transform:GetWorldPosition())))
            else
                self.inst.components.locomotor:Stop()
                self:Sleep(.5)
            end
        else
            self.status = FAILED
        end
    end
end

function DSAFindLight:PickTarget()
    self.targ = GetClosestInstWithTag("lightsource", self.inst, SEE_DIST)
end