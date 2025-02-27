local brain = require "brains/followerbrain"
local brainsw = require "brains/followerbrainsw"
local easing = require "easing"
local Text = require "widgets/text"
local Badge = require "widgets/badge"
local HungerBadge = require "widgets/hungerbadge"
local HealthBadge = require "widgets/healthbadge"
local SanityBadge = require "widgets/sanitybadge"
local MoistureMeter = nil
if IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC) then 
	MoistureMeter = require "widgets/moisturemeter"
end

local assets = {}

if IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC) then 
	assets =
	{
		Asset("ANIM", "anim/player_frozen.zip"),
		Asset("ANIM", "anim/player_shock.zip"),
		Asset("ANIM", "anim/shock_fx.zip"),
		Asset("ANIM", "anim/player_tornado.zip"),
		Asset("ANIM", "anim/player_woodie.zip"),
		Asset("ANIM", "anim/woodie.zip"),
		Asset("ANIM", "anim/werebeaver_build.zip"),
		Asset("ANIM", "anim/werebeaver_basic.zip"),
		Asset("ANIM", "anim/wolfgang.zip"),
		Asset("ANIM", "anim/wolfgang_skinny.zip"),
		Asset("ANIM", "anim/wolfgang_mighty.zip"),
		Asset("ANIM", "anim/player_wolfgang.zip"),
		Asset("ANIM", "anim/wathgrithr.zip"),
		Asset("SOUND", "sound/wathgrithr.fsb"),
		Asset("ANIM", "anim/waxwell.zip"),
		Asset("SOUND", "sound/maxwell.fsb")    
	}
else
	assets =
	{
		Asset("ANIM", "anim/player_woodie.zip"),
		Asset("ANIM", "anim/woodie.zip"),
		Asset("ANIM", "anim/werebeaver_build.zip"),
		Asset("ANIM", "anim/werebeaver_basic.zip"),
		Asset("ANIM", "anim/wolfgang.zip"),
		Asset("ANIM", "anim/wolfgang_skinny.zip"),
		Asset("ANIM", "anim/wolfgang_mighty.zip"),
		Asset("ANIM", "anim/player_wolfgang.zip"),
		Asset("ANIM", "anim/waxwell.zip"),
		Asset("SOUND", "sound/maxwell.fsb"),
        Asset("ANIM", "anim/player_actions_uniqueitem.zip"),
	}
end

local prefabs =
{
	"sparks",
    "beardhair",
    "willowfire",
	"shadowwaxwell",
}

local woodie_inv = 
{
	"dsalucy",
}

local willow_inv = 
{
	"dsalighter",
}

local wendy_inv = 
{
    "dsaabigail_flower",
}

local wes_inv = 
{
    "dsaballoons_empty",
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30
local TARGET_DIST = 20

local function OnUpdate(inst, dt)
	inst.charge_time = inst.charge_time - dt
	if inst.charge_time <= 0 then
		inst.charge_time = 0
		if inst.charged_task then
			inst.charged_task:Cancel()
			inst.charged_task = nil
		end
		inst.SoundEmitter:KillSound("overcharge_sound")
		inst.charged_task = nil
		inst.Light:Enable(false)
		inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED 
		inst.AnimState:SetBloomEffectHandle( "" )
		inst.components.temperature.mintemp = -20
		inst.components.talker:Say(GetString("wx78", "ANNOUNCE_DISCHARGE"))
		--inst.SoundEmitter:KillSound("overcharge_sound")
	else
    	local runspeed_bonus = .5
    	local rad = 3
    	if inst.charge_time < 60 then
    		rad = math.max(.1, rad * (inst.charge_time / 60))
    		runspeed_bonus = (inst.charge_time / 60)*runspeed_bonus
    	end

    	inst.Light:Enable(true)
    	inst.Light:SetRadius(rad)
		inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*(1+runspeed_bonus)
		inst.components.temperature.mintemp = 10
	end
end

local function OnAttacked(inst, data)
    local attacker = data.attacker

    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("companion") and dude.components.follower.leader == GetPlayer() end, MAX_TARGET_SHARES)
end

local function OnAttackOther(inst, data)
    local target = data.target
    inst.components.combat:ShareTarget(target, SHARE_TARGET_DIST, function(dude) return dude:HasTag("companion") and dude.components.follower.leader == GetPlayer() end, MAX_TARGET_SHARES)
end

local function OnNewTarget(inst, data)
	local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if current and current.components.weapon and current.components.weapon.damage < 34 then
		local weapon = inst.components.inventory:FindItem(function(item) return item.components.weapon and item.components.weapon.damage >= 34 end)
		if weapon then
			inst.components.inventory:Equip(weapon)	
		end
	elseif not current then
		local weapon = inst.components.inventory:FindItem(function(item) return item.components.weapon end)
		if weapon then
			inst.components.inventory:Equip(weapon)	
		end
	end
end

local function NormalRetargetFn(inst)
	local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    local newtarget = FindEntity(inst, TARGET_DIST, function(guy)
            return  current and guy.components.combat and 
                    inst.components.combat:CanTarget(guy) and
                    ((guy.components.combat.target == GetPlayer() and guy.prefab ~= "babybeefalo") or (guy ~= GetPlayer() and guy.components.combat.target and guy.components.combat.target:HasTag("companion") and guy.prefab ~= "babybeefalo") or GetPlayer().components.combat.target == guy)
    end)

    return newtarget
end

local function NormalKeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
           and (not target.LightWatcher or target.LightWatcher:IsInLight())
end

local function CalcSanityAura(inst, observer)
	if inst.components.follower and inst.components.follower.leader == observer then
		if inst.components.sanity:GetPercent() <= .25 then
			return -TUNING.SANITYAURA_LARGE
		elseif inst.components.sanity:GetPercent() <= .50 then
			return -TUNING.SANITYAURA_MED
		elseif inst.components.sanity:GetPercent() <= .60 then
			return -TUNING.SANITYAURA_TINY
		elseif inst.components.sanity:GetPercent() <= .70 then
			return TUNING.SANITYAURA_TINY
		elseif inst.components.sanity:GetPercent() <= .80 then
			return TUNING.SANITYAURA_SMALL
		elseif inst.components.sanity:GetPercent() <= .90 then
			return TUNING.SANITYAURA_MED
		else
			return TUNING.SANITYAURA_LARGE
		end
	end
	return 0
end

