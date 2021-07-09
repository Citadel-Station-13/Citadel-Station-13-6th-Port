/obj/item/shield
	name = "shield"
	icon = 'icons/obj/shields.dmi'
	item_flags = ITEM_CAN_BLOCK
	block_parry_data = /datum/block_parry_data/shield
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	/// Shield flags
	var/shield_flags = SHIELD_FLAGS_DEFAULT
	/// Last shieldbash world.time
	var/last_shieldbash = 0
	/// Shieldbashing cooldown
	var/shieldbash_cooldown = 5 SECONDS
	/// Shieldbashing stamina cost
	var/shieldbash_stamcost = 7.5
	/// Shieldbashing knockback
	var/shieldbash_knockback = 2
	/// Shield bashing brute damage
	var/shieldbash_brutedamage = 5
	/// Shield bashing stamina damage
	var/shieldbash_stamdmg = 15
	/// Shield bashing stagger duration
	var/shieldbash_stagger_duration = 3.5 SECONDS
	/// Shield bashing push distance
	var/shieldbash_push_distance = 1

/datum/block_parry_data/shield
	block_damage_multiplier = 0.25
	block_stamina_efficiency = 2.5
	block_stamina_cost_per_second = 2.5
	block_slowdown = 0
	block_lock_attacking = FALSE
	block_lock_sprinting = TRUE
	block_start_delay = 1.5
	block_damage_absorption = 5
	block_resting_stamina_penalty_multiplier = 2
	block_projectile_mitigation = 75
	block_damage_absorption_override = list(
		TEXT_ATTACK_TYPE_TACKLE = INFINITY,
		TEXT_ATTACK_TYPE_THROWN = 10
	)

/obj/item/shield/examine(mob/user)
	. = ..()
	if(shield_flags & SHIELD_CAN_BASH)
		. += "<span class='notice'>Right click on combat mode attack with [src] to shield bash!</span>"
		if(shield_flags & SHIELD_BASH_GROUND_SLAM)
			. += "<span class='notice'>Directly rightclicking on a downed target with [src] will slam them instead of bashing.</span>"

/obj/item/shield/proc/on_shield_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance)
	return TRUE

/obj/item/shield/alt_pre_attack(atom/A, mob/living/user, params)
	user_shieldbash(user, A, user.a_intent == INTENT_HARM)
	return TRUE

/obj/item/shield/altafterattack(atom/target, mob/user, proximity_flag, click_parameters)
	user_shieldbash(user, target, user.a_intent == INTENT_HARM)
	return TRUE

