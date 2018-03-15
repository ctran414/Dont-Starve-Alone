require("stategraphs/commonstates")

local function DoFoleySounds(inst)
	for k,v in pairs(inst.components.inventory.equipslots) do
		if v.components.inventoryitem and v.components.inventoryitem.foleysound then
			inst.SoundEmitter:PlaySound(v.components.inventoryitem.foleysound)
		end
	end

end

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, 
        function(inst, action)
            if inst.sg:HasStateTag("busy") then
                return nil
            end
            local obj = action.target or action.invobject
            if not (obj and obj.components.edible) then
                return nil
            end
            
            if obj.components.edible.foodtype == "MEAT" then
                return "eat"
            else
                return "quickeat"
            end
        end),
    ActionHandler(ACTIONS.CHOP, 
        function(inst) 
            if not inst.sg:HasStateTag("prechop") then 
                if inst.sg:HasStateTag("chopping") then
                    return "chop"
                else
                    return "chop_start"
                end
            end 
        end),
    ActionHandler(ACTIONS.MINE, 
        function(inst) 
            if not inst.sg:HasStateTag("premine") then 
                if inst.sg:HasStateTag("mining") then
                    return "mine"
                else
                    return "mine_start"
                end
            end 
        end),
	ActionHandler(ACTIONS.DIG, 
        function(inst) 
            if not inst.sg:HasStateTag("predig") then 
                if inst.sg:HasStateTag("digging") then
                    return "dig"
                else
                    return "dig_start"
                end
            end 
        end), 
    ActionHandler(ACTIONS.PICKUP, "doshortaction"),
    ActionHandler(ACTIONS.HEAL, "dolongaction"),   
	ActionHandler(ACTIONS.PICK, 
        function(inst, action)
            if action.target.components.pickable then
                if action.target.components.pickable.quickpick then
                    return "doshortaction"
                else
                    return "dolongaction"
                end
            end
        end),
    ActionHandler(ACTIONS.READ, "book"),
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),    
    CommonHandlers.OnLocomote(true,false),
	
	EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") then
			inst.sg:GoToState("talk", data.noanim)
        end     
    end),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("attack") end end),
	EventHandler("equip", function(inst, data)
        if inst.sg:HasStateTag("idle") then
			if data.eslot == EQUIPSLOTS.HANDS then
				inst.sg:GoToState("item_out")
			else
				inst.sg:GoToState("item_hat")
			end
        end
    end),
    EventHandler("toolbroke",
		function(inst, data)
			inst.sg:GoToState("toolbroke", data.tool)
		end), 
    EventHandler("armorbroke",
		function(inst, data)
			inst.sg:GoToState("armorbroke", data.armor)
		end),
    EventHandler("gotosleep",
		function(inst, data)
			inst.sg:GoToState("bedroll")
		end),
    EventHandler("onwakeup",
		function(inst, data)
			inst.sg:GoToState("wakeup")
		end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/death")    
        
		local sound_name = string.sub(inst.prefab, 4)
        inst.SoundEmitter:PlaySound("dontstarve/characters/"..sound_name.."/death_voice")       
    end),		
    EventHandler("transform_werebeaver", function(inst, data)
        if inst.components.beaverness then
            inst.sg:GoToState("werebeaver")
        end
    end),	
    EventHandler("transform_person", function(inst)
		inst.sg:GoToState("towoodie") 
	end),
	EventHandler("powerup",
        function(inst)
            if GetTick() > 0 then
                inst.sg:GoToState("powerup")
            end
        end),       
	EventHandler("powerdown",
        function(inst)
            inst.sg:GoToState("powerdown")
        end),  
}

