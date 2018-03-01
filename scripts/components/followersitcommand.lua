print("Loading FollowerSitCommand component....")

local FollowerSitCommand = Class(function(self, inst)
    self.inst = inst
	self.stay = false
	self.locations = {}

end)

function FollowerSitCommand:CollectSceneActions(doer, actions, rightclick)
	if rightclick and self.inst.components.follower.leader and self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= 10 then
		table.insert(actions, ACTIONS.DROPCOMMAND)
	elseif rightclick and self.inst.components.follower and self.inst.components.follower.leader == GetPlayer() then
		if not self.inst.components.followersitcommand:IsCurrentlyStaying() then
			table.insert(actions, ACTIONS.SITCOMMAND)
		else
			table.insert(actions, ACTIONS.SITCOMMAND_CANCEL)
		end
	end
end

function FollowerSitCommand:IsCurrentlyStaying()
	return self.stay
end

function FollowerSitCommand:SetStaying(stay)
	self.stay = stay
end


function FollowerSitCommand:RememberSitPos(name, pos)
    self.locations[name] = pos
end

-- onsave and onload may seem cumbersome but it requires to iterate because onload doesn't accept tables as single vars
function FollowerSitCommand:OnSave()
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
   
function FollowerSitCommand:OnLoad(data)

	if data then 
		self.stay = data.stay
		self.locations.currentstaylocation = { }
		self.locations.currentstaylocation["x"] = data.varx
		self.locations.currentstaylocation["y"] = data.vary
		self.locations.currentstaylocation["z"] = data.varz
	end
end
   


return FollowerSitCommand


