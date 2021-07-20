/obj/item/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	custom_materials = list(/datum/material/iron=6000, /datum/material/glass=3000)
	item_flags = SURGICAL_TOOL
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	tool_behaviour = TOOL_RETRACTOR
	toolspeed = 1

/obj/item/retractor/attack(mob/living/L, mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from hitting [L] with [src], as you are in help intent.</span>")
		return
	return ..()

/obj/item/retractor/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor_a"
	toolspeed = 0.7

/obj/item/retractor/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_RETRACTOR)
		tool_behaviour = TOOL_HEMOSTAT
		to_chat(user, "<span class='notice'>You configure the gears of [src], they are now in hemostat mode.</span>")
		icon_state = "hemostat_a"
	else
		tool_behaviour = TOOL_RETRACTOR
		to_chat(user, "<span class='notice'>You configure the gears of [src], they are now in retractor mode.</span>")
		icon_state = "retractor_a"

/obj/item/retractor/advanced/examine(mob/living/user)
	. = ..()
	. += "<span class = 'notice> It resembles a [tool_behaviour == TOOL_RETRACTOR ? "retractor" : "hemostat"]. </span>"

/obj/item/retractor/augment
	name = "retractor"
	desc = "Micro-mechanical manipulator for retracting stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	custom_materials = list(/datum/material/iron=6000, /datum/material/glass=3000)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5

/obj/item/retractor/ashwalker
	name = "Bone Retractor"
	desc = "Kinda looks like a chicken bone."
	icon = 'icons/obj/mining.dmi'
	icon_state = "retractor_bone"
	toolspeed = 0.85

/obj/item/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	custom_materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	item_flags = SURGICAL_TOOL
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("attacked", "pinched")
	tool_behaviour = TOOL_HEMOSTAT
	toolspeed = 1

/obj/item/hemostat/attack(mob/living/L, mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from hitting [L] with [src], as you are in help intent.</span>")
		return
	return ..()

/obj/item/hemostat/augment
	name = "hemostat"
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	custom_materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5
	attack_verb = list("attacked", "pinched")

/obj/item/hemostat/ashwalker
	name = "Femurstat"
	desc = "Bones that are strapped together with sinews. Used to stop bleeding."
	icon = 'icons/obj/mining.dmi'
	icon_state = "hemostat_bone"
	toolspeed = 0.85


/obj/item/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	custom_materials = list(/datum/material/iron=2500, /datum/material/glass=750)
	item_flags = SURGICAL_TOOL
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("burnt")
	tool_behaviour = TOOL_CAUTERY
	toolspeed = 1

/obj/item/cautery/attack(mob/living/L, mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from hitting [L] with [src], as you are in help intent.</span>")
		return
	return ..()

/obj/item/cautery/augment
	name = "cautery"
	desc = "A heated element that cauterizes wounds."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	custom_materials = list(/datum/material/iron=2500, /datum/material/glass=750)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5
	attack_verb = list("burnt")

/obj/item/cautery/ashwalker
	name = "Coretery"
	desc = "A legion core strapped to a bone. It can close wounds."
	icon = 'icons/obj/mining.dmi'
	icon_state = "cautery_bone"
	toolspeed = 0.85

/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	item_flags = SURGICAL_TOOL
	flags_1 = CONDUCT_1
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("drilled")
	tool_behaviour = TOOL_DRILL
	toolspeed = 1

/obj/item/surgicaldrill/attack(mob/living/L, mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from hitting [L] with [src], as you are in help intent.</span>")
		return
	return ..()

/obj/item/surgicaldrill/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical application."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgicaldrill_a"
	hitsound = 'sound/items/welder.ogg'

/obj/item/surgicaldrill/advanced/Initialize()
	. = ..()
	set_light(1)

/obj/item/surgicaldrill/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/weapons/tap.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_DRILL)
		tool_behaviour = TOOL_CAUTERY
		to_chat(user, "<span class='notice'>You focus the lenses of [src], it is now in mending mode.</span>")
		icon_state = "cautery_a"
	else
		tool_behaviour = TOOL_DRILL
		to_chat(user, "<span class='notice'>You dilate the lenses of [src], it is now in drilling mode.</span>")
		icon_state = "surgicaldrill_a"

/obj/item/surgicaldrill/advanced/examine(mob/living/user)
	. = ..()
	. += "<span class = 'notice> It's set to [tool_behaviour == TOOL_DRILL ? "drilling" : "mending"] mode.</span>"

/obj/item/surgicaldrill/augment
	name = "surgical drill"
	desc = "Effectively a small power drill contained within your arm, edges dulled to prevent tissue damage. May or may not pierce the heavens."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5
	attack_verb = list("drilled")

/obj/item/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=4000, /datum/material/glass=1000)
	item_flags = SURGICAL_TOOL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY
	tool_behaviour = TOOL_SCALPEL
	toolspeed = 1
	bare_wound_bonus = 20

/obj/item/scalpel/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 80 * toolspeed, 100, 0)

