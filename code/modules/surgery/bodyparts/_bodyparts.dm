
/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	icon = 'icons/mob/human_parts.dmi'
	w_class = WEIGHT_CLASS_SMALL
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	var/mob/living/carbon/owner = null
	var/mob/living/carbon/original_owner = null
	var/status = BODYPART_ORGANIC
	var/needs_processing = FALSE

	var/body_zone //BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	var/list/aux_icons // associative list, currently used for hands
	var/body_part = null //bitflag used to check which clothes cover this bodypart
	var/use_digitigrade = NOT_DIGITIGRADE //Used for alternate legs, useless elsewhere
	var/list/embedded_objects = list()
	var/held_index = 0 //are we a hand? if so, which one!
	var/is_pseudopart = FALSE //For limbs that don't really exist, eg chainsaws

	var/disabled = BODYPART_NOT_DISABLED //If disabled, limb is as good as missing
	var/body_damage_coeff = 1 //Multiplier of the limb's damage that gets applied to the mob
	var/stam_damage_coeff = 0.75
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/stamina_dam = 0
	var/max_stamina_damage = 0
	var/incoming_stam_mult = 1 //Multiplier for incoming staminaloss, decreases when taking staminaloss when the limb is disabled, resets back to 1 when limb is no longer disabled.
	var/max_damage = 0
	/// Threshold at which we are disabled. Defaults to max_damage if unset.
	var/disable_threshold
	var/stam_heal_tick = 0		//per Life(). Defaults to 0 due to citadel changes

	var/brute_reduction = 0 //Subtracted to brute damage taken
	var/burn_reduction = 0	//Subtracted to burn damage taken

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/body_gender = ""
	var/species_id = ""
	var/color_src
	var/base_bp_icon //Overrides the icon being used for this limb. This is mainly for downstreams, implemented and maintained as a favor in return for implementing synths. And also because should_draw_* for icon overrides was pretty messy. You're welcome.
	var/should_draw_gender = FALSE
	var/species_color = ""
	var/mutation_color = ""
	var/no_update = 0
	var/body_markings = ""	//for bodypart markings, deprecated
	var/list/body_markings_list // stores body markings as lists, with the first value being the name of the bodypart, the second value being the name of the marking, and the third being the colour
	var/marking_value // combination of old aux_marking and body_marking variables as they were always set together to the same value
	var/static/default_body_markings_icon = 'modular_citadel/icons/mob/mam_markings.dmi'
	var/list/markings_color = list()
	var/digitigrade_type

	var/animal_origin = null //for nonhuman bodypart (e.g. monkey)
	var/dismemberable = 1 //whether it can be dismembered with a weapon.

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	var/dmg_overlay_type //the type of damage overlay (if any) to use when this bodypart is bruised/burned.

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"


	//Some special vars for robotic bodyparts, in the base type to prevent needing typecasting / fancy checks.
	var/easy_heal_threshhold = -1 //If greater or equal to zero, if limb damage of a type passes this threshhold, it cannot be healed beyond threshhold_passed_mindamage. Only needed for robotic limbs, but is in the basetype to prevent needing spaghetti-checks.
	var/threshhold_passed_mindamage = 0 //If the threshhold got passed, what is the minimum damage this limb can be healed to? Loses the threshhold-passed state healing is started while below mindamage.
	var/threshhold_brute_passed = FALSE
	var/threshhold_burn_passed = FALSE //Ugly but neccessary vars that might get replaced with a flag lateron maybe sometime.

	/// The wounds currently afflicting this body part
	var/list/wounds

	/// The scars currently afflicting this body part
	var/list/scars
	/// Our current stored wound damage multiplier
	var/wound_damage_multiplier = 1

	/// This number is subtracted from all wound rolls on this bodypart, higher numbers mean more defense, negative means easier to wound
	var/wound_resistance = 0
	/// When this bodypart hits max damage, this number is added to all wound rolls. Obviously only relevant for bodyparts that have damage caps.
	var/disabled_wound_penalty = 15

	/// A hat won't cover your face, but a shirt covering your chest will cover your... you know, chest
	var/scars_covered_by_clothes = TRUE
	/// So we know if we need to scream if this limb hits max damage
	var/last_maxed
	/// How much generic bleedstacks we have on this bodypart
	var/generic_bleedstacks
	/// If we have a gauze wrapping currently applied (not including splints)
	var/obj/item/stack/current_gauze
	/// does this limb have replacement capability, despite probably not being robotic?
	// see code\modules\surgery\limb_augmentation.dm, or code\game\machinery\limbgrower.dm
	var/forcereplace = FALSE

/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(brute_dam > DAMAGE_PRECISION)
		. += "<span class='warning'>This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.</span>"
	if(burn_dam > DAMAGE_PRECISION)
		. += "<span class='warning'>This limb has [burn_dam > 30 ? "severe" : "minor"] burns.</span>"

/obj/item/bodypart/blob_act()
	take_damage(max_damage)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	return ..()

