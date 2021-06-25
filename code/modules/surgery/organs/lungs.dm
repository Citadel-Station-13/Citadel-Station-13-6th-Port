#define LUNGS_MAX_HEALTH 300

/obj/item/organ/lungs
	name = "lungs"
	desc = "Looking at them makes you start manual breathing."
	icon_state = "lungs"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_NORMAL

	var/failed = FALSE
	var/operated = FALSE	//whether we can still have our damages fixed through surgery

	//health
	maxHealth = 3 * STANDARD_ORGAN_THRESHOLD

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	high_threshold = 0.6 * LUNGS_MAX_HEALTH	//threshold at 180
	low_threshold = 0.3 * LUNGS_MAX_HEALTH	//threshold at 90

	high_threshold_passed = "<span class='warning'>You feel some sort of constriction around your chest as your breathing becomes shallow and rapid.</span>"
	now_fixed = "<span class='warning'>Your lungs seem to once again be able to hold air.</span>"
	high_threshold_cleared = "<span class='info'>The constriction around your chest loosens as your breathing calms down.</span>"

	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)

	//Breath damage

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 50 // Too much of a good thing, in kPa as well.
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = MOLES_GAS_VISIBLE
	var/safe_ch3br_min = 0
	var/safe_ch3br_max = 1 //problematic even at low concentrations
	var/safe_methane_min = 0
	var/safe_methane_max = 0
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas
	var/gas_stimulation_min = 0.002 //Nitryl and Stimulum

	var/oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/oxy_damage_type = OXY
	var/nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/nitro_damage_type = OXY
	var/co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/co2_damage_type = OXY
	var/tox_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/tox_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/tox_damage_type = TOX
	var/methane_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/methane_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/methane_damage_type = OXY

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_type = BURN

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_type = BURN

	var/crit_stabilizing_reagent = /datum/reagent/medicine/epinephrine



//TODO: lung health affects lung function
/obj/item/organ/lungs/onDamage(damage_mod) //damage might be too low atm.
	var/cached_damage = damage
	if (maxHealth == INFINITY)
		return
	if(cached_damage+damage_mod < 0)
		cached_damage = 0
		return

	cached_damage += damage_mod
	if ((cached_damage/ maxHealth) > 1)
		to_chat(owner, "<span class='userdanger'>You feel your lungs collapse within your chest as you gasp for air, unable to inflate them anymore!</span>")
		owner.emote("gasp")
		SSblackbox.record_feedback("tally", "fermi_chem", 1, "Lungs lost")
		//qdel(src) - Handled elsewhere for now.
	else if ((cached_damage / maxHealth) > 0.75)
		to_chat(owner, "<span class='warning'>It's getting really hard to breathe!!</span>")
		owner.emote("gasp")
		owner.Dizzy(3)
	else if ((cached_damage / maxHealth) > 0.5)
		owner.Dizzy(2)
		to_chat(owner, "<span class='notice'>Your chest is really starting to hurt.</span>")
		owner.emote("cough")
	else if ((cached_damage / maxHealth) > 0.2)
		to_chat(owner, "<span class='notice'>You feel an ache within your chest.</span>")
		owner.emote("cough")
		owner.Dizzy(1)

