DSAWander = Class(BehaviourNode, function(self, inst, homelocation, max_dist, times)
    BehaviourNode._ctor(self, "DSAWander")
    self.homepos = homelocation
    self.maxdist = max_dist
    self.inst = inst
    self.far_from_home = false
    
    self.times =
    {
		minwalktime = times and times.minwalktime or 2,
		randwalktime = times and times.randwalktime or 3,
		minwaittime = times and times.minwaittime or 1,
		randwaittime = times and times.randwaittime or 3,
    }
end)


function DSAWander:Visit()

    if self.status == READY then
        self.inst.components.locomotor:Stop()
		self:Wait(self.times.minwaittime+math.random()*self.times.randwaittime)
        self.walking = false
        self.status = RUNNING
    elseif self.status == RUNNING then
    
		if not self.walking and self:IsFarFromHome() then
            self:PickNewDirection()
		end
    
        if GetTime() > self.waittime then
            self:PickNewDirection()
			return
        else
            if not self.walking then
				self:Sleep(self.waittime - GetTime())
            end
        end
    end
    
    
end

local function tostring_float(f)
    return f and string.format("%2.2f", f) or tostring(f)
end

function DSAWander:DBString()
    local w = self.waittime - GetTime()
    return string.format("%s for %2.2f, %s, %s, %s", 
        self.walking and 'walk' or 'wait', 
        w, 
        tostring(self:GetHomePos()), 
        tostring_float(math.sqrt(self:GetDistFromHomeSq() or 0)), 
        self.far_from_home and "Go Home" or "Go Wherever")
end

function DSAWander:GetHomePos()
    if type(self.homepos) == "function" then 
        return self.homepos(self.inst)
    end
    
    return self.homepos
end

function DSAWander:GetDistFromHomeSq()
    local homepos = self:GetHomePos()
	if not homepos then
		return nil
	end
    local pos = Vector3(self.inst.Transform:GetWorldPosition())
    return distsq(homepos, pos)
end
	
function DSAWander:IsFarFromHome()
	if self:GetHomePos() then
		return self:GetDistFromHomeSq() > self:GetMaxDistSq()
	end
	return false
end


function DSAWander:GetMaxDistSq()
    if type(self.maxdist) == "function" then
        local dist = self.maxdist(self.inst)
        return dist*dist
    end
    
    return self.maxdist*self.maxdist
end

function DSAWander:Wait(t)
    self.waittime = t+GetTime()
    self:Sleep(t)
end

function DSAWander:PickNewDirection()

    self.walking = not self.walking

    self.far_from_home = self:IsFarFromHome()
    
    if self.walking then
        
        if self.far_from_home then
            self.inst.components.locomotor:GoToPoint(self:GetHomePos())
        else
            local pt = Point(self.inst.Transform:GetWorldPosition())
            local angle = math.random()*2*PI
            local radius = 5
            local attempts = 8
            local offset, check_angle, deflected = FindWalkableOffset(pt, angle, radius, attempts, true, false) -- try to avoid walls
            if not check_angle then
                offset, check_angle, deflected = FindWalkableOffset(pt, angle, radius, attempts, true, true) -- if we can't avoid walls, at least avoid water
            end
            if check_angle then
                angle = check_angle
            end
            if offset then
                self.inst.components.locomotor:GoToPoint(self.inst:GetPosition() + offset)
            else
                self.inst.components.locomotor:WalkInDirection(angle/DEGREES)
            end
        end
        
        self:Wait(self.times.minwalktime+math.random()*self.times.randwalktime)
    else
        self.inst.components.locomotor:Stop()
        self:Wait(self.times.minwaittime+math.random()*self.times.randwaittime)
    end
    
end


