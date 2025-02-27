local SEE_DIST = 30
local SAFE_DIST = 2

FindHeat = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "FindHeat")
    self.inst = inst
    self.targ = nil
end)

function FindHeat:DBString()
    return string.format("Stay near heat %s", tostring(self.targ))
end

function FindHeat:Visit()
    
    if self.status == READY then
        self:PickTarget()
        self.status = RUNNING
    end
    
    if self.status == RUNNING then
       
        if self.targ and self.targ.components.heater and self.targ.components.heater:GetHeat(self.inst) > 0 then
            
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

function FindHeat:PickTarget()
    self.targ = FindEntity(self.inst, SEE_DIST, function(item) return item.components.heater and item.components.heater:GetHeat(self.inst) > 0 end)
end
