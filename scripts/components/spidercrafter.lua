local SpiderCrafter = Class(function(self, inst)
    self.inst = inst
    self.time_to_craft = 0
    self.inst:StartUpdatingComponent(self)
	self.crafted = false
end)


function SpiderCrafter:OnUpdate(dt)
    if self.inst.components.inventory:Has('papyrus', 6) and self.inst.components.inventory:Has('silk', 12) and self.inst.components.inventory:Has('spidergland', 6) then
		local eggs = SpawnPrefab('spidereggsack')
		self.inst.components.inventory:GiveItem(eggs)
		self.inst.components.inventory:ConsumeByName("papyrus", 6)
		self.inst.components.inventory:ConsumeByName("silk", 12)
		self.inst.components.inventory:ConsumeByName("spidergland", 6)
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.crafted = true
    end
	if self.crafted == true then
		self.time_to_craft = self.time_to_craft - dt
		if self.time_to_craft <= 0 then	
			self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_ACCOMPLISHMENT_DONE"))
			local eggs = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'spidereggsack' end)
			if eggs then
				self.inst.components.inventory:DropItem(eggs)
				self.crafted = false
			end
		end
	end
end


function SpiderCrafter:GetDebugString()
    return string.format("%2.2f", self.time_to_craft)
end

return SpiderCrafter
