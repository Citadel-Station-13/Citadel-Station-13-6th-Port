/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	var/zone = BODY_ZONE_CHEST
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/organ_flags = ORGAN_EDIBLE
	var/maxHealth = STANDARD_ORGAN_THRESHOLD
	var/damage = 0		//total damage this organ has sustained
	///Healing factor and decay factor function on % of maxhealth, and do not work by applying a static number per tick
	var/healing_factor 	= 0										//fraction of maxhealth healed per on_life(), set to 0 for generic organs
	var/decay_factor 	= 0										//same as above but when without a living owner, set to 0 for generic organs
	var/high_threshold	= STANDARD_ORGAN_THRESHOLD * 0.45		//when severe organ damage occurs
	var/low_threshold	= STANDARD_ORGAN_THRESHOLD * 0.1		//when minor organ damage occurs
	var/severe_cooldown	//cooldown for severe effects, used for synthetic organ emp effects.

	///Organ variables for determining what we alert the owner with when they pass/clear the damage thresholds
	var/prev_damage = 0
	var/low_threshold_passed
	var/high_threshold_passed
	var/now_failing
	var/now_fixed
	var/high_threshold_cleared
	var/low_threshold_cleared

	///When you take a bite you cant jam it in for surgery anymore.
	var/useable = TRUE
	var/list/food_reagents = list(/datum/reagent/consumable/nutriment = 5)

/obj/item/organ/Initialize()
	. = ..()
	if(organ_flags & ORGAN_EDIBLE)
		AddComponent(/datum/component/edible, food_reagents, null, RAW | MEAT | GROSS, null, 10, null, null, null, CALLBACK(src, .proc/OnEatFrom))
	START_PROCESSING(SSobj, src)

/obj/item/organ/Destroy()
	if(owner)
		// The special flag is important, because otherwise mobs can die
		// while undergoing transformation into different mobs.
		Remove(TRUE)
	return ..()

/obj/item/organ/proc/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	if(!iscarbon(M) || owner == M)
		return FALSE

	var/obj/item/organ/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(TRUE)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(M))
		else
			qdel(replaced)

	//Hopefully this doesn't cause problems
	organ_flags &= ~ORGAN_FROZEN

	owner = M
	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	moveToNullspace()
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)
	STOP_PROCESSING(SSobj, src)

	return TRUE

//Special is for instant replacement like autosurgeons
/obj/item/organ/proc/Remove(special = FALSE)
	if(owner)
		owner.internal_organs -= src
		if(owner.internal_organs_slot[slot] == src)
			owner.internal_organs_slot.Remove(slot)
		if((organ_flags & ORGAN_VITAL) && !special && !(owner.status_flags & GODMODE))
			owner.death()
		for(var/X in actions)
			var/datum/action/A = X
			A.Remove(owner)
		. = owner //for possible subtypes specific post-removal code.
	owner = null
	START_PROCESSING(SSobj, src)

/obj/item/organ/proc/on_find(mob/living/finder)
	return

/obj/item/organ/process()	//runs decay when outside of a person AND ONLY WHEN OUTSIDE (i.e. long obj).
	on_death() //Kinda hate doing it like this, but I really don't want to call process directly.

//Sources; life.dm process_organs
/obj/item/organ/proc/on_death(seconds, times_fired) //Runs when outside AND inside.
	decay()

//Applys the slow damage over time decay
/obj/item/organ/proc/decay(seconds, times_fired)
	if(!can_decay())
		STOP_PROCESSING(SSobj, src)
		return
	is_cold()
	if(organ_flags & ORGAN_FROZEN)
		return
	applyOrganDamage(maxHealth * decay_factor * (seconds * 0.5))

/obj/item/organ/proc/can_decay()
	if(CHECK_BITFIELD(organ_flags, ORGAN_NO_SPOIL | ORGAN_SYNTHETIC | ORGAN_FAILING))
		return FALSE
	return TRUE