/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(HAS_TRAIT(C, TRAIT_LIMBATTACHMENT))
			if(!H.get_bodypart(body_zone) && !animal_origin)
				if(H == user)
					H.visible_message("<span class='warning'>[H] jams [src] into [H.p_their()] empty socket!</span>",\
					"<span class='notice'>You force [src] into your empty socket, and it locks into place!</span>")
				else
					H.visible_message("<span class='warning'>[user] jams [src] into [H]'s empty socket!</span>",\
					"<span class='notice'>[user] forces [src] into your empty socket, and it locks into place!</span>")
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				attach_limb(C)
				return
	..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	if(W.sharpness)
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, "<span class='warning'>There is nothing left inside [src]!</span>")
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("<span class='warning'>[user] begins to cut open [src].</span>",\
			"<span class='notice'>You begin to cut open [src]...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(!is_robotic_limb())
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, 1, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user)
	var/turf/T = get_turf(src)
	if(!is_robotic_limb())
		playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)
	if(current_gauze)
		QDEL_NULL(current_gauze)
	for(var/obj/item/organ/drop_organ in get_organs())
		drop_organ.transfer_to_limb(src, owner)

///since organs aren't actually stored in the bodypart themselves while attached to a person, we have to query the owner for what we should have
/obj/item/bodypart/proc/get_organs()
	if(!owner)
		return
	. = list()
	for(var/i in owner.internal_organs) //internal organs inside the dismembered limb are dropped.
		var/obj/item/organ/organ_check = i
		if(check_zone(organ_check.zone) == body_zone)
			. += organ_check

