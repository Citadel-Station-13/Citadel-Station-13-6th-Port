/datum/surgery/advanced/bioware/meninge_fortification
	name = "Meningeal Fortification"
	desc = "A surgical procedure that gives the meninges surrounding the brain a stronger structure, protecting from brain damage."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/saw,
				/datum/surgery_step/incise,
				/datum/surgery_step/fortify_meninges,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_HEAD)
	bioware_target = BIOWARE_BRAIN

/datum/surgery_step/fortify_meninges
	name = "fortify meninges"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/fortify_meninges/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You start fortifying [target]'s meninges.</span>",
		"[user] starts fortifying [target]'s meninges.",
		"[user] starts manipulating [target]'s brain.")

/datum/surgery_step/fortify_meninges/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You successfully fortify [target]'s meninges!</span>",
		"[user] successfully fortifies [target]'s meninges!",
		"[user] finishes manipulating [target]'s brain.")
	new /datum/bioware/meninge_fortification(target)
	return TRUE

/datum/bioware/meninge_fortification
	name = "Meninge Fortification"
	desc = "The subarachnoid space's structure's durability has been increased, leading to lower likelihood of brain damage."
	mod_type = BIOWARE_BRAIN

/datum/bioware/grounded_nerves/on_gain()
	..()
	owner.physiology.brain_mod *= 0.5

/datum/bioware/grounded_nerves/on_lose()
	..()
	owner.physiology.brain_mod *= 2

/datum/surgery/advanced/bioware/brain_respiration
	name = "Brain Oxygenation Optimization"
	desc = "A surgical procedure which optimizes the delivery of oxygen to the patient's brain, allowing them to operate at full capacity in soft critical health."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/saw,
				/datum/surgery_step/incise,
				/datum/surgery_step/optimize_brain,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_BRAIN

/datum/surgery_step/optimize_brain
	name = "optimize circle of willis"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/optimize_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You start optimizing [target]'s circle of willis.</span>",
		"[user] starts optimizing [target]'s circle of willis.",
		"[user] starts manipulating [target]'s brain.")

/datum/surgery_step/optimize_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You successfully fortify [target]'s circle of willis!</span>",
		"[user] successfully optimizing [target]'s circle of willis!",
		"[user] finishes manipulating [target]'s brain.")
	new /datum/bioware/brain_optimization(target)
	return TRUE

/datum/bioware/brain_optimization
	name = "Optimized Circle of Willis"
	desc = "The layout of the arteries that deliver blood to the brain has been optimized, allowing continued operation with less oxygen."
	mod_type = BIOWARE_BRAIN

/datum/bioware/brain_optimization/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, "optimized_brain_oxygenation")

/datum/bioware/brain_optimization/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, "optimized_brain_oxygenation")
