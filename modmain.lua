PrefabFiles = {
	"dsafollowers",
	"dsafollowerskull",
	"dsaskeleton",
	"dsalucy",
	"dsalighter",
	"dsabooks",
	"dsaabigail",
	"dsaabigail_flower",
	"dsaballoons_empty",
	"dsawaxwelljournal",
	"dsashadowwaxwell",
	"dsashadowwaxwell_boat"
}

local STRINGS = GLOBAL.STRINGS
local TUNING = GLOBAL.TUNING
local ACTIONS = GLOBAL.ACTIONS
local require = GLOBAL.require

--ADD SPEECH FOR CHARACTERS
STRINGS.CHARACTERS.DSAWILSON = require "speech_wilson"
STRINGS.CHARACTERS.DSAWILLOW = require "speech_willow"
STRINGS.CHARACTERS.DSAWOLFGANG = require "speech_wolfgang"
STRINGS.CHARACTERS.DSAWENDY = require "speech_wendy"
STRINGS.CHARACTERS.DSAWX78 = require "speech_wx78"
STRINGS.CHARACTERS.DSAWICKERBOTTOM = require "speech_wickerbottom"
STRINGS.CHARACTERS.DSAWOODIE = require "speech_woodie"
STRINGS.CHARACTERS.DSAWAXWELL = require "speech_maxwell"
STRINGS.CHARACTERS.DSAWEBBER = require "speech_webber"
STRINGS.CHARACTERS.DSAWATHGRITHR = require "speech_wathgrithr"
STRINGS.CHARACTERS.DSAWALANI = require "speech_walani"
STRINGS.CHARACTERS.DSAWARLY = require "speech_warly"
STRINGS.CHARACTERS.DSAWILBUR = require "speech_wilbur"
STRINGS.CHARACTERS.DSAWOODLEGS = require "speech_woodlegs"

--FOLLOWERCOMMANDS

local Action = GLOBAL.Action
local ActionHandler = GLOBAL.ActionHandler

local STAYCOMMAND = Action({}, 2, true, true)
STAYCOMMAND.str = "Order to Stay"
STAYCOMMAND.id = "STAYCOMMAND"
STAYCOMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.followercommands then
		act.doer.components.locomotor:Stop()
		targ.components.followercommands:SetStaying(true)
		targ.components.followercommands:RememberSitPos("currentstaylocation", GLOBAL.Point(targ.Transform:GetWorldPosition()))
		return true
	end
end
AddAction(STAYCOMMAND)
AddStategraphActionHandler("wilson", ActionHandler(STAYCOMMAND))

local FOLLOWCOMMAND = Action({}, 2, true, true)
FOLLOWCOMMAND.str = "Order to Follow"
FOLLOWCOMMAND.id = "FOLLOWCOMMAND"
FOLLOWCOMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.followercommands then
		act.doer.components.locomotor:Stop()
		targ.components.followercommands:SetStaying(false)
		return true
	end
end
AddAction(FOLLOWCOMMAND)
AddStategraphActionHandler("wilson", ActionHandler(FOLLOWCOMMAND))

local DROP1COMMAND = Action({}, 2, true, true)
DROP1COMMAND.str = "Order to Drop items"
DROP1COMMAND.id = "DROP1COMMAND"
DROP1COMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.sleeper and not targ.components.sleeper.isasleep then
		act.doer.components.locomotor:Stop()
		targ.components.followercommands:DropItems()
	end
end
AddAction(DROP1COMMAND)
AddStategraphActionHandler("wilson", ActionHandler(DROP1COMMAND))

local DROP2COMMAND = Action({}, 2, true, true)
DROP2COMMAND.str = "Order to Drop unused equipment"
DROP2COMMAND.id = "DROP2COMMAND"
DROP2COMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.sleeper and not targ.components.sleeper.isasleep then
		act.doer.components.locomotor:Stop()
		targ.components.followercommands:DropItems()
	end
end
AddAction(DROP2COMMAND)
AddStategraphActionHandler("wilson", ActionHandler(DROP2COMMAND))

local DROP3COMMAND = Action({}, 2, true, true)
DROP3COMMAND.str = "Order to Drop everything"
DROP3COMMAND.id = "DROP3COMMAND"
DROP3COMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.sleeper and not targ.components.sleeper.isasleep then
		act.doer.components.locomotor:Stop()
		targ.components.followercommands:DropItems()
	end
end
AddAction(DROP3COMMAND)
AddStategraphActionHandler("wilson", ActionHandler(DROP3COMMAND))

local SWITCHCOMMAND = Action({}, 2, true, true)
SWITCHCOMMAND.str = "Order to Switch weapons"
SWITCHCOMMAND.id = "SWITCHCOMMAND"
SWITCHCOMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.sleeper and not targ.components.sleeper.isasleep then
		act.doer.components.locomotor:Stop()
		targ.components.followercommands:SwitchWeapon()
	end
end
AddAction(SWITCHCOMMAND)
AddStategraphActionHandler("wilson", ActionHandler(SWITCHCOMMAND))

local RESURRECT = Action({}, 3)
RESURRECT.str = "Resurrect"
RESURRECT.id = "RESURRECT"
RESURRECT.fn = function(act) 
	if act.doer and act.target and act.target.components.dsaresurrector and act.target.components.dsaresurrector.canresurrect then
        act.invobject.components.dsaresurrectable:OnResurrect(act.target, act.doer)
        return true
    end