/obj/item/bodypart/proc/consider_processing()
	if(stamina_dam > DAMAGE_PRECISION)
		. = TRUE
	//else if.. else if.. so on.
	else
		. = FALSE
	needs_processing = .

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(seconds, times_fired)
	if(stam_heal_tick && stamina_dam > DAMAGE_PRECISION)					//DO NOT update health here, it'll be done in the carbon's life.
		if(heal_damage(brute = 0, burn = 0, stamina = (stam_heal_tick * (disabled ? 2 : 1)), only_robotic = FALSE, only_organic = FALSE, updating_health = FALSE))
			. |= BODYPART_LIFE_UPDATE_HEALTH

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE) // maybe separate BRUTE_SHARP and BRUTE_OTHER eventually somehow hmm
	if(owner && (owner.status_flags & GODMODE))
		return FALSE	//godmode
	var/dmg_mlt = CONFIG_GET(number/damage_multiplier)
	brute = round(max(brute * dmg_mlt, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt, 0),DAMAGE_PRECISION)
	stamina = round(max((stamina * dmg_mlt) * incoming_stam_mult, 0),DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)
	//No stamina scaling.. for now..

	if(!brute && !burn && !stamina)
		return FALSE

	brute *= wound_damage_multiplier
	burn *= wound_damage_multiplier

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take some additional burn //nothing can burn with so much snowflake code around
			burn *= 1.2
			stamina = 0

	/*
	// START WOUND HANDLING
	*/

	// what kind of wounds we're gonna roll for, take the greater between brute and burn, then if it's brute, we subdivide based on sharpness
	var/wounding_type = (brute > burn ? WOUND_BLUNT : WOUND_BURN)
	var/wounding_dmg = max(brute, burn)
	var/mangled_state = get_mangled_state()
	var/bio_state = owner.get_biological_state()
	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	if(wounding_type == WOUND_BLUNT)
		if(sharpness == SHARP_EDGED)
			wounding_type = WOUND_SLASH
		else if(sharpness == SHARP_POINTY)
			wounding_type = WOUND_PIERCE

	//Handling for bone only/flesh only(none right now)/flesh and bone targets
	switch(bio_state)
		// if we're bone only, all cutting attacks go straight to the bone
		if(BIO_JUST_BONE)
			if(wounding_type == WOUND_SLASH)
				wounding_type = WOUND_BLUNT
				wounding_dmg *= (easy_dismember ? 1 : 0.5)
			else if(wounding_type == WOUND_PIERCE)
				wounding_type = WOUND_BLUNT
				wounding_dmg *= (easy_dismember ? 1 : 0.75)
			if((mangled_state & BODYPART_MANGLED_BONE) && try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
				return
		// if we're flesh only, all blunt attacks become weakened slashes in terms of wound damage
		if(BIO_JUST_FLESH)
			if(wounding_type == WOUND_BLUNT)
				wounding_type = WOUND_SLASH
				wounding_dmg *= (easy_dismember ? 1 : 0.3)
			if((mangled_state & BODYPART_MANGLED_FLESH) && try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
				return
		// standard humanoids
		if(BIO_FLESH_BONE)
			// if we've already mangled the skin (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
			// So a big sharp weapon is still all you need to destroy a limb
			if(mangled_state == BODYPART_MANGLED_FLESH && sharpness)
				playsound(src, "sound/effects/wounds/crackandbleed.ogg", 100)
				if(wounding_type == WOUND_SLASH && !easy_dismember)
					wounding_dmg *= 0.5 // edged weapons pass along 50% of their wounding damage to the bone since the power is spread out over a larger area
				if(wounding_type == WOUND_PIERCE && !easy_dismember)
					wounding_dmg *= 0.75 // piercing weapons pass along 75% of their wounding damage to the bone since it's more concentrated
				wounding_type = WOUND_BLUNT
			else if(mangled_state == BODYPART_MANGLED_BOTH && try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
				return

	// now we have our wounding_type and are ready to carry on with wounds and dealing the actual damage
	if(owner && wounding_dmg >= WOUND_MINIMUM_DAMAGE && wound_bonus != CANT_WOUND)
		check_wounding(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)

	for(var/i in wounds)
		var/datum/wound/iter_wound = i
		iter_wound.receive_damage(wounding_type, wounding_dmg, wound_bonus)

	/*
	// END WOUND HANDLING
	*/

	//back to our regularly scheduled program, we now actually apply damage if there's room below limb damage cap

	var/can_inflict = max_damage - get_damage()

	var/total_damage = brute + burn

	if(total_damage > can_inflict && total_damage > 0) // TODO: the second part of this check should be removed once disabling is all done
		brute = round(brute * (max_damage / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (max_damage / total_damage),DAMAGE_PRECISION)

	if(can_inflict <= 0)
		return FALSE

	brute_dam += brute
	burn_dam += burn

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	var/current_damage = get_damage(TRUE)		//This time around, count stamina loss too.
	var/available_damage = max_damage - current_damage
	stamina_dam += round(clamp(stamina, 0, min(max_stamina_damage - stamina_dam, available_damage)), DAMAGE_PRECISION)

	if(disabled && stamina > 10)
		incoming_stam_mult = max(0.01, incoming_stam_mult/(stamina*0.1))

	if(owner && updating_health)
		owner.updatehealth()
		if(stamina > DAMAGE_PRECISION)
			owner.update_stamina()
	consider_processing()
	update_disabled()
	update_threshhold_state()
	return update_bodypart_damage_state()

/// Allows us to roll for and apply a wound without actually dealing damage. Used for aggregate wounding power with pellet clouds
/obj/item/bodypart/proc/painless_wound_roll(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus, sharpness=SHARP_NONE)
	if(!owner || phantom_wounding_dmg <= WOUND_MINIMUM_DAMAGE || wound_bonus == CANT_WOUND)
		return

	var/mangled_state = get_mangled_state()
	var/bio_state = owner.get_biological_state()
	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	if(wounding_type == WOUND_BLUNT)
		if(sharpness == SHARP_EDGED)
			wounding_type = WOUND_SLASH
		else if(sharpness == SHARP_POINTY)
			wounding_type = WOUND_PIERCE

	//Handling for bone only/flesh only(none right now)/flesh and bone targets
	switch(bio_state)
		// if we're bone only, all cutting attacks go straight to the bone
		if(BIO_JUST_BONE)
			if(wounding_type == WOUND_SLASH)
				wounding_type = WOUND_BLUNT
				phantom_wounding_dmg *= (easy_dismember ? 1 : 0.5)
			else if(wounding_type == WOUND_PIERCE)
				wounding_type = WOUND_BLUNT
				phantom_wounding_dmg *= (easy_dismember ? 1 : 0.75)
			if((mangled_state & BODYPART_MANGLED_BONE) && try_dismember(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus))
				return
		// note that there's no handling for BIO_JUST_FLESH since we don't have any that are that right now (slimepeople maybe someday)
		// standard humanoids
		if(BIO_FLESH_BONE)
			// if we've already mangled the skin (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
			// So a big sharp weapon is still all you need to destroy a limb
			if(mangled_state == BODYPART_MANGLED_FLESH && sharpness)
				playsound(src, "sound/effects/wounds/crackandbleed.ogg", 100)
				if(wounding_type == WOUND_SLASH && !easy_dismember)
					phantom_wounding_dmg *= 0.5 // edged weapons pass along 50% of their wounding damage to the bone since the power is spread out over a larger area
				if(wounding_type == WOUND_PIERCE && !easy_dismember)
					phantom_wounding_dmg *= 0.75 // piercing weapons pass along 75% of their wounding damage to the bone since it's more concentrated
				wounding_type = WOUND_BLUNT
			else if(mangled_state == BODYPART_MANGLED_BOTH && try_dismember(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus))
				return

	check_wounding(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus)

/**
  * check_wounding() is where we handle rolling for, selecting, and applying a wound if we meet the criteria
  *
  * We generate a "score" for how woundable the attack was based on the damage and other factors discussed in [/obj/item/bodypart/proc/check_wounding_mods], then go down the list from most severe to least severe wounds in that category.
  * We can promote a wound from a lesser to a higher severity this way, but we give up if we have a wound of the given type and fail to roll a higher severity, so no sidegrades/downgrades
  *
  * Arguments:
  * * woundtype- Either WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE, or WOUND_BURN based on the attack type.
  * * damage- How much damage is tied to this attack, since wounding potential scales with damage in an attack (see: WOUND_DAMAGE_EXPONENT)
  * * wound_bonus- The wound_bonus of an attack
  * * bare_wound_bonus- The bare_wound_bonus of an attack
  */
/obj/item/bodypart/proc/check_wounding(woundtype, damage, wound_bonus, bare_wound_bonus)
	// actually roll wounds if applicable
	if(HAS_TRAIT(owner, TRAIT_EASYLIMBDISABLE))
		damage *= 1.5
	else
		damage = min(damage, WOUND_MAX_CONSIDERED_DAMAGE)

	var/base_roll = rand(max(damage/1.5,25), round(damage ** CONFIG_GET(number/wound_exponent))) + (get_damage()*CONFIG_GET(number/wound_damage_multiplier))
	var/injury_roll = base_roll
	injury_roll += check_woundings_mods(woundtype, damage, wound_bonus, bare_wound_bonus)
	var/list/wounds_checking = GLOB.global_wound_types[woundtype]

	// quick re-check to see if bare_wound_bonus applies, for the benefit of log_wound(), see about getting the check from check_woundings_mods() somehow
	if(ishuman(owner))
		var/mob/living/carbon/human/human_wearer = owner
		var/list/clothing = human_wearer.clothingonpart(src)
		for(var/i in clothing)
			var/obj/item/clothing/clothes_check = i
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			if(clothes_check.armor.getRating("wound"))
				bare_wound_bonus = 0
				break

	//cycle through the wounds of the relevant category from the most severe down
	for(var/PW in wounds_checking)
		var/datum/wound/possible_wound = PW
		var/datum/wound/replaced_wound
		for(var/i in wounds)
			var/datum/wound/existing_wound = i
			if(existing_wound.type in wounds_checking)
				if(existing_wound.severity >= initial(possible_wound.severity))
					return
				else
					replaced_wound = existing_wound

		if(initial(possible_wound.threshold_minimum) < injury_roll)
			var/datum/wound/new_wound
			if(replaced_wound)
				new_wound = replaced_wound.replace_wound(possible_wound)
			else
				new_wound = new possible_wound
				new_wound.apply_wound(src)
			log_wound(owner, new_wound, damage, wound_bonus, bare_wound_bonus, base_roll) // dismembering wounds are logged in the apply_wound() for loss wounds since they delete themselves immediately, these will be immediately returned
			return new_wound

// try forcing a specific wound, but only if there isn't already a wound of that severity or greater for that type on this bodypart
/obj/item/bodypart/proc/force_wound_upwards(specific_woundtype, smited = FALSE)
	var/datum/wound/potential_wound = specific_woundtype
	for(var/i in wounds)
		var/datum/wound/existing_wound = i
		if(existing_wound.wound_type == initial(potential_wound.wound_type))
			if(existing_wound.severity < initial(potential_wound.severity)) // we only try if the existing one is inferior to the one we're trying to force
				existing_wound.replace_wound(potential_wound, smited)
			return

	var/datum/wound/new_wound = new potential_wound
	new_wound.apply_wound(src, smited = smited)

/**
  * check_wounding_mods() is where we handle the various modifiers of a wound roll
  *
  * A short list of things we consider: any armor a human target may be wearing, and if they have no wound armor on the limb, if we have a bare_wound_bonus to apply, plus the plain wound_bonus
  * We also flick through all of the wounds we currently have on this limb and add their threshold penalties, so that having lots of bad wounds makes you more liable to get hurt worse
  * Lastly, we add the inherent wound_resistance variable the bodypart has (heads and chests are slightly harder to wound), and a small bonus if the limb is already disabled
  *
  * Arguments:
  * * It's the same ones on [receive_damage]
  */
/obj/item/bodypart/proc/check_woundings_mods(wounding_type, damage, wound_bonus, bare_wound_bonus)
	var/armor_ablation = 0
	var/injury_mod = 0

	if(owner && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/list/clothing = H.clothingonpart(src)
		for(var/c in clothing)
			var/obj/item/clothing/C = c
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			armor_ablation += C.armor.getRating("wound")
			if(wounding_type == WOUND_SLASH)
				C.take_damage_zone(body_zone, damage, BRUTE, armour_penetration)
			else if(wounding_type == WOUND_BURN && damage >= 10) // lazy way to block freezing from shredding clothes without adding another var onto apply_damage()
				C.take_damage_zone(body_zone, damage, BURN, armour_penetration)

		if(!armor_ablation)
			injury_mod += bare_wound_bonus

	injury_mod -= armor_ablation
	injury_mod += wound_bonus

	for(var/thing in wounds)
		var/datum/wound/W = thing
		injury_mod += W.threshold_penalty

	var/part_mod = -wound_resistance
	if(get_damage(TRUE) >= max_damage)
		part_mod += disabled_wound_penalty

	injury_mod += part_mod

	return injury_mod

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, only_robotic = FALSE, only_organic = TRUE, updating_health = TRUE)

	if(only_robotic && !is_robotic_limb()) //This makes organic limbs not heal when the proc is in Robotic mode.
		return

	if(only_organic && !is_organic_limb(FALSE)) //This makes robolimbs and hybridlimbs not healable by chems.
		return

	brute_dam	= round(max(brute_dam - brute, 0), DAMAGE_PRECISION)
	burn_dam	= round(max(burn_dam - burn, 0), DAMAGE_PRECISION)
	stamina_dam = round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION)
	if(owner && updating_health)
		owner.updatehealth()
	consider_processing()
	update_disabled()
	update_threshhold_state()
	return update_bodypart_damage_state()

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total = max(total, stamina_dam)
	return total

//Checks disabled status thresholds

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled(silent = FALSE)
	if(!owner)
		return
	set_disabled(is_disabled(silent), silent)

/**
 * Gets the damage at which point we're disabled.
 */
/obj/item/bodypart/proc/get_disable_threshold()
	return isnull(disable_threshold)? max_damage : disable_threshold

/obj/item/bodypart/proc/is_disabled(silent = FALSE)
	if(!owner)
		return
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS))
		return BODYPART_DISABLED_PARALYSIS
	for(var/i in wounds)
		var/datum/wound/W = i
		if(W.disabling)
			return BODYPART_DISABLED_WOUND
	var/disable_threshold = get_disable_threshold()
	if(can_dismember() && !HAS_TRAIT(owner, TRAIT_NODISMEMBER))
		. = disabled //inertia, to avoid limbs healing 0.1 damage and being re-enabled
		if(get_damage(TRUE) >= disable_threshold * (HAS_TRAIT(owner, TRAIT_EASYLIMBDISABLE) ? 0.6 : 1)) //Easy limb disable disables the limb at 40% health instead of 0%
			if(!last_maxed && !silent)
				owner.emote("scream")
				last_maxed = TRUE
			if(!is_organic_limb(FALSE) || stamina_dam >= disable_threshold)
				return BODYPART_DISABLED_DAMAGE
		else if(disabled && (get_damage(TRUE) <= (disable_threshold * 0.8))) // reenabled at 80% now instead of 50% as of wounds update
			last_maxed = FALSE
			return BODYPART_NOT_DISABLED
	else
		return BODYPART_NOT_DISABLED

/obj/item/bodypart/proc/check_disabled() //This might be depreciated and should be safe to remove.
	if(!can_dismember() || HAS_TRAIT(owner, TRAIT_NODISMEMBER))
		return
	if(!disabled && (get_damage(TRUE) >= max_damage))
		set_disabled(TRUE)
	else if(disabled && (get_damage(TRUE) <= (max_damage * 0.5)))
		set_disabled(FALSE)


/obj/item/bodypart/proc/set_disabled(new_disabled)
	if(disabled == new_disabled || !owner)
		return FALSE
	disabled = new_disabled
	if(disabled && owner.get_item_for_held_index(held_index))
		owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	owner.update_health_hud() //update the healthdoll
	owner.update_body()
	owner.update_mobility()
	if(!disabled)
		incoming_stam_mult = 1
	return TRUE

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
	var/tburn	= round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE

//Change organ status
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default, no_update = FALSE)
	var/old_status = status
	status = new_limb_status
	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0

	if(status == BODYPART_HYBRID)
		easy_heal_threshhold = HYBRID_BODYPART_DAMAGE_THRESHHOLD
		threshhold_passed_mindamage = HYBRID_BODYPART_THESHHOLD_MINDAMAGE
	else if(old_status == BODYPART_HYBRID)
		easy_heal_threshhold = initial(easy_heal_threshhold)
		threshhold_passed_mindamage = initial(threshhold_passed_mindamage)

	update_threshhold_state()

	if(change_icon_to_default)
		if(is_organic_limb(FALSE))
			icon = base_bp_icon || DEFAULT_BODYPART_ICON_ORGANIC
		else if(is_robotic_limb())
			icon = base_bp_icon || DEFAULT_BODYPART_ICON_ROBOTIC

	if(owner && !no_update) //Only use no_update if you are sure the bodypart will get updated from other sources anyways, to prevent unneccessary processing use.
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()