/obj/item/scalpel/attack(mob/living/L, mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from hitting [L] with [src], as you are in help intent.</span>")
		return
	return ..()

/obj/item/scalpel/advanced
	name = "laser scalpel"
	desc = "An advanced scalpel which uses laser technology to cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel_a"
	hitsound = 'sound/weapons/blade1.ogg'
	force = 16
	toolspeed = 0.7
	light_color = LIGHT_COLOR_GREEN
	sharpness = SHARP_POINTY

/obj/item/scalpel/advanced/Initialize()
	. = ..()
	set_light(1)

/obj/item/scalpel/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_SCALPEL)
		tool_behaviour = TOOL_SAW
		to_chat(user, "<span class='notice'>You increase the power of [src], now it can cut bones.</span>")
		set_light(2)
		force += 1 //we don't want to ruin sharpened stuff
		icon_state = "saw_a"
	else
		tool_behaviour = TOOL_SCALPEL
		to_chat(user, "<span class='notice'>You lower the power of [src], it can no longer cut bones.</span>")
		set_light(1)
		force -= 1
		icon_state = "scalpel_a"

/obj/item/scalpel/advanced/examine(mob/living/user)
	. = ..()
	. += "<span class = 'notice> It's set to [tool_behaviour == TOOL_SCALPEL ? "scalpel" : "saw"] mode. </span>"

/obj/item/scalpel/augment
	name = "scalpel"
	desc = "Ultra-sharp blade attached directly to your bone for extra-accuracy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=4000, /datum/material/glass=1000)
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	toolspeed = 0.5
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY

/obj/item/scalpel/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] [pick("wrists", "throat", "stomach")] with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/scalpel/ashwalker
	name = "diamond scalpel"
	desc = "Bones and a Diamond tied together to make a scalpel."
	icon = 'icons/obj/mining.dmi'
	icon_state = "scalpel_bone"
	force = 12
	toolspeed = 0.85

/obj/item/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	item_flags = SURGICAL_TOOL
	flags_1 = CONDUCT_1
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_SAW
	toolspeed = 1
	wound_bonus = 5
	bare_wound_bonus = 10

/obj/item/circular_saw/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 40 * toolspeed, 100, 5, 'sound/weapons/circsawhit.ogg') //saws are very accurate and fast at butchering