/obj/item/shield/proc/do_shieldbash_effect(mob/living/user, dir, harmful)
	var/px = 0
	var/py = 0
	switch(dir)
		if(NORTH)
			py = 12
		if(SOUTH)
			py = -12
		if(EAST)
			px = 12
		if(WEST)
			px = -12
	var/obj/effect/temp_visual/dir_setting/shield_bash/effect = new(user.loc, dir)
	effect.pixel_x = user.pixel_x - 32		//96x96 effect, -32.
	effect.pixel_y = user.pixel_y - 32
	user.visible_message("<span class='warning'>[user] [harmful? "charges forwards with" : "sweeps"] [src]!</span>")
	animate(user, pixel_x = px, pixel_y = py, time = 3, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
	animate(user, pixel_x = -px, pixel_y = -py, time = 3, flags = ANIMATION_RELATIVE)
	animate(effect, alpha = 0, pixel_x = px * 1.5, pixel_y = py * 1.5, time = 3, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)

/obj/item/shield/proc/bash_target(mob/living/user, mob/living/target, bashdir, harmful)
	if(!(target.status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE))	// should probably add stun absorption check at some point I guess..
		// unified stun absorption system when lol
		target.visible_message("<span class='warning'>[user] slams [target] with [src], but [target] doesn't falter!</span>", "<span class='userdanger'>[user] slams you with [src], but it barely fazes you!</span>")
		return FALSE
	var/target_downed = !CHECK_MOBILITY(target, MOBILITY_STAND)
	var/wallhit = FALSE
	var/turf/target_current_turf = get_turf(target)
	if(harmful)
		target.visible_message("<span class='warning'>[target_downed? "[user] slams [src] into [target]" : "[user] bashes [target] with [src]"]!</span>",
		"<span class='warning'>[target_downed? "[user] slams [src] into you" : "[user] bashes you with [src]"]!</span>")
	else
		target.visible_message("<span class='warning'>[user] shoves [target] with [src]!</span>",
		"<span class='warning'>[user] shoves you with [src]!</span>")
	for(var/i in 1 to harmful? shieldbash_knockback : shieldbash_push_distance)
		var/turf/new_turf = get_step(target, bashdir)
		var/mob/living/carbon/human/H = locate() in (new_turf.contents - target)
		if(H && harmful)
			H.visible_message("<span class='warning'>[target] is sent crashing into [H]!</span>",
			"<span class='userdanger'>[target] is sent crashing into you!</span>")
			H.KnockToFloor()
			wallhit = TRUE
			break
		else
			step(target, bashdir)
			if(get_turf(target) == target_current_turf)
				wallhit = TRUE
				break
			else
				target_current_turf = get_turf(target)
	var/disarming = (target_downed && (shield_flags & SHIELD_BASH_GROUND_SLAM_DISARM)) || (shield_flags & SHIELD_BASH_ALWAYS_DISARM) || (wallhit && (shield_flags & SHIELD_BASH_WALL_DISARM))
	var/knockdown = !target_downed && ((shield_flags & SHIELD_BASH_ALWAYS_KNOCKDOWN) || (wallhit && (shield_flags & SHIELD_BASH_WALL_KNOCKDOWN)))
	if(shieldbash_stagger_duration || knockdown)
		target.visible_message("<span class='warning'>[target] is knocked [knockdown? "to the floor" : "off balance"]!</span>",
		"<span class='userdanger'>You are knocked [knockdown? "to the floor" : "off balance"]!</span>")
	if(knockdown)
		target.KnockToFloor(disarming)
	else if(disarming)
		target.drop_all_held_items()

	if(harmful)
		target.apply_damage(shieldbash_stamdmg, STAMINA, BODY_ZONE_CHEST)
		target.apply_damage(shieldbash_brutedamage, BRUTE, BODY_ZONE_CHEST)
	target.Stagger(shieldbash_stagger_duration)
	return TRUE

/obj/item/shield/proc/user_shieldbash(mob/living/user, atom/target, harmful)
	if(!(shield_flags & SHIELD_CAN_BASH))
		to_chat(user, "<span class='warning'>[src] can't be used to shield bash!</span>")
		return FALSE
	if(!CHECK_MOBILITY(user, MOBILITY_STAND))
		to_chat(user, "<span class='warning'>You can't bash with [src] while on the ground!</span>")
		return FALSE
	if(world.time < last_shieldbash + shieldbash_cooldown)
		to_chat(user, "<span class='warning'>You can't bash with [src] again so soon!</span>")
		return FALSE
	var/mob/living/livingtarget = target		//only access after an isliving check!
	if(isliving(target) && !CHECK_MOBILITY(livingtarget, MOBILITY_STAND))		//GROUND SLAAAM
		if(!(shield_flags & SHIELD_BASH_GROUND_SLAM))
			to_chat(user, "<span class='warning'>You can't ground slam with [src]!</span>")
			return FALSE
		if(!user.UseStaminaBuffer(shieldbash_stamcost, warn = TRUE))
			return FALSE
		bash_target(user, target, NONE, harmful)
		user.do_attack_animation(target, used_item = src)
		playsound(src, harmful? "swing_hit" : 'sound/weapons/thudswoosh.ogg', 75, 1)
		last_shieldbash = world.time
		return TRUE
	// Directional sweep!
	last_shieldbash = world.time
	if(!user.UseStaminaBuffer(shieldbash_stamcost, warn = TRUE))
		return FALSE
	// Since we are in combat mode, we can probably safely use the user's dir instead of getting their mouse pointing cardinal dir.
	var/bashdir = user.dir
	do_shieldbash_effect(user, bashdir, harmful)
	var/list/checking = list(get_step(user, user.dir), get_step(user, turn(user.dir, 45)), get_step(user, turn(user.dir, -45)))
	var/list/victims = list()
	for(var/i in checking)
		var/turf/T = i
		for(var/mob/living/L in T.contents)
			victims += L
	if(length(victims))
		for(var/i in victims)
			bash_target(user, i, bashdir, harmful)
		playsound(src, harmful? "swing_hit" : 'sound/weapons/thudswoosh.ogg', 75, 1)
	else
		playsound(src, 'sound/weapons/punchmiss.ogg', 75, 1)
	return length(victims)

/obj/effect/temp_visual/dir_setting/shield_bash
	icon = 'icons/effects/96x96_attack_sweep.dmi'
	icon_state = "shield_bash"
	duration = 3

/obj/item/shield/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(ismovable(object))
		var/atom/movable/AM = object
		if(CHECK_BITFIELD(shield_flags, SHIELD_TRANSPARENT) && (AM.pass_flags & PASSGLASS))
			return BLOCK_NONE
	if(CHECK_BITFIELD(shield_flags, SHIELD_NO_RANGED) && (attack_type & ATTACK_TYPE_PROJECTILE))
		return BLOCK_NONE
	if(CHECK_BITFIELD(shield_flags, SHIELD_NO_MELEE) && (attack_type & ATTACK_TYPE_MELEE))
		return BLOCK_NONE
	if(attack_type & ATTACK_TYPE_THROWN)
		final_block_chance += 30
	if(attack_type & ATTACK_TYPE_TACKLE)
		final_block_chance = 100
	. = ..()
	if(. & BLOCK_SUCCESS)
		on_shield_block(owner, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, block_return)

/obj/item/shield/on_active_block(mob/living/owner, atom/object, damage, damage_blocked, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return, override_direction)
	on_shield_block(owner, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance)

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/glass=7500, /datum/material/iron=1000)
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time
	var/repair_material = /obj/item/stack/sheet/mineral/titanium
	var/can_shatter = TRUE
	shield_flags = SHIELD_FLAGS_DEFAULT | SHIELD_TRANSPARENT
	max_integrity = 450

