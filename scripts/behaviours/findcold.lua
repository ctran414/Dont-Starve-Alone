local SEE_DIST = 30
local SAFE_DIST = 2

FindCold = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "FindCold")
    self.inst = inst
    self.targ = nil
end)

function FindCold:DBString()
    return string.format("Stay near heat %s", tostring(self.targ))
end

function FindCold:Visit()
    
    if self.status == READY then
        self:PickTarget()
        self.status = RUNNING
    end
    
    if self.status == RUNNING then
       
        if self.targ then
            
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

function FindCold:PickTarget()
    self.targ = FindEntity(self.inst, SEE_DIST, function(item) return item.prefab == "coldfire" or (item.prefab == "coldfirepit" and not item.components.fueled:IsEmpty()) end)
end