local states=
{
	State{
        name = "idle",
        tags = {"idle"},
        onenter = function(inst, pushanim)
            
            inst.components.locomotor:Stop()

            local equippedArmor = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            
            if equippedArmor and equippedArmor:HasTag("band") then
                inst.sg:GoToState("enter_onemanband")
                return
            end

            local anims = {}
            
            local anim = "idle_loop"
            
			if inst:HasTag("beaver") then
				table.insert(anims, "idle_loop")
			elseif not inst.components.sanity:IsSane() then
				table.insert(anims, "idle_sanity_pre")
				table.insert(anims, "idle_sanity_loop")
			elseif inst.components.temperature:IsFreezing() then
				table.insert(anims, "idle_shiver_pre")
				table.insert(anims, "idle_shiver_loop")
            elseif inst.components.temperature:IsOverheating() then
                --plug in overheats once they're done
                table.insert(anims, "idle_hot_pre")
                table.insert(anims, "idle_hot_loop")  
			else
				table.insert(anims, "idle_loop")
			end
		
			if pushanim then
				for k,v in pairs (anims) do
					inst.AnimState:PushAnimation(v, k == #anims)
				end
			else
				inst.AnimState:PlayAnimation(anims[1], #anims == 1)
				for k,v in pairs (anims) do
					if k > 1 then
						inst.AnimState:PushAnimation(v, k == #anims)
					end
				end
			end
            
            inst.sg:SetTimeout(math.random()*4+2)
        end,
        
        ontimeout= function(inst)
            if inst.components.temperature:GetCurrent() > 70 then
                return 
            end
            inst.sg:GoToState("funnyidle")
        end,
    },
	
	State{      
        name = "funnyidle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)       
			
			if inst:HasTag("beaver") then
				inst.AnimState:PlayAnimation("idle_inaction")
			elseif inst.components.temperature:GetCurrent() < 10 then
				inst.AnimState:PlayAnimation("idle_shiver_pre")
				inst.AnimState:PushAnimation("idle_shiver_loop")
				inst.AnimState:PushAnimation("idle_shiver_pst", false)
			elseif inst.components.temperature:GetCurrent() > 60 then
				inst.AnimState:PlayAnimation("idle_hot_pre")
				inst.AnimState:PushAnimation("idle_hot_loop")
				inst.AnimState:PushAnimation("idle_hot_pst", false)
			elseif inst.components.hunger:GetPercent() < TUNING.HUNGRY_THRESH then
				inst.AnimState:PlayAnimation("hungry")
				inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")    
			elseif inst.components.sanity:GetPercent() < .5 then
				inst.AnimState:PlayAnimation("idle_inaction_sanity")
			else
				inst.AnimState:PlayAnimation("idle_inaction")
			end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },      
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst)
			inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
            inst.sg.mem.foosteps = 0
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
        
        timeline=
        {
            TimeEvent(4*FRAMES, function(inst)
                PlayFootstep(inst)
                DoFoleySounds(inst)
            end),
        },        
    },

    State{   
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop")
        end,
        
        timeline=
        {
            TimeEvent(7*FRAMES, function(inst)
				inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                PlayFootstep(inst, inst.sg.mem.foosteps < 5 and 1 or .6)
                DoFoleySounds(inst)
            end),
            TimeEvent(15*FRAMES, function(inst)
				inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                PlayFootstep(inst, inst.sg.mem.foosteps < 5 and 1 or .6)
                DoFoleySounds(inst)
            end),
        },
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },   
    },
    
    State{
        name = "run_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
    },    
   
    State{
        name = "attack",
        --tags = {"attack"},
        tags = {"attack", "notalking", "abouttoattack", "busy"},
         onenter = function(inst)
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local weapon = inst.components.combat:GetWeapon()
            local otherequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            if weapon then
                inst.AnimState:PlayAnimation("atk")
				if weapon:HasTag("icestaff") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff")
				elseif weapon:HasTag("shadow") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
                elseif weapon:HasTag("firestaff") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_firestaff")
                else
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                end
            elseif otherequipped and (otherequipped:HasTag("light") or otherequipped:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			elseif inst.components.beaverness and inst.components.beaverness:IsBeaver() then
                inst.AnimState:PlayAnimation("atk")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            else
				inst.sg.statemem.slow = true
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end
            
            if inst.components.combat.target then
                inst.components.combat:BattleCry()
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end
            
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) inst.sg:RemoveStateTag("abouttoattack") end),
            TimeEvent(12*FRAMES, function(inst) 
				inst.sg:RemoveStateTag("busy")
			end),				
            TimeEvent(13*FRAMES, function(inst)
				if not inst.sg.statemem.slow then
					inst.sg:RemoveStateTag("attack")
				end
            end),
            TimeEvent(24*FRAMES, function(inst)
				if inst.sg.statemem.slow then
					inst.sg:RemoveStateTag("attack")
				end
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	
    State{ name = "chop_start",
        tags = {"prechop", "chopping", "working"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
			if inst.prefab == "dsawoodie" then
				inst.AnimState:PlayAnimation("woodie_chop_pre")
			else
				inst.AnimState:PlayAnimation("chop_pre")
			end
        end,
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) inst.sg:GoToState("chop") end),
        },
    },
	
    State{
        name = "chop",
        tags = {"prechop", "chopping", "working"},
        
        onenter = function(inst)
            inst.Physics:Stop()
			if inst.prefab == "dsawoodie" then
				inst.AnimState:PlayAnimation("woodie_chop_loop")
			else
				inst.AnimState:PlayAnimation("chop_loop")
			end
        end,
        
        timeline=
        {
			TimeEvent(2*FRAMES, function(inst) 
									if inst.prefab == "dsawoodie" then 
										inst:PerformBufferedAction() 
									end 
								end),
			TimeEvent(5*FRAMES, function(inst) 
									if inst.prefab ~= "dsawoodie" then 
										inst:PerformBufferedAction() 
									end
								end),
            TimeEvent(9*FRAMES, function(inst) if inst.prefab == "dsawoodie" then 
										inst.sg:RemoveStateTag("prechop") 
									end 
								end),
            TimeEvent(12*FRAMES, function(inst) if inst.prefab ~= "dsawoodie" then 
										inst.sg:RemoveStateTag("prechop")
									end 
								end),

            TimeEvent(16*FRAMES, function(inst) inst.sg:RemoveStateTag("chopping") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	
	State{ name = "mine_start",
        tags = {"premine", "working"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) inst.sg:GoToState("mine") end),
        },
    },
    
    State{
        name = "mine",
        tags = {"premine", "mining", "working"},
        onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline=
        {
            TimeEvent(12*FRAMES, function(inst) 
                if inst.sg.statemem.action and inst.sg.statemem.action.target then
					local fx = SpawnPrefab("mining_fx")
					fx.Transform:SetPosition(inst.sg.statemem.action.target:GetPosition():Get())
					print('fx',GetTime())
				end
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("premine") 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_pick_rock")
            end),
            
            TimeEvent(16*FRAMES, function(inst) inst.sg:RemoveStateTag("mining") end),
            
        },
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) 
                inst.AnimState:PlayAnimation("pickaxe_pst") 
                inst.sg:GoToState("idle", true)
            end ),
            
        },        
    },
	
	State{ name = "dig_start",
        tags = {"predig", "working"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
        end,
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) inst.sg:GoToState("dig") end),
        },
    },
    
    State{
        name = "dig",
        tags = {"predig", "digging", "working"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("shovel_loop")
			inst.sg.statemem.action = inst:GetBufferedAction()
        end,

        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("predig") 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
                
            end),
            
            TimeEvent(35*FRAMES, function(inst)
				if inst.sg.statemem.action and 
					inst.sg.statemem.action.target and 
					inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
					inst.sg.statemem.action.target.components.workable then
						inst:ClearBufferedAction()
						inst:PushBufferedAction(inst.sg.statemem.action)
				end
            end),
            
        },
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) 
                inst.AnimState:PlayAnimation("shovel_pst") 
                inst.sg:GoToState("idle", true)
            end ),         
        },        
    },       
	
    State{
        name = "eat",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating") 
            inst.AnimState:PlayAnimation("eat")
            inst.components.hunger:Pause()
        end,

        timeline=
        {
            
            TimeEvent(28*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
            end),
            
            TimeEvent(30*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("busy")
            end),
            
            TimeEvent(70*FRAMES, function(inst) 
	            inst.SoundEmitter:KillSound("eating")    
	        end),
            
        },        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("eating")    
            inst.components.hunger:Resume()
        end,
    },    
	
	State{
        name = "quickeat",
        tags ={"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")    
            inst.AnimState:PlayAnimation("quick_eat")
            inst.components.hunger:Pause()
        end,

        timeline=
        {
            TimeEvent(12*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("busy")
            end),
        },        
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("eating")    
            inst.components.hunger:Resume()
        end,
    },  
	
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst:InterruptBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")        
            inst.AnimState:PlayAnimation("hit")    
            inst.Physics:Stop()
			local sound_event = "dontstarve/characters/woodie/hurt"
            inst.SoundEmitter:PlaySound(sound_event)          
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        }, 
        
        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },            
    },
	
	State{
        name = "toolbroke",
        tags = {"busy"},
        onenter = function(inst, tool)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
            inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal") 
            local brokentool = SpawnPrefab("brokentool")
            brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition() )
            inst.sg.statemem.tool = tool
        end,
        
        onexit = function(inst)
		    local sameTool = inst.components.inventory:FindItem(function(item)
		        return item.prefab == inst.sg.statemem.tool.prefab
		    end)
		    if sameTool then
		        inst.components.inventory:Equip(sameTool)
		    end

            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end

        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },
    
    State{
        name = "armorbroke",
        tags = {"busy"},
        onenter = function(inst, armor)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_armour_break")
            inst.sg.statemem.armor = armor
        end,
        
        onexit = function(inst)
		    local sameArmor = inst.components.inventory:FindItem(function(item)
		        return item.prefab == inst.sg.statemem.armor.prefab
		    end)
		    if sameArmor then
		        inst.components.inventory:Equip(sameArmor)
		    end
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },
	
	State{
        name = "talk",
        tags = {"idle", "talking"},
        
        onenter = function(inst, noanim)
            inst.components.locomotor:Stop()
            if not noanim then
                inst.AnimState:PlayAnimation("dial_loop", true)
            end
            
            if inst.talksoundoverride then
                inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
            else
				local sound_name = string.sub(inst.prefab, 4)
                inst.SoundEmitter:PlaySound("dontstarve/characters/"..sound_name.."/talk_LP", "talk")
            end

            inst.sg:SetTimeout(1.5 + math.random()*.5)
        end,
        
        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("talk")
            inst.sg:GoToState("idle")
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("talk")
        end,
        
        events=
        {
            EventHandler("donetalking", function(inst) inst.sg:GoToState("idle") end),
        },
    }, 
	
    State{
        name = "werebeaver",
        tags = {"busy"},
        onenter = function(inst)
			inst.components.beaverness.doing_transform = true
            inst.Physics:Stop()     
            inst.AnimState:PlayAnimation("transform_pre")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
			if not inst.components.beaverness:IsBeaver() then
				inst.components.beaverness.makebeaver(inst)
			end
			inst.components.health:SetInvincible(false)
			inst.components.beaverness.doing_transform = false
        end,

        events =
        {
            EventHandler("animover", function(inst)
	            inst.components.beaverness.makebeaver(inst)
                inst.sg:GoToState("transform_pst")
            end ),
        } 
    },

	State{
        name = "towoodie",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("death")
            inst.sg:SetTimeout(3)
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/death_beaver")
            inst.components.beaverness.doing_transform = true
        end,
        
        ontimeout = function(inst) 
            inst:DoTaskInTime(2, function() 
                inst.components.beaverness.makeperson(inst)
                inst.components.sanity:SetPercent(.25)
                inst.components.health:SetPercent(.33)
                inst.components.hunger:SetPercent(.25)
                inst.components.beaverness.doing_transform = false
                inst.sg:GoToState("wakeup")
            end)
        end
    },
	    
	State{
        name = "wakeup",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("wakeup")
            inst.components.health:SetInvincible(true)
			if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
				inst.components.sleeper:WakeUp()
			end
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "transform_pst",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("transform_pst")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },  
	
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")        
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))    
        end,
		
        --[[events=
        {
            EventHandler("animover", function(inst) 	
				local skeleton = SpawnPrefab("skeleton")
				local spawnPoint = inst:GetPosition()
				skeleton.components.lootdropper:SetLoot({"dsawoodieskull"})
				skeleton.Transform:SetPosition(spawnPoint:Get())
			end ),
        }, ]]
    },  
	
    State{
        name="item_hat",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_hat")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },  
	
    State{
        name="item_in",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_in")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    }, 
	
	State{
        name="item_out",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_out")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },  
	
    State{
        name = "doshortaction",
        tags = {"doing", "busy"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.sg:SetTimeout(6*FRAMES)
        end,
        
        
        timeline=
        {
            TimeEvent(4*FRAMES, function( inst )
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(10*FRAMES, function( inst )
            inst.sg:RemoveStateTag("doing")
            inst.sg:AddStateTag("idle")
            end),
        },
        
        ontimeout = function(inst)
            inst:PerformBufferedAction()
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end ),
        },
    },
	
    State{
        name = "dolongaction",
        tags = {"doing", "busy"},
        
        timeline=
        {
            TimeEvent(4*FRAMES, function( inst )
                inst.sg:RemoveStateTag("busy")
            end),
        },
        
        onenter = function(inst, timeout)
            
            inst.sg:SetTimeout(timeout or 1)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
        end,
        
        ontimeout= function(inst)
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", false)
            inst:PerformBufferedAction()
        end,
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("make")
        end,
        
    },	
	
	State{
        name = "powerup",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerup")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	
    State{
        name = "powerdown",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerdown")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
        name = "sleep",
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep")
            inst.components.health:SetInvincible(true)
        end,

        onexit=function(inst)
            inst.components.health:SetInvincible(false)
        end,

    },
	
	State{
        name = "bedroll",
        
		--tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("bedroll")
             
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        	inst.AnimState:ClearOverrideSymbol("bedroll")          
        end,
        
        
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bedroll")
            end),
        },
        
		events=
		{        
			EventHandler("onwakeup", function(inst) inst.sg:GoToState("wakeup") end),
		},
    },  
	
    State{
        name = "book",
        tags = {"doing"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("book")
            inst.AnimState:OverrideSymbol("book_open", "player_actions_uniqueitem", "book_open")
            inst.AnimState:OverrideSymbol("book_closed", "player_actions_uniqueitem", "book_closed")
            inst.AnimState:OverrideSymbol("book_open_pages", "player_actions_uniqueitem", "book_open_pages")
            --inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal")
            if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.book then
                inst.components.inventory:ReturnActiveItem()
            end
            inst.SoundEmitter:PlaySound("dontstarve/common/use_book")
        end,
        
        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
            if inst.sg.statemem.book_fx then
                inst.sg.statemem.book_fx:Remove()
                inst.sg.statemem.book_fx = nil
            end
        end,
        
        timeline=
        {
            TimeEvent(0, function(inst)
                local fxtoplay = "book_fx"
                if inst.prefab == "waxwell" then
                    fxtoplay = "waxwell_book_fx" 
                end       
                local fx = SpawnPrefab(fxtoplay)
                local pos = inst:GetPosition()
                fx.Transform:SetRotation(inst.Transform:GetRotation())
                fx.Transform:SetPosition( pos.x, pos.y - .2, pos.z ) 
                inst.sg.statemem.book_fx = fx
            end),

            TimeEvent(28*FRAMES, function(inst) 
                if inst.prefab == "waxwell" then
                    inst.SoundEmitter:PlaySound("dontstarve/common/use_book_dark")
                else
                    inst.SoundEmitter:PlaySound("dontstarve/common/use_book_light")
                end
            end),

            TimeEvent(58*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/book_spell")
                inst:PerformBufferedAction()
                inst.sg.statemem.book_fx = nil
            end),

            TimeEvent(62*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "electrocute",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shock")
            --inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.fx = SpawnPrefab("shock_fx")

            inst.fx.Transform:SetRotation(inst.Transform:GetRotation())

            local pos = inst:GetPosition()
            inst.fx.Transform:SetPosition(pos.x, pos.y, pos.z)
            if inst.prefab ~= "dsawx78" then
                --inst.Light:Enable(true)
            end
            if inst.prefab ~= "dsawes" then
				local sound_name = string.sub(inst.prefab, 4)
                local path = inst.talker_path_override or "dontstarve/characters/"
                local sound_event = path..sound_name.."/hurt"
                inst.SoundEmitter:PlaySound(inst.hurtsoundoverride or sound_event)
            end
        end,

        onexit = function(inst)
            if inst.prefab ~= "wx78" then
                --inst.Light:Enable(false)
            end
            --inst.AnimState:ClearBloomEffectHandle()
            inst.fx:Remove()
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("electrocute_pst")
            end),
        },
    },
    State{
        name = "electrocute_pst",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shock_pst")
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end),
        },
    },	
}
    
return StateGraph("follower", states, events, "idle", actionhandlers)


