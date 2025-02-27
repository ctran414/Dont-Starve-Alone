local WeaponCrafter = Class(function(self, inst)
    self.inst = inst
    self.time_to_craft = 0
    self.inst:StartUpdatingComponent(self)
	self.crafted = false
end)


function WeaponCrafter:OnUpdate(dt)
    if self.inst.components.inventory:Has('twigs', 2) and self.inst.components.inventory:Has('goldnugget', 2) and self.inst.components.inventory:Has('flint', 2) then
		local item = SpawnPrefab('spear_wathgrithr')
		self.inst.components.inventory:GiveItem(item)
		self.inst.components.inventory:ConsumeByName("twigs", 2)
		self.inst.components.inventory:ConsumeByName("goldnugget", 2)
		self.inst.components.inventory:ConsumeByName("flint", 2)
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.crafted = true
	elseif self.inst.components.inventory:Has('rocks', 2) and self.inst.components.inventory:Has('goldnugget', 2) then
		local item = SpawnPrefab('wathgrithrhat')
		self.inst.components.inventory:GiveItem(item)
		self.inst.components.inventory:ConsumeByName("rocks", 2)
		self.inst.components.inventory:ConsumeByName("goldnugget", 2)
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.crafted = true
    end
	if self.crafted == true then
		self.time_to_craft = self.time_to_craft - dt
		if self.time_to_craft <= 0 then	
			self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_ACCOMPLISHMENT_DONE"))
			local item = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'spear_wathgrithr' or item.prefab == 'wathgrithrhat' end)
			if item then
				self.inst.components.inventory:Equip(item)
				self.crafted = false
			end
		end
	end
end


function WeaponCrafter:GetDebugString()
    return string.format("%2.2f", self.time_to_craft)
end

return WeaponCrafter
