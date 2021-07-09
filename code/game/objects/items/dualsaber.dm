/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/dualsaber
	icon_state = "dualsaber0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	item_flags = SLOWS_WHILE_IN_HAND
	var/w_class_on = WEIGHT_CLASS_BULKY
	hitsound = "swing_hit"
	var/hitsound_on = 'sound/weapons/blade1.ogg'
	armour_penetration = 35
	var/saber_color = "green"
	light_color = "#00ff00"//green
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF
	wound_bonus = -110
	bare_wound_bonus = 20
	block_parry_data = /datum/block_parry_data/dual_esword
	block_chance = 60
	var/hacked = FALSE
	/// Can this reflect all energy projectiles?
	var/can_reflect = TRUE
	var/brightness_on = 6 //TWICE AS BRIGHT AS A REGULAR ESWORD
	var/list/possible_colors = list("red", "blue", "green", "purple")
	var/list/rainbow_colors = list(LIGHT_COLOR_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER)
	var/spinnable = TRUE
	total_mass = 0.4 //Survival flashlights typically weigh around 5 ounces.
	var/total_mass_on = 3.4
	var/wielded = FALSE // track wielded status on item
	var/slowdown_wielded = 0

/datum/block_parry_data/dual_esword // please run at the man going apeshit with his funny doublesword
	can_block_directions = BLOCK_DIR_NORTH | BLOCK_DIR_NORTHEAST | BLOCK_DIR_NORTHWEST | BLOCK_DIR_WEST | BLOCK_DIR_EAST
	block_damage_absorption = 5
	block_damage_multiplier = 0.15
	block_damage_multiplier_override = list(
		ATTACK_TYPE_MELEE = 0.25
	)
	block_start_delay = 0		// instantaneous block
	block_stamina_cost_per_second = 2.5
	block_stamina_efficiency = 3
	block_lock_sprinting = TRUE
	// no attacking while blocking
	block_lock_attacking = TRUE
	block_projectile_mitigation = 85
	// more efficient vs projectiles
	block_stamina_efficiency_override = list(
		TEXT_ATTACK_TYPE_PROJECTILE = 6
	)

	parry_time_windup = 0
	parry_time_active = 12
	parry_time_spindown = 0
	// we want to signal to players the most dangerous phase, the time when automatic counterattack is a thing.
	parry_time_windup_visual_override = 1
	parry_time_active_visual_override = 3
	parry_time_spindown_visual_override = 4
	parry_flags = PARRY_DEFAULT_HANDLE_FEEDBACK		// esword users can attack while parrying.
	parry_time_perfect = 2		// first ds isn't perfect
	parry_time_perfect_leeway = 1
	parry_imperfect_falloff_percent = 10
	parry_efficiency_considered_successful = 25		// VERY generous
	parry_failed_stagger_duration = 3 SECONDS

/obj/item/dualsaber/directional_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return, override_direction)
	if((attack_type & ATTACK_TYPE_PROJECTILE) && is_energy_reflectable_projectile(object))
		block_return[BLOCK_RETURN_REDIRECT_METHOD] = REDIRECT_METHOD_RETURN_TO_SENDER
		return BLOCK_SUCCESS | BLOCK_REDIRECTED | BLOCK_SHOULD_REDIRECT
	return ..()

/obj/item/dualsaber/on_active_parry(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, list/block_return, parry_efficiency, parry_time)
	. = ..()
	if(parry_efficiency >= 90)		// perfect parry
		block_return[BLOCK_RETURN_REDIRECT_METHOD] = REDIRECT_METHOD_DEFLECT
		. |= BLOCK_SHOULD_REDIRECT

/obj/item/dualsaber/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/dualsaber/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=3, force_wielded=34, \
					wieldsound='sound/weapons/saberon.ogg', unwieldsound='sound/weapons/saberoff.ogg')

/obj/item/dualsaber/Initialize()
	. = ..()
	if(LAZYLEN(possible_colors))
		saber_color = pick(possible_colors)
		switch(saber_color)
			if("red")
				light_color = LIGHT_COLOR_RED
			if("green")
				light_color = LIGHT_COLOR_GREEN
			if("blue")
				light_color = LIGHT_COLOR_LIGHT_CYAN
			if("purple")
				light_color = LIGHT_COLOR_LAVENDER