/obj/item/shield/riot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else if(istype(W, repair_material))
		if(obj_integrity >= max_integrity)
			to_chat(user, "<span class='warning'>[src] is already in perfect condition.</span>")
		else
			var/obj/item/stack/S = W
			S.use(1)
			obj_integrity = max_integrity
			to_chat(user, "<span class='notice'>You repair [src] with [S].</span>")
	else
		return ..()

/obj/item/shield/riot/examine(mob/user)
	. = ..()
	var/healthpercent = round((obj_integrity/max_integrity) * 100, 1)
	switch(healthpercent)
		if(50 to 99)
			. += "<span class='info'>It looks slightly damaged.</span>"
		if(25 to 50)
			. += "<span class='info'>It appears heavily damaged.</span>"
		if(0 to 25)
			. += "<span class='warning'>It's falling apart!</span>"

/obj/item/shield/riot/proc/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/glassbr3.ogg', 100)
	new /obj/item/shard((get_turf(src)))

/obj/item/shield/riot/on_shield_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	var/final_damage = damage

	if(attack_type & ATTACK_TYPE_MELEE)
		var/obj/hittingthing = object
		if(hittingthing.damtype == BURN)
			if(CHECK_BITFIELD(shield_flags, SHIELD_ENERGY_WEAK))
				final_damage *= 2
			else if(CHECK_BITFIELD(shield_flags, SHIELD_ENERGY_STRONG))
				final_damage *= 0.5

		if(hittingthing.damtype == BRUTE)
			if(CHECK_BITFIELD(shield_flags, SHIELD_KINETIC_WEAK))
				final_damage *= 2
			else if(CHECK_BITFIELD(shield_flags, SHIELD_KINETIC_STRONG))
				final_damage *= 0.5

		if(hittingthing.damtype == STAMINA || hittingthing.damtype == TOX || hittingthing.damtype == CLONE || hittingthing.damtype == BRAIN || hittingthing.damtype == OXY)
			final_damage = 0

	if(attack_type & ATTACK_TYPE_PROJECTILE)
		var/obj/item/projectile/shootingthing = object
		if(is_energy_reflectable_projectile(shootingthing))
			if(CHECK_BITFIELD(shield_flags, SHIELD_ENERGY_WEAK))
				final_damage *= 2
			else if(CHECK_BITFIELD(shield_flags, SHIELD_ENERGY_STRONG))
				final_damage *= 0.5

		if(!is_energy_reflectable_projectile(object))
			if(CHECK_BITFIELD(shield_flags, SHIELD_KINETIC_WEAK))
				final_damage *= 2
			else if(CHECK_BITFIELD(shield_flags, SHIELD_KINETIC_STRONG))
				final_damage *= 0.5

		if(shootingthing.damage_type == STAMINA)
			if(CHECK_BITFIELD(shield_flags, SHIELD_DISABLER_DISRUPTED))
				final_damage *= 3 //disablers melt these kinds of shields. Really meant more for holoshields.
			else
				final_damage = 0

		if(shootingthing.damage_type == TOX || shootingthing.damage_type == CLONE || shootingthing.damage_type == BRAIN || shootingthing.damage_type == OXY)
			final_damage = 0

	if(can_shatter && (obj_integrity <= damage))
		var/turf/T = get_turf(owner)
		T.visible_message("<span class='warning'>[attack_text] destroys [src]!</span>")
		shatter(owner)
		qdel(src)
		return FALSE
	take_damage(final_damage)
	return ..()