/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
//TODO: add lung damage = less oxygen gains
	var/breathModifier = (5-(5*(damage/maxHealth)/2)) //range 2.5 - 5
	if((H.status_flags & GODMODE))
		return
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return

	if(!breath || (breath.total_moles() == 0))
		if(H.reagents.has_reagent(crit_stabilizing_reagent))
			return
		if(H.health >= H.crit_threshold)
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else if(!HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		H.failed_last_breath = TRUE
		if(safe_oxygen_min)
			H.throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		else if(safe_toxins_min)
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else if(safe_co2_min)
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else if(safe_nitro_min)
			H.throw_alert("not_enough_nitro", /obj/screen/alert/not_enough_nitro)
		else if(safe_ch3br_min)
			H.throw_alert("not_enough_ch3br", /obj/screen/alert/not_enough_ch3br)
		return FALSE

	var/gas_breathed = 0

	//Partial pressures in our breath
	var/O2_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/oxygen))+(8*breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/pluoxium)))
	var/N2_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/nitrogen))
	var/Toxins_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/plasma))
	var/CO2_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/carbon_dioxide))
	var/CH4_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/methane))
	var/CH3Br_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/methyl_bromide))


	//-- OXY --//

	//Too much oxygen! //Yes, some species may not like it.
	if(safe_oxygen_max)
		if((O2_pp > safe_oxygen_max) && safe_oxygen_max == 0) //I guess plasma men technically need to have a check.
			var/ratio = (breath.get_moles(/datum/gas/oxygen)/safe_oxygen_max) * 10
			H.apply_damage_type(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
			H.throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)

		else if((O2_pp > safe_oxygen_max) && !(safe_oxygen_max == 0)) //Why yes, this is like too much CO2 and spahget. Dirty lizards.
			if(!H.o2overloadtime)
				H.o2overloadtime = world.time
			else if(world.time - H.o2overloadtime > 120)
				H.Dizzy(10)	// better than a minute of you're fucked KO, but certainly a wake up call. Honk.
				H.adjustOxyLoss(3)
				if(world.time - H.o2overloadtime > 300)
					H.adjustOxyLoss(8)
			if(prob(20))
				H.emote("cough")
			H.throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)

		else
			H.o2overloadtime = 0
			H.clear_alert("too_much_oxy")

	//Too little oxygen!
	if(safe_oxygen_min)
		if(O2_pp < safe_oxygen_min)
			gas_breathed = handle_too_little_breath(H, O2_pp, safe_oxygen_min, breath.get_moles(/datum/gas/oxygen))
			H.throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-breathModifier) //More damaged lungs = slower oxy rate up to a factor of half
			gas_breathed = breath.get_moles(/datum/gas/oxygen)
			H.clear_alert("not_enough_oxy")

	//Exhale
	breath.adjust_moles(/datum/gas/oxygen, -gas_breathed)
	breath.adjust_moles(/datum/gas/carbon_dioxide, gas_breathed)
	gas_breathed = 0

	//-- Nitrogen --//

	//Too much nitrogen!
	if(safe_nitro_max)
		if(N2_pp > safe_nitro_max)
			var/ratio = (breath.get_moles(/datum/gas/nitrogen)/safe_nitro_max) * 10
			H.apply_damage_type(clamp(ratio, nitro_breath_dam_min, nitro_breath_dam_max), nitro_damage_type)
			H.throw_alert("too_much_nitro", /obj/screen/alert/too_much_nitro)
			H.losebreath += 2
		else
			H.clear_alert("too_much_nitro")

	//Too little nitrogen!
	if(safe_nitro_min)
		if(N2_pp < safe_nitro_min)
			gas_breathed = handle_too_little_breath(H, N2_pp, safe_nitro_min, breath.get_moles(/datum/gas/nitrogen))
			H.throw_alert("nitro", /obj/screen/alert/not_enough_nitro)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-breathModifier)
			gas_breathed = breath.get_moles(/datum/gas/nitrogen)
			H.clear_alert("nitro")

	//Exhale
	breath.adjust_moles(/datum/gas/nitrogen, -gas_breathed)
	breath.adjust_moles(/datum/gas/carbon_dioxide, gas_breathed)
	gas_breathed = 0

	//-- CO2 --//

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(safe_co2_max)
		if(CO2_pp > safe_co2_max)
			if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				H.co2overloadtime = world.time
			else if(world.time - H.co2overloadtime > 120)
				H.Unconscious(60)
				H.apply_damage_type(3, co2_damage_type) // Lets hurt em a little, let them know we mean business
				if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					H.apply_damage_type(8, co2_damage_type)
				H.throw_alert("too_much_co2", /obj/screen/alert/too_much_co2)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				H.emote("cough")

		else
			H.co2overloadtime = 0
			H.clear_alert("too_much_co2")

	//Too little CO2!
	if(safe_co2_min)
		if(CO2_pp < safe_co2_min)
			gas_breathed = handle_too_little_breath(H, CO2_pp, safe_co2_min, breath.get_moles(/datum/gas/carbon_dioxide))
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-breathModifier)
			gas_breathed = breath.get_moles(/datum/gas/carbon_dioxide)
			H.clear_alert("not_enough_co2")

	//Exhale
	breath.adjust_moles(/datum/gas/carbon_dioxide, -gas_breathed)
	breath.adjust_moles(/datum/gas/oxygen, gas_breathed)
	gas_breathed = 0


	//-- TOX --//

	//Too much toxins!
	if(safe_toxins_max)
		if(Toxins_pp > safe_toxins_max)
			var/ratio = (breath.get_moles(/datum/gas/plasma)/safe_toxins_max) * 10
			H.apply_damage_type(clamp(ratio, tox_breath_dam_min, tox_breath_dam_max), tox_damage_type)
			H.throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
		else
			H.clear_alert("too_much_tox")


	//Too little toxins!
	if(safe_toxins_min)
		if(Toxins_pp < safe_toxins_min)
			gas_breathed = handle_too_little_breath(H, Toxins_pp, safe_toxins_min, breath.get_moles(/datum/gas/plasma))
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-breathModifier)
			gas_breathed = breath.get_moles(/datum/gas/plasma)
			H.clear_alert("not_enough_tox")

	//Exhale
	breath.adjust_moles(/datum/gas/plasma, -gas_breathed)
	breath.adjust_moles(/datum/gas/carbon_dioxide, gas_breathed)
	gas_breathed = 0

