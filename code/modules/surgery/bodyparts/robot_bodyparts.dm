#define ROBOTIC_LIGHT_BRUTE_MSG "marred"
#define ROBOTIC_MEDIUM_BRUTE_MSG "dented"
#define ROBOTIC_HEAVY_BRUTE_MSG "falling apart"

#define ROBOTIC_LIGHT_BURN_MSG "scorched"
#define ROBOTIC_MEDIUM_BURN_MSG "charred"
#define ROBOTIC_HEAVY_BURN_MSG "smoldering"

//For ye whom may venture here, split up arm / hand sprites are formatted as "l_hand" & "l_arm".
//The complete sprite (displayed when the limb is on the ground) should be named "borg_l_arm".
//Failure to follow this pattern will cause the hand's icons to be missing due to the way get_limb_icon() works to generate the mob's icons using the aux_zone var.

/obj/item/bodypart/l_arm/robot
	name = "cyborg left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_arm"
	status = BODYPART_ROBOTIC

	wound_resistance = 10
	easy_heal_threshhold = 35 //Resistant against damage, but high mindamage once the threshhold is passed
	threshhold_passed_mindamage = 25

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/r_arm/robot
	name = "cyborg right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_r_arm"
	status = BODYPART_ROBOTIC

	wound_resistance = 10
	easy_heal_threshhold = 35 //Resistant against damage, but high mindamage once the threshhold is passed
	threshhold_passed_mindamage = 25

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/l_leg/robot
	name = "cyborg left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_leg"
	status = BODYPART_ROBOTIC

	wound_resistance = 10
	easy_heal_threshhold = 35 //Resistant against damage, but high mindamage once the threshhold is passed
	threshhold_passed_mindamage = 25

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/r_leg/robot
	name = "cyborg right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_r_leg"
	status = BODYPART_ROBOTIC

	wound_resistance = 10
	easy_heal_threshhold = 35 //Resistant against damage, but high mindamage once the threshhold is passed
	threshhold_passed_mindamage = 25

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/chest/robot
	name = "cyborg torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_chest"
	status = BODYPART_ROBOTIC

	wound_resistance = 10
	easy_heal_threshhold = 35 //Resistant against damage, but high mindamage once the threshhold is passed
	threshhold_passed_mindamage = 25

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	var/wired = 0
	var/obj/item/stock_parts/cell/cell = null

/obj/item/bodypart/chest/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(src.cell)
			to_chat(user, "<span class='warning'>You have already inserted a cell!</span>")
			return
		else
			if(!user.transferItemToLoc(W, src))
				return
			src.cell = W
			to_chat(user, "<span class='notice'>You insert the cell.</span>")
	else if(istype(W, /obj/item/stack/cable_coil))
		if(src.wired)
			to_chat(user, "<span class='warning'>You have already inserted wire!</span>")
			return
		if (W.use_tool(src, user, 0, 1))
			src.wired = 1
			to_chat(user, "<span class='notice'>You insert the wire.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of coil to wire it!</span>")
	else
		return ..()

/obj/item/bodypart/chest/robot/Destroy()
	if(cell)
		qdel(cell)
		cell = null
	return ..()


/obj/item/bodypart/chest/robot/drop_organs(mob/user)
	if(wired)
		new /obj/item/stack/cable_coil(user.loc, 1)
	if(cell)
		cell.forceMove(user.loc)
		cell = null
	..()


/obj/item/bodypart/head/robot
	name = "cyborg head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_head"
	status = BODYPART_ROBOTIC

	wound_resistance = 10
	easy_heal_threshhold = 35 //Resistant against damage, but high mindamage once the threshhold is passed
	threshhold_passed_mindamage = 25

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	var/obj/item/assembly/flash/handheld/flash1 = null
	var/obj/item/assembly/flash/handheld/flash2 = null



/obj/item/bodypart/head/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/F = W
		if(src.flash1 && src.flash2)
			to_chat(user, "<span class='warning'>You have already inserted the eyes!</span>")
			return
		else if(F.crit_fail)
			to_chat(user, "<span class='warning'>You can't use a broken flash!</span>")
			return
		else
			if(!user.transferItemToLoc(F, src))
				return
			if(src.flash1)
				src.flash2 = F
			else
				src.flash1 = F
			to_chat(user, "<span class='notice'>You insert the flash into the eye socket.</span>")
	else if(W.tool_behaviour == TOOL_CROWBAR)
		if(flash1 || flash2)
			W.play_tool_sound(src)
			to_chat(user, "<span class='notice'>You remove the flash from [src].</span>")
			if(flash1)
				flash1.forceMove(user.loc)
				flash1 = null
			if(flash2)
				flash2.forceMove(user.loc)
				flash2 = null
		else
			to_chat(user, "<span class='warning'>There is no flash to remove from [src].</span>")

	else
		return ..()

/obj/item/bodypart/head/robot/Destroy()
	if(flash1)
		qdel(flash1)
		flash1 = null
	if(flash2)
		qdel(flash2)
		flash2 = null
	return ..()


/obj/item/bodypart/head/robot/drop_organs(mob/user)
	if(flash1)
		flash1.forceMove(user.loc)
		flash1 = null
	if(flash2)
		flash2.forceMove(user.loc)
		flash2 = null
	..()