//Checks to see if the organ is frozen from temperature
/obj/item/organ/proc/is_cold()
	if(istype(loc, /obj/))//Freezer of some kind, I hope.
		if(is_type_in_typecache(loc, GLOB.freezing_objects))
			if(!(organ_flags & ORGAN_FROZEN))//Incase someone puts them in when cold, but they warm up inside of the thing. (i.e. they have the flag, the thing turns it off, this rights it.)
				organ_flags |= ORGAN_FROZEN
			return TRUE
		return (organ_flags & ORGAN_FROZEN) //Incase something else toggles it

	var/local_temp
	if(istype(loc, /turf/))//Only concern is adding an organ to a freezer when the area around it is cold.
		var/turf/T = loc
		var/datum/gas_mixture/enviro = T.return_air()
		local_temp = enviro.return_temperature()

	else if(!owner && ismob(loc))
		var/mob/M = loc
		if(is_type_in_typecache(M.loc, GLOB.freezing_objects))
			if(!(organ_flags & ORGAN_FROZEN))
				organ_flags |= ORGAN_FROZEN
			return TRUE
		var/turf/T = M.loc
		var/datum/gas_mixture/enviro = T.return_air()
		local_temp = enviro.return_temperature()

	if(owner)
		//Don't interfere with bodies frozen by structures.
		if(is_type_in_typecache(owner.loc, GLOB.freezing_objects))
			if(!(organ_flags & ORGAN_FROZEN))
				organ_flags |= ORGAN_FROZEN
			return TRUE
		local_temp = owner.bodytemperature

	if(!local_temp)//Shouldn't happen but in case
		return
	if(local_temp < 154)//I have a pretty shaky citation that states -120 allows indefinite cyrostorage
		organ_flags |= ORGAN_FROZEN
		return TRUE
	organ_flags &= ~ORGAN_FROZEN
	return FALSE

/obj/item/organ/proc/on_life(seconds, times_fired)	//repair organ damage if the organ is not failing or synthetic
	if(organ_flags & ORGAN_FAILING || !owner)
		return FALSE
	if(organ_flags & ORGAN_SYNTHETIC_EMP) //Synthetic organ has been emped, is now failing.
		applyOrganDamage(maxHealth * decay_factor)
		return
	if(!is_cold() && damage)
		///Damage decrements by a percent of its maxhealth
		var/healing_amount = -(maxHealth * healing_factor)
		///Damage decrements again by a percent of its maxhealth, up to a total of 4 extra times depending on the owner's satiety
		healing_amount -= owner.satiety > 0 ? 4 * healing_factor * owner.satiety / MAX_SATIETY : 0
		if(healing_amount)
			applyOrganDamage(healing_amount) //to FERMI_TWEAK
	return TRUE

/obj/item/organ/examine(mob/user)
	. = ..()
	if(organ_flags & ORGAN_FAILING)
		if(status == ORGAN_ROBOTIC)
			. += "<span class='warning'>[src] seems to be broken!</span>"
			return
		. += "<span class='warning'>[src] has decayed for too long, and has turned a sickly color! It doesn't look like it will work anymore!</span>"
		return
	if(damage > high_threshold)
		. += "<span class='warning'>[src] is starting to look discolored.</span>"

/obj/item/organ/proc/OnEatFrom(eater, feeder)
	useable = FALSE //You can't use it anymore after eating it you spaztic

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

///Adjusts an organ's damage by the amount "d", up to a maximum amount, which is by default max damage
/obj/item/organ/proc/applyOrganDamage(var/d, var/maximum = maxHealth)	//use for damaging effects
	if(!d || maximum < damage) //Micro-optimization.
		return FALSE
	damage = clamp(damage + d, 0, maximum)
	var/mess = check_damage_thresholds()
	prev_damage = damage
	if(mess && owner)
		to_chat(owner, mess)
	return TRUE

///SETS an organ's damage to the amount "d", and in doing so clears or sets the failing flag, good for when you have an effect that should fix an organ if broken
/obj/item/organ/proc/setOrganDamage(var/d)	//use mostly for admin heals
	applyOrganDamage(d - damage)

/** check_damage_thresholds
  * input: M (a mob, the owner of the organ we call the proc on)
  * output: returns a message should get displayed.
  * description: By checking our current damage against our previous damage, we can decide whether we've passed an organ threshold.
  *				 If we have, send the corresponding threshold message to the owner, if such a message exists.
  */
/obj/item/organ/proc/check_damage_thresholds()
	if(damage == prev_damage)
		return
	var/delta = damage - prev_damage
	if(delta > 0)
		if(damage >= maxHealth)
			organ_flags |= ORGAN_FAILING
			if(owner)
				owner.med_hud_set_status()
			return now_failing
		if(damage > high_threshold && prev_damage <= high_threshold)
			return high_threshold_passed
		if(damage > low_threshold && prev_damage <= low_threshold)
			return low_threshold_passed
	else
		organ_flags &= ~ORGAN_FAILING
		if(owner)
			owner.med_hud_set_status()
		if(!owner)//Processing is stopped when the organ is dead and outside of someone. This hopefully should restart it if a removed organ is repaired outside of a body.
			START_PROCESSING(SSobj, src)
		if(prev_damage > low_threshold && damage <= low_threshold)
			return low_threshold_cleared
		if(prev_damage > high_threshold && damage <= high_threshold)
			return high_threshold_cleared
		if(prev_damage == maxHealth)
			return now_fixed

