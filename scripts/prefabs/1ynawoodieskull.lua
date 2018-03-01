local assets = 
{
	Asset("ANIM", "anim/skulls.zip"),
	Asset("ANIM", "anim/woodie.zip"),
    Asset("ATLAS", "images/inventoryimages/ynawoodieskull.xml"),
}
local prefabs = 
{
	"ynawoodie",
}

local function SummonWoodie(inst, target)
    inst:AddTag("lightningrod")
    inst.lightningpriority = 100

	Sleep(0.5)

	GetWorld().components.seasonmanager:DoLightningStrike(inst:GetPosition())

	Sleep(0.1)

	local light = SpawnPrefab("chesterlight")

	local fx = SpawnPrefab("maxwell_smoke")
	fx.Transform:SetPosition(inst:GetPosition():Get())
	
	local summon = SpawnPrefab("ynawoodie")
	summon.components.health:SetPercent(.50)
	summon.components.hunger:SetPercent(.50)
	summon.components.sanity:SetPercent(.50)
	summon.Physics:SetCapsule(1, 1)
	summon.Transform:SetPosition(inst:GetPosition():Get())
	light.Transform:SetPosition(inst:GetPosition():Get())
	light:TurnOn()
	summon.components.followersitcommand:SetStaying(true)
	summon.components.followersitcommand:RememberSitPos("currentstaylocation", Point(summon.Transform:GetWorldPosition())) 
	summon.AnimState:PlayAnimation("sleep", true)
	summon:DoTaskInTime(0, function(summon) summon.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/appear") end)

	Sleep(1)

	summon.SoundEmitter:PlaySound("dontstarve/characters/woodie/hurt")
	summon.AnimState:PushAnimation("wakeup")
	summon:DoTaskInTime(41*FRAMES, function(summon) PlayFootstep(summon) end)
	summon:DoTaskInTime(72*FRAMES, function(summon) PlayFootstep(summon) end)
	summon:DoTaskInTime(89*FRAMES, function(summon) PlayFootstep(summon) end)
	summon.AnimState:PushAnimation("idle_loop", true)

	Sleep(4)
	
	summon.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/appear")
	light:TurnOff()

	inst:RemoveTag("lightningrod")
	inst.lightningpriority = -100
end

local function StartSummonSequence(inst, target)
	inst.SummmonSequence = inst:StartThread(function() SummonWoodie(inst, target) end) 
end

local function OnBury(inst, hole, doer)
	if doer.components.inventory then
		local current = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if current and current.prefab == 'amulet' then
			StartSummonSequence(hole, doer)
			doer.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
			inst:Remove()
			current:Remove()
		end
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local snd = inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	anim:SetBank("skulls")
	anim:SetBuild("skulls")
	anim:PlayAnimation("f12")
	--f1 wilson, f2 willow, f3 wx78, f4 webber, f5 wallace, f6 wes, f7 winnie, f8 wilton, f9 monkeyman, f10 wortox, f11 waverly, f12 woodie, f13 wickerbottom, f14 wendy, 15 wolfgang,
	inst:AddTag("woodieskull")
    inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:ChangeImageName("skull_woodie")
	inst:AddComponent("inspectable")
	inst:AddComponent("buryable")
	inst.components.buryable:SetOnBury(OnBury)

	return inst
end

return Prefab("common/inventory/ynawoodieskull", fn, assets, prefabs)