/obj/item/shield/riot/energy_proof
	name = "energy resistant shield"
	desc = "An ablative shield designed to absorb and disperse energy attacks. This comes at significant cost to its ability to withstand ballistics and kinetics, breaking apart easily."
	armor = list("melee" = 30, "bullet" = -10, "laser" = 80, "energy" = 80, "bomb" = -40, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50)
	icon_state = "riot_laser"
	item_state = "riot_laser"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	shield_flags = SHIELD_FLAGS_DEFAULT | SHIELD_ENERGY_STRONG | SHIELD_KINETIC_WEAK
	max_integrity = 300

/obj/item/shield/riot/kinetic_proof
	name = "kinetic resistant shield"
	desc = "A polymer and ceramic shield designed to absorb ballistic projectiles and kinetic force. It doesn't do very well into energy attacks, especially from weapons that inflict burns."
	armor = list("melee" = 30, "bullet" = 80, "laser" = 0, "energy" = 0, "bomb" = -40, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50)
	icon_state = "riot_bullet"
	item_state = "riot_bullet"
	shield_flags = SHIELD_FLAGS_DEFAULT | SHIELD_KINETIC_STRONG | SHIELD_ENERGY_WEAK
	max_integrity = 300

/obj/item/shield/riot/roman
	name = "\improper Roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	repair_material = /obj/item/stack/sheet/mineral/wood
	shield_flags = SHIELD_FLAGS_DEFAULT
	max_integrity = 250

/obj/item/shield/riot/roman/fake
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>. It appears to be a bit flimsy."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	shield_flags = SHIELD_ENERGY_WEAK | SHIELD_KINETIC_WEAK | SHIELD_NO_RANGED
	max_integrity = 40

/obj/item/shield/riot/roman/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/grillehit.ogg', 100)
	new /obj/item/stack/sheet/metal(get_turf(src))

/obj/item/shield/riot/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	item_state = "buckler"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 10)
	resistance_flags = FLAMMABLE
	repair_material = /obj/item/stack/sheet/mineral/wood
	shield_flags = SHIELD_FLAGS_DEFAULT | SHIELD_ENERGY_WEAK
	max_integrity = 150

