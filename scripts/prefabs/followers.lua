local brain = require "brains/followerbrain"
local easing = require "easing"

local assets =
{	
	Asset("ANIM", "anim/player_basic.zip"),
	Asset("ANIM", "anim/player_idles_shiver.zip"),
	Asset("ANIM", "anim/player_actions.zip"),
	Asset("ANIM", "anim/player_actions_axe.zip"),
	Asset("ANIM", "anim/player_actions_pickaxe.zip"),
	Asset("ANIM", "anim/player_actions_shovel.zip"),
	Asset("ANIM", "anim/player_actions_blowdart.zip"),
	Asset("ANIM", "anim/player_actions_eat.zip"),
	Asset("ANIM", "anim/player_actions_item.zip"),
	Asset("ANIM", "anim/player_cave_enter.zip"),
	Asset("ANIM", "anim/player_actions_uniqueitem.zip"),
	Asset("ANIM", "anim/player_actions_bugnet.zip"),
	Asset("ANIM", "anim/player_actions_fishing.zip"),
	Asset("ANIM", "anim/player_actions_boomerang.zip"),
	Asset("ANIM", "anim/player_bush_hat.zip"),
	Asset("ANIM", "anim/player_attacks.zip"),
	Asset("ANIM", "anim/player_idles.zip"),
	Asset("ANIM", "anim/player_rebirth.zip"),
	Asset("ANIM", "anim/player_jump.zip"),
	Asset("ANIM", "anim/player_amulet_resurrect.zip"),
	Asset("ANIM", "anim/player_teleport.zip"),
	Asset("ANIM", "anim/wilson_fx.zip"),
	Asset("ANIM", "anim/player_one_man_band.zip"),
	Asset("ANIM", "anim/player_slurtle_armor.zip"),
	Asset("ANIM", "anim/player_staff.zip"),
	Asset("ANIM", "anim/player_frozen.zip"),
	Asset("ANIM", "anim/player_shock.zip"),
	Asset("ANIM", "anim/shock_fx.zip"),
	Asset("ANIM", "anim/player_tornado.zip"),
	Asset("ANIM", "anim/fish01.zip"),
	Asset("ANIM", "anim/eel01.zip"),	
	Asset("ANIM", "anim/shadow_hands.zip"),
	
    Asset("ANIM", "anim/player_woodie.zip"),
	Asset("ANIM", "anim/woodie.zip"),
    Asset("ANIM", "anim/werebeaver_build.zip"),
    Asset("ANIM", "anim/werebeaver_basic.zip"),
	Asset("ANIM", "anim/wolfgang.zip"),
    Asset("ANIM", "anim/wolfgang_skinny.zip"),
    Asset("ANIM", "anim/wolfgang_mighty.zip"),
    Asset("ANIM", "anim/player_wolfgang.zip"),
	Asset("ANIM", "anim/swap_bedroll_straw.zip"),
	Asset("ANIM", "anim/willow.zip"),
    Asset("ANIM", "anim/wickerbottom.zip"),
    Asset("ANIM", "anim/wx78.zip"),
	
	Asset("SOUND", "sound/sfx.fsb"),
	Asset("SOUND", "sound/woodie.fsb"),
	Asset("SOUND", "sound/wolfgang.fsb"),
	Asset("SOUND", "sound/willow.fsb"),
	Asset("SOUND", "sound/wickerbottom.fsb"), 
	Asset("SOUND", "sound/wx78.fsb")     
}

local woodie_inv = 
{
	"ynalucy",
}

local willow_inv = 
{
	"ynalighter",
}

local wendy_inv = 
{
    "ynaabigail_flower",
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function onupdate(inst, dt)
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

local onloadfn = function(inst, data)
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

			onupdate(inst, 0)
			inst.charged_task = inst:DoPeriodicTask(1, onupdate, nil, 1)
		end
	end
end

local onsavefn = function(inst, data)
	if inst.components.sleeper:IsAsleep() then
		data.sleeping = true
		data.bedroll = inst.bedroll
	end
	if inst.prefab == 'ynawx78' then
		data.level = inst.level
		data.charge_time = inst.charge_time
	end
end

local function OnAttacked(inst, data)
    local attacker = data.attacker

    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("summonedbyplayer") and dude.components.follower.leader == GetPlayer() end, MAX_TARGET_SHARES)
end