local function ShouldAcceptItem(inst, item)
	if inst.components.sleeper.isasleep then
		return false
	end
	
	if inst.components.beaverness and inst.components.beaverness:IsBeaver() and item.prefab ~= "log" then
		return false
	end
	
	if item.components.book and not inst.components.reader then
		return false
	end
	if (item.prefab == "dsawaxwelljournal" and inst.prefab ~= "dsawaxwell") or ((item.prefab == "dsabook_sleep" or item.prefab == "dsabook_gardening" or item.prefab == "dsabook_brimstone" or item.prefab == "dsabook_birds" or item.prefab == "dsabook_tentacles") and inst.prefab ~= "dsawickerbottom") or (item.prefab == "dsalucy" and inst.prefab ~= "dsawoodie") or (item.prefab == "dsalighter" and inst.prefab ~= "dsawillow") or (item.prefab == "dsaabigail_flower" and inst.prefab ~= "dsawendy") or (item.prefab == "dsaballoons_empty" and inst.prefab ~= "dsawes") then
		return false
	end
	
	if item.prefab == 'bedroll_straw' or item.prefab == 'bedroll_furry' then
		if inst:HasTag('insomniac') then
			return false
		end
		if GetClock():IsDay() then
			return false
		end
		local danger = FindEntity(inst, 10, function(target) return target:HasTag("monster") or target.components.combat and target.components.combat.target == inst end)
		local hounded = GetWorld().components.hounded

		if hounded and (hounded.warning or hounded.timetoattack <= 0) then
			danger = true
		end
		if danger then
			return false
		end
		if inst.components.hunger.current < TUNING.CALORIES_MED then
			return false
		end
	end
	
	if item.components.edible and item.components.edible.foodtype ~= "MEAT" and inst.prefab == "dsawathgrithr" then
		return false
	end
	
	return true	
end

local function TryToEat(inst, item) 
	if inst.components.eater:CanEat(item) and (item:HasTag("preparedfood") or string.match(item.prefab, "cooked") or item.components.edible.foodtype == "GEARS" or (inst.prefab == "dsawebber" and item.prefab == "monstermeat")) then
		local ba = BufferedAction(inst, item, ACTIONS.EAT) 
		inst:PushBufferedAction(ba)
	end
end

local function TryToRead(inst,item)
	if (item.prefab == "dsawaxwelljournal" and inst.prefab == "dsawaxwell") or (inst.prefab == "dsawickerbottom" and (item.prefab == "dsabook_sleep" or item.prefab == "dsabook_gardening" or item.prefab == "dsabook_brimstone" or item.prefab == "dsabook_birds" or item.prefab == "dsabook_tentacles")) then
		local ba = BufferedAction(inst, item, ACTIONS.READ) 
		inst:PushBufferedAction(ba)
	end
end

local function TryToInflate(inst,item)
	local ba = BufferedAction(inst, nil, ACTIONS.MAKEBALLOON, item) 
	inst:PushBufferedAction(ba)
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.equippable and (item.components.equippable.equipslot == EQUIPSLOTS.HEAD or item.components.equippable.equipslot == EQUIPSLOTS.HANDS or item.components.equippable.equipslot == EQUIPSLOTS.BODY) then
        inst.components.inventory:Equip(item)
	elseif item.components.edible then
		TryToEat(inst, item)
    elseif item.prefab == 'bedroll_straw' then
		inst.bedroll = 'straw'
		inst.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_straw", "bedroll_straw")
		inst.components.sleeper:GoToSleep()
		item:Remove()
	elseif item.prefab == 'bedroll_furry' then
		inst.bedroll = 'furry'
		inst.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_furry", "bedroll_furry")	
		inst.components.sleeper:GoToSleep()
		local usesRemaining = item.components.finiteuses:GetUses() - 1
		if usesRemaining > 0 then
			item.components.finiteuses:SetUses(usesRemaining)
		else
			item:Remove()
		end
	elseif item.components.book then
		TryToRead(inst, item)
	elseif item.prefab == "dsaballoons_empty" then
		TryToInflate(inst, item)
    end
end

local function OnRefuseItem(inst, giver, item)
	if item.prefab == 'bedroll_straw' or item.prefab == 'bedroll_furry' then
		if GetClock():IsDay() then
			local tosay = "ANNOUNCE_NODAYSLEEP"
			if GetWorld():IsCave() then
				tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
			end
			inst.components.talker:Say(GetString(inst.prefab, tosay))
		end
		local danger = FindEntity(inst, 10, function(target) return target:HasTag("monster") or target.components.combat and target.components.combat.target == inst end)
		local hounded = GetWorld().components.hounded

		if hounded and (hounded.warning or hounded.timetoattack <= 0) then
			danger = true
		end
		if danger then
			inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_NODANGERSLEEP"))
		end

		if inst.components.hunger.current < TUNING.CALORIES_MED then
			inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_NOHUNGERSLEEP"))
		end
	elseif item.components.edible then
		inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "INVALID"))
	else
		inst.components.talker:Say(GetString(inst.prefab, "ACTIONFAIL_GENERIC"))
	end
end

local function NormalShouldSleep(inst)
    return false
end

local function AddStatus(inst)
	local mult = 10 ^ 2
	local healthP = math.floor(tostring(inst.components.health:GetPercent()) * mult + 0.5)
	local sanityP = math.floor(tostring(inst.components.sanity:GetPercent()) * mult + 0.5)
	local hungerP = math.floor(tostring(inst.components.hunger:GetPercent()) * mult + 0.5)
	local health = math.floor(tostring(inst.components.health.currenthealth))
	local sanity = math.floor(tostring(inst.components.sanity.current))
	local hunger = math.floor(tostring(inst.components.hunger.current))
	if inst.components.beaverness and inst.components.beaverness:IsBeaver() then
		local beaverness = math.floor(tostring(inst.components.beaverness:GetPercent()) * mult + 0.5)
		return inst.desc.."\n\nBeaverness: "..beaverness.." ("..beaverness.."%)"
	elseif inst.components.moisture and inst.components.moisture:GetMoisturePercent() > 0 then
		local moisture = math.floor(tostring(inst.components.moisture:GetMoisturePercent()) * mult + 0.5)
		return inst.desc.."\n\nHealth: "..health.." ("..healthP.."%)\nSanity: "..sanity.." ("..sanityP.."%)\nHunger: "..hunger.." ("..hungerP.."%)\nMoisture: "..moisture.." ("..moisture.."%)"
	else
		return inst.desc.."\n\nHealth: "..health.." ("..healthP.."%)\nSanity: "..sanity.." ("..sanityP.."%)\nHunger: "..hunger.." ("..hungerP.."%)"
	end