//-- METHANE --//

	//Too much methane!
	if(safe_methane_max)
		if(CH4_pp > safe_methane_max) //Same effect as excess nitrogen, generally nontoxic
			var/ratio = (breath.get_moles(/datum/gas/methane)/safe_methane_max) * 10
			H.apply_damage_type(clamp(ratio, methane_breath_dam_min, methane_breath_dam_max), methane_damage_type)
			H.throw_alert("too_much_ch4", /obj/screen/alert/too_much_ch4)
			H.losebreath += 2
		else
			H.clear_alert("too_much_ch4")
	//Too little methane!
	if(safe_methane_min)
		if(CH4_pp < safe_methane_min)
			gas_breathed = handle_too_little_breath(H, CH4_pp, safe_methane_min, breath.get_moles(/datum/gas/methane))
			H.throw_alert("not_enough_ch4", /obj/screen/alert/not_enough_ch4)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-breathModifier)
			gas_breathed = breath.get_moles(/datum/gas/methane)
			H.clear_alert("not_enough_ch4")

	//Exhale
	breath.adjust_moles(/datum/gas/methane, -gas_breathed)
	breath.adjust_moles(/datum/gas/methyl_bromide, gas_breathed)
	gas_breathed = 0

//-- CH3BR --//

	//Too much methyl bromide!
	if(safe_ch3br_max)
		if(CH3Br_pp > safe_ch3br_max)
			if(prob(CH3Br_pp/0.5))
				H.adjustOrganLoss(ORGAN_SLOT_LUNGS, 3, 150) //Inhaling this is a bad idea
				if(prob(CH3Br_pp/2))
					to_chat(H, "<span class='alert'>Your throat closes up!</span>")
					H.silent = max(H.silent, 3)
			H.throw_alert("too_much_ch3br", /obj/screen/alert/too_much_ch3br)
		else
			H.clear_alert("too_much_ch3br")
	//Too little methyl bromide!
	if(safe_ch3br_min)
		if(CH3Br_pp < safe_ch3br_min)
			gas_breathed = handle_too_little_breath(H, CH3Br_pp, safe_ch3br_min, breath.get_moles(/datum/gas/methyl_bromide))
			H.throw_alert("not_enough_ch3br", /obj/screen/alert/not_enough_ch3br)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-breathModifier)
			gas_breathed = breath.get_moles(/datum/gas/methyl_bromide)
			H.clear_alert("not_enough_ch3br")

	//-- TRACES --//

	if(breath)	// If there's some other shit in the air lets deal with it here.

	// N2O

		var/SA_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/nitrous_oxide))
		if(SA_pp > SA_para_min) // Enough to make us stunned for a bit
			H.Unconscious(60) // 60 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.Sleeping(max(H.AmountSleeping() + 40, 200))
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))
				SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
		else
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")

	// BZ

		var/bz_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/bz))
		if(bz_pp > BZ_trip_balls_min)
			H.hallucination += 10
			H.reagents.add_reagent(/datum/reagent/bz_metabolites,5)
			if(prob(33))
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)

		else if(bz_pp > 0.01)
			H.hallucination += 5
			H.reagents.add_reagent(/datum/reagent/bz_metabolites,1)


	// Tritium
		var/trit_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/tritium))
		if (trit_pp > 50)
			H.radiation += trit_pp/2 //If you're breathing in half an atmosphere of radioactive gas, you fucked up.
		else
			H.radiation += trit_pp/10

	// Nitryl
		var/nitryl_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/nitryl))
		if (prob(nitryl_pp))
			to_chat(H, "<span class='alert'>Your mouth feels like it's burning!</span>")
		if (nitryl_pp >40)
			H.emote("gasp")
			H.adjustFireLoss(10)
			if (prob(nitryl_pp/2))
				to_chat(H, "<span class='alert'>Your throat closes up!</span>")
				H.silent = max(H.silent, 3)
		else
			H.adjustFireLoss(nitryl_pp/4)
		gas_breathed = breath.get_moles(/datum/gas/nitryl)
		if (gas_breathed > gas_stimulation_min)
			H.reagents.add_reagent(/datum/reagent/nitryl,1)

		breath.adjust_moles(/datum/gas/nitryl, -gas_breathed)

	// Stimulum
		gas_breathed = breath.get_moles(/datum/gas/stimulum)
		if (gas_breathed > gas_stimulation_min)
			var/existing = H.reagents.get_reagent_amount(/datum/reagent/stimulum)
			H.reagents.add_reagent(/datum/reagent/stimulum, max(0, 5 - existing))
		breath.adjust_moles(/datum/gas/stimulum, -gas_breathed)

	// Miasma
		if (breath.get_moles(/datum/gas/miasma))
			var/miasma_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/miasma))
			if(miasma_pp > MINIMUM_MOLES_DELTA_TO_MOVE)

				//Miasma sickness
				if(prob(0.05 * miasma_pp))
					var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(TRUE, 2,3)
					miasma_disease.name = "Unknown"
					miasma_disease.try_infect(owner)

				// Miasma side effects
				switch(miasma_pp)
					if(1 to 5)
						// At lower pp, give out a little warning
						SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")
						if(prob(5))
							to_chat(owner, "<span class='notice'>There is an unpleasant smell in the air.</span>")
					if(5 to 15)
						//At somewhat higher pp, warning becomes more obvious
						if(prob(15))
							to_chat(owner, "<span class='warning'>You smell something horribly decayed inside this room.</span>")
							SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
					if(15 to 30)
						//Small chance to vomit. By now, people have internals on anyway
						if(prob(5))
							to_chat(owner, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
							SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
							owner.vomit()
					if(30 to INFINITY)
						//Higher chance to vomit. Let the horror start
						if(prob(15))
							to_chat(owner, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
							SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
							owner.vomit()
					else
						SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")

				// In a full miasma atmosphere with 101.34 pKa, about 10 disgust per breath, is pretty low compared to threshholds
				// Then again, this is a purely hypothetical scenario and hardly reachable
				owner.adjust_disgust(0.1 * miasma_pp)

				breath.adjust_moles(/datum/gas/miasma, -gas_breathed)

		// Clear out moods when no miasma at all
		else
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")

		handle_breath_temperature(breath, H)
	return TRUE


/obj/item/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return FALSE

	if(prob(20))
		H.emote("gasp")
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		H.failed_last_breath = TRUE
		. = true_pp*ratio/6
	else
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.failed_last_breath = TRUE


/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	var/breath_temperature = breath.return_temperature()

	if(!HAS_TRAIT(H, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = H.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			H.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (cold_level_3_damage*cold_modifier*2))
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			H.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (cold_level_2_damage*cold_modifier*2))
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			H.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (cold_level_1_damage*cold_modifier*2))
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [cold_message] in your [name]!</span>")

	if(!HAS_TRAIT(H, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = H.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			H.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (heat_level_1_damage*heat_modifier*2))
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			H.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (heat_level_2_damage*heat_modifier*2))
		if(breath_temperature > heat_level_3_threshold)
			H.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (heat_level_3_damage*heat_modifier*2))
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [hot_message] in your [name]!</span>")

