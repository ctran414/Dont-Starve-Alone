local brain = require "brains/followerbrain"

local assets =
{
	Asset("ATLAS", "images/inventoryimages/ynawoodie.xml"),
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
    Asset("ANIM", "anim/player_woodie.zip"),
	Asset("ANIM", "anim/woodie.zip"),
    Asset("ANIM", "anim/werebeaver_build.zip"),
    Asset("ANIM", "anim/werebeaver_basic.zip"),
	Asset("ANIM", "anim/shadow_hands.zip"),
	Asset("ANIM", "anim/swap_bedroll_straw.zip"),
	Asset("SOUND", "sound/sfx.fsb"),
	Asset("SOUND", "sound/woodie.fsb"),
}

local prefabs =
{
	'ynawoodieskull',
}

local start_inv = 
{
	"ynalucy",
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
        str = GetString("woodie", "COMBAT_QUIT", "prey")
    else
        str = GetString("woodie", "COMBAT_QUIT")
    end
    return str
end

local function OnAttacked(inst, data)
	if inst.components.sleeper.isasleep then
		inst.sg:GoToState("wakeup")
		inst.components.sleeper.isasleep = false
	end
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
		inst.components.talker:Say(GetString("woodie", "ANNOUNCE_EAT", "INVALID"))
	else
		inst.components.talker:Say(GetString("woodie", "ACTIONFAIL_GENERIC"))
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
--[[
	inst:AddComponent("worker")
	inst:ListenForEvent("oneatsomething", onbeavereat)

	inst.components.sanity:SetPercent(1)
	inst.components.health:SetPercent(1)
	inst.components.hunger:SetPercent(1)

	inst.components.hunger:Pause()
	inst.components.sanity.ignore = true
	inst.components.health.redirect = beaverhurt
	inst.components.health.redirect_percent = .25

	local dt = 3
	local BEAVER_DRAIN_TIME = 50
	inst.components.beaverness:StartTimeEffect(dt, (-100/BEAVER_DRAIN_TIME)*dt)]]
    
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

    inst:AddTag("woodie")
    inst:AddTag("sheltercarrier")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("scarytoprey")

    anim:SetBank("wilson")
	anim:SetBuild("woodie")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.components.locomotor.fasteronroad = true
   
    inst:AddComponent("temperature")

    inst:AddComponent("inventory")
	inst.components.inventory:GuaranteeItems(start_inv)
	
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    MakeMediumBurnableCharacter(inst, "pig_torso")
    ------------------
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
	inst.components.combat.GetGiveUpString = giveupstring
	inst.components.combat.hiteffectsymbol = "torso"
	
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
    minimap:SetIcon( "ynawoodie.tex" )
    ------------------------------------------
   
    inst:SetBrain(brain)
	
    if ACTIONS.SITCOMMAND ~= nil then
    	inst:AddComponent("followersitcommand")
    end

    inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"ynawoodieskull"})

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
	
	inst:AddComponent("beaverness")		
	inst.components.beaverness.makeperson = BecomeWoodie
	inst.components.beaverness.makebeaver = BecomeBeaver
	
	inst.components.beaverness.onbecomeperson = function()
		inst:PushEvent("transform_person")
	end

	inst.components.beaverness.onbecomebeaver = function()
		inst:PushEvent("transform_werebeaver")
	end
	
    inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(2)
    inst.components.sleeper:SetSleepTest(NormalShouldSleep)
    inst.components.sleeper:SetWakeTest(DefaultWakeTest)
	
	BecomeWoodie(inst)

    inst:ListenForEvent("nighttime", function(global, data)
	    if GetClock():GetMoonPhase() == "full" and not inst.components.beaverness:IsBeaver() and not inst.components.beaverness.ignoremoon then
	        if not inst.components.beaverness.doing_transform then
				inst.components.beaverness:SetPercent(1)
				inst.components.sleeper.isasleep = false
			end
	    else
			local torch = inst.components.inventory:FindItem(function(item) return item.prefab == "torch" end)
			if torch and (not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab ~= torch.prefab) then
				inst.components.inventory:Equip(torch)
			end
		end
	end, GetWorld())
	
	inst:ListenForEvent("daytime", function(global, data)
	    if inst.components.beaverness:IsBeaver() then
	        if not inst.components.beaverness.doing_transform then
				inst.components.beaverness:SetPercent(0)
			end
		elseif inst.components.sleeper.isasleep then
			--inst.sg:GoToState("wakeup")
			--inst.components.sleeper.isasleep = false
			inst.components.hunger:DoDelta(-TUNING.CALORIES_HUGE, false, true)
			inst.components.sanity:DoDelta(TUNING.SANITY_LARGE, false)
			inst.components.temperature:SetTemperature(15)
			print('sanity',inst.components.sanity:GetPercent())
	    end
	end, GetWorld())
   
    inst:ListenForEvent("attacked", OnAttacked)    
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
	
    return inst
end

return Prefab( "common/ynawoodie", fn, assets, prefabs)