end

local BeaverBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "beaver_meter", owner)
end)

local function HasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function SetHUDState(inst)

	local labels = {}
	if inst.follower_pos == 0 then
		for k,v in pairs(Ents) do
			if v:HasTag("resurrected") and v.follower_pos then
				table.insert(labels, v.follower_pos)
			end
		end
		for k = 1, 9 do
			if not HasValue(labels, k) then
				inst.follower_pos = k
				break
			end
		end
	end

	if inst.follower_pos == 0 then
		return
	end

	local x = -1 * (70 + (125 * inst.follower_pos))
	if inst.namebadge == nil then
		inst.namebadge = GetPlayer().HUD.controls.sidepanel:AddChild(Text(TITLEFONT, 25))
	end

	if inst.prefab == 'dsawilson' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWILSON)
	elseif inst.prefab == 'dsawillow' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWILLOW)
	elseif inst.prefab == 'dsawolfgang' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWOLFGANG)
	elseif inst.prefab == 'dsawendy' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWENDY)
	elseif inst.prefab == 'dsawx78' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWX78)
	elseif inst.prefab == 'dsawickerbottom' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWICKERBOTTOM)
	elseif inst.prefab == 'dsawoodie' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWOODIE)
	elseif inst.prefab == 'dsawes' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWES)
	elseif inst.prefab == 'dsawaxwell' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWAXWELL)
	elseif inst.prefab == 'dsawebber' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWEBBER)
	elseif inst.prefab == 'dsawathgrithr' then
		inst.namebadge:SetString(STRINGS.NAMES.DSAWATHGRITHR)
	end
	
	inst.namebadge:SetPosition(x, 40, 0)
	
	if inst.components.beaverness and inst.components.beaverness:IsBeaver() then
		if inst.healthbadge then
			inst.healthbadge:Kill()
			inst.healthbadge = nil
		end
		if inst.hungerbadge then
			inst.hungerbadge:Kill()
			inst.hungerbadge = nil
		end
		if inst.sanitybadge then
			inst.sanitybadge:Kill()
			inst.sanitybadge = nil	
		end
		if inst.moisturemeter then
			inst.moisturemeter:Kill()
			inst.moisturemeter = nil	
		end
		if not inst.beaverbadge then
			inst.beaverbadge = GetPlayer().HUD.controls.sidepanel:AddChild(BeaverBadge(inst))
			inst.beaverbadge:SetPosition(x,-25,0)
			inst.beaverbadge:SetScale(0.75,0.75,0.75)
			inst.beaverbadge:SetPercent(1)
			inst.beaverbadge.inst:ListenForEvent("beavernessdelta", function(_, data) 
				inst.beaverbadge:SetPercent(inst.components.beaverness:GetPercent(), inst.components.beaverness.max)
				if not data.overtime then
					if data.newpercent > data.oldpercent then
						inst.beaverbadge:PulseGreen()
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
					elseif data.newpercent < data.oldpercent then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
						inst.beaverbadge:PulseRed()
					end
				end
			end, inst)
		end
	else
		if inst.beaverbadge then
			inst.beaverbadge:Kill()
			inst.beaverbadge = nil
		end
		if not inst.healthbadge then
			inst.healthbadge = GetPlayer().HUD.controls.sidepanel:AddChild(HealthBadge(inst))
			inst.healthbadge:SetPosition(x+25,0,0)
			inst.healthbadge:SetScale(0.75,0.75,0.75)
			inst.healthbadge:SetPercent(inst.components.health:GetPercent(), inst.components.health.maxhealth)
			inst.healthbadge.inst:ListenForEvent("healthdelta", function(_, data) 
				inst.healthbadge:SetPercent(inst.components.health:GetPercent(), inst.components.health.maxhealth)
				if not data.overtime then
					if data.newpercent > data.oldpercent then
						inst.healthbadge:PulseGreen()
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
					elseif data.newpercent < data.oldpercent then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
						inst.healthbadge:PulseRed()
					end
				end
			end, inst)		
		end
		if not inst.hungerbadge then
			inst.hungerbadge = GetPlayer().HUD.controls.sidepanel:AddChild(HungerBadge(inst))
			inst.hungerbadge:SetPosition(x-25,0,0)
			inst.hungerbadge:SetScale(0.75,0.75,0.75)
			inst.hungerbadge:SetPercent(inst.components.hunger:GetPercent())
			inst.hungerbadge.inst:ListenForEvent("hungerdelta", function(_, data) 
				inst.hungerbadge:SetPercent(inst.components.hunger:GetPercent(), inst.components.hunger.max)
				if not data.overtime then
					if data.newpercent > data.oldpercent then
						inst.hungerbadge:PulseGreen()
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_up")
					elseif data.newpercent < data.oldpercent then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_down")
						inst.hungerbadge:PulseRed()
					end
				end
			end, inst)
		end
		if not inst.sanitybadge then
			inst.sanitybadge = GetPlayer().HUD.controls.sidepanel:AddChild(SanityBadge(inst))
			inst.sanitybadge:SetPosition(x-25,-50,0)
			inst.sanitybadge:SetScale(0.75,0.75,0.75)
			inst.sanitybadge:SetPercent(inst.components.sanity:GetPercent())
			inst.sanitybadge.inst:ListenForEvent("sanitydelta", function(_, data) 
				inst.sanitybadge:SetPercent(inst.components.sanity:GetPercent(), inst.components.sanity.max)
				if not data.overtime then
					if data.newpercent > data.oldpercent then
						inst.sanitybadge:PulseGreen()
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
					elseif data.newpercent < data.oldpercent then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
						inst.sanitybadge:PulseRed()
					end
				end
			end, inst)
		end
		if (IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC)) and not inst.moisturemeter then
			inst.moisturemeter = GetPlayer().HUD.controls.sidepanel:AddChild(MoistureMeter(inst))
			inst.moisturemeter:SetPosition(x+25,-50,0)
			inst.moisturemeter:SetScale(0.75,0.75,0.75)
		end
	end
end

--[[WILLOW]]
local function SanityFn(inst)
	local x,y,z = inst.Transform:GetWorldPosition()	
	local delta = 0
	local max_rad = 10
	local ents = TheSim:FindEntities(x,y,z, max_rad, {"fire"})
    for k,v in pairs(ents) do 
    	if v.components.burnable and v.components.burnable.burning then
    		local sz = TUNING.SANITYAURA_TINY
    		local rad = v.components.burnable:GetLargestLightRadius() or 1
    		sz = sz * ( math.min(max_rad, rad) / max_rad )
			local distsq = inst:GetDistanceSqToInst(v)
			delta = delta + sz/math.max(1, distsq)
    	end
    end
    
    return delta