end
AddAction(RESURRECT)
AddStategraphActionHandler("wilson", ActionHandler(RESURRECT, "doshortaction"))

ACTIONS.GIVE.priority = 4

local MOUNTCOMMAND = Action({}, 2, true, true)
MOUNTCOMMAND.str = "Order to Mount Raft"
MOUNTCOMMAND.id = "MOUNTCOMMAND"
MOUNTCOMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.followercommands then
		targ.components.followercommands:SetMount(true)
		return true
	end
end
AddAction(MOUNTCOMMAND)
AddStategraphActionHandler("wilson", ActionHandler(MOUNTCOMMAND))

local DISMOUNTCOMMAND = Action({}, 2, true, true)
DISMOUNTCOMMAND.str = "Order to Dismount Raft"
DISMOUNTCOMMAND.id = "DISMOUNTCOMMAND"
DISMOUNTCOMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.followercommands then
		targ.components.followercommands:SetDismount(true)
		return true
	end
end
AddAction(DISMOUNTCOMMAND)
AddStategraphActionHandler("wilson", ActionHandler(DISMOUNTCOMMAND))

--ADD CHARACTER STRINGS
--WILSON 	
STRINGS.NAMES.DSAWILSON = "Wilson"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWILSON = "Stars and atoms! Are you my doppelganger?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWILSON = "Hi Wilson!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWILSON = "Is tiny egghead man, Wilson! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWILSON = "How do you do, Wilson?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWILSON = "DETECTING... WILSON!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWILSON = "Greetings, dear Wilson! How are your theorems coming?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWILSON = "Wilson! Hey buddy!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWILSON = "Err, greetings, Mr. Wilson."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWILSON = "Hi Wilson! Nice weather we're having!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWILSON = "Wisdom guide you, Wilson!"

STRINGS.NAMES.DSAWILSONSKELETON = "Wilson's skeleton."
STRINGS.NAMES.DSAWILSONSKULL = "Wilson's skull."

--WILLOW
STRINGS.NAMES.DSAWILLOW = "Willow"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWILLOW = "Good day to you, Willow!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWILLOW = "Hey! That's my face! Give it back!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWILLOW = "Is tiny torchlady, Willow! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWILLOW = "How do you do, Willow?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWILLOW = "DETECTING... WILLOW!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWILLOW = "Ah, greetings dear Willow!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWILLOW = "Look who it is! Willow!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWILLOW = "Greetings, Ms. Willow."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWILLOW = "Hi Willow! How's Bernie?"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWILLOW = "Greetings, Willow, the Inflammable!"

STRINGS.NAMES.DSALIGHTER = "Willow's Lighter"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIGHTER = "It's her lucky lighter."

STRINGS.NAMES.DSAWILLOWSKELETON = "Willow's skeleton."
STRINGS.NAMES.DSAWILLOWSKULL = "Willow's skull."

--WOLFGANG	
STRINGS.NAMES.DSAWOLFGANG = "Wolfgang"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWOLFGANG = "It's good to see you, Wolfgang!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWOLFGANG = "Hi Wolfgang!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWOLFGANG = "Hello friend! We must arm wrestle!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWOLFGANG = "Hi Wolfgang. Why are you shaking?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWOLFGANG = "DETECTING... WOLFGANG!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWOLFGANG = "Ah, greetings dear Wolfgang!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWOLFGANG = "That's my buddy, Wolfgang! Hey!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWOLFGANG = "Good day to you, Mr. Wolfgang."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWOLFGANG = "Hi %s! Have you been working out?"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWOLFGANG = "Health and strength to you, Wolfgang!"

STRINGS.NAMES.DSAWOLFGANGSKELETON = "Wolfgang's skeleton."
STRINGS.NAMES.DSAWOLFGANGSKULL = "Wolfgang's skull."

--WENDY	
STRINGS.NAMES.DSAWENDY = "Wendy"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWENDY = "Greetings, Wendy!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWENDY = "Hi Wendy!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWENDY = "Is very tiny, scary Wendy! H-hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWENDY = "She looks sad..."
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWENDY = "DETECTING... WENDY!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWENDY = "Ah, greetings dear Wendy!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWENDY = "Wendy! Hi little buddy!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWENDY = "Greetings, Ms. Wendy. How are you?"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWENDY =  "Hi Wendy! Let's play, okay?"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWENDY = "Spirits be with you, Wendy!"

STRINGS.NAMES.DSAABIGAIL_FLOWER = "Abigail's Flower"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ABIGAIL_FLOWER = 
		{ 
			GENERIC ="It's hauntingly beautiful.",
			LONG = "It hurts my soul to look at that thing.",
			MEDIUM = "It's giving me the creeps.",
			SOON = "Something is up with that flower!",
			HAUNTED_POCKET = "I don't think I should hang on to this.",
			HAUNTED_GROUND = "I'd die to find out what it does.",
		}
STRINGS.NAMES.DSAABIGAIL = "Abigail"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ABIGAIL = "Awww, she has a cute little bow."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ABIGAIL = "What do you desire, apparition?"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ABIGAIL = "Why won't these mortals just stay dead?"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.ABIGAIL = "That's no party poltergeist!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ABIGAIL = "Fascinating. Can you speak, specter?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.ABIGAIL = "So, what happened to you?"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ABIGAIL = "Are you friendly ghost?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.ABIGAIL = "That ain't right."
STRINGS.CHARACTERS.WX78.DESCRIBE.ABIGAIL = "UNDEAD ALERT"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ABIGAIL = "Why won't these mortals just stay dead?"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.ABIGAIL = "That's no party poltergeist!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ABIGAIL = "What do you desire, apparition?"