local function OnAttackOther(inst, data)
    local target = data.target
    inst.components.combat:ShareTarget(target, SHARE_TARGET_DIST, function(dude) return dude:HasTag("summonedbyplayer") and dude.components.follower.leader == GetPlayer() end, MAX_TARGET_SHARES)
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
	if inst.components.sleeper.isasleep or (inst.components.beaverness and inst.components.beaverness:IsBeaver()) then
		return false
	end
	
	if item.components.book and not inst.components.reader then
		return false
	end
	
	if item.prefab == 'axe' and inst.prefab == 'ynawoodie' and (inst.components.inventory:Has('ynalucy', 1) or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == 'ynalucy') then
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
	
	return true	
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.equippable and (item.components.equippable.equipslot == EQUIPSLOTS.HEAD or item.components.equippable.equipslot == EQUIPSLOTS.HANDS or item.components.equippable.equipslot == EQUIPSLOTS.BODY) then    
		local newslot = item.components.equippable.equipslot
		local current = inst.components.inventory:GetEquippedItem(newslot)
		--if current then
        --    inst.components.inventory:DropItem(current)
        --end      
        inst.components.inventory:Equip(item)
	elseif item.components.edible then
		if inst.prefab == 'ynawickerbottom' and (item.prefab == 'bird_egg' or item.prefab == 'seeds') then
			return
		else
			inst.components.eater:Eat(item) 
		end
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
		if item.prefab == 'ynabook_birds' then
			inst.read = 'ynabook_birds' 
		elseif item.prefab == 'ynabook_tentacles' then
			inst.read = 'ynabook_tentacles' 
		elseif item.prefab == 'ynabook_gardening' then
			inst.read = 'ynabook_gardening' 
		elseif item.prefab == 'ynabook_brimstone' then
			inst.read = 'ynabook_brimstone' 
		elseif item.prefab == 'ynabook_sleep' then
			inst.read = 'ynabook_sleep' 
		end
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
	elseif item.prefab == 'axe' then
		local lucy = inst.components.inventory:FindItem(function(item) return item.prefab == 'ynalucy' end)
		if lucy then
			inst.components.talker:Say(STRINGS.YNAWOODIE.NOAXE)
			inst.components.inventory:Equip(lucy)
		end
	elseif item.components.edible then
		inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "INVALID"))
	else
		inst.components.talker:Say(GetString(inst.prefab, "ACTIONFAIL_GENERIC"))
	end
end

local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST,
        function(guy) 
			if guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) then
                if guy:HasTag("monster") and guy.prefab ~= "webber" then
					return guy
				end
				if inst.components.sanity:GetPercent() == 0 and (guy:HasTag('player') or guy:HasTag('summonedbyplayer')) then
					inst:RemoveTag('summonedbyplayer')
					return guy
				end
			end
        end)
end

local function NormalKeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
           and (not target.LightWatcher or target.LightWatcher:IsInLight())
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
	return inst.desc.."\n\nHealth: "..health.." ("..healthP.."%)\nSanity: "..sanity.." ("..sanityP.."%)\nHunger: "..hunger.." ("..hungerP.."%)"
end

--[[WOODIE]]
local function BecomeWoodie(inst)
	inst.beaver = false
    inst.ActionStringOverride = nil
    inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("woodie")

	inst:RemoveTag("beaver")
	
	--inst:RemoveComponent("worker")
	inst.components.talker:StopIgnoringAll()
	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
	inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
	
	inst.components.eater:SetOmnivore()
	
	inst.components.hunger:Resume()
	inst.components.sanity.ignore = false
	inst.components.temperature:SetTemp(nil)
    inst.components.combat:SetAttackPeriod(2)
end

local function BecomeBeaver(inst)
	inst.beaver = true
	inst:AddTag("beaver")
	inst.AnimState:SetBuild("werebeaver_build")
	inst.AnimState:SetBank("werebeaver")
	inst.components.talker:IgnoreAll()
	inst.components.combat:SetDefaultDamage(TUNING.BEAVER_DAMAGE)

	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.1
	inst.components.inventory:DropEverything()
	
	inst.components.eater:SetBeaver()

	inst:AddComponent("worker")
--	inst:ListenForEvent("oneatsomething", onbeavereat)

	inst.components.sanity:SetPercent(1)
	inst.components.health:SetPercent(1)
	inst.components.hunger:SetPercent(1)

	inst.components.hunger:Pause()
	inst.components.sanity.ignore = true
    inst.components.temperature:SetTemp(20)
    inst.components.combat:SetAttackPeriod(0)