//Runs some code on the organ when damage is taken/healed
/obj/item/organ/proc/onDamage(var/d, var/maximum = maxHealth)
	return

//Runs some code on the organ when damage is taken/healed
/obj/item/organ/proc/onSetDamage(var/d, var/maximum = maxHealth)
	return

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/mob/living/proc/regenerate_organs()
	return 0

/mob/living/carbon/regenerate_organs(only_one = FALSE)
	var/breathes = TRUE
	var/blooded = TRUE
	if(dna && dna.species)
		if(HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT))
			breathes = FALSE
		if(NOBLOOD in dna.species.species_traits)
			blooded = FALSE
		var/has_liver = (!(NOLIVER in dna.species.species_traits))
		var/has_stomach = (!(NOSTOMACH in dna.species.species_traits))

		for(var/obj/item/organ/O in internal_organs)
			if(O.organ_flags & ORGAN_FAILING)
				O.setOrganDamage(0)
				if(only_one)
					return TRUE

		if(has_liver && !getorganslot(ORGAN_SLOT_LIVER))
			var/obj/item/organ/liver/LI

			if(dna.species.mutantliver)
				LI = new dna.species.mutantliver()
			else
				LI = new()
			LI.Insert(src)
			if(only_one)
				return TRUE

		if(has_stomach && !getorganslot(ORGAN_SLOT_STOMACH))
			var/obj/item/organ/stomach/S

			if(dna.species.mutantstomach)
				S = new dna.species.mutantstomach()
			else
				S = new()
			S.Insert(src)
			if(only_one)
				return TRUE

	if(breathes && !getorganslot(ORGAN_SLOT_LUNGS))
		var/obj/item/organ/lungs/L = new()
		L.Insert(src)
		if(only_one)
			return TRUE

	if(blooded && !getorganslot(ORGAN_SLOT_HEART))
		var/obj/item/organ/heart/H = new()
		H.Insert(src)
		if(only_one)
			return TRUE

	if(!getorganslot(ORGAN_SLOT_TONGUE))
		var/obj/item/organ/tongue/T

		if(dna && dna.species && dna.species.mutanttongue)
			T = new dna.species.mutanttongue()
		else
			T = new()

		// if they have no mutant tongues, give them a regular one
		T.Insert(src)
		if(only_one)
			return TRUE

	else if (!only_one)
		var/obj/item/organ/tongue/oT = getorganslot(ORGAN_SLOT_TONGUE)
		if(oT.name == "fluffy tongue")
			var/obj/item/organ/tongue/T
			if(dna && dna.species && dna.species.mutanttongue)
				T = new dna.species.mutanttongue()
			else
				T = new()
			oT.Remove()
			qdel(oT)
			T.Insert(src)

	if(!getorganslot(ORGAN_SLOT_EYES))
		var/obj/item/organ/eyes/E

		if(dna && dna.species && dna.species.mutanteyes)
			E = new dna.species.mutanteyes()

		else
			E = new()
		E.Insert(src)
		if(only_one)
			return TRUE

	if(!getorganslot(ORGAN_SLOT_EARS))
		var/obj/item/organ/ears/ears
		if(dna && dna.species && dna.species.mutantears)
			ears = new dna.species.mutantears
		else
			ears = new

		ears.Insert(src)
		if(only_one)
			return TRUE

	if(!getorganslot(ORGAN_SLOT_TAIL))
		var/obj/item/organ/tail/tail
		if(dna && dna.species && dna.species.mutanttail)
			tail = new dna.species.mutanttail
			tail.Insert(src)
			if(only_one)
				return TRUE


/obj/item/organ/random
	name = "Illegal organ"
	desc = "Something hecked up"

/obj/item/organ/random/Initialize()
	..()
	var/list = list(/obj/item/organ/tongue, /obj/item/organ/brain, /obj/item/organ/heart, /obj/item/organ/liver, /obj/item/organ/ears, /obj/item/organ/eyes, /obj/item/organ/tail, /obj/item/organ/stomach)
	var/newtype = pick(list)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL
