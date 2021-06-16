/mob/living/carbon
	var/list/overlays_standing[TOTAL_LAYERS]

/mob/living/carbon/proc/apply_overlay(cache_index)
	if((. = overlays_standing[cache_index]))
		add_overlay(.)

/mob/living/carbon/proc/remove_overlay(cache_index)
	var/I = overlays_standing[cache_index]
	if(I)
		cut_overlay(I)
		overlays_standing[cache_index] = null

/mob/living/carbon/regenerate_icons()
	if(mob_transforming)
		return 1
	update_inv_hands()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_fire()


/mob/living/carbon/update_inv_hands()
	remove_overlay(HANDS_LAYER)
	if (handcuffed)
		drop_all_held_items()
		return

	var/list/hands = list()
	for(var/obj/item/I in held_items)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			I.screen_loc = ui_hand_position(get_held_index_of_item(I))
			client.screen += I
			if(observers && observers.len)
				for(var/M in observers)
					var/mob/dead/observe = M
					if(observe.client && observe.client.eye == src)
						observe.client.screen += I
					else
						observers -= observe
						if(!observers.len)
							observers = null
							break

		var/icon_file = I.lefthand_file
		if(get_held_index_of_item(I) % 2 == 0)
			icon_file = I.righthand_file

		hands += I.build_worn_icon(default_layer = HANDS_LAYER, default_icon_file = icon_file, isinhands = TRUE)

	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_LAYER)


/mob/living/carbon/update_fire(var/fire_icon = "Generic_mob_burning")
	remove_overlay(FIRE_LAYER)
	if(on_fire)
		var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', fire_icon, -FIRE_LAYER)
		new_fire_overlay.appearance_flags = RESET_COLOR
		overlays_standing[FIRE_LAYER] = new_fire_overlay

	apply_overlay(FIRE_LAYER)



/mob/living/carbon/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)
	var/dam_colors = "#E62525"
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		dam_colors = H.dna.species.exotic_blood_color

	var/mutable_appearance/damage_overlay = mutable_appearance('icons/mob/dam_mob.dmi', "blank", -DAMAGE_LAYER, color = dam_colors)
	overlays_standing[DAMAGE_LAYER] = damage_overlay

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.dmg_overlay_type)
			if(BP.brutestate)
				damage_overlay.add_overlay("[BP.dmg_overlay_type]_[BP.body_zone]_[BP.brutestate]0")	//we're adding icon_states of the base image as overlays
			if(BP.burnstate)
				damage_overlay.add_overlay("[BP.dmg_overlay_type]_[BP.body_zone]_0[BP.burnstate]")

	apply_overlay(DAMAGE_LAYER)


/mob/living/carbon/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_WEAR_MASK]
		inv?.update_icon()

	if(wear_mask)
		if(!(head && (head.flags_inv & HIDEMASK)))
			overlays_standing[FACEMASK_LAYER] = wear_mask.build_worn_icon(default_layer = FACEMASK_LAYER, default_icon_file = 'icons/mob/clothing/mask.dmi', override_state = wear_mask.icon_state)
		update_hud_wear_mask(wear_mask)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/update_inv_neck()
	remove_overlay(NECK_LAYER)

	if(client && hud_used && hud_used.inv_slots[SLOT_NECK])
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_NECK]
		inv.update_icon()

	if(wear_neck)
		if(!(head && (head.flags_inv & HIDENECK)))
			overlays_standing[NECK_LAYER] = wear_neck.build_worn_icon(default_layer = NECK_LAYER, default_icon_file = 'icons/mob/clothing/neck.dmi', override_state = wear_neck.icon_state)
		update_hud_neck(wear_neck)

	apply_overlay(NECK_LAYER)

/mob/living/carbon/update_inv_back()
	remove_overlay(BACK_LAYER)

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_BACK]
		inv?.update_icon()

	if(back)
		overlays_standing[BACK_LAYER] = back.build_worn_icon(default_layer = BACK_LAYER, default_icon_file = 'icons/mob/clothing/back.dmi', override_state = back.icon_state)
		update_hud_back(back)

	apply_overlay(BACK_LAYER)

