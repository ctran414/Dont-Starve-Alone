local assets = 
{
	Asset("ANIM", "anim/skulls.zip"),
	--Asset("ANIM", "anim/woodie.zip"),
	--Asset("ANIM", "anim/wolfgang.zip"),
	--Asset("ANIM", "anim/willow.zip"),
}

local function SummonFollower(inst, target, item)
    inst:AddTag("lightningrod")
    inst.lightningpriority = 100

	Sleep(0.5)

	GetWorld().components.seasonmanager:DoLightningStrike(inst:GetPosition())

	Sleep(0.1)

	local light = SpawnPrefab("chesterlight")

	local fx = SpawnPrefab("maxwell_smoke")
	fx.Transform:SetPosition(inst:GetPosition():Get())
	local summon = SpawnPrefab(item.char)
	summon.components.health:SetPercent(.50)
	summon.components.hunger:SetPercent(.50)
	summon.components.sanity:SetPercent(.50)
	summon.Physics:SetCapsule(1, 1)
	summon.Transform:SetPosition(inst:GetPosition():Get())
	light.Transform:SetPosition(inst:GetPosition():Get())
	light:TurnOn()
	summon.components.followercommands:SetStaying(true)
	summon.components.followercommands:RememberSitPos("currentstaylocation", Point(summon.Transform:GetWorldPosition())) 
	summon.AnimState:PlayAnimation("sleep", true)
	summon:DoTaskInTime(0, function(summon) summon.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/appear") end)

	Sleep(1)

    local sound_name = item.model
    summon.SoundEmitter:PlaySound("dontstarve/characters/"..sound_name.."/hurt")
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

local function StartSummonSequence(inst, target, item)
	inst.SummmonSequence = inst:StartThread(function() SummonFollower(inst, target, item) end) 
end

local function OnBury(inst, hole, doer)
	if doer.components.inventory then
		--local current = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		--if current and current.prefab == 'amulet' then
			StartSummonSequence(hole, doer, inst)
			doer.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
			inst:Remove()
			--current:Remove()
		--end
	end
end

local function common()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local snd = inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	anim:SetBank("skulls")
	anim:SetBuild("skulls")
	--f1 wilson, f2 willow, f3 wx78, f4 webber, f5 wallace, f6 wes, f7 winnie, f8 wilton, f9 monkeyman, f10 wortox, f11 waverly, f12 woodie, f13 wickerbottom, f14 wendy, 15 wolfgang,
    inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")

	inst:AddComponent("inventoryitem")
	inst:AddComponent("inspectable")
	inst:AddComponent("buryable")
	inst.components.buryable:SetOnBury(OnBury)

	return inst
end

local function woodie()
    local inst = common()
    inst.AnimState:PlayAnimation("f12")
	inst:AddTag("woodieskull")
	inst.char = "dsawoodie"
	inst.model = "woodie"
	inst.components.inventoryitem:ChangeImageName("skull_woodie")
    return inst
end

local function wolfgang()
    local inst = common()
    inst.AnimState:PlayAnimation("f15")
	inst:AddTag("wolfgangskull")
	inst.char = "dsawolfgang"
	inst.model = "wolfgang"
	inst.components.inventoryitem:ChangeImageName("skull_wolfgang")
    return inst
end

local function willow()
    local inst = common()
    inst.AnimState:PlayAnimation("f2")
	inst:AddTag("dsawillowskull")
	inst.char = "dsawillow"
	inst.model = "willow"
	inst.components.inventoryitem:ChangeImageName("skull_willow")
    return inst
end

local function wickerbottom()
    local inst = common()
    inst.AnimState:PlayAnimation("f13")
	inst:AddTag("dsawickerbottomskull")
	inst.char = "dsawickerbottom"
	inst.model = "wickerbottom"
	inst.components.inventoryitem:ChangeImageName("skull_wickerbottom")
    return inst
end

local function wx78()
    local inst = common()
    inst.AnimState:PlayAnimation("f3")
	inst:AddTag("dsawx78skull")
	inst.char = "dsawx78"
	inst.model = "wx78"
	inst.components.inventoryitem:ChangeImageName("skull_wx78")
    return inst
end

local function wendy()
    local inst = common()
    inst.AnimState:PlayAnimation("f14")
	inst:AddTag("dsawendyskull")
	inst.char = "dsawendy"
	inst.model = "wendy"
	inst.components.inventoryitem:ChangeImageName("skull_wendy")
    return inst
end

local function wes()
    local inst = common()
    inst.AnimState:PlayAnimation("f6")
	inst:AddTag("dsawesskull")
	inst.char = "dsawes"
	inst.model = "wes"
	inst.components.inventoryitem:ChangeImageName("skull_wes")
    return inst
end

local function wilson()
    local inst = common()
    inst.AnimState:PlayAnimation("f1")
	inst:AddTag("dsawilsonskull")
	inst.char = "dsawilson"
	inst.model = "wilson"
	inst.components.inventoryitem:ChangeImageName("skull_wilson")
    return inst
end

return Prefab("common/inventory/dsawoodieskull", woodie, assets),
		Prefab("common/inventory/dsawolfgangskull", wolfgang, assets),
		Prefab("common/inventory/dsawillowskull", willow, assets),
		Prefab("common/inventory/dsawickerbottomskull", wickerbottom, assets),
		Prefab("common/inventory/dsawx78skull", wx78, assets),
		Prefab("common/inventory/dsawendyskull", wendy, assets),
		Prefab("common/inventory/dsawesskull", wes, assets),
		Prefab("common/inventory/dsawilsonskull", wilson, assets)