/// Triggered on wield of two handed item
/// Specific hulk checks due to reflection chance for balance issues and switches hitsounds.
/obj/item/dualsaber/proc/on_wield(obj/item/source, mob/living/carbon/user)
	if(user.has_dna() && user.dna.check_mutation(HULK))
		to_chat(user, "<span class='warning'>You lack the grace to wield this!</span>")
		return COMPONENT_TWOHANDED_BLOCK_WIELD
	wielded = TRUE
	sharpness = SHARP_EDGED
	w_class = w_class_on
	total_mass = total_mass_on
	hitsound = 'sound/weapons/blade1.ogg'
	slowdown += slowdown_wielded
	START_PROCESSING(SSobj, src)
	set_light(brightness_on)
	AddElement(/datum/element/sword_point)
	item_flags |= (ITEM_CAN_BLOCK|ITEM_CAN_PARRY)

/// Triggered on unwield of two handed item
/// switch hitsounds
/obj/item/dualsaber/proc/on_unwield(obj/item/source, mob/living/carbon/user)
	sharpness = initial(sharpness)
	w_class = initial(w_class)
	total_mass = initial(total_mass)
	wielded = FALSE
	hitsound = "swing_hit"
	slowdown_wielded -= slowdown_wielded
	STOP_PROCESSING(SSobj, src)
	set_light(0)
	RemoveElement(/datum/element/sword_point)
	item_flags &= ~(ITEM_CAN_BLOCK|ITEM_CAN_PARRY)

/obj/item/dualsaber/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/dualsaber/update_icon_state()
	if(wielded)
		icon_state = "dualsaber[saber_color][wielded]"
	else
		icon_state = "dualsaber0"
	clean_blood()

/obj/item/dualsaber/suicide_act(mob/living/carbon/user)
	if(wielded)
		user.visible_message("<span class='suicide'>[user] begins spinning way too fast! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)//stole from chainsaw code
		var/obj/item/organ/brain/B = user.getorganslot(ORGAN_SLOT_BRAIN)
		B.organ_flags &= ~ORGAN_VITAL	//this cant possibly be a good idea
		var/randdir
		for(var/i in 1 to 24)//like a headless chicken!
			if(user.is_holding(src))
				randdir = pick(GLOB.alldirs)
				user.Move(get_step(user, randdir),randdir)
				user.emote("spin")
				if (i == 3 && myhead)
					myhead.drop_limb()
				sleep(3)
			else
				user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
				return OXYLOSS
	else
		user.visible_message("<span class='suicide'>[user] begins beating [user.p_them()]self to death with \the [src]'s handle! It probably would've been cooler if [user.p_they()] turned it on first!</span>")
	return BRUTELOSS

/obj/item/dualsaber/attack(mob/target, mob/living/carbon/human/user)
	if(user.has_dna() && user.dna.check_mutation(HULK))
		to_chat(user, "<span class='warning'>You grip the blade too hard and accidentally drop it!</span>")
		user.dropItemToGround(src)
		return
	..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && (wielded) && user.prob_bad(40))
		impale(user)
		return
	if(spinnable && (wielded) && prob(50))
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/dualsaber/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.emote("flip")
		sleep(1)

/obj/item/dualsaber/proc/impale(mob/living/user)
	to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on [src].</span>")
	if (force)
		user.take_bodypart_damage(20,25)
	else
		user.adjustStaminaLoss(25)

/obj/item/dualsaber/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(!wielded)
		return NONE
	if(can_reflect && is_energy_reflectable_projectile(object) && (attack_type & ATTACK_TYPE_PROJECTILE))
		block_return[BLOCK_RETURN_REDIRECT_METHOD] = REDIRECT_METHOD_RETURN_TO_SENDER			//no you
		return BLOCK_SHOULD_REDIRECT | BLOCK_SUCCESS | BLOCK_REDIRECTED
	return ..()

/obj/item/dualsaber/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)  //In case thats just so happens that it is still activated on the groud, prevents hulk from picking it up
	if(wielded)
		to_chat(user, "<span class='warning'>You can't pick up such dangerous item with your meaty hands without losing fingers, better not to!</span>")
		return 1

/obj/item/dualsaber/process()
	if(wielded)
		if(hacked)
			rainbow_process()
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/dualsaber/proc/rainbow_process()
	light_color = pick(rainbow_colors)

/obj/item/dualsaber/ignition_effect(atom/A, mob/user)
	// same as /obj/item/melee/transforming/energy, mostly
	if(!wielded)
		return ""
	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [user.p_their()] nose"
	. = "<span class='warning'>[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.</span>"
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)
	// Light your candles while spinning around the room
	if(spinnable)
		INVOKE_ASYNC(src, .proc/jedi_spin, user)

/obj/item/dualsaber/green
	possible_colors = list("green")

/obj/item/dualsaber/red
	possible_colors = list("red")

/obj/item/dualsaber/blue
	possible_colors = list("blue")

/obj/item/dualsaber/purple
	possible_colors = list("purple")