/mob/living/carbon/update_inv_head()
	remove_overlay(HEAD_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //Decapitated
		return

	if(client && hud_used)
		var/obj/screen/inventory/inv = hud_used.inv_slots[SLOT_HEAD]
		inv?.update_icon()

	if(head)
		overlays_standing[HEAD_LAYER] = head.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head.dmi', override_state = head.icon_state)
		update_hud_head(head)

	apply_overlay(HEAD_LAYER)


/mob/living/carbon/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		var/mutable_appearance/cuffs = mutable_appearance('icons/mob/clothing/restraints.dmi', handcuffed.item_state, -HANDCUFF_LAYER)
		cuffs.color = handcuffed.color

		overlays_standing[HANDCUFF_LAYER] = cuffs
		apply_overlay(HANDCUFF_LAYER)

/mob/living/carbon/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	clear_alert("legcuffed")
	if(legcuffed)
		var/mutable_appearance/legcuffs = mutable_appearance('icons/mob/clothing/restraints.dmi', legcuffed.item_state, -LEGCUFF_LAYER)
		legcuffs.color = legcuffed.color

		overlays_standing[LEGCUFF_LAYER] = legcuffs
		apply_overlay(LEGCUFF_LAYER)
		throw_alert("legcuffed", /obj/screen/alert/restrained/legcuffed, new_master = legcuffed)

//mob HUD updates for items in our inventory

//update whether handcuffs appears on our hud.
/mob/living/carbon/proc/update_hud_handcuffed()
	if(hud_used)
		for(var/hand in hud_used.hand_slots)
			var/obj/screen/inventory/hand/H = hud_used.hand_slots[hand]
			if(H)
				H.update_icon()

//update whether our head item appears on our hud.
/mob/living/carbon/proc/update_hud_head(obj/item/I)
	return

//update whether our mask item appears on our hud.
/mob/living/carbon/proc/update_hud_wear_mask(obj/item/I)
	return

//update whether our neck item appears on our hud.
/mob/living/carbon/proc/update_hud_neck(obj/item/I)
	return

//update whether our back item appears on our hud.
/mob/living/carbon/proc/update_hud_back(obj/item/I)
	return

/mob/living/carbon/update_body(update_genitals = FALSE, send_signal = TRUE)
	update_body_parts(send_signal)

/mob/living/carbon/proc/update_body_parts(send_signal = TRUE)
	//CHECK FOR UPDATE
	var/oldkey = icon_render_key
	icon_render_key = generate_icon_render_key()
	if(oldkey == icon_render_key)
		return
	remove_overlay(BODYPARTS_LAYER)

	var/is_taur = FALSE
	if(dna?.species.mutant_bodyparts["taur"])
		var/datum/sprite_accessory/taur/T = GLOB.taur_list[dna.features["taur"]]
		if(T?.hide_legs)
			is_taur = TRUE

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		BP.update_limb()
	//LOAD ICONS
	if(limb_icon_cache[icon_render_key])
		load_limb_from_cache(send_signal)
		return

	//GENERATE NEW LIMBS
	var/static/list/leg_day = typecacheof(list(/obj/item/bodypart/r_leg, /obj/item/bodypart/l_leg))
	var/list/new_limbs = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		if(is_taur && leg_day[BP.type])
			continue
		new_limbs += BP.get_limb_icon()
	if(new_limbs.len)
		overlays_standing[BODYPARTS_LAYER] = new_limbs
		limb_icon_cache[icon_render_key] = new_limbs
	apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()


/////////////////////
// Limb Icon Cache //
/////////////////////
/*
	Called from update_body_parts() these procs handle the limb icon cache.
	the limb icon cache adds an icon_render_key to a human mob, it represents:
	- skin_tone (if applicable)
	- gender
	- limbs (stores as the limb name and whether it is removed/fine, organic/robotic)
	These procs only store limbs as to increase the number of matching icon_render_keys
	This cache exists because drawing 6/7 icons for humans constantly is quite a waste
	See RemieRichards on irc.rizon.net #coderbus
*/

//produces a key based on the mob's limbs

/mob/living/carbon/proc/generate_icon_render_key()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += "-[BP.body_zone]"
		if(BP.use_digitigrade)
			. += "-digitigrade[BP.use_digitigrade]"
		if(BP.animal_origin)
			. += "-[BP.animal_origin]"
		if(BP.is_organic_limb(FALSE))
			. += "-organic"
		else
			. += "-robotic"

	if(HAS_TRAIT(src, TRAIT_HUSK))
		. += "-husk"


//change the mob's icon to the one matching its key
/mob/living/carbon/proc/load_limb_from_cache()
	if(limb_icon_cache[icon_render_key])
		remove_overlay(BODYPARTS_LAYER)
		overlays_standing[BODYPARTS_LAYER] = limb_icon_cache[icon_render_key]
		apply_overlay(BODYPARTS_LAYER)
	update_damage_overlays()