end

--[[WOLFGANG]]
local function ApplyMightiness(inst)

	local percent = inst.components.hunger:GetPercent()
	
	local damage_mult = TUNING.WOLFGANG_ATTACKMULT_NORMAL
	local hunger_rate = TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL
	local health_max = TUNING.WOLFGANG_HEALTH_NORMAL
	local scale = 1

	local mighty_scale = 1.25
	local wimpy_scale = .9


	if inst.strength == "mighty" then
		local mighty_start = (TUNING.WOLFGANG_START_MIGHTY_THRESH/TUNING.WOLFGANG_HUNGER)	
		local mighty_percent = math.max(0, (percent - mighty_start) / (1 - mighty_start))
		damage_mult = easing.linear(mighty_percent, TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN, TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MAX - TUNING.WOLFGANG_ATTACKMULT_MIGHTY_MIN, 1)
		health_max = easing.linear(mighty_percent, TUNING.WOLFGANG_HEALTH_NORMAL, TUNING.WOLFGANG_HEALTH_MIGHTY - TUNING.WOLFGANG_HEALTH_NORMAL, 1)	
		hunger_rate = easing.linear(mighty_percent, TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL, TUNING.WOLFGANG_HUNGER_RATE_MULT_MIGHTY - TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL, 1)	
		scale = easing.linear(mighty_percent, 1, mighty_scale - 1, 1)	
	elseif inst.strength == "wimpy" then
		local wimpy_start = (TUNING.WOLFGANG_START_WIMPY_THRESH/TUNING.WOLFGANG_HUNGER)	
		local wimpy_percent = math.min(1, percent/wimpy_start )
		damage_mult = easing.linear(wimpy_percent, TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN, TUNING.WOLFGANG_ATTACKMULT_WIMPY_MAX - TUNING.WOLFGANG_ATTACKMULT_WIMPY_MIN, 1)
		health_max = easing.linear(wimpy_percent, TUNING.WOLFGANG_HEALTH_WIMPY, TUNING.WOLFGANG_HEALTH_NORMAL - TUNING.WOLFGANG_HEALTH_WIMPY, 1)	
		hunger_rate = easing.linear(wimpy_percent, TUNING.WOLFGANG_HUNGER_RATE_MULT_WIMPY, TUNING.WOLFGANG_HUNGER_RATE_MULT_NORMAL - TUNING.WOLFGANG_HUNGER_RATE_MULT_WIMPY, 1)	
		scale = easing.linear(wimpy_percent, wimpy_scale, 1 - wimpy_scale, 1)	
	end
	
	inst.Transform:SetScale(scale,scale,scale)
	inst.components.hunger:SetRate(hunger_rate*TUNING.WILSON_HUNGER_RATE)
	inst.components.combat.damagemultiplier = damage_mult

	local health_percent = inst.components.health:GetPercent()
	inst.components.health.maxhealth = health_max
	inst.components.health:SetPercent(health_percent)
	inst.components.health:DoDelta(0, true)

end

local function OnHungerChange(inst, data)

	local silent = POPULATING

	if inst.strength == "mighty" then
		if inst.components.hunger.current < TUNING.WOLFGANG_END_MIGHTY_THRESH then
			inst.strength = "normal"
			inst.AnimState:SetBuild("wolfgang")

			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_MIGHTYTONORMAL"))
				inst.sg:PushEvent("powerdown")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/shrink_lrgtomed")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt"
		end
	elseif inst.strength == "wimpy" then
		if inst.components.hunger.current > TUNING.WOLFGANG_END_WIMPY_THRESH then
			inst.strength = "normal"
			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_WIMPYTONORMAL"))
				inst.sg:PushEvent("powerup")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_smtomed")	
			end
			inst.AnimState:SetBuild("wolfgang")
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt"
		end
	else
		if inst.components.hunger.current > TUNING.WOLFGANG_START_MIGHTY_THRESH then
			inst.strength = "mighty"
			inst.AnimState:SetBuild("wolfgang_mighty")
			if not silent then
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_NORMALTOMIGHTY"))
				inst.sg:PushEvent("powerup")
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/grow_medtolrg")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_large_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_large"

		elseif inst.components.hunger.current < TUNING.WOLFGANG_START_WIMPY_THRESH then
			inst.strength = "wimpy"
			inst.AnimState:SetBuild("wolfgang_skinny")
			if not silent then
				inst.sg:PushEvent("powerdown")
				inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_NORMALTOWIMPY"))
				inst.SoundEmitter:PlaySound("dontstarve/characters/wolfgang/shrink_medtosml")
			end
			inst.talksoundoverride = "dontstarve/characters/wolfgang/talk_small_LP"
			inst.hurtsoundoverride = "dontstarve/characters/wolfgang/hurt_small"
		end
	end

	ApplyMightiness(inst)
end

--[[WENDY]]
local function DropFlower(inst, data)
    local target = inst.components.inventory:FindItem(function(item) 
		return item.prefab == "dsaabigail_flower" and item.components.inspectable and item.components.inspectable.getstatus(item) == "HAUNTED_POCKET"
	end)
	if target then
		inst.components.inventory:DropItem(target)
	end
end

--[[WX-78]]
local function ApplyUpgrades(inst)
	local max_upgrades = 15
	local upgrades = math.min(inst.level, max_upgrades)

	local hunger_percent = inst.components.hunger:GetPercent()
	local health_percent = inst.components.health:GetPercent()
	local sanity_percent = inst.components.sanity:GetPercent()

	inst.components.hunger.max = math.ceil(TUNING.WX78_MIN_HUNGER + upgrades* (TUNING.WX78_MAX_HUNGER - TUNING.WX78_MIN_HUNGER)/max_upgrades)
	inst.components.health.maxhealth = math.ceil(TUNING.WX78_MIN_HEALTH + upgrades* (TUNING.WX78_MAX_HEALTH - TUNING.WX78_MIN_HEALTH)/max_upgrades)
	inst.components.sanity.max = math.ceil(TUNING.WX78_MIN_SANITY + upgrades* (TUNING.WX78_MAX_SANITY - TUNING.WX78_MIN_SANITY)/max_upgrades)

	inst.components.hunger:SetPercent(hunger_percent)
	inst.components.health:SetPercent(health_percent)
	inst.components.sanity:SetPercent(sanity_percent)