/obj/item/bodypart/proc/is_organic_limb(hybrid_allowed = TRUE)
	if(!hybrid_allowed)
		return (status == BODYPART_ORGANIC)
	return ((status == BODYPART_ORGANIC) || (status == BODYPART_HYBRID)) //Goodbye if(B.status == BODYPART_ORGANIC || B.status == BODYPART_HYBRID)

/obj/item/bodypart/proc/is_robotic_limb(hybrid_allowed = TRUE)
	if(!hybrid_allowed)
		return (status == BODYPART_ROBOTIC)
	return ((status == BODYPART_ROBOTIC) || (status == BODYPART_HYBRID))

/obj/item/bodypart/proc/update_threshhold_state(brute = TRUE, burn = TRUE)
	if(brute)
		if(brute_dam < threshhold_passed_mindamage || easy_heal_threshhold < 0)
			threshhold_brute_passed = FALSE
		else if(brute_dam >= easy_heal_threshhold)
			threshhold_brute_passed = TRUE
	if(burn)
		if(burn_dam < threshhold_passed_mindamage || easy_heal_threshhold < 0)
			threshhold_burn_passed = FALSE
		else if(burn_dam >= easy_heal_threshhold)
			threshhold_burn_passed = TRUE

//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source)
	body_markings_list = list()
	var/mob/living/carbon/C
	if(source)
		C = source
		if(!original_owner)
			original_owner = source
	else if(original_owner && owner != original_owner) //Foreign limb
		no_update = TRUE
	else
		C = owner
		no_update = FALSE

	if(HAS_TRAIT(C, TRAIT_HUSK) && is_organic_limb())
		species_id = "husk" //overrides species_id
		dmg_overlay_type = "" //no damage overlay shown when husked
		should_draw_gender = FALSE
		color_src = FALSE
		base_bp_icon = DEFAULT_BODYPART_ICON
		no_update = TRUE
		marking_value = "husk"

	if(no_update)
		return

	if(!animal_origin)
		var/mob/living/carbon/human/H = C
		color_src = FALSE

		var/datum/species/S = H.dna.species
		base_bp_icon = S?.icon_limbs || DEFAULT_BODYPART_ICON
		species_id = S.mutant_bodyparts["limbs_id"]
		species_flags_list = H.dna.species.species_traits

		//body marking memes
		var/list/colorlist = list()
		colorlist.Cut()
		colorlist += ReadRGB("[H.dna.features["mcolor"]]00")
		colorlist += ReadRGB("[H.dna.features["mcolor2"]]00")
		colorlist += ReadRGB("[H.dna.features["mcolor3"]]00")
		colorlist += list(0,0,0, S.hair_alpha)
		for(var/index=1, index<=colorlist.len, index++)
			colorlist[index] = colorlist[index]/255

		if(S.use_skintones)
			skin_tone = H.skin_tone
		else
			skin_tone = ""

		body_gender = H.dna.features["body_model"]
		if(GLOB.nongendered_limb_types[species_id])
			should_draw_gender = FALSE
		else
			should_draw_gender = S.sexes

		var/mut_colors = (MUTCOLORS in S.species_traits)
		if(mut_colors)
			if(S.fixed_mut_color)
				species_color = S.fixed_mut_color
			else
				species_color = H.dna.features["mcolor"]
		else
			species_color = ""

		if(S.mutant_bodyparts["legs"])
			if(body_zone == BODY_ZONE_L_LEG || body_zone == BODY_ZONE_R_LEG)
				if(DIGITIGRADE in S.species_traits)
					digitigrade_type = lowertext(H.dna.features["legs"])
			else
				digitigrade_type = null

		if(S.mutant_bodyparts["mam_body_markings"]) // checks if the species can actually have body markings
			// get all markings for this bodypart type
			for(var/list/marking in H.dna.features["mam_body_markings"])
				// marking is a list containing bodypart type, bodymarking name, and then the colour (colour won't be used in v1)
				if(marking[1] == body_part)
					var/datum/sprite_accessory/Smark
					Smark = GLOB.mam_body_markings_list[marking[2]]
					var/body_markings_icon = default_body_markings_icon
					if(Smark)
						body_markings_icon = Smark.icon
					var/marking_value = "" // combination of body and aux markings from old system
					if(H.dna.features["mam_body_markings"] != "None")
						marking_value = Smark?.icon_state || lowertext(H.dna.features["mam_body_markings"])
					else
						marking_value = "plain"
					var/list/color_values
					if(length(marking) == 3)
						color_values = marking[3]
					else
						color_values = list("#FFFFFF", "#FFFFFF", "#FFFFFF")
					body_markings_list += list(list(body_markings_icon, marking_value, color_values))

			markings_color = list(colorlist)
		else
			marking_value = null

		if(S.override_bp_icon)
			base_bp_icon = S.override_bp_icon
		else
			if(species_id in GLOB.greyscale_limb_types) //should they have greyscales?
				base_bp_icon = DEFAULT_BODYPART_ICON_ORGANIC
			else
				base_bp_icon = DEFAULT_BODYPART_ICON

		if(base_bp_icon != DEFAULT_BODYPART_ICON)
			color_src = mut_colors ? MUTCOLORS : ((H.dna.skin_tone_override && S.use_skintones == USE_SKINTONES_GRAYSCALE_CUSTOM) ? CUSTOM_SKINTONE : SKINTONE)

		if(!dropping_limb && H.dna.check_mutation(HULK))
			mutation_color = "00aa00"
		else
			mutation_color = ""

		dmg_overlay_type = S.damage_overlay_type

	else if(animal_origin == MONKEY_BODYPART) //currently monkeys are the only non human mob to have damage overlays.
		dmg_overlay_type = animal_origin

	if(is_robotic_limb())
		dmg_overlay_type = "robotic"
		if(is_robotic_limb(FALSE))
			marking_value = null

	if(dropping_limb)
		no_update = TRUE //when attached, the limb won't be affected by the appearance changes of its mob owner.

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	cut_overlays()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)

