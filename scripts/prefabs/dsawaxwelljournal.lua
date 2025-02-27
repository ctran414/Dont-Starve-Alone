local assets =
{
	Asset("ANIM", "anim/book_maxwell.zip"),
}

local prefabs =
{
	"shadowwaxwell",
    "waxwell_book_fx"
}

local function doeffects(inst, pos)
    SpawnPrefab("statue_transition").Transform:SetPosition(pos:Get())
    SpawnPrefab("statue_transition_2").Transform:SetPosition(pos:Get())
end

local function canread(inst)
    return (inst.prefab == "dsawaxwell" and inst.components.sanity.current >= 100)
end

local function onread(inst, reader)

    --Check sanity
    if not canread(reader) then 
        if reader.prefab == "dsawaxwell" and reader.components.talker then
            reader.components.talker:Say(GetString(reader.prefab, "ANNOUNCE_NOSANITY"))
            return true
        end
		return true
    end

    --Check reagent
    if not reader.components.inventory:Has("nightmarefuel", TUNING.SHADOWWAXWELL_FUEL_COST) then
        if reader.components.talker then
            reader.components.talker:Say(GetString(reader.prefab, "ANNOUNCE_NOFUEL"))
            return true
        end
    end

    reader.components.inventory:ConsumeByName("nightmarefuel", TUNING.SHADOWWAXWELL_FUEL_COST)

    --Ok you had everything. Make the image.
    local theta = math.random() * 2 * PI
    local pt = inst:GetPosition()
    local radius = math.random(3, 6)
    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
    if offset then
        local image = SpawnPrefab("dsashadowwaxwell")
        local pos = pt + offset
        image.Transform:SetPosition(pos:Get())
        doeffects(inst, pos)
        image.components.follower:SetLeader(reader)
        reader.components.health:DoDelta(-TUNING.SHADOWWAXWELL_HEALTH_COST)
        reader.components.sanity:DoDelta(-100)
        reader.components.sanity:RecalculatePenalty()
        inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_appear")
        return true
    end
end



local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    
    anim:SetBank("book_maxwell")
    anim:SetBuild("book_maxwell")
    anim:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
	if IsDLCEnabled(CAPY_DLC) then
		MakeInventoryFloatable(inst, "idle_water", "idle")
	end
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:ChangeImageName("waxwelljournal")

    -----------------------------------
    inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "waxwelljournal"
    inst:AddComponent("book")
    inst.components.book.onread = onread

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("common/dsawaxwelljournal", fn, assets)