end

local function OnEat(inst, food)
	if food and food.components.edible and food.components.edible.foodtype == "GEARS" then
		--give an upgrade!
		inst.level = inst.level + 1
		ApplyUpgrades(inst)	
		inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
	end
end

local OnLoadFn = function(inst, data)
	if data then
		if data.sleeping then
			if data.bedroll == 'straw' then
				inst.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_straw", "bedroll_straw")
				inst.bedroll = 'straw'
			elseif data.bedroll == 'furry' then		
				inst.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_furry", "bedroll_furry")
				inst.bedroll = 'furry'
			end
			inst.components.sleeper:GoToSleep()
		end
		if data.charge_time then
			inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

			OnUpdate(inst, 0)
			inst.charged_task = inst:DoPeriodicTask(1, OnUpdate, nil, 1)
		end
		if data.level then
			inst.level = data.level
			ApplyUpgrades(inst)
			--re-set these from the save data, because of load-order clipping issues
			if data.health and data.health.health then inst.components.health.currenthealth = data.health.health end
			if data.hunger and data.hunger.hunger then inst.components.hunger.current = data.hunger.hunger end
			if data.sanity and data.sanity.current then inst.components.sanity.current = data.sanity.current end
			inst.components.health:DoDelta(0)
			inst.components.hunger:DoDelta(0)
			inst.components.sanity:DoDelta(0)
		end
		if data.follower_pos then
			inst.follower_pos = data.follower_pos
		end
	end
end

local OnSaveFn = function(inst, data)
	if inst.components.sleeper:IsAsleep() then
		data.sleeping = true
		data.bedroll = inst.bedroll
	end
	if inst.prefab == 'dsawx78' then
		data.level = inst.level
		data.charge_time = inst.charge_time
	end
	data.follower_pos = inst.follower_pos
end

local function OnPreload(inst, data)
	if data then
		if data.level then
			inst.level = data.level
			ApplyUpgrades(inst)
			--re-set these from the save data, because of load-order clipping issues
			if data.health and data.health.health then inst.components.health.currenthealth = data.health.health end
			if data.hunger and data.hunger.hunger then inst.components.hunger.current = data.hunger.hunger end
			if data.sanity and data.sanity.current then inst.components.sanity.current = data.sanity.current end
			inst.components.health:DoDelta(0)
			inst.components.hunger:DoDelta(0)
			inst.components.sanity:DoDelta(0)
		end
	end
end

local function OnLightningStrike(inst)
	if inst.components.health and not inst.components.health:IsDead() then
		local protected = false
	    if inst.components.inventory:IsInsulated() then
	        protected = true
	    end

	    if not protected then
			inst.charge_time = inst.charge_time + TUNING.TOTAL_DAY_TIME*(.5 + .5*math.random())

			inst.sg:GoToState("electrocute")
			inst.components.health:DoDelta(TUNING.HEALING_SUPERHUGE,false,"lightning")
			inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
			inst.components.talker:Say(GetString("wx78", "ANNOUNCE_CHARGE"))

			inst.SoundEmitter:KillSound("overcharge_sound")
			inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/charged", "overcharge_sound")
			inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
			
			if not inst.charged_task then
				OnUpdate(inst, 0)
				inst.charged_task = inst:DoPeriodicTask(1, OnUpdate, nil, 1)
			end
		else
			inst:PushEvent("lightningdamageavoided")
		end
	end
end

local function DoRainSparks(inst, dt)
	local mitigates_rain = false
	for k,v in pairs (inst.components.inventory.equipslots) do
		if v.components.dapperness then
			if v.components.dapperness.mitigates_rain then
				mitigates_rain = true
			end
		end		
	end
	
    if GetSeasonManager() and GetSeasonManager():IsRaining() and not mitigates_rain then
    	inst.spark_time = inst.spark_time - dt

    	if inst.spark_time <= 0 then   		
    		--GetClock():DoLightningLighting()
    		inst.spark_time = 3+math.random()*2
    		inst.components.health:DoDelta(-.5, false, "rain")
			local pos = Vector3(inst.Transform:GetWorldPosition())
			pos.y = pos.y + 1 + math.random()*1.5
			local spark = SpawnPrefab("sparks")
			spark.Transform:SetPosition(pos:Get())			
    	end
    end
end

--[[WOODIE]]
local function onbeavereat(inst, data)
	if data.food and data.food.components.edible.woodiness and inst.components.beaverness then
		inst.components.beaverness:DoDelta(data.food.components.edible.woodiness)
	end
end

local function beaverhurt(inst, delta)
	if delta < 0 then
		inst.sg:PushEvent("attacked")
		inst.components.beaverness:DoDelta(delta*.25)
	end
end

local function BecomeWoodie(inst)
	inst.beaver = false
    inst.ActionStringOverride = nil
    inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("woodie")
	if IsDLCEnabled(REIGN_OF_GIANTS) then
		inst:SetStateGraph("SGfollowerrog")
	elseif IsDLCEnabled(CAPY_DLC) then
		inst:SetStateGraph("SGfollowersw")
	else
		inst:SetStateGraph("SGfollowerds")
	end
	inst:RemoveTag("beaver")
	
	inst:RemoveComponent("worker")
	inst.components.talker:StopIgnoringAll()
	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
	inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
	
	inst.components.eater:SetOmnivore()
	
	inst.components.hunger:Resume()
	inst.components.sanity.ignore = false
	inst.components.health.redirect = nil
	
	inst.components.beaverness:StartTimeEffect(2, -1)
	
	inst:RemoveEventCallback("oneatsomething", onbeavereat)
	inst.components.temperature:SetTemp(nil)
	
	inst:DoTaskInTime(0, function() SetHUDState(inst) end)
end

local function onworked(inst, data)
	if not inst.components.beaverness:IsBeaver() and data.target and data.target.components.workable and data.target.components.workable.action == ACTIONS.CHOP then
		inst.components.beaverness:DoDelta(3)
	end
end