STRINGS.NAMES.DSAWENDYSKELETON = "Wendy's skeleton."
STRINGS.NAMES.DSAWENDYSKULL = "Wendy's skull."

--WX78 	
STRINGS.NAMES.DSAWX78 = "WX-78"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWX78 = "Good day to you, WX-78!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWX78 = "Hi WX-78!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWX78 = "Is tiny robot, WX-78! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWX78 = "How do you do, WX-78?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWX78 = "GREETINGS. YOU LOOK MORE INTELLIGENT THAN THE OTHERS"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWX78 = "Ah, the automaton. Greetings, dear WX-78!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWX78 = "It's my metal buddy, WX-78!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWX78 = "Greetings, Mx. WX-78."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWX78 = "Hi WX-78! You look very non-organic today!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWX78 = "May Thor's bolts energize you, WX-78!"

STRINGS.NAMES.DSAWX78SKELETON = "WX-78's skeleton."
STRINGS.NAMES.DSAWX78SKULL = "WX-78's skull."

--WICKERBOTTOM 
STRINGS.NAMES.DSAWICKERBOTTOM = "Wickerbottom"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWICKERBOTTOM = "Good day, Wickerbottom!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWICKERBOTTOM = "Hi Wickerbottom!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWICKERBOTTOM = "Is strong brainlady! Hello, tiny Wickerbottom!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWICKERBOTTOM = "How do you do, Ms. Wickerbottom?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWICKERBOTTOM = "DETECTING... WICKERBOTTOM!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWICKERBOTTOM = "Ah, greetings! Fancy seeing you here."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWICKERBOTTOM = "Wickerbottom. Ma'am."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWICKERBOTTOM = "Greetings, Ms. Wickerbottom."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWICKERBOTTOM = "Hello Ms. Wickerbottom!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWICKERBOTTOM = "Good health and wisdom to you, elder Wickerbottom!"

STRINGS.NAMES.DSAWICKERBOTTOMSKELETON = "Wickerbottom's skeleton."
STRINGS.NAMES.DSAWICKERBOTTOMSKULL = "Wickerbottom's skull."

STRINGS.NAMES.DSABOOK_BIRDS = "Birds of the World"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_BIRDS = "No point studying when I can just wing it."

STRINGS.NAMES.DSABOOK_BRIMSTONE = "The End is Nigh!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_BRIMSTONE = "The beginning was dull, but got better near the end."

STRINGS.NAMES.DSABOOK_SLEEP = "Sleepytime Stories"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_SLEEP = "Strange, it's just 500 pages of telegraph codes."

STRINGS.NAMES.DSABOOK_GARDENING = "Applied Horticulture"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_GARDENING = "I see no farm in reading that."

STRINGS.NAMES.DSABOOK_TENTACLES = "On Tentacles"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_TENTACLES = "Someone'll get suckered into reading this."

--WOODIE
STRINGS.NAMES.DSAWOODIE = "Woodie"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWOODIE = "Greetings, Woodie!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWOODIE = "Hi Woodie!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWOODIE = "Is beard! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWOODIE = "How do you do, Woodie?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWOODIE = "DETECTING... WOODIE!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWOODIE = "Ah, greetings dear Woodie!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWOODIE = "Fancy seeing another Canadian here."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWOODIE = "Greetings, Mr. Woodie."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWOODIE = "Hi Woodie, hi Lucy!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWOODIE = "May Yggdrasil bind us as the nine worlds, Woodie!"

STRINGS.NAMES.DSALUCY = "Lucy the Axe"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUCY = "That's a prettier axe than I'm used to."

STRINGS.NAMES.DSAWOODIESKELETON = "Woodie's skeleton."
STRINGS.NAMES.DSAWOODIESKULL = "Woodie's skull."

--WES
STRINGS.NAMES.DSAWES = "Wes"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWES = "Greetings, Wes!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWES = "Hi Wes!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWES = "Is tiny oddman, Wes! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWES = "How do you do, Wes?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWES = "DETECTING... WES!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWES = "Ah, the mime lad. Greetings, dear Wes!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWES = "Wes! How ya doin', buddy?"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWES = "Greetings, Mr. Wes."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWES = "Hey! Hi Wes!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWES = "Good health to you, Wes!"

STRINGS.NAMES.DSABALLOONS_EMPTY = "Pile o' Balloons"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BALLOONS_EMPTY = "It looks like clown currency."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BALLOON = "How are they floating?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.BALLOONS_EMPTY = "I could fill them with flammable gas."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.BALLOON = "That's just asking to be popped."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.BALLOONS_EMPTY = "Wolfgang will make balloon muscles."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.BALLOON = "Is full of clown breath!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.BALLOONS_EMPTY = "These look as deflated as I feel..."
STRINGS.CHARACTERS.WENDY.DESCRIBE.BALLOON = "A colorful reminder that my childhood is no more."
STRINGS.CHARACTERS.WX78.DESCRIBE.BALLOONS_EMPTY = "USELESS RUBBER SACKS"
STRINGS.CHARACTERS.WX78.DESCRIBE.BALLOON = "WX-78 CANNOT BE FOOLED. THESE ANIMALS ARE NOT REAL."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.BALLOONS_EMPTY = "These seem frivolous."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.BALLOON = "Could serve as a suitable diversion."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.BALLOONS_EMPTY = "Are those balloons?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.BALLOON = "It's squeaky. Just like a real woodland creature."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.BALLOONS_EMPTY = "Those look much too jovial for my liking."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.BALLOON = "This seems out of place here. Too cheery."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.BALLOONS_EMPTY = "Is there going to be a party?!"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.BALLOON = "Balloon animals! Balloon animals!!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.BALLOONS_EMPTY = "Such colors! I could sing!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.BALLOON = "Fie! Foul beast!"