/obj/item/dualsaber/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			to_chat(user, "<span class='warning'>2XRNBW_ENGAGE</span>")
			saber_color = "rainbow"
			update_icon()
		else
			to_chat(user, "<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()

/////////////////////////////////////////////////////
//	HYPEREUTACTIC Blades	/////////////////////////
/////////////////////////////////////////////////////

/obj/item/dualsaber/hypereutactic
	icon = 'icons/obj/1x2.dmi'
	icon_state = "hypereutactic"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	item_state = "hypereutactic"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	name = "hypereutactic blade"
	desc = "A supermassive weapon envisioned to cleave the very fabric of space and time itself in twain, the hypereutactic blade dynamically flash-forges a hypereutactic crystaline nanostructure capable of passing through most known forms of matter like a hot knife through butter."
	force = 7
	hitsound_on = 'sound/weapons/nebhit.ogg'
	armour_penetration = 60
	light_color = "#37FFF7"
	rainbow_colors = list("#FF0000", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF","#FF00FF", "#3399ff", "#ff9900", "#fb008b", "#9800ff", "#00ffa3", "#ccff00")
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "destroyed", "ripped", "devastated", "shredded")
	spinnable = FALSE
	total_mass_on = 4
	slowdown_wielded = 1

/obj/item/dualsaber/hypereutactic/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=7, force_wielded=40, \
					wieldsound='sound/weapons/nebon.ogg', unwieldsound='sound/weapons/nebhit.ogg')
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/dualsaber/hypereutactic/update_icon_state()
	return

/obj/item/dualsaber/hypereutactic/update_overlays()
	. = ..()
	var/mutable_appearance/blade_overlay = mutable_appearance(icon, "hypereutactic_blade")
	var/mutable_appearance/gem_overlay = mutable_appearance(icon, "hypereutactic_gem")

	if(light_color)
		blade_overlay.color = light_color
		gem_overlay.color = light_color

	. += gem_overlay

	if(wielded)
		. += blade_overlay

	clean_blood()

/obj/item/dualsaber/hypereutactic/AltClick(mob/living/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, FALSE) || hacked)
		return
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(alert("Are you sure you want to recolor your blade?", "Confirm Repaint", "Yes", "No") == "Yes")
		var/energy_color_input = input(usr,"","Choose Energy Color",light_color) as color|null
		if(!energy_color_input || !user.canUseTopic(src, BE_CLOSE, FALSE) || hacked)
			return
		light_color = sanitize_hexcolor(energy_color_input, desired_format=6, include_crunch=1)
		update_icon()
		update_light()
	return TRUE

/obj/item/dualsaber/hypereutactic/worn_overlays(isinhands, icon_file, used_state, style_flags = NONE)
	. = ..()
	if(isinhands)
		var/mutable_appearance/gem_inhand = mutable_appearance(icon_file, "hypereutactic_gem")
		gem_inhand.color = light_color
		. += gem_inhand
		if(wielded)
			var/mutable_appearance/blade_inhand = mutable_appearance(icon_file, "hypereutactic_blade")
			blade_inhand.color = light_color
			. += blade_inhand

/obj/item/dualsaber/hypereutactic/examine(mob/user)
	. = ..()
	if(!hacked)
		. += "<span class='notice'>Alt-click to recolor it.</span>"

/obj/item/dualsaber/hypereutactic/rainbow_process()
	. = ..()
	update_icon()
	update_light()

/obj/item/dualsaber/hypereutactic/chaplain
	name = "divine lightblade"
	desc = "A giant blade of bright and holy light, said to cut down the wicked with ease."
	force = 5
	armour_penetration = 0
	block_parry_data = /datum/block_parry_data/chaplain
	var/chaplain_spawnable = TRUE
	can_reflect = FALSE
	obj_flags = UNIQUE_RENAME

/datum/block_parry_data/chaplain
	parry_stamina_cost = 12
	parry_time_windup = 2
	parry_time_active = 5
	parry_time_spindown = 3
	// parry_flags = PARRY_DEFAULT_HANDLE_FEEDBACK
	parry_time_perfect = 1
	parry_time_perfect_leeway = 1
	parry_imperfect_falloff_percent = 7.5
	parry_efficiency_considered_successful = 80
	parry_efficiency_perfect = 120
	parry_efficiency_perfect_override = list(
		TEXT_ATTACK_TYPE_PROJECTILE = 30,
	)
	parry_failed_stagger_duration = 3 SECONDS

/obj/item/dualsaber/hypereutactic/chaplain/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=5, force_wielded=20, \
					wieldsound='sound/weapons/nebon.ogg', unwieldsound='sound/weapons/nebhit.ogg')
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, FALSE, null, null, FALSE)