/obj/item/circular_saw/attack(mob/living/L, mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from hitting [L] with [src], as you are in help intent.</span>")
		return
	return ..()

/obj/item/circular_saw/augment
	name = "circular saw"
	desc = "A small but very fast spinning saw. Edges dulled to prevent accidental cutting inside of the surgeon."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	hitsound = 'sound/weapons/circsawhit.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	toolspeed = 0.5
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = SHARP_EDGED

/obj/item/circular_saw/ashwalker
	name = "diamond bonesaw"
	desc = "Bones designed like a skull, with diamond teeth to cut through bones."
	icon = 'icons/obj/mining.dmi'
	icon_state = "saw_bone"
	force = 12
	toolspeed = 0.85

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("slapped")

/obj/item/surgical_drapes/attack(mob/living/M, mob/user)
	if(!attempt_initiate_surgery(src, M, user))
		..()

/obj/item/surgical_drapes/advanced
	name = "smart surgical drapes"
	desc = "A smart set of drapes with wireless synchronization to the station's research networks, with an integrated display allowing users to execute advanced surgeries without the aid of an operating computer."
	var/datum/techweb/linked_techweb

/obj/item/surgical_drapes/advanced/Initialize(mapload)
	. = ..()
	linked_techweb = SSresearch.science_tech

/obj/item/surgical_drapes/advanced/proc/get_advanced_surgeries()
	. = list()
	if(!linked_techweb)
		return
	for(var/subtype in subtypesof(/datum/design/surgery))
		var/datum/design/surgery/prototype = subtype
		var/id = initial(prototype.id)
		if(id in linked_techweb.researched_designs)
			prototype = SSresearch.techweb_design_by_id(id)
			. |= prototype.surgery


/obj/item/surgical_drapes/goliath
	name = "goliath drapes"
	desc = "Probably not the most hygienic but what the heck else are you gonna use?"
	icon = 'icons/obj/mining.dmi'
	icon_state = "surgical_drapes_goli"

/obj/item/organ_storage //allows medical cyborgs to manipulate organs without hands
	name = "organ storage bag"
	desc = "A container for holding body parts."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_flags = SURGICAL_TOOL

/obj/item/organ_storage/afterattack(obj/item/I, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(contents.len)
		to_chat(user, "<span class='notice'>[src] already has something inside it.</span>")
		return
	if(!isorgan(I) && !isbodypart(I))
		to_chat(user, "<span class='notice'>[src] can only hold body parts!</span>")
		return

	user.visible_message("[user] puts [I] into [src].", "<span class='notice'>You put [I] inside [src].</span>")
	icon_state = "evidence"
	var/xx = I.pixel_x
	var/yy = I.pixel_y
	I.pixel_x = 0
	I.pixel_y = 0
	var/image/img = image("icon"=I, "layer"=FLOAT_LAYER)
	img.plane = FLOAT_PLANE
	I.pixel_x = xx
	I.pixel_y = yy
	add_overlay(img)
	add_overlay("evidence")
	desc = "An organ storage container holding [I]."
	I.forceMove(src)
	w_class = I.w_class

/obj/item/organ_storage/attack_self(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("[user] dumps [I] from [src].", "<span class='notice'>You dump [I] from [src].</span>")
		cut_overlays()
		I.forceMove(get_turf(src))
		icon_state = "evidenceobj"
		desc = "A container for holding body parts."
	else
		to_chat(user, "[src] is empty.")
	return

/obj/item/surgical_processor //allows medical cyborgs to scan and initiate advanced surgeries
	name = "\improper Surgical Processor"
	desc = "A device for scanning and initiating surgeries from a disk or operating computer."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_flags = NOBLUDGEON
	var/list/advanced_surgeries = list()

/obj/item/surgical_processor/afterattack(obj/item/O, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(O, /obj/item/disk/surgery))
		to_chat(user, "<span class='notice'>You load the surgery protocol from [O] into [src].</span>")
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 10, target = O))
			advanced_surgeries |= D.surgeries
		return TRUE
	if(istype(O, /obj/machinery/computer/operating))
		to_chat(user, "<span class='notice'>You copy surgery protocols from [O] into [src].</span>")
		var/obj/machinery/computer/operating/OC = O
		if(do_after(user, 10, target = O))
			advanced_surgeries |= OC.advanced_surgeries
		return TRUE
	return

/obj/item/bonesetter
	name = "bonesetter"
	desc = "For setting things right."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("corrected", "properly set")
	tool_behaviour = TOOL_BONESET
	toolspeed = 1

/obj/item/bonesetter/attack(mob/living/L, mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from hitting [L] with [src], as you are in help intent.</span>")
		return
	return ..()

/obj/item/bonesetter/bone
	name = "bone bonesetter"
	desc = "A bonesetter made of bones... for setting bones with... bones?"
	icon = 'icons/obj/mining.dmi'
	icon_state = "bone setter_bone"
	toolspeed = 0.85