/obj/item/shield/riot/buckler/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/bang.ogg', 50)
	new /obj/item/stack/sheet/mineral/wood(get_turf(src))

/obj/item/shield/riot/flash
	name = "strobe shield"
	desc = "A shield with a built in, high intensity light capable of blinding and disorienting suspects. Takes regular handheld flashes as bulbs."
	icon_state = "flashshield"
	item_state = "flashshield"
	var/obj/item/assembly/flash/handheld/embedded_flash

/obj/item/shield/riot/flash/Initialize()
	. = ..()
	embedded_flash = new(src)

/obj/item/shield/riot/flash/ComponentInitialize()
	. = .. ()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/shield/riot/flash/attack(mob/living/M, mob/user)
	. =  embedded_flash.attack(M, user)
	update_icon()

/obj/item/shield/riot/flash/attack_self(mob/living/carbon/user)
	. = embedded_flash.attack_self(user)
	update_icon()

/obj/item/shield/riot/flash/on_shield_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	. = ..()
	if (. && damage && !embedded_flash.crit_fail)
		embedded_flash.activate()
		update_icon()

/obj/item/shield/riot/flash/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/flash = W
		if(flash.crit_fail)
			to_chat(user, "<span class='warning'>No sense replacing it with a broken bulb!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You begin to replace the bulb...</span>")
			if(do_after(user, 20, target = user))
				if(flash.crit_fail || !flash || QDELETED(flash))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				qdel(embedded_flash)
				embedded_flash = flash
				flash.forceMove(src)
				update_icon()
				return
	..()

/obj/item/shield/riot/flash/emp_act(severity)
	. = ..()
	embedded_flash.emp_act(severity)
	update_icon()

/obj/item/shield/riot/flash/update_icon_state()
	if(!embedded_flash || embedded_flash.crit_fail)
		icon_state = "riot"
		item_state = "riot"
	else
		icon_state = "flashshield"
		item_state = "flashshield"

/obj/item/shield/riot/flash/examine(mob/user)
	. = ..()
	if (embedded_flash?.crit_fail)
		. += "<span class='info'>The mounted bulb has burnt out. You can try replacing it with a new one.</span>"

/obj/item/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon_state = "teleriot0"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
	var/active = FALSE

/obj/item/shield/riot/tele/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(!active)
		return BLOCK_NONE
	return ..()

/obj/item/shield/riot/tele/can_active_block()
	return ..() && active

/obj/item/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	icon_state = "teleriot[active]"
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, TRUE)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = ITEM_SLOT_BACK
		to_chat(user, "<span class='notice'>You extend \the [src].</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = null
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)

/obj/item/shield/makeshift
	name = "metal shield"
	desc = "A large shield made of wired and welded sheets of metal. The handle is made of cloth and leather, making it unwieldy."
	armor = list("melee" = 25, "bullet" = 25, "laser" = 5, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 80)
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	item_state = "metal"
	icon_state = "makeshift_shield"
	custom_materials = list(/datum/material/iron = 18000)
	slot_flags = null
	max_integrity = 300 //Made of metal welded together its strong but not unkillable
	force = 10
	throwforce = 7

/obj/item/shield/riot/tower
	name = "tower shield"
	desc = "An immense tower shield. Designed to ensure maximum protection to the user, at the expense of mobility."
	armor = list("melee" = 95, "bullet" = 95, "laser" = 75, "energy" = 60, "bomb" = 90, "bio" = 90, "rad" = 0, "fire" = 90, "acid" = 10) //Armor for the item, dosnt transfer to user
	item_state = "metal"
	icon_state = "metal"
	force = 16
	slowdown = 2
	throwforce = 15 //Massive piece of metal
	max_integrity = 600
	w_class = WEIGHT_CLASS_HUGE
	item_flags = SLOWS_WHILE_IN_HAND | ITEM_CAN_BLOCK
	shield_flags = SHIELD_FLAGS_DEFAULT

/obj/item/shield/riot/tower/swat
	name = "swat shield"
	max_integrity = 250

