/datum/species/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Anthropomorphic Plant"
	id = SPECIES_POD
	default_color = "59CE00"
	species_traits = list(MUTCOLORS,EYECOLOR,CAN_SCAR,HAS_FLESH,HAS_BONE)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	exotic_blood_color = BLOOD_COLOR_PLANT
	disliked_food = MEAT | DAIRY
	liked_food = VEGETABLES | FRUIT | GRAIN
	species_language_holder = /datum/language_holder/sylvan
	var/light_nutrition_gain_factor = 4
	var/light_toxheal = -1
	var/light_oxyheal = -1
	var/light_burnheal = -1
	var/light_bruteheal = -1

	species_category = SPECIES_CATEGORY_PLANT

	allowed_limb_ids = list("pod","mush")

/datum/species/pod/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.faction |= "plants"
	C.faction |= "vines"
	C.AddElement(/datum/element/photosynthesis, light_bruteheal, light_burnheal, light_toxheal, light_oxyheal, light_nutrition_gain_factor)

/datum/species/pod/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.faction -= "plants"
	C.faction -= "vines"
	C.RemoveElement(/datum/element/photosynthesis, light_bruteheal, light_burnheal, light_toxheal, light_oxyheal, light_nutrition_gain_factor)

/datum/species/pod/spec_life(mob/living/carbon/human/H)
	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/datum/species/pod/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
	return ..()

/datum/species/pod/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	switch(P.type)
		if(/obj/item/projectile/energy/floramut)
			if(H.prob_bad(15))
				H.rad_act(rand(30,80))
				H.DefaultCombatKnockdown(100)
				H.visible_message("<span class='warning'>[H] writhes in pain as [H.p_their()] vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='italics'>You hear the crunching of leaves.</span>")
				if(prob(80))
					H.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
				else
					H.easy_randmut(POSITIVE)
				H.domutcheck()
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='userdanger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.adjust_nutrition(30, NUTRITION_LEVEL_FULL)
		if(/obj/item/projectile/energy/florarevolution)
			H.show_message("<span class='notice'>The radiation beam leaves you feeling disoriented!</span>")
			H.Dizzy(15)
			H.emote("flip")
			H.emote("spin")

/datum/species/pod/pseudo_weak
	name = "Anthropomorphic Plant"
	id = SPECIES_POD_WEAK
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,MUTCOLORS,CAN_SCAR,HAS_FLESH,HAS_BONE)
	mutant_bodyparts = list("mcolor" = "FFFFFF","mcolor2" = "FFFFFF","mcolor3" = "FFFFFF", "mam_snouts" = "Husky", "mam_tail" = "Husky", "mam_ears" = "Husky", "mam_body_markings" = list(), "taur" = "None", "legs" = "Normal Legs")
	limbs_id = SPECIES_POD
	light_nutrition_gain_factor = 3
	light_bruteheal = -0.2
	light_burnheal = -0.2
	light_toxheal = -0.7

	tail_type = "mam_tail"
	wagging_type = "mam_waggingtail"
