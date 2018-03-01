local brain = require "brains/ynawillowbrain"

local assets =
{
	Asset("ATLAS", "images/inventoryimages/ynawillow.xml"),
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
	Asset("ANIM", "anim/willow.zip"),
	Asset("ANIM", "anim/shadow_hands.zip"),
	Asset("SOUND", "sound/sfx.fsb"),
	Asset("SOUND", "sound/willow.fsb"),
}

local prefabs =
{
	'ynawillowskull',
	'willowfire',
}

local start_inv = 
{
	"ynalighter",
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
        str = GetString("willow", "COMBAT_QUIT", "prey")
    else
        str = GetString("willow", "COMBAT_QUIT")
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
	end
end

local function CalcSanityAura(inst, observer)
	local sanityAura = TUNING.SANITYAURA_LARGE
	if inst.components.follower and inst.components.follower.leader == observer then
		if inst.components.sanity:GetPercent() <= .15 then
			sanityAura = -TUNING.SANITYAURA_LARGE
		elseif inst.components.sanity:GetPercent() <= .5 then
			sanityAura = -TUNING.SANITYAURA_MED
		end
		return sanityAura
	end
	return 0
end

local function ShouldAcceptItem(inst, item)
	if item.components.edible and item.components.edible.foodtype ~= "WOOD" then
		return true
	end
	
    return item.components.equippable and (item.components.equippable.equipslot == EQUIPSLOTS.HEAD or item.components.equippable.equipslot == EQUIPSLOTS.HANDS or item.components.equippable.equipslot == EQUIPSLOTS.BODY) and not item.components.projectile
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
    end
end

local function OnRefuseItem(inst, giver, item)
	if item.components.edible then
		inst.components.talker:Say(GetString("willow", "ANNOUNCE_EAT", "INVALID"))
	else
		inst.components.talker:Say(GetString("willow", "ACTIONFAIL_GENERIC"))
	end
    inst.sg:GoToState("talk")
end

local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST,
        function(guy)
                return guy:HasTag("monster") and guy.prefab ~= "webber" and guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy)
        end)
end

local function NormalKeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
           and (not target.LightWatcher or target.LightWatcher:IsInLight())
end

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

local function fn()
    
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	local player = GetPlayer()
	
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()
	
    MakeCharacterPhysics(inst, 30, .3)

	local lightwatch = inst.entity:AddLightWatcher()
	lightwatch:SetLightThresh(.075)
	lightwatch:SetDarkThresh(.05)
	
    inst:AddTag("ynawillow")
    inst:AddTag("sheltercarrier")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("scarytoprey")

    anim:SetBank("wilson")
	anim:SetBuild("willow")

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
	inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)
	inst.components.sanity.custom_rate_fn = sanityfn
	
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
				"willow",
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
    minimap:SetIcon( "ynawillow.tex" )
    ------------------------------------------
   
    inst:SetBrain(brain)
	
    if ACTIONS.SITCOMMAND ~= nil then
    	inst:AddComponent("followersitcommand")
    end

    inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"ynawillowskull"})

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

	inst:AddComponent("grue")
	inst.components.grue:SetSounds("dontstarve/charlie/warn","dontstarve/charlie/attack")
	
    inst.AnimState:Hide("ARM_carry") 
    inst.AnimState:Show("ARM_normal") 

    inst:AddComponent("wisecrackerfollower")
    inst:SetStateGraph("SGynawillow")
   
	inst:AddComponent("firebug")
	inst.components.firebug.prefab = "willowfire"
	inst.components.health.fire_damage_scale = 0
	
	inst:ListenForEvent("attacked", OnAttacked)    
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("nighttime", function(it, data) 	
		local lighter = inst.components.inventory:FindItem(function(item) return item.prefab == "ynalighter" end)

		if lighter and (not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab ~= lighter.prefab) then
			inst.components.inventory:Equip(lighter)
		end
	end, GetWorld())
   
    return inst
end

return Prefab( "common/ynawillow", fn, assets, prefabs)