STRINGS.NAMES.DSAWESSKELETON = "Wes's skeleton."
STRINGS.NAMES.DSAWESSKULL = "Wes's skull."

--WAXWELL
STRINGS.NAMES.DSAWAXWELL = "Maxwell"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWAXWELL = "Decent day to you, Maxwell!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWAXWELL = "Hi Maxwell!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWAXWELL = "Is tiny frailman, Maxwell! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWAXWELL = "How are you coping, Maxwell?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWAXWELL = "DETECTING... MAXWELL!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWAXWELL = "Ah, greetings dear Maxwell!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWAXWELL = "Hey Maxwell, how you doin' ya big hoser?"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWAXWELL = "What a dapper fellow!"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWAXWELL = "Hi Maxwell! Lookin' dapper!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWAXWELL = "Greetings, Maxwell, my ally!"

STRINGS.NAMES.DSAWAXWELLSKELETON = "Maxwell's skeleton."
STRINGS.NAMES.DSAWAXWELLSKULL = "Maxwell's skull."

STRINGS.NAMES.DSAWAXWELLJOURNAL = "Codex Umbra"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WAXWELLJOURNAL = "Spooky."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.WAXWELLJOURNAL = "Would make a great bedtime story... for nightmares!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WAXWELLJOURNAL = "Wolfgang is glad he cannot read!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.WAXWELLJOURNAL = "Do you want me to read you a story, Abigail?"
STRINGS.CHARACTERS.WX78.DESCRIBE.WAXWELLJOURNAL = "GOOSEBUMPS ACTIVATED"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.WAXWELLJOURNAL = "I'm not letting THAT in MY library!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.WAXWELLJOURNAL = "Trees made into... paper? How unholy!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.WAXWELLJOURNAL = "I'm so sorry Charlie."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.WAXWELLJOURNAL = "I don't think we should play with that..."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.WAXWELLJOURNAL = "A tragic tale of woe and misery!"

--WEBBER
STRINGS.NAMES.DSAWEBBER = "Webber"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWEBBER = "Good day, Webber!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWEBBER = "Hi Webber!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWEBBER = "Is tiny monsterchild, Webber! H-hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWEBBER = "Hey, Webber!"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWEBBER = "DETECTING... WEBBER!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWEBBER = "Ah, greetings dear Webber!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWEBBER = "Webber! Hi little buddy!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWEBBER = "Greetings, Mr. Webber."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWEBBER = "A spiderfriend! Hi Webber!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWEBBER = "Blessings upon you, spiderchild Webber!"

STRINGS.NAMES.DSAWEBBERSKELETON = "Webber's skeleton."
STRINGS.NAMES.DSAWEBBERSKULL = "Webber's skull."

--WATHGRITHR
STRINGS.NAMES.DSAWATHGRITHR = "Wigfrid"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWATHGRITHR = "Good day, Wigfrid!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWATHGRITHR = "Hi Wigfrid!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWATHGRITHR = "Is very strong, Wigfrid! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWATHGRITHR = "How do you do, Wigfrid?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWATHGRITHR = "DETECTING... WIGFRID!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWATHGRITHR = "Ah, greetings dear Wigfrid!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWATHGRITHR = "Wigfrid! Hi little buddy!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.DSAWATHGRITHR = "Greetings, Ms. Wigfrid."
STRINGS.CHARACTERS.WEBBER.DESCRIBE.DSAWATHGRITHR = "Wow, Wigfrid! You're lookin' tough!"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.DSAWATHGRITHR = "Hail, Wigfrid, fellow shieldmaiden!"

STRINGS.NAMES.DSAWATHGRITHRSKELETON = "Wigfrid's skeleton."
STRINGS.NAMES.DSAWATHGRITHRSKULL = "Wigfrid's skull."

