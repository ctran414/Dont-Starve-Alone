local brain = require "brains/followerbrain"
local easing = require "easing"

local assets =
{
	Asset("ATLAS", "images/inventoryimages/ynawolfgang.xml"),
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
	Asset("ANIM", "anim/wolfgang.zip"),
    Asset("ANIM", "anim/wolfgang_skinny.zip"),
    Asset("ANIM", "anim/wolfgang_mighty.zip"),
    Asset("ANIM", "anim/player_wolfgang.zip"),
	Asset("ANIM", "anim/shadow_hands.zip"),
	Asset("SOUND", "sound/sfx.fsb"),
	Asset("SOUND", "sound/wolfgang.fsb"),
}

local prefabs =
{
	'ynawolfgangskull',
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local onloadfn = function(inst, data)
	if data and data.sleeping then
		inst.components.sleeper:GoToSleep()
	end
end

local onsavefn = function(inst, data)
	if inst.components.sleeper:IsAsleep() then
		data.sleeping = true
	end
end

local function giveupstring(combat, target)
    local str = ""
    if target and target:HasTag("prey") then
        str = GetString("wolfgang", "COMBAT_QUIT", "prey")
    else
        str = GetString("wolfgang", "COMBAT_QUIT")
    end
    return str
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
	if item.prefab == 'bedroll_straw' or item.prefab == 'bedroll_furry' then
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
	--if item.components.edible and (item.components.edible.foodtype == "MEAT" or item.components.edible.foodtype == "VEGGIE") then
	--return true
	--end
	
    --return item.components.equippable and (item.components.equippable.equipslot == EQUIPSLOTS.HEAD or item.components.equippable.equipslot == EQUIPSLOTS.HANDS or item.components.equippable.equipslot == EQUIPSLOTS.BODY) and not item.components.projectile
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
		inst.components.eater:Eat(item) 
    elseif item.prefab == 'bedroll_straw' then
		inst.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_straw", "bedroll_straw")
		inst.components.sleeper:GoToSleep()
		item:Remove()
	elseif item.prefab == 'bedroll_furry' then
		inst.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_furry", "bedroll_furry")	
		inst.components.sleeper:GoToSleep()
		local usesRemaining = item.components.finiteuses:GetUses() - 1
		if usesRemaining > 0 then
			item.components.finiteuses:SetUses(usesRemaining)
			--inst.components.inventory:DropItem(item)
		else
			item:Remove()
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
	elseif item.components.edible then
		inst.components.talker:Say(GetString("wolfgang", "ANNOUNCE_EAT", "INVALID"))
	else
		inst.components.talker:Say(GetString("wolfgang", "ACTIONFAIL_GENERIC"))
	end
    inst.sg:GoToState("talk")
end

local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST,
        function(guy) 
			if guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) then
                if guy:HasTag("monster") and guy.prefab ~= "webber" then
					return guy
				end
				if inst.components.sanity:GetPercent() == 0 and (guy:HasTag('player') or guy:HasTag('summonedbyplayer')) then
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

local function fn()
    
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	local player = GetPlayer()
	
	inst.actionbuffer = 0
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()
	
    MakeCharacterPhysics(inst, 30, .3)

	local lightwatch = inst.entity:AddLightWatcher()
	lightwatch:SetLightThresh(.075)
	lightwatch:SetDarkThresh(.05)
	
    inst:AddTag("wolfgang")
    inst:AddTag("sheltercarrier")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("scarytoprey")

    anim:SetBank("wilson")
	anim:SetBuild("wolfgang")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.components.locomotor.fasteronroad = true
   
    inst:AddComponent("temperature")

    inst:AddComponent("inventory")
    
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    MakeMediumBurnableCharacter(inst, "pig_torso")
    ------------------
    inst:AddComponent("moisture")
	
    inst:AddComponent("sanity")
	inst.components.sanity:SetMax(TUNING.WILSON_SANITY)	
	inst.components.sanity.night_drain_mult = 1.1
	inst.components.sanity.neg_aura_mult = 1.1
	
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
	inst.components.combat.GetGiveUpString = giveupstring
	inst.components.combat.hiteffectsymbol = "torso"
	
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
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "ynawolfgang.tex" )
    ------------------------------------------
   
    inst:SetBrain(brain)
	
    if ACTIONS.SITCOMMAND ~= nil then
    	inst:AddComponent("followersitcommand")
    end

    inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"ynawolfgangskull"})

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
   
	inst.strength = "normal"
   	inst.components.hunger:SetMax(TUNING.WOLFGANG_HUNGER)
	inst.components.hunger.current = TUNING.WOLFGANG_START_HUNGER
	applymightiness(inst)

    inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(2)
    inst.components.sleeper:SetSleepTest(NormalShouldSleep)
    inst.components.sleeper:SetWakeTest(DefaultWakeTest)
	
	inst:ListenForEvent("hungerdelta", onhungerchange)
	
    inst:ListenForEvent("attacked", OnAttacked)    
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("nighttime", function(it, data) 	
		local torch = inst.components.inventory:FindItem(function(item) return item.prefab == "torch" end)

		if torch and (not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab ~= torch.prefab) then
			inst.components.inventory:Equip(torch)
		end
	end, GetWorld())
		
	inst:ListenForEvent("daytime", function(global, data)
	    if inst.components.sleeper.isasleep then
			--inst.sg:GoToState("wakeup")
			--inst.components.sleeper.isasleep = false
			inst.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
			inst.components.sanity:DoDelta(TUNING.SANITY_LARGE, false)
			inst.components.temperature:SetTemperature(15)
			print('sanity',inst.components.sanity:GetPercent())
	    end
	end, GetWorld())
    return inst
end

return Prefab( "common/ynawolfgang", fn, assets, prefabs)
