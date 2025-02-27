local assets =
{
	Asset("ANIM", "anim/abigail_flower.zip"),
	--Asset("SOUND", "sound/common.fsb"),
    Asset("INV_IMAGE", "abigail_flower"),
    Asset("INV_IMAGE", "abigail_flower2"),
    Asset("INV_IMAGE", "abigail_flower_haunted"),

}
 
local prefabs =
{
	"abigail",
}    


local function GetWendy()
    return TheSim:FindFirstEntityWithTag("wendy")
end

local function getstatus(inst)
    if inst.components.cooldown:IsCharged() then
        if inst.components.inventoryitem.owner then
            return "HAUNTED_POCKET"
        else
            return "HAUNTED_GROUND"
        end
    end
	
	local time_charge = inst.components.cooldown:GetTimeToCharged()
    if time_charge < TUNING.TOTAL_DAY_TIME*.5 then
        return "SOON"
    elseif time_charge < TUNING.TOTAL_DAY_TIME*2 then
        return "MEDIUM"
    else
        return "LONG"
    end
    
end

local function updateimage(inst)
	if inst.components.cooldown:IsCharged() then
	    inst.components.inventoryitem:ChangeImageName("abigail_flower_haunted")
		inst.AnimState:PlayAnimation("haunted_pre")
		inst.AnimState:PushAnimation("idle_haunted_loop", true)
		inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
		inst:DoTaskInTime(0, function()
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("dontstarve/common/haunted_flower_LP", "loop")
			end
		end)
	    
	else
		inst.AnimState:SetBloomEffectHandle( "" )
		if inst.components.cooldown:GetTimeToCharged() < TUNING.TOTAL_DAY_TIME then
			inst.components.inventoryitem:ChangeImageName("abigail_flower2")
			
			if IsDLCEnabled(CAPY_DLC) then
				inst.components.floatable:UpdateAnimations("idle_2_water", "idle_2")
				if inst.components.floatable.onwater then
					inst.AnimState:PlayAnimation("idle_2_water")
				else
					inst.AnimState:PlayAnimation("idle_2")
				end
			else
				inst.AnimState:PlayAnimation("idle_2")
			end
		else
			inst.components.inventoryitem:ChangeImageName("abigail_flower")
			if IsDLCEnabled(CAPY_DLC) then
				inst.components.floatable:UpdateAnimations("idle_1_water", "idle_1")
				if inst.components.floatable.onwater then
					inst.AnimState:PlayAnimation("idle_1_water")
				else
					inst.AnimState:PlayAnimation("idle_1")
				end
			else
				inst.AnimState:PlayAnimation("idle_1")
			end
		end
	end
end

local function startcharging(inst)
	updateimage(inst)
end

local function oncharged(inst)
	updateimage(inst)
end

local function ondeath(inst, deadthing)
	local wendy = GetWendy()
    if inst and deadthing and inst.components.inventoryitem and inst:IsValid() and deadthing:IsValid() and inst.components.inventoryitem.owner == nil and not deadthing:HasTag("wall") and inst:GetDistanceSqToInst(deadthing) < 16*16 then
        if inst.components.cooldown:IsCharged() and wendy then
            wendy.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
            local abigail = SpawnPrefab("dsaabigail")
            abigail.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
            inst:Remove()
        end
    end
end

local function topocket(inst)
    inst.SoundEmitter:KillAllSounds()
end

local function toground(inst)
    if inst.components.cooldown:IsCharged() then
        inst.SoundEmitter:PlaySound("dontstarve/common/haunted_flower_LP", "loop")
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    anim:SetBank("abigail_flower")
    anim:SetBuild("abigail_flower")
    anim:PlayAnimation("idle1")
    MakeInventoryPhysics(inst)
	if IsDLCEnabled(CAPY_DLC) then
		MakeInventoryFloatable(inst, "idle_water", "idle")
	end
    inst:AddTag("irreplaceable")
    
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "abigail_flower.png" )
    

    inst:AddComponent("inventoryitem")
    -----------------------------------
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "abigail_flower"
    inst.components.inspectable.getstatus = getstatus

    --inst:AddComponent("dsacharacterspecific")
    --inst.components.dsacharacterspecific:SetOwner("dsawendy")
	
    inst:AddComponent("cooldown")
    inst.components.cooldown.cooldown_duration = TUNING.TOTAL_DAY_TIME + math.random()*TUNING.TOTAL_DAY_TIME*2
    inst.components.cooldown.onchargedfn = oncharged
    inst.components.cooldown.startchargingfn = startcharging
    inst.components.cooldown:StartCharging()
    
    inst:ListenForEvent("daytime", function() updateimage(inst) end, GetWorld())
    inst:ListenForEvent("dusktime", function() updateimage(inst) end, GetWorld())
    inst:ListenForEvent("nighttime", function() updateimage(inst) end, GetWorld())
    

    inst:ListenForEvent("entity_death", function(world, data) ondeath(inst, data.inst) end, GetWorld())

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)    


    inst:DoTaskInTime(0, function() 
		for k,v in pairs(Ents) do
			if v.prefab == "dsaabigail" then
				v:Remove()
			end
		end
		
		updateimage(inst)
	end)

    return inst
end

return Prefab( "common/dsaabigail_flower", fn, assets, prefabs) 