/obj/item/organ/lungs/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(!.)
		return
	if(!failed && organ_flags & ORGAN_FAILING)
		if(owner && owner.stat == CONSCIOUS)
			owner.visible_message("<span class='danger'>[owner] grabs [owner.p_their()] throat, struggling for breath!</span>", \
								"<span class='userdanger'>You suddenly feel like you can't breathe!</span>")
		failed = TRUE
	else if(!(organ_flags & ORGAN_FAILING))
		failed = FALSE

/obj/item/organ/lungs/ipc
	name = "ipc cooling system"
	icon_state = "lungs-c"

/obj/item/organ/lungs/ipc/emp_act(severity) //Should probably put it somewhere else later
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	to_chat(owner, "<span class='warning'>Alert: Critical cooling system failure!</span>")
	switch(severity)
		if(1)
			owner.adjust_bodytemperature(100*TEMPERATURE_DAMAGE_COEFFICIENT)
		if(2)
			owner.adjust_bodytemperature(30*TEMPERATURE_DAMAGE_COEFFICIENT)

/obj/item/organ/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon_state = "lungs-plasma"

	safe_oxygen_min = 0 //We don't breath this
	safe_oxygen_max = 0 // Like, at all.
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0
	maxHealth = INFINITY//I don't understand how plamamen work, so I'm not going to try t give them special lungs atm