--COMPONENT POSTINITS
function addLightningStrikeToFollowers(inst)
	inst.DoLightningStrike = function(self, pos, ignoreRods)
		local rod = nil
		local player = nil
		if not ignoreRods then
			local rods = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 40, {"lightningrod"}, {"dead"})
			for k,v in pairs(rods) do -- Find nearby lightning rods, prioritize battery-charging rods and closer rods
				if not rod or (v.lightningpriority > rod.lightningpriority or GLOBAL.distsq(pos, Vector3(v.Transform:GetWorldPosition())) < GLOBAL.distsq(pos, GLOBAL.Vector3(rod.Transform:GetWorldPosition()))) then
					rod = v
				end
			end			
		end
		
		local followers = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 10, {"summonedbyplayer"})
		for k,v in pairs(followers) do 
			if not follower or GLOBAL.distsq(pos, GLOBAL.Vector3(v.Transform:GetWorldPosition())) < GLOBAL.distsq(pos, GLOBAL.Vector3(follower.Transform:GetWorldPosition())) then
				follower = v
			end
		end
		local rand = math.random()
		if rod then
			pos = GLOBAL.Vector3(rod.Transform:GetWorldPosition() )
		elseif follower and rand <= follower.components.playerlightningtarget:GetHitChance() then
			pos = GLOBAL.Vector3(follower.Transform:GetWorldPosition()) 
		elseif GLOBAL.GetPlayer().components.playerlightningtarget 
		  and rand <= GLOBAL.GetPlayer().components.playerlightningtarget:GetHitChance() then
			player = GLOBAL.GetPlayer()
			pos = GLOBAL.Vector3(GLOBAL.GetPlayer().Transform:GetWorldPosition() )
		end

		local lightning = GLOBAL.SpawnPrefab("lightning")
		lightning.Transform:SetPosition(pos:Get())

		if rod then
			rod:PushEvent("lightningstrike", {rod=rod})
		else
			if player then
				player.components.playerlightningtarget:DoStrike()
			elseif follower and rand <= follower.components.playerlightningtarget:GetHitChance() then
				follower.components.playerlightningtarget:DoStrike()
			end
			local ents = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 3)
			for k,v in pairs(ents) do 
				if not v:IsInLimbo() then
					if v.components.burnable and not v.components.fueled and not v.components.burnable.lightningimmune then
						v.components.burnable:Ignite()
					end
				end
			end
		end
	end
end
AddComponentPostInit("seasonmanager", addLightningStrikeToFollowers)

function restrictCharacter(inst)
	inst.CollectInventoryActions = function(self, doer, actions, right)
		if doer.prefab == "wes" or doer.prefab == "dsawes" then
			table.insert(actions, ACTIONS.MAKEBALLOON)
		end
	end
end
AddComponentPostInit("balloonmaker", restrictCharacter)

function setForWebber(inst)
	inst.DoFoodEffects = function(self, food)
		if food:HasTag("monstermeat") then
			if self.inst:HasTag("player") or self.inst.prefab == "dsawebber" then
				return not self.monsterimmune
			else
				return not self.strongstomach
			end
		else
			return true
		end
	end
end
AddComponentPostInit("eater", setForWebber)

function removeValidTarget(inst)
	inst.IsValidTarget = function(self, target)
		if not target 
		   or not target:IsValid()
		   or not target.components
		   or not target.components.combat
		   or not target.entity:IsVisible()
		   or not target.components.health
		   or target == self.inst
		   or target.components.health:IsDead()
		   or (target:HasTag("shadow") and not self.inst.components.sanity)
		   or GLOBAL.Vector3(target.Transform:GetWorldPosition()).y > self.attackrange
		   or (self.inst == GLOBAL.GetPlayer() and target:HasTag("resurrected")) then
			return false
		else
			return true
		end
	end
end
AddComponentPostInit("combat", removeValidTarget)
--[[function adjustGuarantee(inst)
	inst.GuaranteeItems = function(self, items)

		self.inst:DoTaskInTime(0,function()
			for k,v in pairs(items) do
				local item = v
				
				if type(v) == "table" then
					item = v.equipped
				end 
				
				local equipped = false
				for k,v in pairs (self.equipslots) do
					if v and v.prefab == item then
						equipped = true
					end
				end

				if self == GLOBAL.GetPlayer() and (equipped or self:Has(item, 1)) then
					for k,v in pairs(Ents) do
						if v.prefab == item and v.components.inventoryitem:GetGrandOwner() ~= GetPlayer() then
							v:Remove()
						end
					end
				else
					if type(v) == "table" then
						item = v.placed
					end 
					for k,v in pairs(GLOBAL.Ents) do
						if v.prefab == item then
							item = nil
							break
						end
					end
					if item then
					     if type(v) == "table" then
							item = v.equipped
						end   
						self:GiveItem(GLOBAL.SpawnPrefab(item))
					end
				end
			end
		end)
	end
end
AddComponentPostInit("inventory", adjustGuarantee)]]

function removeDistortionFromFollower(inst)
	inst.OnUpdate = function(self, dt)
		if self.inst:HasTag("player") then	
			local t = 1 - self:GetPercent()
			local b = 0
			local c = .2
			local d =1
			t = t / d
			local speed = -c * t * (t - 2) + b
			self.fxtime = self.fxtime + dt*speed
			
			GLOBAL.PostProcessor:SetEffectTime(self.fxtime)
		
			t = self:GetPercent()
			c = 1
			t = t / d
			local distortion_value = -c * t * (t - 2) + b
			GLOBAL.PostProcessor:SetDistortionFactor(distortion_value)
			GLOBAL.PostProcessor:SetDistortionRadii( 0.5, 0.685 )
		end

		if self.inst.components.health.invincible == true or self.inst.is_teleporting == true then
			return
		end
		
		self:Recalc(dt)	
	end
end
AddComponentPostInit("sanity", removeDistortionFromFollower)

function addFollowerDamageResist(inst)
	inst.CalcDamage = function(self, target, weapon, multiplier)
		if target:HasTag("alwaysblock") then
			return 0
		end
		local multiplier = multiplier or self.damagemultiplier or 1
		local bonus = self.damagebonus or 0
		if weapon then
			local weapondamage = 0
			if weapon.components.weapon.variedmodefn then
				local d = weapon.components.weapon.variedmodefn(weapon)
				weapondamage = d.damage        
			else
				weapondamage = weapon.components.weapon.damage
			end
			if not weapondamage then weapondamage = 0 end
			return weapondamage*multiplier + bonus
		end
		
		if target and (target:HasTag("player") or target:HasTag("summonedbyplayer")) then
			return self.defaultdamage * self.playerdamagepercent * multiplier + bonus
		end
		
		return self.defaultdamage * multiplier + bonus
	end
