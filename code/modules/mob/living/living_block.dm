// This file has a weird name, but it's for anything related to the checks for shields, blocking, dodging,
// and similar "stop this attack before it actually impacts the target" as opposed to "defend once it has hit".

/** The actual proc for block checks. DO NOT USE THIS DIRECTLY UNLESS YOU HAVE VERY GOOD REASON TO. To reduce copypaste for differences between handling for real attacks and virtual checks.
  * Automatically checks all held items for /obj/item/proc/run_block() with the same parameters.
  * @params
  * real_attack - If this attack is real. This one is quirky; If it's real, run_block is called. If it's not, check_block is called and none of the regular checks happen, and this is effectively only useful
  * 	for populating return_list with blocking metadata.
  * object - Whatever /atom is actually hitting us, in essence. For example, projectile if gun, item if melee, structure/whatever if it's a thrown, etc.
  * damage - The nominal damage this would do if it was to hit. Obviously doesn't take into effect explosions/magic/similar things.. unless you implement it to raise the value.
  * attack_text - The text that this attack should show, in the context of something like "[src] blocks [attack_text]!"
  * attack_type - See __DEFINES/combat.dm - Attack types, to distinguish between, for example, someone throwing an item at us vs bashing us with it.
  * armour_penetration - 0-100 value of how effectively armor penetrating the attack should be.
  * attacker - Set to the mob attacking IF KNOWN. Do not expect this to always be set!
  * def_zone - The zone this'll impact.
  * return_list - If something wants to grab things from what items/whatever put into list/block_return on obj/item/run_block and the comsig, pass in a list so you can grab anything put in it after block runs.
  * attack_direction - Direction of the attack. It is highly recommended to put this in, as the automatic guesswork that's done otherwise is quite inaccurate at times.
  */
/mob/living/proc/do_run_block(real_attack = TRUE, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, list/return_list = list(), attack_direction)
	if(real_attack)
		. = run_parry(object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, return_list)			//Parry - Highest priority!
		if((. & BLOCK_SUCCESS) && !(. & BLOCK_CONTINUE_CHAIN))
			return
	// Component signal block runs have highest priority.. for now.
	. = SEND_SIGNAL(src, COMSIG_LIVING_RUN_BLOCK, real_attack, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, return_list, attack_direction)
	if((. & BLOCK_SUCCESS) && !(. & BLOCK_CONTINUE_CHAIN))
		return_list[BLOCK_RETURN_PROJECTILE_BLOCK_PERCENTAGE] = 100
		return
	var/list/obj/item/tocheck = get_blocking_items()
	sortTim(tocheck, /proc/cmp_numeric_dsc, TRUE)
	// i don't like this
	var/block_chance_modifier = round(damage / -3)
	if(real_attack)
		for(var/obj/item/I in tocheck)
			// i don't like this too
			var/final_block_chance = I.block_chance - (clamp((armour_penetration-I.armour_penetration)/2,0,100)) + block_chance_modifier //So armour piercing blades can still be parried by other blades, for example
			var/results
			if(I == active_block_item)
				results = I.active_block(src, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, return_list, attack_direction)
			else if(I.can_passive_block() && !SEND_SIGNAL(src, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
				results = I.passive_block(src, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, return_list, attack_direction)
			else
				results = I.run_block(src, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, return_list)
			. |= results
			if((results & BLOCK_SUCCESS) && !(results & BLOCK_CONTINUE_CHAIN))
				break
	else
		for(var/obj/item/I in tocheck)
			// i don't like this too
			var/final_block_chance = I.block_chance - (clamp((armour_penetration-I.armour_penetration)/2,0,100)) + block_chance_modifier //So armour piercing blades can still be parried by other blades, for example
			if(I == active_block_item)		//block is long termed enough we give a damn. parry, not so much.
				I.check_active_block(src, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, return_list, attack_direction)
			else
				I.check_block(src, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, return_list)
	if(. & BLOCK_SUCCESS)
		return_list[BLOCK_RETURN_PROJECTILE_BLOCK_PERCENTAGE] = 100
	else if(isnull(return_list[BLOCK_RETURN_PROJECTILE_BLOCK_PERCENTAGE]))
		return_list[BLOCK_RETURN_PROJECTILE_BLOCK_PERCENTAGE] = return_list[BLOCK_RETURN_MITIGATION_PERCENT]

/// Gets an unsortedlist of objects to run block checks on. List must have associative values for priorities!
/mob/living/proc/get_blocking_items()
	. = list()
	if(active_block_item)
		var/datum/block_parry_data/data = active_block_item.get_block_parry_data()
		.[active_block_item] = data.block_active_priority
	SEND_SIGNAL(src, COMSIG_LIVING_GET_BLOCKING_ITEMS, .)
	for(var/obj/item/I in held_items)
		// this is a bad check but i am not removing it until a better catchall is made
		if(istype(I, /obj/item/clothing))
			continue
		if(.[I])			//don't override block/parry.
			continue
		.[I] = I.block_priority

/obj/item
	/// The 0% to 100% chance for the default implementation of random block rolls.
	var/block_chance = 0
	/// Block priority, higher means we check this higher in the "chain".
	var/block_priority = BLOCK_PRIORITY_DEFAULT

/// Runs block and returns flag for do_run_block to process.
/obj/item/proc/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	. = SEND_SIGNAL(src, COMSIG_ITEM_RUN_BLOCK, owner, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, block_return)
	if(. & BLOCK_SUCCESS)
		return
	if(owner.prob_good(final_block_chance))
		owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>",
			"<span class='danger'>You block [attack_text] with [src]!</span>")
		return . | BLOCK_SUCCESS | BLOCK_PHYSICAL_EXTERNAL
	return . | BLOCK_NONE

/// Returns block information using list/block_return. Used for check_block() on mobs.
/obj/item/proc/check_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	SEND_SIGNAL(src, COMSIG_ITEM_CHECK_BLOCK, owner, object, damage, attack_text, attack_type, armour_penetration, attacker, def_zone, final_block_chance, block_return)
	var/existing = block_return[BLOCK_RETURN_NORMAL_BLOCK_CHANCE]
	block_return[BLOCK_RETURN_NORMAL_BLOCK_CHANCE] = max(existing || 0, final_block_chance)

// HELPER PROCS

/**
  * Considers a block return_list and calculates damage to use from that.
  */
/proc/block_calculate_resultant_damage(damage, list/block_return)
	if(!isnull(block_return[BLOCK_RETURN_SET_DAMAGE_TO]))	// higher priority
		return block_return[BLOCK_RETURN_SET_DAMAGE_TO]
	else if(!isnull(block_return[BLOCK_RETURN_MITIGATION_PERCENT]))
		return damage * ((100 - block_return[BLOCK_RETURN_MITIGATION_PERCENT]) * 0.01)
	return damage