--[[	inst.components.health.redirect = beaverhurt
	inst.components.health.redirect_percent = .25

	local dt = 3
	local BEAVER_DRAIN_TIME = 50
	inst.components.beaverness:StartTimeEffect(dt, (-100/BEAVER_DRAIN_TIME)*dt)]]
    
end

--[[WOLFGANG]]
local function applymightiness(inst)

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

local function onhungerchange(inst, data)

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

	applymightiness(inst)
end

--[[WILLOW]]
local function sanityfn(inst)
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

--[[WX-78]]
local function applyupgrades(inst)
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

local function oneat(inst, food)
	if food and food.components.edible and food.components.edible.foodtype == "GEARS" then
		--give an upgrade!
		inst.level = inst.level + 1
		applyupgrades(inst)	
		inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
	end
end

local function onpreload(inst, data)
	if data then
		if data.level then
			inst.level = data.level
			applyupgrades(inst)
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

local function onlightingstrike(inst)
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
				onupdate(inst, 0)
				inst.charged_task = inst:DoPeriodicTask(1, onupdate, nil, 1)
			end
		else
			inst:PushEvent("lightningdamageavoided")
		end
	end
end

local function dorainsparks(inst, dt)
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

--[[COMMON]]
local function common()
    
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	local player = GetPlayer()
	
	inst.actionbuffer = 0
	inst.bedroll = nil
	shadow:SetSize( 1.3, .6 )
    inst.Transform:SetFourFaced()
	
    MakeCharacterPhysics(inst, 30, .3)

	local lightwatch = inst.entity:AddLightWatcher()
	lightwatch:SetLightThresh(.075)
	lightwatch:SetDarkThresh(.05)

    inst:AddTag("sheltercarrier")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("scarytoprey")
    inst:AddTag("character")

    anim:SetBank("wilson")
	anim:Hide("hat")
	anim:Hide("hat_hair")
	anim:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	anim:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
	anim:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")
		
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.components.locomotor.fasteronroad = true
   
    inst:AddComponent("temperature")

    inst:AddComponent("inventory")
	
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("moisture")
	
    inst:AddComponent("sanity")
	inst.components.sanity:SetMax(TUNING.WILSON_SANITY)
	
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH)
	
    inst:AddComponent("hunger")
    inst.components.hunger:SetMax(TUNING.WILSON_HUNGER)
    inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
    inst.components.hunger:SetKillRate(TUNING.WILSON_HEALTH/TUNING.STARVE_KILL_TIME)
	
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
	inst.components.combat.hiteffectsymbol = "torso"
	
    inst:AddComponent("frostybreather")
    inst:AddComponent("eater")
    inst.components.eater:SetOmnivore()

    ------------------------------------------
    inst.entity:AddLabel()
    inst.Label:SetFontSize(20)
    inst.Label:SetFont(DEFAULTFONT)
    inst.Label:SetPos(0,3,0)
    inst.Label:SetColour(1, 1, 1)
    inst.Label:Enable(true)
    ------------------------------------------

    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = 99999999
    player.components.leader:AddFollower(inst)
	inst.components.follower:AddLoyaltyTime(9999999)
    ------------------------------------------
    inst:AddComponent("talker")
    inst.components.talker:StopIgnoringAll()
    ------------------------------------------
    inst:AddComponent("inspectable")
	inst.components.inspectable:SetDescription(AddStatus)
    ------------------------------------------
   
    inst:SetBrain(brain)
	
    if ACTIONS.SITCOMMAND ~= nil then
    	inst:AddComponent("followersitcommand")
    end

    inst:AddComponent("lootdropper")

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

	inst:AddComponent("grue")
	inst.components.grue:SetSounds("dontstarve/charlie/warn","dontstarve/charlie/attack")
	
    inst.AnimState:Hide("ARM_carry") 
    inst.AnimState:Show("ARM_normal") 

    inst:AddComponent("wisecrackerfollower")
    inst:SetStateGraph("SGfollower")
	
    inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(2)
    inst.components.sleeper:SetSleepTest(NormalShouldSleep)
    inst.components.sleeper:SetWakeTest(DefaultWakeTest)	
   
	inst:AddComponent("playerlightningtarget")
	
    inst:ListenForEvent("attacked", OnAttacked)    
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
	inst:ListenForEvent("daytime", function(global, data)
	    if inst.components.beaverness and inst.components.beaverness:IsBeaver() then
	        if not inst.components.beaverness.doing_transform then
				inst.components.beaverness:SetPercent(0)
			end
		elseif inst.bedroll == 'straw' then
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
	inst.OnSave = onsavefn
	inst.OnLoad = onloadfn
    return inst
end

local function woodie()
    local inst = common()
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("woodie.png")
    minimap:SetPriority( 10 )
    inst:AddTag("woodie")
    inst.AnimState:SetBuild("woodie")
	inst.desc = "Woodie, the lumberjack."    
	inst.components.inventory:GuaranteeItems(woodie_inv)
	function inst.components.combat:GetBattleCryString(target)
            return target ~= nil
                and target:IsValid()
                and GetString(
                    "woodie",
                    "BATTLECRY",
                    (target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
                    (string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or target.prefab
                )
                or nil         
        end
	
	function inst.components.combat:GetGiveUpString(combat, target)
		local str = ""
		if target and target:HasTag("prey") then
			str = GetString("woodie", "COMBAT_QUIT", "prey")
		else
			str = GetString("woodie", "COMBAT_QUIT")
		end
		return str
	end

	inst.components.lootdropper:SetLoot({"ynawoodieskull"})
	inst:AddComponent("beaverness")		
	inst.components.beaverness.makeperson = BecomeWoodie
	inst.components.beaverness.makebeaver = BecomeBeaver
	
	inst.components.beaverness.onbecomeperson = function()
		inst:PushEvent("transform_person")
	end

	inst.components.beaverness.onbecomebeaver = function()
		inst:PushEvent("transform_werebeaver")
	end
	
	BecomeWoodie(inst)

    inst:ListenForEvent("nighttime", function(global, data)
	    if --[[GetClock():GetMoonPhase() == "full" and]] not inst.components.beaverness:IsBeaver() and not inst.components.beaverness.ignoremoon and not inst.components.sleeper.isasleep then
	        if not inst.components.beaverness.doing_transform then
				inst.components.beaverness:SetPercent(1)
			end
		end
	end, GetWorld())
	
    return inst
end

local function wolfgang()
    local inst = common()
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("wolfgang.png")
    minimap:SetPriority( 10 )
    inst:AddTag("wolfgang")
	inst.AnimState:SetBuild("wolfgang")
	inst.desc = "Wolfgang, the strongman."   
	
	inst.components.sanity.night_drain_mult = 1.1
	inst.components.sanity.neg_aura_mult = 1.1
	
	function inst.components.combat:GetBattleCryString(target)
		return target ~= nil
			and target:IsValid()
			and GetString(
				"wolfgang",
				"BATTLECRY",
				(target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
				(string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or target.prefab
			)
			or nil         
	end
		
	function inst.components.combat:GetGiveUpString(combat, target)
		local str = ""
		if target and target:HasTag("prey") then
			str = GetString("wolfgang", "COMBAT_QUIT", "prey")
		else
			str = GetString("wolfgang", "COMBAT_QUIT")
		end
		return str
	end
	
	inst.components.lootdropper:SetLoot({"ynawolfgangskull"})
	
	inst.strength = "normal"
   	inst.components.hunger:SetMax(TUNING.WOLFGANG_HUNGER)
	inst.components.hunger.current = TUNING.WOLFGANG_START_HUNGER
	applymightiness(inst)
	
	inst:ListenForEvent("hungerdelta", onhungerchange)
    return inst
end

local function willow()
    local inst = common()
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("willow.png")
    minimap:SetPriority( 10 )
    inst:AddTag("willow")
	inst.AnimState:SetBuild("willow")
	inst.desc = "Willow, the firestarter."   
	inst.components.inventory:GuaranteeItems(willow_inv)
	
	inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)
	inst.components.sanity.custom_rate_fn = sanityfn
	
	function inst.components.combat:GetBattleCryString(target)
		return target ~= nil
			and target:IsValid()
			and GetString(
				"willow",
				"BATTLECRY",
				(target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
				(string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or target.prefab
			)
			or nil         
	end
		
	function inst.components.combat:GetGiveUpString(combat, target)
		local str = ""
		if target and target:HasTag("prey") then
			str = GetString("willow", "COMBAT_QUIT", "prey")
		else
			str = GetString("willow", "COMBAT_QUIT")
		end
		return str
	end
	
	inst:AddComponent("firebug")
	inst.components.firebug.prefab = "willowfire"
	inst.components.health.fire_damage_scale = 0
	
	inst.components.lootdropper:SetLoot({"ynawillowskull"})
	
    --[[inst:ListenForEvent("nighttime", function(it, data) 	
		local lighter = inst.components.inventory:FindItem(function(item) return item.prefab == "ynalighter" end)

		if lighter and (not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab ~= lighter.prefab) then
			inst.components.inventory:Equip(lighter)
		end
	end, GetWorld())]]
	
    return inst
end

local function wickerbottom()
    local inst = common()
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("wickerbottom.png")
    minimap:SetPriority( 10 )
    inst:AddTag("wickerbottom")
	inst.AnimState:SetBuild("wickerbottom")
	inst.desc = "Wickerbottom, the librarian."
	inst.read = false
	
	inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)
	inst.components.sanity.custom_rate_fn = sanityfn
	
	function inst.components.combat:GetBattleCryString(target)
		return target ~= nil
			and target:IsValid()
			and GetString(
				"wickerbottom",
				"BATTLECRY",
				(target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
				(string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or target.prefab
			)
			or nil         
	end
		
	function inst.components.combat:GetGiveUpString(combat, target)
		local str = ""
		if target and target:HasTag("prey") then
			str = GetString("wickerbottom", "COMBAT_QUIT", "prey")
		else
			str = GetString("wickerbottom", "COMBAT_QUIT")
		end
		return str
	end
	
	inst.components.lootdropper:SetLoot({"ynawickerbottomskull"})
	
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

local function wx78()
	local inst = common()
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("wx78.png")
    minimap:SetPriority( 10 )
    inst:AddTag("wx78")
	inst.AnimState:SetBuild("wx78")
	inst.desc = "WX-78, the soulless automaton"
	inst.level = 0
	inst.charge_time = 0
	inst.spark_time = 3
	
	function inst.components.combat:GetBattleCryString(target)
		return target ~= nil
			and target:IsValid()
			and GetString(
				"wx78",
				"BATTLECRY",
				(target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
				(string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or target.prefab
			)
			or nil         
	end
		
	function inst.components.combat:GetGiveUpString(combat, target)
		local str = ""
		if target and target:HasTag("prey") then
			str = GetString("wx78", "COMBAT_QUIT", "prey")
		else
			str = GetString("wx78", "COMBAT_QUIT")
		end
		return str
	end
	
	inst.components.lootdropper:SetLoot({"ynawx78skull"})
	
	inst.components.eater.ignoresspoilage = true
	table.insert(inst.components.eater.foodprefs, "GEARS")
	inst.components.eater:SetOnEatFn(oneat)
	applyupgrades(inst)

	inst.components.playerlightningtarget:SetHitChance(.1)
	inst.components.playerlightningtarget:SetOnStrikeFn(onlightingstrike)
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

	inst:DoPeriodicTask(1/10, function() dorainsparks(inst, 1/10) end)
	inst.OnPreLoad = onpreload
	return inst
end

local function wendy()
	local inst = common()
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("wendy.png")
    minimap:SetPriority( 10 )
    inst:AddTag("wendy")
	inst.AnimState:SetBuild("wendy")
	inst.desc = "Wendy, the bereaved."
	
	function inst.components.combat:GetBattleCryString(target)
		return target ~= nil
			and target:IsValid()
			and GetString(
				"wendy",
				"BATTLECRY",
				(target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
				(string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or target.prefab
			)
			or nil         
	end
		
	function inst.components.combat:GetGiveUpString(combat, target)
		local str = ""
		if target and target:HasTag("prey") then
			str = GetString("wendy", "COMBAT_QUIT", "prey")
		else
			str = GetString("wendy", "COMBAT_QUIT")
		end
		return str
	end
	
	inst.components.lootdropper:SetLoot({"ynawendyskull"})

	inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
    inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT
    inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT
	
	inst:AddComponent("leader")
	
    inst:DoTaskInTime(0, function() 
    		local found = false
    		for k,v in pairs(Ents) do
    			if v.prefab == "ynaabigail" then
    				found = true
    				break
    			end
    		end
    		if not found then
    			inst.components.inventory:GuaranteeItems(wendy_inv)
    		end
    	end)
		
	return inst
end

return Prefab("common/ynawoodie", woodie, assets),
	Prefab("common/ynawolfgang", wolfgang, assets),
	Prefab("common/ynawillow", willow, assets),
	Prefab("common/ynawickerbottom", wickerbottom, assets),
	Prefab("common/ynawx78", wx78, assets),
	Prefab("common/ynawendy", wendy, assets)