end
AddComponentPostInit("combat", addFollowerDamageResist)

--PREFAB POSTINITS
function RemoveSelfBurn(inst)
	inst.components.weapon:SetAttackCallback(nil)
end
AddPrefabPostInit("torch", RemoveSelfBurn)

function AddSkulls(inst)
	inst:DoTaskInTime(0, function() 
	
		if GLOBAL.GetWorld():IsCave() or GLOBAL.GetWorld():IsRuins() or GLOBAL.GetWorld():HasTag("volcano") then
			return
		end
		
		local skulls = {}
		local wilson_exists = false
		local willow_exists = false
		local wolfgang_exists = false
		local wendy_exists = false
		local wx78_exists = false
		local wickerbottom_exists = false
		local woodie_exists = false
		local wes_exists = false
		local waxwell_exists = false
		local webber_exists = false
		local wigrid_exists = false
		for k,v in pairs(GLOBAL.Ents) do
			if v.prefab == "wilson" or v.prefab == "dsawilson" or v.prefab == "dsawilsonskull" or v.prefab == "dsawilsonskeleton" then
				wilson_exists = true
			elseif v.prefab == "willow" or v.prefab == "dsawillow" or v.prefab == "dsawillowskull" or v.prefab == "dsawillowskeleton" then
				willow_exists = true
			elseif v.prefab == "wolfgang" or v.prefab == "dsawolfgang" or v.prefab == "dsawolfgangskull" or v.prefab == "dsawolfgangskeleton" then
				wolfgang_exists = true
			elseif v.prefab == "wendy" or v.prefab == "dsawendy" or v.prefab == "dsawendyskull" or v.prefab == "dsawendyskeleton" then
				wendy_exists = true
			elseif v.prefab == "wx78" or v.prefab == "dsawx78" or v.prefab == "dsawx78skull" or v.prefab == "dsawx78skeleton" then
				wx78_exists = true
			elseif v.prefab == "wickerbottom" or v.prefab == "dsawickerbottom" or v.prefab == "dsawickerbottomskull" or v.prefab == "dsawickerbottomskeleton" then
				wickerbottom_exists = true
			elseif v.prefab == "woodie" or v.prefab == "dsawoodie" or v.prefab == "dsawoodieskull" or v.prefab == "dsawoodieskeleton" then
				woodie_exists = true
			elseif v.prefab == "wes" or v.prefab == "dsawes" or v.prefab == "dsawesskull" or v.prefab == "dsawesskeleton" then
				wes_exists = true
			elseif v.prefab == "waxwell" or v.prefab == "dsawaxwell" or v.prefab == "dsawaxwellskull" or v.prefab == "dsawaxwellskeleton" then
				waxwell_exists = true
			elseif v.prefab == "webber" or v.prefab == "dsawebber" or v.prefab == "dsawebberskull" or v.prefab == "dsawebberskeleton" then
				webber_exists = true
			elseif v.prefab == "wathgrithr" or v.prefab == "dsawathgrithr" or v.prefab == "dsawathgrithrskull" or v.prefab == "dsawathgrithrskeleton" then
				wigrid_exists = true
			end
		end
		if not wilson_exists then
			table.insert(skulls,"dsawilsonskeleton")
		end
		if not willow_exists then
			table.insert(skulls,"dsawillowskeleton")
		end
		if not wolfgang_exists then
			table.insert(skulls,"dsawolfgangskeleton")
		end
		if not wendy_exists then
			table.insert(skulls,"dsawendyskeleton")
		end
		if not wx78_exists then
			table.insert(skulls,"dsawx78skeleton")
		end
		if not wickerbottom_exists then
			table.insert(skulls,"dsawickerbottomskeleton")
		end
		if not woodie_exists then
			table.insert(skulls,"dsawoodieskeleton")
		end
		if not wes_exists then
			table.insert(skulls,"dsawesskeleton")
		end
		if not waxwell_exists then
			table.insert(skulls,"dsawaxwellskeleton")
		end
		if not webber_exists then
			table.insert(skulls,"dsawebberskeleton")
		end
		if not wigrid_exists then
			table.insert(skulls,"dsawathgrithrskeleton")
		end
		
		for i,v in ipairs(skulls) do
			local skull = GLOBAL.SpawnPrefab(v)
			local offset = GLOBAL.Vector3(math.random(-5,5),0,math.random(-5,5))
			local spawnPoint = inst:GetPosition()+offset
			skull.Transform:SetPosition(spawnPoint:Get())
			if v == "dsawillowskeleton" then
				local item = GLOBAL.SpawnPrefab("dsalighter")
				item.Transform:SetPosition(spawnPoint:Get())
			elseif v == "dsawendyskeleton" then
				local item = GLOBAL.SpawnPrefab("dsaabigail_flower")
				item.Transform:SetPosition(spawnPoint:Get())
			elseif v == "dsawoodieskeleton" then
				local item = GLOBAL.SpawnPrefab("dsalucy")
				item.Transform:SetPosition(spawnPoint:Get())
			elseif v == "dsawesskeleton" then
				local item = GLOBAL.SpawnPrefab("dsaballoons_empty")
				item.Transform:SetPosition(spawnPoint:Get())
			elseif v == "dsawaxwellskeleton" then
				local item = GLOBAL.SpawnPrefab("dsawaxwelljournal")
				item.Transform:SetPosition(spawnPoint:Get())
			end
				
		end
		
	end)
