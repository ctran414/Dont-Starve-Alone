local BookCrafter = Class(function(self, inst)
    self.inst = inst
    self.time_to_craft = 0
    self.inst:StartUpdatingComponent(self)
	self.bookcrafted = false
	self.book = nil
end)


function BookCrafter:OnUpdate(dt)
    if self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('bird_egg', 2) then
		self.book = 'ynabook_birds'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		local ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'papyrus' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'bird_egg' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
	elseif self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('seeds', 1) and self.inst.components.inventory:Has('poop', 1) then
		self.book = 'ynabook_gardening'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		local ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'papyrus' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'seeds' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'poop' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
	elseif self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('tentaclespots', 1) then
		self.book = 'ynabook_tentacles'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		local ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'papyrus' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'tentaclespots' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
	elseif self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('nightmarefuel', 2) then
		self.book = 'ynabook_sleep'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		local ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'papyrus' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'nightmarefuel' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
			self.inst.components.inventory:RemoveItem(ingredient)
		end
		self.time_to_craft = 1
		self.inst.sg:GoToState("dolongaction")
		self.bookcrafted = true
	elseif self.inst.components.inventory:Has('papyrus', 2) and self.inst.components.inventory:Has('redgem', 1) then
		self.book = 'ynabook_brimstone'
		local book = SpawnPrefab(self.book)
		self.inst.components.inventory:GiveItem(book)
		local ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'papyrus' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
			self.inst.components.inventory:RemoveItem(ingredient)
		end			
		ingredient = self.inst.components.inventory:FindItem(function(item) return item.prefab == 'redgem' end)
		if ingredient then
			self.inst.components.inventory:RemoveItem(ingredient)
		end
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
