local SEE_DIST = 15
local SAFE_DIST = 2

FindShelter = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "FindShelter")
    self.inst = inst
    self.targ = nil
end)

function FindShelter:DBString()
    return string.format("Stay near shelter %s", tostring(self.targ))
end

function FindShelter:Visit()
    
    if self.status == READY then
        self:PickTarget()
        self.status = RUNNING
    end
    
    if self.status == RUNNING then
       
        if self.targ and self.targ:HasTag("shelter") then
            
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

function FindShelter:PickTarget()
    self.targ = FindEntity(self.inst, SEE_DIST, function(item) return item:HasTag("shelter") end)
end