end
AddPrefabPostInit("wilson", AddSkulls)
AddPrefabPostInit("willow", AddSkulls)
AddPrefabPostInit("wolfgang", AddSkulls)
AddPrefabPostInit("wendy", AddSkulls)
AddPrefabPostInit("wickerbottom", AddSkulls)
AddPrefabPostInit("wx78", AddSkulls)
AddPrefabPostInit("woodie", AddSkulls)
AddPrefabPostInit("wes", AddSkulls)
AddPrefabPostInit("waxwell", AddSkulls)
AddPrefabPostInit("webber", AddSkulls)
AddPrefabPostInit("wathgrithr", AddSkulls)
AddPrefabPostInit("walani", AddSkulls)
AddPrefabPostInit("warly", AddSkulls)
AddPrefabPostInit("wilbur", AddSkulls)
AddPrefabPostInit("woodlegs", AddSkulls)

function AddTradable(inst)
	if not inst.components.tradable then
		inst:AddComponent("tradable")
	end
end
--Add Weapons
AddPrefabPostInit("torch", AddTradable)
AddPrefabPostInit("lantern", AddTradable)
AddPrefabPostInit("axe", AddTradable)
AddPrefabPostInit("goldenaxe", AddTradable)
AddPrefabPostInit("pickaxe", AddTradable)
AddPrefabPostInit("goldenpickaxe", AddTradable)
AddPrefabPostInit("shovel", AddTradable)
AddPrefabPostInit("goldenshovel", AddTradable)
AddPrefabPostInit("hammer", AddTradable)
AddPrefabPostInit("pitchfork", AddTradable)
AddPrefabPostInit("multitool_axe_pickaxe", AddTradable)
AddPrefabPostInit("umbrella", AddTradable)
AddPrefabPostInit("grass_umbrella", AddTradable)
AddPrefabPostInit("fishingrod", AddTradable)
AddPrefabPostInit("bugnet", AddTradable)
AddPrefabPostInit("cane", AddTradable)
AddPrefabPostInit("spear", AddTradable)
AddPrefabPostInit("hambat", AddTradable)
AddPrefabPostInit("batbat", AddTradable)
AddPrefabPostInit("tentaclespike", AddTradable)
AddPrefabPostInit("nightsword", AddTradable)
AddPrefabPostInit("ruins_bat", AddTradable)
AddPrefabPostInit("nightstick", AddTradable)
AddPrefabPostInit("blowdart_sleep", AddTradable)
AddPrefabPostInit("blowdart_fire", AddTradable)
AddPrefabPostInit("blowdart_pipe", AddTradable)
AddPrefabPostInit("boomerang", AddTradable)
AddPrefabPostInit("icestaff", AddTradable)
AddPrefabPostInit("firestaff", AddTradable)
AddPrefabPostInit("telestaff", AddTradable)
AddPrefabPostInit("orangestaff", AddTradable)
AddPrefabPostInit("greenstaff", AddTradable)
AddPrefabPostInit("yellowstaff", AddTradable)

--Add Armor
AddPrefabPostInit("armorgrass", AddTradable)
AddPrefabPostInit("armorwood", AddTradable)
AddPrefabPostInit("armormarble", AddTradable)
AddPrefabPostInit("armorruins", AddTradable)
AddPrefabPostInit("armor_sanity", AddTradable)
AddPrefabPostInit("armorslurper", AddTradable)
AddPrefabPostInit("armorsnurtleshell", AddTradable)
AddPrefabPostInit("sweatervest", AddTradable)
AddPrefabPostInit("trunkvest_summer", AddTradable)
AddPrefabPostInit("trunkvest_winter", AddTradable)
AddPrefabPostInit("amulet", AddTradable)
AddPrefabPostInit("blueamulet", AddTradable)
AddPrefabPostInit("purpleamulet", AddTradable)
AddPrefabPostInit("orangeamulet", AddTradable)
AddPrefabPostInit("greenamulet", AddTradable)
AddPrefabPostInit("yellowamulet", AddTradable)

