local FollowerCommands = Class(function(self, inst)
    self.inst = inst
	self.stay = false
	self.locations = {}
	self.state = 1
	self.pos = 0
	self.timer = 0
	self.mount = false
	self.dismount = false

    self.inst:DoPeriodicTask(1, function() self:OnUpdate() end)
    self.inst:DoPeriodicTask(0, function() self:ResetTimer() end)
end)

function FollowerCommands:CollectSceneActions(doer, actions, rightclick)
	if rightclick then
		if TheInput:IsKeyDown(KEY_ALT) and self.state == 1 then
			table.insert(actions, ACTIONS.DROP1COMMAND)
		elseif TheInput:IsKeyDown(KEY_ALT) and self.state == 2 then
			table.insert(actions, ACTIONS.DROP2COMMAND)
		elseif TheInput:IsKeyDown(KEY_ALT) and self.state == 3 then
			table.insert(actions, ACTIONS.DROP3COMMAND)
		elseif TheInput:IsKeyDown(KEY_SHIFT) then
			table.insert(actions, ACTIONS.SWITCHCOMMAND)
		elseif self.inst.components.follower.leader and self.inst.components.follower.leader.components.driver and self.inst.components.follower.leader.components.driver:GetIsDriving()and self.inst.components.driver and not self.inst.components.driver:GetIsDriving() then
			local boat = FindEntity(self.inst, 5, function(item) return item.components.drivable and not item.components.drivable.driver end)
			if boat then
				table.insert(actions, ACTIONS.MOUNTCOMMAND)
			end
		elseif self.inst.components.follower.leader and self.inst.components.follower.leader.components.driver and not self.inst.components.follower.leader.components.driver:GetIsDriving() and self.inst.components.driver and self.inst.components.driver:GetIsDriving() then 
			table.insert(actions, ACTIONS.DISMOUNTCOMMAND)
		elseif not TheInput:IsKeyDown(KEY_ALT) and not TheInput:IsKeyDown(KEY_SHIFT) and self.inst.components.follower and self.inst.components.follower.leader == GetPlayer() then
			if not self.inst.components.followercommands:IsCurrentlyStaying() then
				table.insert(actions, ACTIONS.STAYCOMMAND)
			else
				table.insert(actions, ACTIONS.FOLLOWCOMMAND)
			end
		end
	end
end

function FollowerCommands:IsCurrentlyStaying()
	return self.stay
end

function FollowerCommands:SetStaying(stay)
	self.stay = stay
end

function FollowerCommands:RememberSitPos(name, pos)
    self.locations[name] = pos
end 

function FollowerCommands:DropItems()
	if self.state == 3 then
		self.inst.components.inventory:DropEverything()
	else
		for k = 1, self.inst.components.inventory.maxslots do
			local v = self.inst.components.inventory.itemslots[k]
			if v and self.state == 1 and not v.components.equippable then
				self.inst.components.inventory:DropItem(v, true, true)
			elseif v and self.state == 2 and not self.inst.components.inventory:IsItemEquipped(v) then
				self.inst.components.inventory:DropItem(v, true, true)
			end
		end	
	end
	
	self.timer = GetTime()
	self.state = self.state + 1
end

function FollowerCommands:SwitchWeapon()
	local hands = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local head = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	local body = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
	for k = self.pos, self.inst.components.inventory.maxslots + 1 do
		if k == self.inst.components.inventory.maxslots + 1 and hands ~= nil then
			self.inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
			hands.components.equippable:ToPocket()
			self.inst.components.inventory:GiveItem(hands)
			self.pos = 1
			return
		--[[elseif k == self.inst.components.inventory.maxslots + 2 and head ~= nil then
			self.inst.components.inventory:Unequip(EQUIPSLOTS.HEAD)
			head.components.equippable:ToPocket()
			self.inst.components.inventory:GiveItem(head)
			pos = k + 1
			return true
		elseif k == self.inst.components.inventory.maxslots + 3 and body ~= nil then
			self.inst.components.inventory:Unequip(EQUIPSLOTS.BODY)
			body.components.equippable:ToPocket()
			self.inst.components.inventory:GiveItem(body)
			pos = 1
			return true]]
		end
		
		local v = self.inst.components.inventory.itemslots[k]
		if v and v.components.equippable then
			if k == self.inst.components.inventory.maxslots then
				self.pos = 1
			else
				self.pos = k + 1
			end
			self.inst.components.inventory:Equip(v)
			return
		end
	end		
	for k = 1, self.pos do
		local v = self.inst.components.inventory.itemslots[k]
		if v and v.components.equippable then
			if k == self.inst.components.inventory.maxslots then
				self.pos = 1
			else
				self.pos = k + 1
			end
			self.inst.components.inventory:Equip(v)
			return
		end
	end
end

-- onsave and onload may seem cumbersome but it requires to iterate because onload doesn't accept tables as single vars
function FollowerCommands:OnSave()
	if self.stay == true then
		local data = 
			{ 
				stay = self.stay,
				varx = self.locations.currentstaylocation["x"], 
				vary = self.locations.currentstaylocation["y"], 
				varz = self.locations.currentstaylocation["z"]
			}
		return data
	end
end  

function FollowerCommands:OnLoad(data)

	if data then 
		self.stay = data.stay
		self.locations.currentstaylocation = { }
		self.locations.currentstaylocation["x"] = data.varx
		self.locations.currentstaylocation["y"] = data.vary
		self.locations.currentstaylocation["z"] = data.varz
	end
end
   
function FollowerCommands:OnUpdate()
	
	if self.inst.components.follower.leader ~= nil and self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) > 1200 then
		self.inst.components.follower:StopFollowing()
	end
	if self.inst.components.follower.leader == nil and self.inst:GetDistanceSqToInst(GetPlayer()) < 1000 then
		self.inst.components.follower.maxfollowtime = 99999999
		self.inst.components.follower:SetLeader(GetPlayer())
		--player.components.leader:AddFollower(inst)
		self.inst.components.follower:AddLoyaltyTime(9999999)
	end
	--self.state = 0;
end

function FollowerCommands:ResetTimer()
	if GetTime() - self.timer > 2 then
		self.state = 1;
	end
end

function FollowerCommands:SetMount(mount)
	self.mount = mount
end

function FollowerCommands:SetDismount(dismount)
	self.dismount = dismount
end

return FollowerCommands