local function BecomeBeaver(inst)
	inst.beaver = true
	inst:AddTag("beaver")
	inst.AnimState:SetBuild("werebeaver_build")
	inst.AnimState:SetBank("werebeaver")
	inst:SetStateGraph("SGwoodbeaver")
	inst.components.talker:IgnoreAll()
	inst.components.combat:SetDefaultDamage(TUNING.BEAVER_DAMAGE)
    inst.components.combat:SetAttackPeriod(0)

	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.1
	inst.components.inventory:DropEverything()
	
	inst.components.eater:SetBeaver()

	inst:AddComponent("worker")
	inst.components.worker:SetAction(ACTIONS.DIG, 1)
	inst.components.worker:SetAction(ACTIONS.CHOP, 4)
	inst.components.worker:SetAction(ACTIONS.MINE, 1)
	inst.components.worker:SetAction(ACTIONS.HAMMER, 1)
	inst:ListenForEvent("oneatsomething", onbeavereat)

	inst.components.sanity:SetPercent(1)
	inst.components.health:SetPercent(1)
	inst.components.hunger:SetPercent(1)

	inst.components.hunger:Pause()
	inst.components.sanity.ignore = true
    inst.components.temperature:SetTemp(20)
    inst.components.health.redirect = beaverhurt
	inst.components.health.redirect_percent = .25

	local dt = 3
	local BEAVER_DRAIN_TIME = 120
	inst.components.beaverness:StartTimeEffect(dt, (-100/BEAVER_DRAIN_TIME)*dt)
	inst.components.temperature:SetTemp(20)
    
	inst:DoTaskInTime(0, function() SetHUDState(inst) end)
end

--[[WES]]
local function MakeBalloon(inst)
	local target = inst.components.inventory:FindItem(function(item) return item.prefab == "dsaballoons_empty" end)
    if target then
		local ba = BufferedAction(inst, nil, ACTIONS.MAKEBALLOON, target) 
		inst:PushBufferedAction(ba)
    end
end

--[[WIGFRID]]
local function onkill(inst, data)
	if data.cause == inst.prefab 
		and not data.inst:HasTag("prey") 
		and not data.inst:HasTag("veggie") 
		and not data.inst:HasTag("structure") then
		local delta = (data.inst.components.combat.defaultdamage) * 0.25
        inst.components.health:DoDelta(delta, false, "battleborn")
        inst.components.sanity:DoDelta(delta)

        if math.random() < .1 and not data.inst.components.health.nofadeout then
        	local time = data.inst.components.health.destroytime or 2
        	inst:DoTaskInTime(time, function()
        		local s = 0.7
        		if data.inst:HasTag("smallcreature") then
        			s = 0.5
    			elseif data.inst:HasTag("largecreature") then
    				s = 1.1
    			end
        		local fx = SpawnPrefab("wathgrithr_spirit")
        		fx.Transform:SetPosition(data.inst:GetPosition():Get())
        		fx.Transform:SetScale(s,s,s)
    		end)
        end
	end
end

--[[COMMON]]
local function MakeFollower(modelname)
    
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	local minimap = inst.entity:AddMiniMapEntity()
	local player = GetPlayer()
	
	inst.bedroll = nil
	inst.namebadge = nil
	inst.healthbadge = nil
	inst.hungerbadge = nil
	inst.sanitybadge = nil
	inst.beaverbadge = nil
	inst.moisturemeter = nil
	inst.follower_pos = 0
	
    inst.entity:AddLabel()
    inst.Label:SetFontSize(20)
    inst.Label:SetFont(DEFAULTFONT)
    inst.Label:SetPos(0,3,0)
    inst.Label:SetColour(1, 1, 1)
    inst.Label:Enable(true)
	
    inst.Transform:SetFourFaced()
	
    MakeCharacterPhysics(inst, 30, .3)
	
	if IsDLCEnabled(CAPY_DLC) then 
		MakePoisonableCharacter(inst, nil, nil, 0, 0, 0)
		inst.components.poisonable.duration = TUNING.TOTAL_DAY_TIME * 3
		inst.components.poisonable.transfer_poison_on_attack = false
		inst.components.poisonable.show_fx = false
	end
	
	shadow:SetSize(1.3, .6)
	
    minimap:SetIcon(modelname..".png")
    minimap:SetPriority(10)
	
	local lightwatch = inst.entity:AddLightWatcher()
	lightwatch:SetLightThresh(.075)
	lightwatch:SetDarkThresh(.05)

    inst:AddTag(modelname)
    inst:AddTag("resurrected")
    inst:AddTag("scarytoprey")
    inst:AddTag("character")
	inst:AddTag("companion")

    anim:SetBank("wilson")
	anim:SetBuild(modelname)
	
    anim:Hide("ARM_carry") 
	anim:Hide("hat")
	anim:Hide("hat_hair")
	anim:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	anim:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
	anim:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")
		
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.components.locomotor.fasteronroad = true
   
	inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
	inst.components.combat:SetRange(2)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
	inst.components.combat.hiteffectsymbol = "torso"
	function inst.components.combat:GetBattleCryString(target)
		return target ~= nil
			and target:IsValid()
			and GetString(
				inst.soundsname,
				"BATTLECRY",
				(target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
				(string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or target.prefab
			)
			or nil         
	end
	function inst.components.combat:GetGiveUpString(combat, target)
		local str = ""
		if target and target:HasTag("prey") then
			str = GetString(inst.soundsname, "COMBAT_QUIT", "prey")
		else
			str = GetString(inst.soundsname, "COMBAT_QUIT")
		end
		return str
	end
	
    inst:AddComponent("inventory")
	
	if IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC) then 
		inst:AddComponent("moisture")
	end
	
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH)
	
    inst:AddComponent("hunger")
    inst.components.hunger:SetMax(TUNING.WILSON_HUNGER)
    inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
    inst.components.hunger:SetKillRate(TUNING.WILSON_HEALTH/TUNING.STARVE_KILL_TIME)
	
    inst:AddComponent("sanity")
	inst.components.sanity:SetMax(TUNING.WILSON_SANITY)
	
    inst:AddComponent("kramped")
    inst:AddComponent("talker")
    inst.components.talker:StopIgnoringAll()
	
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
	
    inst:AddComponent("wisecrackerfollower")
        
	inst:AddComponent("resurrectable")
	
    inst:AddComponent("temperature")

    inst:AddComponent("catcher")
	
	if IsDLCEnabled(REIGN_OF_GIANTS) then
		inst:AddComponent("playerlightningtarget")
	end
	
    inst:AddComponent("eater")
    inst.components.eater:SetOmnivore()
	
    inst:AddComponent("frostybreather")

	inst:AddComponent("grue")
	inst.components.grue:SetSounds("dontstarve/charlie/warn","dontstarve/charlie/attack")
	
	if IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC) then 
        MakeHugeFreezableCharacter(inst)
        inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)
	end
	
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("follower")
	
    inst:AddComponent("inspectable")
	--inst.components.inspectable:SetDescription(AddStatus)
    ------------------------------------------
   
	if IsDLCEnabled(CAPY_DLC) then
		inst:SetBrain(brainsw)
	else
		inst:SetBrain(brain)
	end
	
    inst:AddComponent("lootdropper")

	if IsDLCEnabled(REIGN_OF_GIANTS) then
		inst:SetStateGraph("SGfollowerrog")
	elseif IsDLCEnabled(CAPY_DLC) then
		inst:SetStateGraph("SGfollowersw")
	else
		inst:SetStateGraph("SGfollowerds")
	end
	
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetSleepTest(NormalShouldSleep)
    inst.components.sleeper:SetWakeTest(DefaultWakeTest)
	
    inst:AddComponent("followercommands")
	
	if IsDLCEnabled(CAPY_DLC) then
		inst:AddComponent("keeponland")

		inst:AddComponent("krakener")

		inst:AddComponent("driver")
		inst.components.driver.landstategraph = "SGfollowersw"
		inst.components.driver.boatingstategraph = "SGfollowerboating"
	end
		
    inst:ListenForEvent("attacked", OnAttacked)    
    inst:ListenForEvent("onattackother", OnAttackOther)
    --inst:ListenForEvent("newcombattarget", OnNewTarget)
	inst:ListenForEvent("daytime", function(global, data)
	    --[[if inst.components.beaverness and inst.components.beaverness:IsBeaver() then
	        if not inst.components.beaverness.doing_transform then
				inst.components.beaverness:SetPercent(0)
			end]]
		if inst.bedroll == 'straw' then
			inst.bedroll = nil
			inst.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
			inst.components.sanity:DoDelta(TUNING.SANITY_LARGE, false)
			inst.components.temperature:SetTemperature(15)
		elseif inst.bedroll == 'furry' then
			inst.bedroll = nil
			inst.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
			inst.components.sanity:DoDelta(TUNING.SANITY_HUGE, false)
			inst.components.health:DoDelta(TUNING.HEALING_MEDLARGE, false, "bedroll", true)
			inst.components.temperature:SetTemperature(inst.components.temperature.maxtemp)
	    end
	end, GetWorld())
	inst:ListenForEvent("death", function () 
				if inst.namebadge then
					inst.namebadge:Kill()
					inst.namebadge = nil
				end
				if inst.healthbadge then
					inst.healthbadge:Kill()
					inst.healthbadge = nil
				end
				if inst.hungerbadge then
					inst.hungerbadge:Kill()
					inst.hungerbadge = nil
				end
				if inst.sanitybadge then
					inst.sanitybadge:Kill()
					inst.sanitybadge = nil
				end
				if inst.moisturemeter then
					inst.moisturemeter:Kill()
					inst.moisturemeter = nil
				end
			end)
	inst:DoTaskInTime(0, function() SetHUDState(inst) end)
	
	inst.OnSave = OnSaveFn
	inst.OnLoad = OnLoadFn
    return inst
