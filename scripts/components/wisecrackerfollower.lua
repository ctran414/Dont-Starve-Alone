local WisecrackerFollower = Class(function(self, inst)
    self.inst = inst 
    self.time_to_convo = 10
    self.time_in_lightstate = 0
    self.inlight = true

    inst:ListenForEvent("oneatsomething", 
        function(inst, data) 
            if data.food and data.food.components.edible then
		    			
				if data.food.prefab == "spoiled_food" then
					inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "SPOILED"))
				elseif data.food.components.edible:GetHealth(inst) < 0 and data.food.components.edible:GetSanity(inst) <= 0 then
					inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "PAINFUL"))
				elseif data.food.components.perishable and not data.food.components.perishable:IsFresh() then
					if data.food.components.perishable:IsStale() then
						inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "STALE"))
					elseif data.food.components.perishable:IsSpoiled() then
						inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "SPOILED"))
					end
				end
			end
        end)


	inst:StartUpdatingComponent(self)
        
        
    inst:ListenForEvent("dusktime", function(it, data) 
            if it:IsCave() then
                return 
            end
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_DUSK"))
        end, GetWorld())

    inst:ListenForEvent("torchranout", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_TORCH_OUT"))
    end)
 
	inst:ListenForEvent("hungerdelta", 
        function(inst, data) 
            if (data.newpercent > TUNING.HUNGRY_THRESH) ~= (data.oldpercent > TUNING.HUNGRY_THRESH) then
                if data.newpercent <= TUNING.HUNGRY_THRESH then
					inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_HUNGRY"))
                end
            end    
        end)   
		
    inst:ListenForEvent("startfreezing", 
        function(inst, data) 
			inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_COLD"))
        end)
		
    inst:ListenForEvent("torchranout", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_TORCH_OUT"))
    end)

    inst:ListenForEvent("heargrue", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_CHARLIE"))
    end)
    
    inst:ListenForEvent("attackedbygrue", function(inst, data)
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_CHARLIE_ATTACK"))
    end)

    inst:ListenForEvent("coveredinbees", function(inst, data)
		inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_BEES"))
    end)
    
    inst:ListenForEvent("wormholespit", function(inst, data)
        inst.components.talker:Say(GetString(inst.prefab "ANNOUNCE_WORMHOLE"))
    end)

    inst:ListenForEvent("huntlosttrail", function(inst, data)
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_HUNT_LOST_TRAIL"))
    end)
        
    inst:ListenForEvent("huntbeastnearby", function(inst, data)
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_HUNT_BEAST_NEARBY"))
    end)
	
    local dt = 5
    self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end)
		
end)

function WisecrackerFollower:OnUpdate(dt)
    self.time_to_convo = self.time_to_convo - dt
    if self.time_to_convo <= 0 and self.inst.sg:HasStateTag('idle') and not self.inst.sg:HasStateTag('busy') then
        self:MakeIdleConversation()
    end
	
	local light_thresh = .5
	local dark_thresh = .5

	if self.inst.LightWatcher:IsInLight() then
		if not self.inlight then
			if self.inst.LightWatcher:GetTimeInLight() >= light_thresh then
				self.inlight = true
				self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_ENTER_LIGHT"))
			end
		end
	else
		if self.inlight then
			if self.inst.LightWatcher:GetTimeInDark() >= dark_thresh then
				self.inlight = false
				self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_ENTER_DARK"))
			end
		end
	end
end

function WisecrackerFollower:Say(phrase, sound_override)
    self.sound_override = sound_override
    self.inst.components.talker:Say(phrase)
    self.time_to_convo = math.random(60, 120)
end

function WisecrackerFollower:MakeIdleConversation()
	local currenthealth = self.inst.components.health.currenthealth / self.inst.components.health.maxhealth	
	if currenthealth < 0.5 then 
		self:Say(STRINGS.YNAWOODIE.HURT)
		return
	end
	
	local target = FindEntity(self.inst, 10, function(item) return item.components.inspectable and not item:HasTag("summonedbyplayer") end)
	if target then
		local status = target.components.inspectable:GetStatus(self.inst)
		local quip = GetDescription(self.inst.prefab, target, status)
		if quip then
			self:Say(quip)
		end
	end
end

return WisecrackerFollower