/obj/item/shield/riot/implant
	name = "hardlight shield implant"
	desc = "A hardlight plane of force projected from the implant. While it is capable of withstanding immense amounts of abuse, it will eventually overload from sustained impacts, especially against energy attacks. Recharges while retracted."
	item_state = "holoshield"
	icon_state = "holoshield"
	slowdown = 1
	shield_flags = SHIELD_FLAGS_DEFAULT
	max_integrity = 100
	obj_integrity = 100
	can_shatter = FALSE
	item_flags = ITEM_CAN_BLOCK
	shield_flags = SHIELD_FLAGS_DEFAULT | SHIELD_KINETIC_STRONG | SHIELD_DISABLER_DISRUPTED
	var/recharge_timerid
	var/recharge_delay = 15 SECONDS

/// Entirely overriden take_damage. This shouldn't exist outside of an implant (other than maybe christmas).
/obj/item/shield/riot/implant/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	obj_integrity -= damage_amount
	if(obj_integrity < 0)
		obj_integrity = 0
	if(obj_integrity == 0)
		if(ismob(loc))
			var/mob/living/L = loc
			playsound(src, "sparks", 100, TRUE)
			L.visible_message("<span class='boldwarning'>[src] overloads from the damage sustained!</span>")
			L.dropItemToGround(src)			//implant component catch hook will grab it.

/obj/item/shield/riot/implant/Moved()
	. = ..()
	if(istype(loc, /obj/item/organ/cyberimp/arm/shield))
		recharge_timerid = addtimer(CALLBACK(src, .proc/recharge), recharge_delay, flags = TIMER_STOPPABLE)
	else		//extending
		if(recharge_timerid)
			deltimer(recharge_timerid)
			recharge_timerid = null

/obj/item/shield/riot/implant/proc/recharge()
	if(obj_integrity == max_integrity)
		return
	obj_integrity = max_integrity
	if(ismob(loc.loc))		//cyberimplant.user
		to_chat(loc, "<span class='notice'>[src] has recharged its reinforcement matrix and is ready for use!</span>")

/obj/item/shield/energy
	name = "energy combat shield"
	desc = "A shield that reflects almost all energy projectiles, but is useless against physical attacks. It can be retracted, expanded, and stored anywhere."
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("shoved", "bashed")
	throw_range = 5
	force = 3
	throwforce = 3
	throw_speed = 3
	var/base_icon_state = "eshield" // [base_icon_state]1 for expanded, [base_icon_state]0 for contracted
	var/on_force = 10
	var/on_throwforce = 8
	var/on_throw_speed = 2
	var/active = 0
	var/clumsy_check = TRUE

/obj/item/shield/energy/Initialize()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/shield/energy/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if((attack_type & ATTACK_TYPE_PROJECTILE) && is_energy_reflectable_projectile(object))
		block_return[BLOCK_RETURN_REDIRECT_METHOD] = REDIRECT_METHOD_DEFLECT
		return BLOCK_SUCCESS | BLOCK_REDIRECTED | BLOCK_SHOULD_REDIRECT
	return ..()

/obj/item/shield/energy/directional_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return, override_direction)
	if((attack_type & ATTACK_TYPE_PROJECTILE) && is_energy_reflectable_projectile(object))
		block_return[BLOCK_RETURN_REDIRECT_METHOD] = REDIRECT_METHOD_DEFLECT
		return BLOCK_SUCCESS | BLOCK_REDIRECTED | BLOCK_SHOULD_REDIRECT
	return ..()

/obj/item/shield/energy/attack_self(mob/living/carbon/human/user)
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && user.prob_bad(50))
		to_chat(user, "<span class='userdanger'>You beat yourself in the head with [src]!</span>")
		user.take_bodypart_damage(5)
	active = !active
	icon_state = "[base_icon_state][active]"

	if(active)
		force = on_force
		throwforce = on_throwforce
		throw_speed = on_throw_speed
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 35, TRUE)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = initial(force)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, TRUE)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)