end

local function wilson()
	local inst = MakeFollower("wilson")
	inst.desc = "Wilson, the gentleman scientist."
	inst.soundsname = "wilson" 
		
	inst:AddComponent("beard")
    inst.components.beard.onreset = function()
        inst.AnimState:ClearOverrideSymbol("beard")
    end
    inst.components.beard.prize = "beardhair"
    
	local beard_days = {4, 8, 16}
	local beard_bits = {1, 3,  9}
    
    inst.components.beard:AddCallback(beard_days[1], function()
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_short")
        inst.components.beard.bits = beard_bits[1]
    end)
    
    inst.components.beard:AddCallback(beard_days[2], function()
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_medium")
        inst.components.beard.bits = beard_bits[2]
    end)
    
    inst.components.beard:AddCallback(beard_days[3], function()
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_long")
        inst.components.beard.bits = beard_bits[3]
    end)

	return inst
end

local function willow()
    local inst = MakeFollower("willow")
	inst.desc = "Willow, the firestarter."
	inst.soundsname = "willow" 
	--inst.components.inventory:GuaranteeItems(willow_inv)
	
	inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)
	inst.components.sanity.custom_rate_fn = SanityFn
	
	inst:AddComponent("firebug")
	inst.components.firebug.prefab = "willowfire"
	inst.components.health.fire_damage_scale = 0
	
    return inst
end

local function wolfgang()
    local inst = MakeFollower("wolfgang")
	inst.desc = "Wolfgang, the strongman."
	inst.soundsname = "wolfgang"
	
	inst.components.sanity.night_drain_mult = 1.1
	inst.components.sanity.neg_aura_mult = 1.1
	
	inst.strength = "normal"
   	inst.components.hunger:SetMax(TUNING.WOLFGANG_HUNGER)
	inst.components.hunger.current = TUNING.WOLFGANG_START_HUNGER
	ApplyMightiness(inst)
	
	inst:ListenForEvent("hungerdelta", OnHungerChange)

    return inst
end

local function wendy()
	local inst = MakeFollower("wendy")
	inst.desc = "Wendy, the bereaved."
	inst.soundsname = "wendy"

	inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
    inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT
    inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT
	
	inst:AddComponent("leader")
	
    inst:ListenForEvent("newcombattarget", DropFlower)
    --[[inst:DoTaskInTime(0, function() 
    		local found = false
    		for k,v in pairs(Ents) do
    			if v.prefab == "dsaabigail" then
    				found = true
    				break
    			end
    		end
    		if not found then
    			inst.components.inventory:GuaranteeItems(wendy_inv)
    		end
    	end)]]
		
	return inst
end

local function wx78()
	local inst = MakeFollower("wx78")
	inst.desc = "WX-78, the soulless automaton"
	inst.soundsname = "wx78"
	inst.level = 0
	inst.charge_time = 0
	inst.spark_time = 3
	
	inst.components.eater.ignoresspoilage = true
	table.insert(inst.components.eater.foodprefs, "GEARS")
	inst.components.eater:SetOnEatFn(OnEat)
	ApplyUpgrades(inst)

	if IsDLCEnabled(REIGN_OF_GIANTS) then 
		inst.components.playerlightningtarget:SetHitChance(1)
		inst.components.playerlightningtarget:SetOnStrikeFn(OnLightningStrike)
	end
	inst:AddTag("electricdamageimmune") --This is for combat, not lightning strikes
	
    local light = inst.entity:AddLight()
    inst.Light:Enable(false)
	inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.75)
    inst.Light:SetIntensity(.9)
    inst.Light:SetColour(235/255,121/255,12/255)
	
	inst.OnLongUpdate = function(inst, dt) 
		inst.charge_time = math.max(0, inst.charge_time - dt)
	end

	inst:DoPeriodicTask(1/10, function() DoRainSparks(inst, 1/10) end)
	inst.OnPreload = OnPreload

	return inst
