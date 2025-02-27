local DSACharacterSpecific = Class(function(self, inst)
    self.inst = inst

    self.owner = "wilson"
    self.inst:DoPeriodicTask(3, function() self:CheckOwner() end)
end)

function DSACharacterSpecific:SetOwner(name)
	self.owner = name
end

function DSACharacterSpecific:CheckOwner()
    local owner = self.inst.components.inventoryitem.owner
	if owner == nil or owner.prefab == self.owner then
		return
	end
	
	local item = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if item == self.inst then
		owner.components.inventory:DropItem(self.inst)
        owner.components.talker:Say(GetString(owner.prefab, "ACTIONFAIL_GENERIC"))
	end

end

return DSACharacterSpecific