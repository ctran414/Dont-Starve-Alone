local function GetWoodie()
    return TheSim:FindFirstEntityWithTag("woodie")
end

local LucyTalk = Class(function(self, inst)
    self.inst = inst
    self.time_to_convo = 10

    self.inst:ListenForEvent("ondropped", function() self:OnDropped() end)
    self.inst:ListenForEvent("equipped", function(_, data) self:OnEquipped(data.owner) end)
    self.inst:ListenForEvent("finishedwork", function(_, data) self:OnFinishedWork(data.target, data.action) end, GetWoodie())
    self.inst:ListenForEvent("beavernessdelta", function(_, data) self:OnBeaverDelta(data.oldpercent, data.newpercent) end, GetWoodie())
    self.inst:ListenForEvent("beaverstart", function(_, data) self:OnBecomeBeaver() end, GetWoodie())
    self.inst:ListenForEvent("beaverend", function(_, data) self:OnBecomeHuman() end, GetWoodie())
    local dt = 5
    self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end)
    self.warnlevel = 0
	self.owner = nil
end)

function LucyTalk:OnFinishedWork(target, action)
    if action == ACTIONS.CHOP and 
        self.inst.components.inventoryitem.owner == GetWoodie() and 
        self.inst.components.equippable:IsEquipped() and
        (GetWoodie().components.beaverness and GetWoodie().components.beaverness:GetPercent() < .25) then
        self:Say(STRINGS.LUCY.on_chopped)
    end
end

function LucyTalk:OnBeaverDelta(old, new)
    
    if GetWoodie().components.beaverness:IsBeaver() then return end

    if new > old then
        if new > .33 and old <= .33 and self.warnlevel < 1 then
            self:Say(STRINGS.LUCY.beaver_up_early)     
            self.warnlevel = 1
        elseif new > .66 and old <= .66 and self.warnlevel < 2 then
            self:Say(STRINGS.LUCY.beaver_up_mid)     
            self.warnlevel = 2
        elseif new > .9 and old <= .9 and self.warnlevel < 3 then
            self:Say(STRINGS.LUCY.beaver_up_late)
            self.warnlevel = 3   
            self.washigh = true  
        end

    else
        if self.warnlevel == 3 and new < .66 then
            self.warnlevel = 2
        elseif self.warnlevel == 2 and new < .33 then
            self.warnlevel = 1
        end

        if new <= 0 and old > 0 then
            if self.washigh then
                
                local warn_sounds = {"dontstarve/characters/woodie/lucy_warn_1","dontstarve/characters/woodie/lucy_warn_2","dontstarve/characters/woodie/lucy_warn_3"}
                self:Say(STRINGS.LUCY.beaver_down_washigh, warn_sounds[self.warnlevel])     
                self.warnlevel = 0
                self.washigh = false
            end
        end            
    end
end

function LucyTalk:OnBecomeHuman()
    self:Say(STRINGS.LUCY.transform_woodie)
end

function LucyTalk:OnBecomeBeaver()
    self:Say(STRINGS.LUCY.transform_beaver, "dontstarve/characters/woodie/lucy_transform")
end

function LucyTalk:OnDropped()
	
	if self.owner and self.owner.components.beaverness and self.owner.components.beaverness:IsBeaver() then
		self:Say(STRINGS.LUCY.transform_beaver)
	else
		self:Say(STRINGS.LUCY.on_dropped)
	end
end

function LucyTalk:OnEquipped(picked_up_by)
    if picked_up_by.prefab == "dsawoodie" then
        self:Say(STRINGS.LUCY.on_pickedup) 
	else
        self:Say(STRINGS.LUCY.other_owner) 
    end
	self.owner = picked_up_by
end

function LucyTalk:OnUpdate(dt)
    self.time_to_convo = self.time_to_convo - dt
    if self.time_to_convo <= 0 then
        self:MakeConversation()
    end
end

function LucyTalk:Say(list, sound_override)
    self.sound_override = sound_override
    self.inst.components.talker:Say(list[math.random(#list)])
    self.time_to_convo = math.random(60, 120)
end


function LucyTalk:MakeConversation()
    
    local grand_owner = self.inst.components.inventoryitem:GetGrandOwner()
    local owner = self.inst.components.inventoryitem.owner

    local quiplist = nil
    if owner and owner.prefab == "dsawoodie" then
        if self.inst.components.equippable:IsEquipped() then
            --currently equipped
			quiplist = STRINGS.LUCY.equipped
        else
            --in player inventory
        end
    elseif owner == nil then
        --on the ground
        quiplist = STRINGS.LUCY.on_ground
    elseif grand_owner ~= owner and grand_owner.prefab == "dsawoodie" then
        --in a backpack
        quiplist = STRINGS.LUCY.in_container
    elseif owner and owner.components.container then
        --in a container
        quiplist = STRINGS.LUCY.in_container
    else
        --owned by someone else
		quiplist = STRINGS.LUCY.other_owner
    end

    if quiplist then
        self:Say(quiplist)
    end
end

return LucyTalk