end

local function wickerbottom()
    local inst = MakeFollower("wickerbottom")
	inst.desc = "Wickerbottom, the librarian."
	inst.soundsname = "wickerbottom"
	
	inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)
	inst.components.sanity.custom_rate_fn = SanityFn
	
	inst:AddComponent("reader")
	
	inst:AddComponent("bookcrafter")
	inst:AddTag("insomniac")
    inst.components.eater.stale_hunger = TUNING.WICKERBOTTOM_STALE_FOOD_HUNGER
    inst.components.eater.stale_health = TUNING.WICKERBOTTOM_STALE_FOOD_HEALTH
    inst.components.eater.spoiled_hunger = TUNING.WICKERBOTTOM_SPOILED_FOOD_HUNGER
    inst.components.eater.spoiled_health = TUNING.WICKERBOTTOM_SPOILED_FOOD_HEALTH
	
	inst.components.sanity:SetMax(TUNING.WICKERBOTTOM_SANITY)

    return inst
end

local function woodie()
    local inst = MakeFollower("woodie")
	inst.desc = "Woodie, the lumberjack."
	inst.soundsname = "woodie"

	inst:AddComponent("beaverness")		
	inst.components.beaverness.makeperson = BecomeWoodie
	inst.components.beaverness.makebeaver = BecomeBeaver
	
	inst.components.beaverness.onbecomeperson = function()
		inst:PushEvent("transform_person")
	end

	inst.components.beaverness.onbecomebeaver = function()
		inst:PushEvent("transform_werebeaver")
	end
	
	inst:ListenForEvent("working", onworked)
	BecomeWoodie(inst)

    inst:ListenForEvent("nighttime", function(global, data)
	    if GetClock():GetMoonPhase() == "full" and not inst.components.beaverness:IsBeaver() and not inst.components.beaverness.ignoremoon and not inst.components.sleeper.isasleep then
	        if not inst.components.beaverness.doing_transform then
				inst.components.beaverness:SetPercent(1)
			end
		end
	end, GetWorld())
	
    return inst
end

local function wes()
	local inst = MakeFollower("wes")
	inst.desc = "Wes, the silent."
	inst.soundsname = "wes"
	inst.balloon_time = 3

	inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH * .75 )
	inst.components.hunger:SetMax(TUNING.WILSON_HUNGER * .75 )
	inst.components.combat.damagemultiplier = .75
	inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE*1.25)
	inst.components.sanity:SetMax(TUNING.WILSON_SANITY*.75)
	inst.components.talker.special_speech = true
		
	--inst:DoPeriodicTask(GetRandomWithVariance(10, 3), MakeBalloon)
	
	return inst
end

local function waxwell()
	local inst = MakeFollower("waxwell")
	inst.desc = "Maxwell, the puppetmaster."
	inst.soundsname = "maxwell"
	
	inst:AddComponent("reader")

	inst.components.sanity.dapperness = TUNING.DAPPERNESS_HUGE
	inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH * .5 )
	
	return inst
end

local function webber()
	local inst = MakeFollower("webber")
	inst.desc = "Webber, the indigestible."
	inst.soundsname = "webber"
	inst.talker_path_override = "dontstarve_DLC001/characters/"
	
	inst:AddTag("spiderwhisperer")
	inst:AddTag("monster")
	inst.components.locomotor.triggerscreep = false

	inst.components.eater.monsterimmune = true

	inst.components.health:SetMaxHealth(TUNING.WEBBER_HEALTH)
	inst.components.hunger:SetMax(TUNING.WEBBER_HUNGER)
	inst.components.sanity:SetMax(TUNING.WEBBER_SANITY)

    inst:AddComponent("beard")
    inst.components.beard.insulation_factor = TUNING.WEBBER_BEARD_INSULATION_FACTOR
    inst.components.beard.onreset = function()
        inst.AnimState:ClearOverrideSymbol("beard")
    end
    inst.components.beard.prize = "silk"
    
	local beard_days = {3, 6, 9}
	local beard_bits = {1, 3, 6}
    
    inst.components.beard:AddCallback(beard_days[1], function()
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_short")
        inst.components.beard.bits = beard_bits[1]
    end)
    
    inst.components.beard:AddCallback(beard_days[2], function()
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_medium")
        inst.components.beard.bits = beard_bits[2]
    end)
    
    inst.components.beard:AddCallback(beard_days[3], function()
        inst.AnimState:OverrideSymbol("beard", "beard_silk", "beardsilk_long")
        inst.components.beard.bits = beard_bits[3]
    end)
	
	inst:AddComponent("spidercrafter")
	
	return inst
end

local function wigfrid()
	local inst = MakeFollower("wathgrithr")
	inst.desc = "Wigfrid, the performance artist."
	inst.soundsname = "wathgrithr"
	inst.talker_path_override = "dontstarve_DLC001/characters/"

	inst.components.eater:SetCarnivore(true)

	inst.components.health:SetMaxHealth(TUNING.WATHGRITHR_HEALTH)
	inst.components.hunger:SetMax(TUNING.WATHGRITHR_HUNGER)
	inst.components.sanity:SetMax(TUNING.WATHGRITHR_SANITY)
	inst.components.combat.damagemultiplier = TUNING.WATHGRITHR_DAMAGE_MULT
	inst.components.health:SetAbsorptionAmount(TUNING.WATHGRITHR_ABSORPTION)

	inst.components.talker.font = TALKINGFONT_WATHGRITHR

    inst:ListenForEvent("entity_death", function(wrld, data) onkill(inst, data) end, GetWorld())
	
	inst:AddComponent("weaponcrafter")
	return inst
end	

return Prefab("common/dsawilson", wilson, assets),
	Prefab("common/dsawillow", willow, assets),
	Prefab("common/dsawolfgang", wolfgang, assets),
	Prefab("common/dsawendy", wendy, assets),
	Prefab("common/dsawx78", wx78, assets, prefabs),
	Prefab("common/dsawickerbottom", wickerbottom, assets),
	Prefab("common/dsawoodie", woodie, assets),
	Prefab("common/dsawes", wes, assets),
	Prefab("common/dsawaxwell", waxwell, assets),
	Prefab("common/dsawebber", webber, assets),
	Prefab("common/dsawathgrithr", wigfrid, assets)
