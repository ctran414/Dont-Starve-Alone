local BookCrafter = Class(function(self, inst)
    self.inst = inst
    self.time_to_craft = 0
    self.inst:StartUpdatingComponent(self)
	self.bookcrafted = false
	self.book = nil
end)


function BookCrafter:OnUpdate(dt)
    if self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('bird_egg', 2) then
		self.book = 'dsabook_birds'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		self.inst.components.inventory:ConsumeByName("papyrus", 2)
		self.inst.components.inventory:ConsumeByName("bird_egg", 2)
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
	elseif self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('seeds', 1) and self.inst.components.inventory:Has('poop', 1) then
		self.book = 'dsabook_gardening'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		self.inst.components.inventory:ConsumeByName("papyrus", 2)
		self.inst.components.inventory:ConsumeByName("seeds", 1)
		self.inst.components.inventory:ConsumeByName("poop", 1)
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
	elseif self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('tentaclespots', 1) then
		self.book = 'dsabook_tentacles'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		self.inst.components.inventory:ConsumeByName("papyrus", 2)
		self.inst.components.inventory:ConsumeByName("tentaclespots", 1)
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
	elseif self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('nightmarefuel', 2) then
		self.book = 'dsabook_sleep'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		self.inst.components.inventory:ConsumeByName("papyrus", 2)
		self.inst.components.inventory:ConsumeByName("nightmarefuel", 2)
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
	elseif self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('redgem', 1) then
		self.book = 'dsabook_brimstone'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		self.inst.components.inventory:ConsumeByName("papyrus", 2)
		self.inst.components.inventory:ConsumeByName("redgem", 1)
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
    end
	if self.book then
		self.time_to_craft = self.time_to_craft - dt
		if self.time_to_craft <= 0 then	
			self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_ACCOMPLISHMENT_DONE"))
			local book = self.inst.components.inventory:FindItem(function(item) return item.prefab == self.book end)
			if book then
				self.inst.components.inventory:DropItem(book)
				self.book = nil
			end
		end
	end
end


function BookCrafter:GetDebugString()
    return string.format("%2.2f", self.time_to_craft)
end

return BookCrafter
