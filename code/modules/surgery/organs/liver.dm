#define LIVER_DEFAULT_HEALTH 100 //amount of damage required for liver failure
#define LIVER_DEFAULT_TOX_TOLERANCE 3 //amount of toxins the liver can filter out
#define LIVER_DEFAULT_TOX_LETHALITY 0.01 //lower values lower how harmful toxins are to the liver

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	desc = "Pairing suggestion: chianti and fava beans."

	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	high_threshold_passed = "<span class='warning'>You feel a stange ache in your abdomen, almost like a stitch. This pain is encumbering your movements.</span>"
	high_threshold_cleared = "<span class='notice'>The stitching ache in your abdomen passes away, unencumbering your movements.</span>"
	now_fixed = "<span class='notice'>The stabbing pain in your abdomen slowly calms down into a more tolerable ache.</span>"

	var/alcohol_tolerance = ALCOHOL_RATE//affects how much damage the liver takes from alcohol
	var/toxTolerance = LIVER_DEFAULT_TOX_TOLERANCE//maximum amount of toxins the liver can just shrug off
	var/toxLethality = LIVER_DEFAULT_TOX_LETHALITY//affects how much damage toxins do to the liver
	var/filterToxins = TRUE //whether to filter toxins
	var/cachedmoveCalc = 1
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/iron = 5)

/obj/item/organ/liver/on_life(seconds, times_fired)
	. = ..()
	if(!. || !owner)//can't process reagents with a failing liver
		return

	if(filterToxins && !HAS_TRAIT(owner, TRAIT_TOXINLOVER))
		//handle liver toxin filtration
		for(var/datum/reagent/toxin/T in owner.reagents.reagent_list)
			var/thisamount = owner.reagents.get_reagent_amount(T.type)
			if (thisamount && thisamount <= toxTolerance)
				owner.reagents.remove_reagent(T.type, 1)
			else
				damage += (thisamount*toxLethality)

	//metabolize reagents
	owner.reagents.metabolize(owner, seconds, times_fired, can_overdose=TRUE)

	if(damage > 10 && prob(damage/3))//the higher the damage the higher the probability
		to_chat(owner, "<span class='warning'>You feel a dull pain in your abdomen.</span>")

/obj/item/organ/liver/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(!. || QDELETED(owner))
		return
	if(damage >= high_threshold)
		var/move_calc = 1+((round(damage) - high_threshold)/(high_threshold/3))
		owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/liver_cirrhosis, multiplicative_slowdown = move_calc)
		sizeMoveMod(move_calc, owner)
	else
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/liver_cirrhosis)
		sizeMoveMod(1, owner)

/obj/item/organ/liver/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(. && damage >= high_threshold)
		var/move_calc = 1+((round(damage) - high_threshold)/(high_threshold/3))
		M.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/liver_cirrhosis, multiplicative_slowdown = move_calc)
		sizeMoveMod(move_calc, owner)

/obj/item/organ/liver/Remove(special = FALSE)
	if(!QDELETED(owner))
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/liver_cirrhosis)
		sizeMoveMod(1, owner)
	return ..()

/obj/item/organ/liver/proc/sizeMoveMod(value, mob/living/carbon/C)
	if(cachedmoveCalc == value)
		return
	C.action_cooldown_mod /= cachedmoveCalc
	C.action_cooldown_mod *= value
	cachedmoveCalc = value

/obj/item/organ/liver/slime
	name = "viscoplasm" //this is the name that Fermis came up with when working on that organ PR that never got finished - if Fermis ever updates this, this probably will have a lot more functionality.
	icon_state = "liver-s"
	desc = "An organelle resembling a liver for slimepeople."

/obj/item/organ/liver/fly
	name = "insectoid liver"
	icon_state = "liver-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant liver designed to handle the unique diet of a flyperson."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/plasmaman
	name = "reagent processing crystal"
	icon_state = "liver-p"
	desc = "A large crystal that is somehow capable of metabolizing chemicals, these are found in plasmamen."

/obj/item/organ/liver/ipc
	name = "reagent processing liver"
	icon_state = "liver-c"

/obj/item/organ/liver/cybernetic
	name = "basic cybernetic liver"
	icon_state = "liver-c"
	desc = "A very basic device designed to mimic the functions of a human liver. Handles toxins slightly worse than an organic liver."
	organ_flags = ORGAN_SYNTHETIC
	toxTolerance = 0.3 * LIVER_DEFAULT_TOX_TOLERANCE //little less than 1u of toxin purging
	toxLethality = 1.1 * LIVER_DEFAULT_TOX_LETHALITY
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.5

	var/emp_vulnerability = 1 //The value the severity of emps are divided by to determine the likelihood of permanent damage.

/obj/item/organ/liver/cybernetic/tier2
	name = "cybernetic liver"
	icon_state = "liver-c-u"
	desc = "An electronic device designed to mimic the functions of a human liver. Handles toxins slightly better than an organic liver."
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 2 * LIVER_DEFAULT_TOX_TOLERANCE //6 units of toxin purging
	toxLethality = 0.8 * LIVER_DEFAULT_TOX_LETHALITY //20% less damage than a normal liver
	emp_vulnerability = 2

/obj/item/organ/liver/cybernetic/tier3
	name = "upgraded cybernetic liver"
	icon_state = "liver-c-u2"
	desc = "An upgraded version of the cybernetic liver, designed to improve further upon organic livers. It is resistant to alcohol poisoning and is very robust at filtering toxins."
	alcohol_tolerance = 0.001
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 5 * LIVER_DEFAULT_TOX_TOLERANCE //15 units of toxin purging
	toxLethality = 0.4 * LIVER_DEFAULT_TOX_LETHALITY //60% less damage than a normal liver
	emp_vulnerability = 3

/obj/item/organ/liver/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.adjustToxLoss(10)
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)
	if(prob(severity/emp_vulnerability)) //Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP //Starts organ faliure - gonna need replacing soon.
