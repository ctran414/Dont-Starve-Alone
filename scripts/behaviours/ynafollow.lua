Follow = Class(BehaviourNode, function(self, inst, target, target_dist, max_dist, canrun)
    BehaviourNode._ctor(self, "Follow")
    
    self.inst = inst
    self.target = target
    self.max_dist = max_dist
    self.target_dist = target_dist
    self.canrun = canrun
    self.offset = Vector3(0,0,0)
	
    if self.canrun == nil then self.canrun = true end
    
    self.action = "STAND"
end)

function Follow:GetTarget()
    if type(self.target) == "function" then
        return self.target(self.inst)
    end
    
    return self.target
end


function Follow:DBString()
    
    local pos = Point(self.inst.Transform:GetWorldPosition())
    local target_pos = Vector3(0,0,0)
    if self.currenttarget then
        target_pos = Point(self.currenttarget.Transform:GetWorldPosition())
    end
    
    return string.format("%s %s, (%2.2f) ", tostring(self.currenttarget), self.action, math.sqrt(distsq(target_pos, pos)))
end

function Follow:Visit()

    if self.status == READY then
        self.currenttarget = self:GetTarget()
        if self.currenttarget then
			
			local pos = Point(self.inst.Transform:GetWorldPosition())
			local target_pos = Point(self.currenttarget.Transform:GetWorldPosition())
			local dist_sq = distsq(pos, target_pos)
			
			local x = math.random()+math.random(-3,3)
			local y = math.random()+math.random(-3,3)
			local z = math.random()+math.random(-3,3)
			self.offset = Vector3(x,y,z)
			
			self.status = RUNNING
			
			if dist_sq > self.max_dist*self.max_dist then
				self.action = "APPROACH"
			else
				self.status = FAILED
			end
			
        else
            self.status = FAILED
        end
        
    end

    if self.status == RUNNING then
        if not self.currenttarget or not self.currenttarget:IsValid()
           or (self.currenttarget.components.health and self.currenttarget.components.health:IsDead() ) then
            self.status = FAILED
            self.inst.components.locomotor:Stop()
            return
        end
        
        
        local pos = Point(self.inst.Transform:GetWorldPosition())
        local target_pos = Point(self.currenttarget.Transform:GetWorldPosition())
        local dist_sq = distsq(pos, target_pos)
    
        if self.action == "APPROACH" then
            if dist_sq < self.target_dist*self.target_dist then
                self.status = SUCCESS
                return
            end
        end
        
        if self.action == "APPROACH" then
            local should_run = dist_sq > (self.max_dist*.75)*(self.max_dist*.75)
            local is_running = self.inst.sg:HasStateTag("running")
            if self.canrun and (should_run or is_running) then
                self.inst.components.locomotor:GoToPoint(target_pos + self.offset, nil, true)
            else
                self.inst.components.locomotor:GoToPoint(target_pos + self.offset)
            end
        end
        
        self:Sleep(.25)
    end
    
end

