local DSAResurrectable = Class(function(self, inst)
    
    self.inst = inst
    self.onResurrect = nil
    
end)

function DSAResurrectable:OnResurrect(slab, doer)
	if self.onResurrect then
		self.onResurrect(self.inst, slab, doer)
	end
end

function DSAResurrectable:SetOnResurrect(fn)
	self.onResurrect = fn
end

function DSAResurrectable:CollectUseActions(doer, target, actions)
    if target.components.dsaresurrector and target.components.dsaresurrector.canresurrect then
        table.insert(actions, ACTIONS.RESURRECT)
    end
end

return DSAResurrectable