// Surplus lims
/obj/item/bodypart/l_arm/robot/surplus
	name = "surplus prosthetic left arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	max_damage = 25
	max_stamina_damage = 25
	wound_resistance = -20
	easy_heal_threshhold = 15 //Weak. Low threshhold, requiring specialized repair once damaged
	threshhold_passed_mindamage = 15

/obj/item/bodypart/r_arm/robot/surplus
	name = "surplus prosthetic right arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	max_damage = 25
	max_stamina_damage = 25
	wound_resistance = -20
	easy_heal_threshhold = 15 //Weak. Low threshhold, requiring specialized repair once damaged
	threshhold_passed_mindamage = 15

/obj/item/bodypart/l_leg/robot/surplus
	name = "surplus prosthetic left leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	max_damage = 25
	max_stamina_damage = 25
	wound_resistance = -20
	easy_heal_threshhold = 15 //Weak. Low threshhold, requiring specialized repair once damaged
	threshhold_passed_mindamage = 15

/obj/item/bodypart/r_leg/robot/surplus
	name = "surplus prosthetic right leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	max_damage = 25
	max_stamina_damage = 25
	wound_resistance = -20
	easy_heal_threshhold = 15 //Weak. Low threshhold, requiring specialized repair once damaged
	threshhold_passed_mindamage = 15

// Upgraded Prosthesics - Harder to hurt, harder to fix
/obj/item/bodypart/l_arm/robot/upgraded
	name = "reinforced prosthetic left arm"
	desc = "A robotic limb, reinforced to protect the internals from impact, but also significantly harder to repair without assistance."
	max_damage = 70
	max_stamina_damage = 70
	body_damage_coeff = 0.5 //keeps core damage contribution cap roughly equivalent despite higher actual health
	stam_damage_coeff = 0.5
	wound_resistance = 25
	easy_heal_threshhold = 40 //Can take significantly higher amounts of damage, but once you hit the threshold, cable and welding won't cut it.
	threshhold_passed_mindamage = 40

/obj/item/bodypart/r_arm/robot/upgraded
	name = "reinforced prosthetic right arm"
	desc = "A robotic limb, reinforced to protect the internals from impact, but also significantly harder to repair without assistance."
	max_damage = 70
	max_stamina_damage = 70
	body_damage_coeff = 0.5 //keeps core damage contribution cap roughly equivalent despite higher actual health
	stam_damage_coeff = 0.5
	wound_resistance = 25
	easy_heal_threshhold = 40 //Can take significantly higher amounts of damage, but once you hit the threshold, cable and welding won't cut it.
	threshhold_passed_mindamage = 40

/obj/item/bodypart/l_leg/robot/upgraded
	name = "reinforced prosthetic left leg"
	desc = "A robotic limb, reinforced to protect the internals from impact, but also significantly harder to repair without assistance."
	max_damage = 70
	max_stamina_damage = 70
	body_damage_coeff = 0.5 //keeps core damage contribution cap roughly equivalent despite higher actual health
	stam_damage_coeff = 0.5
	wound_resistance = 25
	easy_heal_threshhold = 40 //Can take significantly higher amounts of damage, but once you hit the threshold, cable and welding won't cut it.
	threshhold_passed_mindamage = 40

/obj/item/bodypart/r_leg/robot/upgraded
	name = "reinforced prosthetic right leg"
	desc = "A robotic limb, reinforced to protect the internals from impact, but also significantly harder to repair without assistance."
	max_damage = 70
	max_stamina_damage = 70
	body_damage_coeff = 0.5 //keeps core damage contribution cap roughly equivalent despite higher actual health
	stam_damage_coeff = 0.5
	wound_resistance = 25
	easy_heal_threshhold = 40 //Can take significantly higher amounts of damage, but once you hit the threshold, cable and welding won't cut it.
	threshhold_passed_mindamage = 40

/obj/item/bodypart/chest/robot/upgraded
	name = "reinforced prosthetic torso"
	desc = "A robotic torso, reinforced to protect the internals from impact, but also significantly harder to repair without assistance."
	wound_resistance = 25
	easy_heal_threshhold = 40 //Can take significantly higher amounts of damage, but once you hit the threshold, cable and welding won't cut it.
	threshhold_passed_mindamage = 40

/obj/item/bodypart/head/robot/upgraded
	name = "reinforced prosthetic head"
	desc = "A robotic braincase, reinforced to protect the internals from impact, but also significantly harder to repair without assistance."
	wound_resistance = 25
	easy_heal_threshhold = 40 //Can take significantly higher amounts of damage, but once you hit the threshold, cable and welding won't cut it.
	threshhold_passed_mindamage = 40

#undef ROBOTIC_LIGHT_BRUTE_MSG
#undef ROBOTIC_MEDIUM_BRUTE_MSG
#undef ROBOTIC_HEAVY_BRUTE_MSG

#undef ROBOTIC_LIGHT_BURN_MSG
#undef ROBOTIC_MEDIUM_BURN_MSG
#undef ROBOTIC_HEAVY_BURN_MSG
