local assets = 
{
	Asset("ANIM", "anim/skeletons.zip"),
}

local prefabs = {}
if IsDLCEnabled(REIGN_OF_GIANTS) then 
	prefabs =
	{
		"boneshard",
		"collapse_small",
	}

	SetSharedLootTable( 'skeleton',
	{
		{'boneshard',	1.00},
		{'boneshard',	1.00},
	})
end

local animstates = {1, 3, 4, 5, 6} --not going to use the spear skeleton until anim to take spear is made

local function onsave(inst, data)
	data.anim = inst.animnum
end

local function onload(inst, data)
	if data then
		if data.anim then
			inst.animnum = data.anim
			inst.AnimState:PlayAnimation("idle"..inst.animnum)
		end
	end
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function fn()

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeObstaclePhysics(inst, 0.25)

	inst.animnum = animstates[math.random(#animstates)]
	anim:SetBank("skeleton")
	anim:SetBuild("skeletons")
	anim:PlayAnimation("idle"..inst.animnum)

	inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('skeleton') 

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "skeleton"
	inst.components.inspectable:RecordViews()
	inst.OnLoad = onload
	inst.OnSave = onsave

	return inst
end

local function wilson()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawilsonskull"})
	return inst
end

local function willow()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawillowskull"})
	return inst
end

local function wolfgang()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawolfgangskull"})
	return inst
end

local function wendy()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawendyskull"})
	return inst
end

local function wx78()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawx78skull"})
	return inst
end

local function wickerbottom()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawickerbottomskull"})
	return inst
end

local function woodie()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawoodieskull"})
	return inst
end

local function wes()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawesskull"})
	return inst
end

local function waxwell()
	local inst = fn()
	inst.components.lootdropper:SetLoot({"dsawaxwellskull"})
	return inst
end

local function webber()
	local inst = fn()
	if IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC) then 
		inst.components.lootdropper:SetLoot({"dsawebberskull"})
	end
	return inst
end

local function wigfrid()
	local inst = fn()
	if IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC) then 
		inst.components.lootdropper:SetLoot({"dsawathgrithrskull"})
	end
	return inst
end

return Prefab("common/objects/dsawilsonskeleton", wilson, assets, prefabs),
	Prefab("common/objects/dsawillowskeleton", willow, assets, prefabs),
	Prefab("common/objects/dsawolfgangskeleton", wolfgang, assets, prefabs),
	Prefab("common/objects/dsawendyskeleton", wendy, assets, prefabs),
	Prefab("common/objects/dsawx78skeleton", wx78, assets, prefabs),
	Prefab("common/objects/dsawickerbottomskeleton", wickerbottom, assets, prefabs),
	Prefab("common/objects/dsawoodieskeleton", woodie, assets, prefabs),
	Prefab("common/objects/dsawesskeleton", wes, assets, prefabs),
	Prefab("common/objects/dsawaxwellskeleton", waxwell, assets, prefabs),
	Prefab("common/objects/dsawebberskeleton", webber, assets, prefabs),
	Prefab("common/objects/dsawathgrithrskeleton", wigfrid, assets, prefabs)