/obj/item/organ/lungs/cybernetic
	name = "basic cybernetic lungs"
	desc = "A basic cybernetic version of the lungs found in traditional humanoid entities."
	icon_state = "lungs-c"
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5

	var/emp_vulnerability = 1 //The value the severity of emps are divided by to determine the likelihood of permanent damage.

/obj/item/organ/lungs/cybernetic/tier2
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. Allows for greater intakes of oxygen than organic lungs, requiring slightly less pressure."
	icon_state = "lungs-c-u"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	safe_oxygen_min = 13
	safe_oxygen_max = 100
	emp_vulnerability = 2

/obj/item/organ/lungs/cybernetic/tier3
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs. Features the ability to filter out various airbourne toxins and carbon dioxide even at heavy levels."
	icon_state = "lungs-c-u2"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	safe_oxygen_min = 4 //You could literally be breathing the thinnest amount of oxygen and be fine
	safe_oxygen_max = 250 //Or be in an enriched oxygen room for that matter
	safe_toxins_max = 30
	safe_co2_max = 30
	SA_para_min = 30
	SA_sleep_min = 50
	BZ_trip_balls_min = 30
	emp_vulnerability = 3

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100
	maxHealth = 550

/obj/item/organ/lungs/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.losebreath += 20
		COOLDOWN_START(src, severe_cooldown, 30 SECONDS)
	if(prob(severity/emp_vulnerability)) //Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP //Starts organ faliure - gonna need replacing soon.

/obj/item/organ/lungs/ashwalker
	name = "ash lungs"
	desc = "blackened lungs identical from specimens recovered from lavaland, unsuited to higher air pressures."
	icon_state = "lungs-ll"
	safe_oxygen_min = 3	//able to handle much thinner oxygen, something something ash storm adaptation
	safe_oxygen_max = 18 // Air standard is 22kpA of O2, LL is 14kpA
	safe_nitro_max = 28 // Air standard is 82kpA of N2, LL is 23kpA

	cold_level_1_threshold = 280 // Ash Lizards can't take the cold very well, station air is only just warm enough
	cold_level_2_threshold = 240
	cold_level_3_threshold = 200

	heat_level_1_threshold = 400 // better adapted for heat, obv. Lavaland standard is 300
	heat_level_2_threshold = 600 // up 200 from level 1, 1000 is silly but w/e for level 3

/obj/item/organ/lungs/slime
	name = "vacuole"
	icon_state = "lungs-s"
	desc = "A large organelle designed to store oxygen and other important gasses."

	safe_toxins_max = 0 //We breathe this to gain POWER.

	cold_level_1_threshold = 285 // Remember when slimes used to be succeptable to cold? Well....
	cold_level_2_threshold = 260
	cold_level_3_threshold = 230

	maxHealth = 250

/obj/item/organ/lungs/slime/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	. = ..()
	if (breath)
		var/plasma_pp = breath.get_breath_partial_pressure(breath.get_moles(/datum/gas/plasma))
		owner.AddIntegrationBlood(0.2 * plasma_pp) // 10/s when breathing literally nothing but plasma, which will suffocate you.

/obj/item/organ/lungs/yamerol
	name = "Yamerol lungs"
	desc = "A temporary pair of lungs made from self assembling yamerol molecules."
	maxHealth = 200
	color = "#68e83a"

/obj/item/organ/lungs/yamerol/on_life()
	. = ..()
	if(.)
		applyOrganDamage(2) //Yamerol lungs are temporary