//Gives you a proper icon appearance for the dismembered limb
/obj/item/bodypart/proc/get_limb_icon(dropped)
	cut_overlays()
	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	var/image_dir = 0
	var/icon_gender = (body_gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable

	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)

		if(!isnull(body_markings) && is_organic_limb(FALSE))
			for(var/list/marking_list in body_markings_list)
				// marking stores icon and value for the specific bodypart
				if(!use_digitigrade)
					if(body_zone == BODY_ZONE_CHEST)
						. += image(marking_list[1], "[marking_list[2]]_[body_zone]_[icon_gender]", -MARKING_LAYER, image_dir)
					else
						. += image(marking_list[1], "[marking_list[2]]_[body_zone]", -MARKING_LAYER, image_dir)
				else
					. += image(marking_list[1], "[marking_list[2]]_[digitigrade_type]_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/list/aux = list()
	var/list/auxmarking = list()

	. += limb

	if(animal_origin)
		if(is_organic_limb(FALSE))
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(species_id == "husk")
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"
		return

	if((body_zone != BODY_ZONE_HEAD && body_zone != BODY_ZONE_CHEST))
		should_draw_gender = FALSE

	var/list/markings_list = list()
	if(is_organic_limb())
		limb.icon = base_bp_icon || 'icons/mob/human_parts.dmi'
		if(should_draw_gender)
			limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
		else if (use_digitigrade)
			if(base_bp_icon == DEFAULT_BODYPART_ICON_ORGANIC) //Compatibility hack for the current iconset.
				limb.icon_state = "[digitigrade_type]_[use_digitigrade]_[body_zone]"
			else
				limb.icon_state = "[species_id]_[digitigrade_type]_[use_digitigrade]_[body_zone]"
		else
			limb.icon_state = "[species_id]_[body_zone]"

		// Body markings
		if(length(body_markings_list))
			if(species_id == "husk")
				. += image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[body_zone]", -MARKING_LAYER, image_dir)
			else if(species_id == "husk" && use_digitigrade)
				. += image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[digitigrade_type]_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)
			else
				for(var/list/marking_list in body_markings_list)
					// marking stores icon and value for the specific bodypart
					if(!use_digitigrade)
						if(body_zone == BODY_ZONE_CHEST)
							markings_list.Add(image(marking_list[1], "[marking_list[2]]_[body_zone]_[icon_gender]", -MARKING_LAYER, image_dir))
						else
							markings_list.Add(image(marking_list[1], "[marking_list[2]]_[body_zone]", -MARKING_LAYER, image_dir))
					else
						markings_list.Add(image(marking_list[1], "[marking_list[2]]_[digitigrade_type]_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir))

					if(color_src && length(marking_list) == 3)
						var/image/I = markings_list[length(markings_list)]
						I.color = marking_list[3]
		. += markings_list

		// Citadel End

		if(aux_icons)
			for(var/I in aux_icons)
				var/aux_layer = aux_icons[I]
				aux += image(limb.icon, "[species_id]_[I]", -aux_layer, image_dir)
				if(species_id == "husk")
					auxmarking += image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[I]", -aux_layer, image_dir)
				else
					for(var/marking_list in body_markings_list)
						var/image/aux_marking_image = image(marking_list[1], "[marking_list[2]]_[I]", -aux_layer, image_dir)
						if(length(marking_list) == 3)
							aux_marking_image.color = marking_list[3]
						auxmarking += aux_marking_image
			. += aux
			. += auxmarking

	else
		limb.icon = icon
		if(should_draw_gender)
			limb.icon_state = "[body_zone]_[icon_gender]"
		else
			limb.icon_state = "[body_zone]"

		if(aux_icons)
			for(var/I in aux_icons)
				var/aux_layer = aux_icons[I]
				aux += image(limb.icon, "[I]", -aux_layer, image_dir)
				if(species_id == "husk")
					auxmarking += image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[I]", -aux_layer, image_dir)
				else
					for(var/marking_list in body_markings_list)
						var/image/aux_marking_image = image(marking_list[1], "[marking_list[2]]_[I]", -aux_layer, image_dir)
						if(length(marking_list) == 3)
							aux_marking_image.color = marking_list[3]
						auxmarking += aux_marking_image
			. += auxmarking
			. += aux

		if(length(body_markings))
			if(species_id == "husk")
				. += image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[body_zone]", -MARKING_LAYER, image_dir)
			else if(species_id == "husk" && use_digitigrade)
				. += image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_digitigrade_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)
			else
				for(var/list/marking_list in body_markings_list)
					// marking stores icon and value for the specific bodypart
					if(!use_digitigrade)
						if(body_zone == BODY_ZONE_CHEST)
							. += image(marking_list[1], "[marking_list[2]]_[body_zone]_[icon_gender]", -MARKING_LAYER, image_dir)
						else
							. += image(marking_list[1], "[marking_list[2]]_[body_zone]", -MARKING_LAYER, image_dir)
					else
						. += image(marking_list[1], "[marking_list[2]]_[digitigrade_type]_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)
		return

	if(color_src) //TODO - add color matrix support for base species limbs (or dont because color matrixes suck)
		var/draw_color = mutation_color || species_color
		var/grayscale = FALSE
		if(!draw_color)
			draw_color = SKINTONE2HEX(skin_tone)
			grayscale = color_src == CUSTOM_SKINTONE //Cause human limbs have a very pale pink hue by def.
		else
			draw_color = "#[draw_color]"
		if(draw_color)
			if(grayscale)
				limb.icon_state += "_g"
			limb.color = draw_color
			if(aux_icons)
				for(var/a in aux)
					var/image/I = a
					if(grayscale)
						I.icon_state += "_g"
					I.color = draw_color
				for(var/a in auxmarking)
					var/image/I = a
					if(species_id == "husk")
						I.color = "#141414"

			if(!isnull(body_markings))
				if(species_id == "husk")
					for(var/image/marking in markings_list)
						marking.color = "#141414"

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/// Get whatever wound of the given type is currently attached to this limb, if any
/obj/item/bodypart/proc/get_wound_type(checking_type)
	if(isnull(wounds))
		return
	for(var/i in wounds)
		if(istype(i, checking_type))
			return i

/**
  * update_wounds() is called whenever a wound is gained or lost on this bodypart, as well as if there's a change of some kind on a bone wound possibly changing disabled status
  *
  * Covers tabulating the damage multipliers we have from wounds (burn specifically), as well as deleting our gauze wrapping if we don't have any wounds that can use bandaging
  *
  * Arguments:
  * * replaced- If true, this is being called from the remove_wound() of a wound that's being replaced, so the bandage that already existed is still relevant, but the new wound hasn't been added yet
  */
/obj/item/bodypart/proc/update_wounds(replaced = FALSE)
	var/dam_mul = 1 //initial(wound_damage_multiplier)
	// we can only have one wound per type, but remember there's multiple types
	// we can (normally) only have one wound per type, but remember there's multiple types (smites like :B:loodless can generate multiple cuts on a limb)
	for(var/i in wounds)
		var/datum/wound/iter_wound = i
		dam_mul *= iter_wound.damage_mulitplier_penalty

	if(!LAZYLEN(wounds) && current_gauze && !replaced)
		owner.visible_message("<span class='notice'>\The [current_gauze] on [owner]'s [name] fall away.</span>", "<span class='notice'>The [current_gauze] on your [name] fall away.</span>")
		QDEL_NULL(current_gauze)
	wound_damage_multiplier = dam_mul
	update_disabled()

/obj/item/bodypart/proc/get_bleed_rate()
	if(!is_organic_limb()) // maybe in the future we can bleed oil from aug parts, but not now
		return
	var/bleed_rate = 0
	if(generic_bleedstacks > 0)
		bleed_rate++

	//We want an accurate reading of .len
	listclearnulls(embedded_objects)
	for(var/obj/item/embeddies in embedded_objects)
		if(!embeddies.isEmbedHarmless())
			bleed_rate += 0.5

	for(var/thing in wounds)
		var/datum/wound/W = thing
		bleed_rate += W.blood_flow
	if(owner.mobility_flags & ~MOBILITY_STAND)
		bleed_rate *= 0.75
	return bleed_rate

/**
  * apply_gauze() is used to- well, apply gauze to a bodypart
  *
  * As of the Wounds 2 PR, all bleeding is now bodypart based rather than the old bleedstacks system, and 90% of standard bleeding comes from flesh wounds (the exception is embedded weapons).
  * The same way bleeding is totaled up by bodyparts, gauze now applies to all wounds on the same part. Thus, having a slash wound, a pierce wound, and a broken bone wound would have the gauze
  * applying blood staunching to the first two wounds, while also acting as a sling for the third one. Once enough blood has been absorbed or all wounds with the ACCEPTS_GAUZE flag have been cleared,
  * the gauze falls off.
  *
  * Arguments:
  * * gauze- Just the gauze stack we're taking a sheet from to apply here
  */
/obj/item/bodypart/proc/apply_gauze(obj/item/stack/gauze)
	if(!istype(gauze) || !gauze.absorption_capacity)
		return
	QDEL_NULL(current_gauze)
	current_gauze = new gauze.type(src, 1)
	gauze.use(1)

/**
  * seep_gauze() is for when a gauze wrapping absorbs blood or pus from wounds, lowering its absorption capacity.
  *
  * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandages fall off and we're left with nothing.
  *
  * Arguments:
  * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
  */
/obj/item/bodypart/proc/seep_gauze(seep_amt = 0)
	if(!current_gauze)
		return
	current_gauze.absorption_capacity -= seep_amt
	if(current_gauze.absorption_capacity < 0)
		owner.visible_message("<span class='danger'>\The [current_gauze] on [owner]'s [name] fall away in rags.</span>", "<span class='warning'>\The [current_gauze] on your [name] fall away in rags.</span>", vision_distance=COMBAT_MESSAGE_RANGE)
		QDEL_NULL(current_gauze)