--Add Miscellaneous
AddPrefabPostInit("cutgrass", AddTradable)
AddPrefabPostInit("sapling", AddTradable)
AddPrefabPostInit("twigs", AddTradable)
AddPrefabPostInit("pinecone", AddTradable)
AddPrefabPostInit("nightlight", AddTradable)
AddPrefabPostInit("bluegem", AddTradable)
AddPrefabPostInit("redgem", AddTradable)
AddPrefabPostInit("purplegem", AddTradable)
AddPrefabPostInit("orangegem", AddTradable)
AddPrefabPostInit("greengem", AddTradable)
AddPrefabPostInit("yellowgem", AddTradable)
AddPrefabPostInit("log", AddTradable)
AddPrefabPostInit("livinglog", AddTradable)
AddPrefabPostInit("marble", AddTradable)
AddPrefabPostInit("cutreeds", AddTradable)
AddPrefabPostInit("cutlichen", AddTradable)
AddPrefabPostInit("bedroll_straw", AddTradable)
AddPrefabPostInit("bedroll_furry", AddTradable)
AddPrefabPostInit("dug_grass", AddTradable)
AddPrefabPostInit("dug_sapling", AddTradable)
AddPrefabPostInit("dug_berrybush", AddTradable)
AddPrefabPostInit("dug_berrybush2", AddTradable)
AddPrefabPostInit("tentaclespots", AddTradable)
AddPrefabPostInit("poop", AddTradable)
AddPrefabPostInit("guano", AddTradable)
AddPrefabPostInit("nightmarefuel", AddTradable)
AddPrefabPostInit("slurper_pelt", AddTradable)
AddPrefabPostInit("gears", AddTradable)
AddPrefabPostInit("ash", AddTradable)
AddPrefabPostInit("spoiled_food", AddTradable)
AddPrefabPostInit("stinger", AddTradable)
AddPrefabPostInit("spidergland", AddTradable)
AddPrefabPostInit("feather_crow", AddTradable)
AddPrefabPostInit("feather_robin", AddTradable)
AddPrefabPostInit("feather_robin_winter", AddTradable)
AddPrefabPostInit("beardhair", AddTradable)
AddPrefabPostInit("manrabbit_tail", AddTradable)
AddPrefabPostInit("charcoal", AddTradable)
AddPrefabPostInit("mosquitosack", AddTradable)
AddPrefabPostInit("slurtleslime", AddTradable)
AddPrefabPostInit("spidereggsack", AddTradable)
AddPrefabPostInit("heatrock", AddTradable)
AddPrefabPostInit("thulecite_pieces", AddTradable)
AddPrefabPostInit("walrus_tusk", AddTradable)
AddPrefabPostInit("dsabook_sleep", AddTradable)
AddPrefabPostInit("dsabook_gardening", AddTradable)
AddPrefabPostInit("dsabook_brimstone", AddTradable)
AddPrefabPostInit("dsabook_birds", AddTradable)
AddPrefabPostInit("dsabook_tentacles", AddTradable)
AddPrefabPostInit("dsaabigail_flower", AddTradable)
AddPrefabPostInit("dsaballoons_empty", AddTradable)
AddPrefabPostInit("dsalucy", AddTradable)
AddPrefabPostInit("dsalighter", AddTradable)
AddPrefabPostInit("dsawaxwelljournal", AddTradable)

--DLC REIGN OF GIANTS
AddPrefabPostInit("glommerfuel", AddTradable)
AddPrefabPostInit("boneshard", AddTradable)
AddPrefabPostInit("coontail", AddTradable)
AddPrefabPostInit("goose_feather", AddTradable)
AddPrefabPostInit("dragon_scales", AddTradable)
AddPrefabPostInit("bearger_fur", AddTradable)
AddPrefabPostInit("lightninggoathorn", AddTradable)

AddPrefabPostInit("staff_tornado", AddTradable)
AddPrefabPostInit("spear_wathgrithr", AddTradable)

AddPrefabPostInit("reflectivevest", AddTradable)
AddPrefabPostInit("hawaiianshirt", AddTradable)
AddPrefabPostInit("raincoat", AddTradable)
AddPrefabPostInit("beargervest", AddTradable)
AddPrefabPostInit("armordragonfly", AddTradable)

--DLC SHIPWRECKED
AddPrefabPostInit("vine", AddTradable)
AddPrefabPostInit("bamboo", AddTradable)
AddPrefabPostInit("sand", AddTradable)
AddPrefabPostInit("seashell", AddTradable)
AddPrefabPostInit("seaweed", AddTradable)
AddPrefabPostInit("seaweed_cooked", AddTradable)
AddPrefabPostInit("limestone", AddTradable)
AddPrefabPostInit("messagebottleempty", AddTradable)
AddPrefabPostInit("coral_brain", AddTradable)
AddPrefabPostInit("snakeskin", AddTradable)
AddPrefabPostInit("shark_gills", AddTradable)
AddPrefabPostInit("ox_horn", AddTradable)

AddPrefabPostInit("machete", AddTradable)
AddPrefabPostInit("goldenmachete", AddTradable)
AddPrefabPostInit("obsidianmachete", AddTradable)
AddPrefabPostInit("obsidianaxe", AddTradable)
AddPrefabPostInit("obsidianspear", AddTradable)
AddPrefabPostInit("obsidianmachete", AddTradable)
AddPrefabPostInit("palmleaf_umbrella", AddTradable)

AddPrefabPostInit("armorlimestone", AddTradable)
AddPrefabPostInit("blubbersuit", AddTradable)
AddPrefabPostInit("armor_snakeskin", AddTradable)
AddPrefabPostInit("armor_windbreaker", AddTradable)
AddPrefabPostInit("tarsuit", AddTradable)
AddPrefabPostInit("armor_snakeskin", AddTradable)
AddPrefabPostInit("armorobsidian", AddTradable)

function AddRessurector(inst)
	if not inst.components.dsaresurrector then
		inst:AddComponent("dsaresurrector")
	end
end
AddPrefabPostInit("resurrectionstone", AddRessurector)

local function HearPanFlute(inst, musician, instrument)
	if inst.components.sleeper and not inst:HasTag('summonedbyplayer') then
	    inst.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME)
	end
end

function BlockFollowersFromSleep(inst)
	inst.components.instrument:SetOnHeardFn(HearPanFlute)
end
AddPrefabPostInit("panflute", BlockFollowersFromSleep)