
//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

/datum/reagent/medicine
	name = "Medicine"
	taste_description = "bitterness"
	value = REAGENT_VALUE_VERY_COMMON //Low prices, spess medical companies are cheapstakes and products are taxed honk...

/datum/reagent/medicine/on_mob_life(mob/living/carbon/M)
	current_cycle++
	holder.remove_reagent(type, metabolization_rate / M.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

/datum/reagent/medicine/leporazine
	name = "Leporazine"
	description = "Leporazine will effectively regulate a patient's body temperature, ensuring it never leaves safe levels."
	pH = 8.4
	color = "#82b8aa"
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/leporazine/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	else if(M.bodytemperature < (BODYTEMP_NORMAL + 1))
		M.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()

/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	description = "It's magic. We don't have to explain it."
	color = "#ffffff"
	can_synth = FALSE
	taste_description = "badmins"
	value = REAGENT_VALUE_GLORIOUS

// The best stuff there is. For testing/debugging.
/datum/reagent/medicine/adminordrazine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.adjustWater(round(chems.get_reagent_amount(type) * 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(type) * 1))
		mytray.adjustPests(-rand(1,5))
		mytray.adjustWeeds(-rand(1,5))
	if(chems.has_reagent(type, 3))
		switch(rand(100))
			if(66  to 100)
				mytray.mutatespecie()
			if(33	to 65)
				mytray.mutateweed()
			if(1   to 32)
				mytray.mutatepest(user)
			else if(prob(20))
				mytray.visible_message("<span class='warning'>Nothing happens...</span>")

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
	M.setCloneLoss(0, 0)
	M.setOxyLoss(0, 0)
	M.radiation = 0
	M.heal_bodypart_damage(5,5)
	M.adjustToxLoss(-5, 0, TRUE)
	M.hallucination = 0
	M.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
	REMOVE_TRAITS_NOT_IN(M, list(SPECIES_TRAIT, ROUNDSTART_TRAIT, ORGAN_TRAIT))
	M.set_blurriness(0)
	M.set_blindness(0)
	M.SetAllImmobility(0, 0)
	M.SetUnconscious(0, 0)
	M.silent = FALSE
	M.dizziness = 0
	M.disgust = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.slurring = 0
	M.confused = 0
	M.SetSleeping(0, 0)
	M.jitteriness = 0
	M.cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
	if(M.blood_volume < (BLOOD_VOLUME_NORMAL*M.blood_ratio))
		M.blood_volume = (BLOOD_VOLUME_NORMAL*M.blood_ratio)

	for(var/organ in M.internal_organs)
		var/obj/item/organ/O = organ
		O.setOrganDamage(0)

	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.severity == DISEASE_SEVERITY_POSITIVE)
			continue
		D.cure()
	..()
	. = 1

/datum/reagent/medicine/adminordrazine/quantum_heal
	name = "Quantum Medicine"
	description = "Rare and experimental particles, that apparently swap the user's body with one from an alternate dimension where it's completely healthy."
	taste_description = "science"

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	description = "Increases resistance to stuns as well as reducing drowsiness and hallucinations."
	color = "#FF00FF"
	pH = 4

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	M.AdjustAllImmobility(-20, 0)
	M.AdjustUnconscious(-20, 0)
	if(holder.has_reagent(/datum/reagent/toxin/mindbreaker))
		holder.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/medicine/synaphydramine
	name = "Diphen-Synaptizine"
	description = "Reduces drowsiness, hallucinations, and Histamine from body."
	color = "#EC536D" // rgb: 236, 83, 109
	pH = 5.2
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/synaphydramine/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(holder.has_reagent(/datum/reagent/toxin/mindbreaker))
		holder.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
	if(holder.has_reagent(/datum/reagent/toxin/histamine))
		holder.remove_reagent(/datum/reagent/toxin/histamine, 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	description = "Instantly restores all hearing to the patient, but does not cure deafness."
	color = "#6600FF" // rgb: 100, 165, 255
	pH = 2
	value = 10

/datum/reagent/medicine/inacusiate/on_mob_life(mob/living/carbon/M)
	M.restoreEars()
	..()

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the patient's body temperature must be under 270K for it to metabolise correctly."
	color = "#0000C8"
	taste_description = "sludge"
	pH = 11
	value = REAGENT_VALUE_COMMON

// Healing
/datum/reagent/medicine/cryoxadone/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	mytray.adjustHealth(round(chems.get_reagent_amount(type) * 3))
	mytray.adjustToxic(-round(chems.get_reagent_amount(type) * 3))

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/M)
	var/power = -0.00003 * (M.bodytemperature ** 2) + 3
	if(M.bodytemperature < T0C)
		M.adjustOxyLoss(-3 * power, 0)
		M.adjustBruteLoss(-power, 0)
		M.adjustFireLoss(-power, 0)
		M.adjustToxLoss(-power, 0, TRUE) //heals TOXINLOVERs
		M.adjustCloneLoss(-power, 0)
		for(var/i in M.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(power)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC) //fixes common causes for disfiguration
		. = 1
	metabolization_rate = REAGENTS_METABOLISM * (0.00001 * (M.bodytemperature ** 2) + 0.5)
	..()

/datum/reagent/medicine/clonexadone
	name = "Clonexadone"
	description = "A chemical that derives from Cryoxadone. It specializes in healing clone damage, but nothing else. Requires very cold temperatures to properly metabolize, and metabolizes quicker than cryoxadone."
	color = "#0000C8"
	taste_description = "muscle"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	pH = 13
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/clonexadone/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature < T0C)
		M.adjustCloneLoss(0.00006 * (M.bodytemperature ** 2) - 6, 0)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = 1
	metabolization_rate = REAGENTS_METABOLISM * (0.000015 * (M.bodytemperature ** 2) + 0.75)
	..()

/datum/reagent/medicine/pyroxadone
	name = "Pyroxadone"
	description = "A mixture of cryoxadone and slime jelly, that apparently inverses the requirement for its activation."
	color = "#f7832a"
	taste_description = "spicy jelly"
	pH = 12
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/medicine/pyroxadone/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		var/power = 0
		switch(M.bodytemperature)
			if(BODYTEMP_HEAT_DAMAGE_LIMIT to 400)
				power = 2
			if(400 to 460)
				power = 3
			else
				power = 5
		if(M.on_fire)
			power *= 2

		M.adjustOxyLoss(-2 * power, 0)
		M.adjustBruteLoss(-power, 0)
		M.adjustFireLoss(-1.5 * power, 0)
		M.adjustToxLoss(-power, 0, TRUE)
		M.adjustCloneLoss(-power, 0)
		for(var/i in M.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(power)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = 1
	..()

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	description = "A powder derived from fish toxin, Rezadone can effectively treat genetic damage as well as restoring minor wounds. Overdose will cause intense nausea and minor toxin damage."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30
	taste_description = "fish"
	pH = 12.2
	value = REAGENT_VALUE_RARE

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/carbon/M)
	M.setCloneLoss(0) //Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that.
	M.heal_bodypart_damage(1,1)
	REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
	..()
	. = 1

/datum/reagent/medicine/rezadone/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	M.Dizzy(5)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/medicine/rezadone/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	. = ..()
	if(iscarbon(M))
		var/mob/living/carbon/patient = M
		var/vol = reac_volume + M.reagents.get_reagent_amount(/datum/reagent/medicine/rezadone)
		if(vol >= 5 && HAS_TRAIT_FROM(patient, TRAIT_HUSK, "burn") && patient.getFireLoss() < THRESHOLD_UNHUSK) //One carp yields 12u rezadone.
			patient.cure_husk("burn")
			patient.visible_message("<span class='nicegreen'>[patient]'s body rapidly absorbs moisture from the enviroment, taking on a more healthy appearance.")

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	description = "Spaceacillin will prevent a patient from conventionally spreading any diseases they are currently infected with. Also reduces infection in serious burns."
	color = "#f2f2f2"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	pH = 8.1

//Goon Chems. Ported mainly from Goonstation. Easily mixable (or not so easily) and provide a variety of effects.
/datum/reagent/medicine/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	description = "If used in touch-based applications, immediately restores burn wounds as well as restoring more over time. It is mildly poisonous taken orally or by injection. If overdosed, deals brute and minor liver damage."
	reagent_state = LIQUID
	pH = 7.2
	color = "#ffeac9"
	metabolization_rate = 5 * REAGENTS_METABOLISM
	overdose_threshold = 50

/datum/reagent/medicine/silver_sulfadiazine/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/stack/medical/gauze/adv))
		var/obj/item/stack/medical/gauze/G = O
		reac_volume = min((reac_volume / 5), G.amount)
		new /obj/item/stack/medical/mesh/five(get_turf(G), reac_volume)
		G.use(reac_volume)

/datum/reagent/medicine/silver_sulfadiazine/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			M.adjustToxLoss(0.5*reac_volume)
			if(show_message)
				to_chat(M, "<span class='warning'>You don't feel so good...</span>")
		else if(M.getFireLoss())
			M.adjustFireLoss(-reac_volume)
			if(show_message)
				to_chat(M, "<span class='danger'>You feel your burns healing! It stings like hell!</span>")
			M.emote("scream")
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
	..()

/datum/reagent/medicine/silver_sulfadiazine/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-2*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/silver_sulfadiazine/overdose_start(mob/living/M)
	metabolization_rate = 15 * REAGENTS_METABOLISM
	..()
	. = 1

/datum/reagent/medicine/silver_sulfadiazine/overdose_process(mob/living/M)
	M.adjustFireLoss(2*REM, 0)
	var/obj/item/organ/liver/L = M.getorganslot(ORGAN_SLOT_LIVER)
	if(L)
		L.applyOrganDamage(1)
	..()
	. = 1

/datum/reagent/medicine/oxandrolone
	name = "Oxandrolone"
	description = "Stimulates the healing of severe burns. Extremely rapidly heals severe burns and slowly heals minor ones. Overdose will worsen existing burns."
	reagent_state = LIQUID
	color = "#f7ffa5"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25
	pH = 10.7
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/oxandrolone/on_mob_life(mob/living/carbon/M)
	if(M.getFireLoss() > 25)
		M.adjustFireLoss(-4*REM, 0) //Twice as effective as silver sulfadiazine for severe burns
	else
		M.adjustFireLoss(-0.5*REM, 0) //But only a quarter as effective for more minor ones
	..()
	. = 1

/datum/reagent/medicine/oxandrolone/overdose_process(mob/living/M)
	if(M.getFireLoss()) //It only makes existing burns worse
		M.adjustFireLoss(4.5*REM, 0) // it's going to be healing either 4 or 0.5
		. = 1
	..()

/datum/reagent/medicine/styptic_powder
	name = "Styptic Powder"
	description = "If used in touch-based applications, immediately restores bruising as well as restoring more over time. It is poisonous if taken orally or by injection. If overdosed, deals brute and minor liver damage."
	reagent_state = LIQUID
	color = "#FF9696"
	pH = 6.7
	metabolization_rate = 5 * REAGENTS_METABOLISM
	overdose_threshold = 50

/datum/reagent/medicine/styptic_powder/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			M.adjustToxLoss(0.5*reac_volume)
			if(show_message)
				to_chat(M, "<span class='warning'>You don't feel so good...</span>")
		else if(M.getBruteLoss())
			M.adjustBruteLoss(-reac_volume)
			if(show_message)
				to_chat(M, "<span class='danger'>You feel your bruises healing! It stings like hell!</span>")
			M.emote("scream")
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
	..()

/datum/reagent/medicine/styptic_powder/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/stack/medical/gauze/adv))
		var/obj/item/stack/medical/gauze/G = O
		reac_volume = min((reac_volume / 5), G.amount)
		new /obj/item/stack/medical/suture/five(get_turf(G), reac_volume)
		G.use(reac_volume)

/datum/reagent/medicine/styptic_powder/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-2*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/styptic_powder/overdose_start(mob/living/M)
	metabolization_rate = 15 * REAGENTS_METABOLISM
	..()
	. = 1

/datum/reagent/medicine/styptic_powder/overdose_process(mob/living/M)
	M.adjustBruteLoss(2*REM, 0)
	var/obj/item/organ/liver/L = M.getorganslot(ORGAN_SLOT_LIVER)
	if(L)
		L.applyOrganDamage(1)
	..()
	. = 1

/datum/reagent/medicine/salglu_solution
	name = "Saline-Glucose Solution"
	description = "Has a 33% chance per metabolism cycle to heal brute and burn damage. Can be used as a temporary blood substitute, as well as slowly speeding blood regeneration."
	reagent_state = LIQUID
	color = "#DCDCDC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	taste_description = "sweetness and salt"
	var/last_added = 0
	var/maximum_reachable = BLOOD_VOLUME_NORMAL - 10	//So that normal blood regeneration can continue with salglu active
	var/extra_regen = 0.25 // in addition to acting as temporary blood, also add this much to their actual blood per tick
	pH = 5.5

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/carbon/M)
	if((HAS_TRAIT(M, TRAIT_NOMARROW)))
		return
	if(last_added)
		M.integrating_blood -= min(M.integrating_blood, last_added)
		last_added = 0
	if(M.blood_volume < maximum_reachable)	//Can only up to double your effective blood level.
		last_added = volume * 5
		M.AddIntegrationBlood(last_added)
	if(prob(33))
		M.adjustBruteLoss(-0.5*REM, 0)
		M.adjustFireLoss(-0.5*REM, 0)
		. = TRUE
	..()

/datum/reagent/medicine/salglu_solution/overdose_process(mob/living/M)
	if(prob(3))
		to_chat(M, "<span class = 'warning'>You feel salty.</span>")
		holder.add_reagent(/datum/reagent/consumable/sodiumchloride, 1)
		holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	else if(prob(3))
		to_chat(M, "<span class = 'warning'>You feel sweet.</span>")
		holder.add_reagent(/datum/reagent/consumable/sugar, 1)
		holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	if(prob(33))
		M.adjustBruteLoss(0.5*REM, 0)
		M.adjustFireLoss(0.5*REM, 0)
		. = TRUE
	..()

/datum/reagent/medicine/mine_salve
	name = "Miner's Salve"
	description = "A powerful painkiller. Restores bruising and burns in addition to making the patient believe they are fully healed. Also great for treating severe burn wounds in a pinch."
	reagent_state = LIQUID
	color = "#6D6374"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	pH = 2.6
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/mine_salve/on_mob_life(mob/living/carbon/C)
	C.hal_screwyhud = SCREWYHUD_HEALTHY
	C.adjustBruteLoss(-0.25*REM, 0)
	C.adjustFireLoss(-0.25*REM, 0)
	C.adjustStaminaLoss(-0.5*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/mine_salve/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			M.adjust_nutrition(-5)
			if(show_message)
				to_chat(M, "<span class='warning'>Your stomach feels empty and cramps!</span>")
		else
			var/mob/living/carbon/C = M
			for(var/s in C.surgeries)
				var/datum/surgery/S = s
				S.success_multiplier = max(0.1, S.success_multiplier)
				// +10% success propability on each step, useful while operating in less-than-perfect conditions

			if(show_message)
				to_chat(M, "<span class='danger'>You feel your injuries fade away to nothing!</span>" )
	..()

/datum/reagent/medicine/mine_salve/on_mob_end_metabolize(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = SCREWYHUD_NONE
	..()

/datum/reagent/medicine/synthflesh
	name = "Synthflesh"
	description = "Has a 100% chance of healing large amounts of brute and burn damage very quickly. One unit of the chemical will heal one point of damage. Touch application only."
	reagent_state = LIQUID
	color = "#FFEBEB"
	pH = 11.5
	metabolization_rate = 5 * REAGENTS_METABOLISM
	overdose_threshold = 40
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/synthflesh/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(INGEST, VAPOR))
			C.losebreath++
			C.emote("cough")
			to_chat(M, "<span class='danger'>You feel your throat closing up!</span>")
		else if(method == INJECT)
			return
		else if(method in list(PATCH, TOUCH))
			M.adjustBruteLoss(-1 * reac_volume)
			M.adjustFireLoss(-1 * reac_volume)
			for(var/i in C.all_wounds)
				var/datum/wound/iter_wound = i
				iter_wound.on_synthflesh(reac_volume)
			if(show_message)
				to_chat(M, "<span class='danger'>You feel your burns and bruises healing! It stings like hell!</span>")
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
			var/vol = reac_volume + M.reagents.get_reagent_amount(/datum/reagent/medicine/synthflesh)
			//Has to be at less than THRESHOLD_UNHUSK burn damage and have 100 synthflesh before unhusking. Corpses dont metabolize.
			if(HAS_TRAIT_FROM(M, TRAIT_HUSK, "burn") && M.getFireLoss() < THRESHOLD_UNHUSK && (vol >= 100))
				M.cure_husk("burn")
				M.visible_message("<span class='nicegreen'>Most of [M]'s burnt off or charred flesh has been restored.")
	..()

/datum/reagent/medicine/synthflesh/overdose_start(mob/living/M)
	metabolization_rate = 15 * REAGENTS_METABOLISM

/datum/reagent/medicine/charcoal
	name = "Charcoal"
	description = "Heals toxin damage as well as slowly removing any other chemicals the patient has in their bloodstream."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "ash"
	pH = 5

/datum/reagent/medicine/charcoal/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-2*REM, 0)
	. = 1
	for(var/A in M.reagents.reagent_list)
		var/datum/reagent/R = A
		if(R != src)
			M.reagents.remove_reagent(R.type,1)
	..()

/datum/reagent/medicine/omnizine
	name = "Omnizine"
	description = "Slowly heals all damage types. Overdose will cause damage in all types instead."
	reagent_state = LIQUID
	color = "#DCDCDC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	pH = 2
	value = REAGENT_VALUE_UNCOMMON
	var/healing = 0.5

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-healing*REM, 0)
	M.adjustOxyLoss(-healing*REM, 0)
	M.adjustBruteLoss(-healing*REM, 0)
	M.adjustFireLoss(-healing*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/omnizine/overdose_process(mob/living/M)
	M.adjustToxLoss(1.5*REM, 0)
	M.adjustOxyLoss(1.5*REM, 0)
	M.adjustBruteLoss(1.5*REM, 0)
	M.adjustFireLoss(1.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/omnizine/protozine
	name = "Protozine"
	description = "A less environmentally friendly and somewhat weaker variant of omnizine."
	color = "#d8c7b7"
	healing = 0.2

/datum/reagent/medicine/calomel
	name = "Calomel"
	description = "Quickly purges the body of all chemicals. Toxin damage is dealt if the patient is in good condition."
	reagent_state = LIQUID
	color = "#19C832"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "acid"
	pH = 1.5

/datum/reagent/medicine/calomel/on_mob_life(mob/living/carbon/M)
	for(var/A in M.reagents.reagent_list)
		var/datum/reagent/R = A
		if(R != src)
			M.reagents.remove_reagent(R.type,2.5)
	if(M.health > 20)
		M.adjustToxLoss(2.5*REM, 0)
		. = 1
	..()

/datum/reagent/medicine/potass_iodide
	name = "Potassium Iodide"
	description = "Efficiently restores low radiation damage."
	reagent_state = LIQUID
	color = "#14FF3C"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	pH = 12 //It's a reducing agent

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/carbon/M)
	if(M.radiation > 0)
		M.radiation -= min(M.radiation, 8)
	..()

/datum/reagent/medicine/prussian_blue
	name = "Prussian Blue"
	description = "Efficiently restores heavy radiation damage."
	reagent_state = LIQUID
	color = "#003153" // RGB 0, 49, 83
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	pH = 8.9
	value = REAGENT_VALUE_COMMON //uncraftable

/datum/reagent/medicine/prussian_blue/on_mob_life(mob/living/carbon/M)
	if(M.radiation > 0)
		M.radiation -= min(M.radiation, 20)
	..()

/datum/reagent/medicine/pen_acid
	name = "Pentetic Acid"
	description = "Reduces massive amounts of radiation and toxin damage while purging other chemicals from the body."
	reagent_state = LIQUID
	color = "#E6FFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	pH = 1 //One of the best buffers, NEVERMIND!
	value = REAGENT_VALUE_UNCOMMON
	var/healtoxinlover = FALSE

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/carbon/M)
	M.radiation -= max(M.radiation-RAD_MOB_SAFE, 0)/50
	M.adjustToxLoss(-2*REM, 0, healtoxinlover)
	for(var/A in M.reagents.reagent_list)
		var/datum/reagent/R = A
		if(R != src)
			M.reagents.remove_reagent(R.type,2)
	..()
	. = 1

/datum/reagent/medicine/pen_acid/pen_jelly
	name = "Pentetic Jelly"
	description = "Reduces massive amounts of radiation and toxin damage while purging other chemicals from the body. Slimepeople friendly!"
	color = "#91D865"
	healtoxinlover = TRUE
	pH = 12//invert
	value = REAGENT_VALUE_RARE

/datum/reagent/medicine/sal_acid
	name = "Salicylic Acid"
	description = "Stimulates the healing of severe bruises. Extremely rapidly heals severe bruising and slowly heals minor ones. Overdose will worsen existing bruising."
	reagent_state = LIQUID
	color = "#D2D2D2"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25
	pH = 2.1
	value = REAGENT_VALUE_COMMON


/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() > 25)
		M.adjustBruteLoss(-4*REM, 0) //Twice as effective as styptic powder for severe bruising
	else
		M.adjustBruteLoss(-0.5*REM, 0) //But only a quarter as effective for more minor ones
	..()
	. = 1

/datum/reagent/medicine/sal_acid/overdose_process(mob/living/M)
	if(M.getBruteLoss()) //It only makes existing bruises worse
		M.adjustBruteLoss(4.5*REM, 0) // it's going to be healing either 4 or 0.5
		. = 1
	..()

/datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	description = "Rapidly restores oxygen deprivation as well as preventing more of it to an extent. Causes jittering."
	reagent_state = LIQUID
	color = "#00FFFF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	pH = 2

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-3*REM, 0)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/medicine/perfluorodecalin
	name = "Perfluorodecalin"
	description = "Extremely rapidly restores oxygen deprivation, but inhibits speech. May also heal small amounts of bruising and burns."
	reagent_state = LIQUID
	color = "#FF6464"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	pH = 11

/datum/reagent/medicine/perfluorodecalin/on_mob_life(mob/living/carbon/human/M)
	M.adjustOxyLoss(-12*REM, 0)
	M.silent = max(M.silent, 5)
	if(prob(33))
		M.adjustBruteLoss(-0.5*REM, 0)
		M.adjustFireLoss(-0.5*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	description = "Increases stun resistance. Overdose deals toxin damage and inhibits breathing."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 45
	addiction_threshold = 30
	pH = 12

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/carbon/M)
	M.AdjustAllImmobility(-20, FALSE)
	M.AdjustUnconscious(-20, FALSE)
	M.adjustStaminaLoss(-4.5*REM, FALSE)
	M.Jitter(10)
	if(prob(50))
		M.confused = max(M.confused, 1)
	..()
	return TRUE

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(0.5*REM, 0)
		M.losebreath++
		. = 1
	return TRUE

/datum/reagent/medicine/ephedrine/addiction_act_stage1(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(2*REM, 0)
		M.losebreath += 2
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage2(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(3*REM, 0)
		M.losebreath += 3
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage3(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(4*REM, 0)
		M.losebreath += 4
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage4(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(5*REM, 0)
		M.losebreath += 5
		. = 1
	..()

/datum/reagent/medicine/diphenhydramine
	name = "Diphenhydramine"
	description = "Rapidly purges the body of Histamine and reduces jitteriness. Slight chance of causing drowsiness."
	reagent_state = LIQUID
	color = "#64FFE6"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	pH = 11.5
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		M.drowsyness += 1
	M.jitteriness -= 1
	M.reagents.remove_reagent(/datum/reagent/toxin/histamine,3)
	..()

/datum/reagent/medicine/morphine
	name = "Morphine"
	description = "A painkiller that allows the patient to move at full speed even in bulky objects. Causes drowsiness and eventually unconsciousness in high doses. Overdose will cause a variety of effects, ranging from minor to lethal."
	reagent_state = LIQUID
	color = "#A9FBFB"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_threshold = 25
	pH = 8.96

/datum/reagent/medicine/morphine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_mod_immunities(type, list(/datum/movespeed_modifier/damage_slowdown, /datum/movespeed_modifier/damage_slowdown_flying, /datum/movespeed_modifier/monkey_health_speedmod))

/datum/reagent/medicine/morphine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_mod_immunities(type, list(/datum/movespeed_modifier/damage_slowdown, /datum/movespeed_modifier/damage_slowdown_flying, /datum/movespeed_modifier/monkey_health_speedmod))
	..()

/datum/reagent/medicine/morphine/on_mob_life(mob/living/carbon/M)
	switch(current_cycle)
		if(11)
			to_chat(M, "<span class='warning'>You start to feel tired...</span>" )
		if(12 to 24)
			M.drowsyness += 1
		if(24 to INFINITY)
			M.Sleeping(40, 0)
			. = 1
	..()

/datum/reagent/medicine/morphine/overdose_process(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.Dizzy(2)
		M.Jitter(2)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage1(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.Jitter(2)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage2(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(1*REM, 0)
		. = 1
		M.Dizzy(3)
		M.Jitter(3)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage3(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(2*REM, 0)
		. = 1
		M.Dizzy(4)
		M.Jitter(4)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage4(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(3*REM, 0)
		. = 1
		M.Dizzy(5)
		M.Jitter(5)
	..()

/datum/reagent/medicine/oculine
	name = "Oculine"
	description = "Quickly restores eye damage, cures nearsightedness, and has a chance to restore vision to the blind."
	reagent_state = LIQUID
	color = "#FFFFFF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "dull toxin"
	pH = 10

/datum/reagent/medicine/oculine/on_mob_life(mob/living/carbon/M)
	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	eyes.applyOrganDamage(-2)
	if(HAS_TRAIT_FROM(M, TRAIT_BLIND, EYE_DAMAGE))
		if(prob(20))
			to_chat(M, "<span class='warning'>Your vision slowly returns...</span>")
			M.cure_blind(EYE_DAMAGE)
			M.cure_nearsighted(EYE_DAMAGE)
			M.blur_eyes(35)

	else if(HAS_TRAIT_FROM(M, TRAIT_NEARSIGHT, EYE_DAMAGE))
		to_chat(M, "<span class='warning'>The blackness in your peripheral vision fades.</span>")
		M.cure_nearsighted(EYE_DAMAGE)
		M.blur_eyes(10)
	else if(M.eye_blind || M.eye_blurry)
		M.set_blindness(0)
		M.set_blurriness(0)
	..()

/datum/reagent/medicine/atropine
	name = "Atropine"
	description = "If a patient is in critical condition, rapidly heals all damage types as well as regulating oxygen in the body. Excellent for stabilizing wounded patients."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 35
	pH = 12
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/medicine/atropine/on_mob_life(mob/living/carbon/M)
	if(M.health < 0)
		M.adjustToxLoss(-2*REM, 0)
		M.adjustBruteLoss(-2*REM, 0)
		M.adjustFireLoss(-2*REM, 0)
		M.adjustOxyLoss(-5*REM, 0)
		. = 1
	M.losebreath = 0
	if(prob(20))
		M.Dizzy(5)
		M.Jitter(5)
	..()

/datum/reagent/medicine/atropine/overdose_process(mob/living/M)
	M.adjustToxLoss(0.5*REM, 0)
	. = 1
	M.Dizzy(1)
	M.Jitter(1)
	..()

/datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	description = "Minor boost to stun resistance. Slowly heals damage if a patient is in critical condition, as well as regulating oxygen loss. Overdose causes weakness and toxin damage."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	pH = 10.2

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/carbon/M)
	if(M.health < 0)
		M.adjustToxLoss(-0.5*REM, 0)
		M.adjustBruteLoss(-0.5*REM, 0)
		M.adjustFireLoss(-0.5*REM, 0)
	if(M.oxyloss > 35)
		M.setOxyLoss(35, 0)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	if(M.losebreath < 0)
		M.losebreath = 0
	M.adjustStaminaLoss(-0.5*REM, 0)
	. = 1
	if(prob(20))
		M.AdjustAllImmobility(-20, 0)
		M.AdjustUnconscious(-20, 0)
	..()

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM, 0)
		M.adjustToxLoss(1*REM, 0)
		M.losebreath++
		. = 1
	..()

/datum/reagent/medicine/strange_reagent
	name = "Strange Reagent"
	description = "A miracle drug capable of bringing the dead back to life. Only functions when applied by patch or spray, if the target has less than 100 brute and burn damage (independent of one another) and hasn't been husked. Causes slight damage to the living."
	reagent_state = LIQUID
	color = "#A0E85E"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "magnets"
	pH = 0
	value = REAGENT_VALUE_RARE

// FEED ME SEYMOUR
/datum/reagent/medicine/strange_reagent/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.spawnplant()

/datum/reagent/medicine/strange_reagent/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.stat == DEAD)
		if(M.suiciding || M.hellbound) //they are never coming back
			M.visible_message("<span class='warning'>[M]'s body does not react...</span>")
			return
		if(M.getBruteLoss() >= 100 || M.getFireLoss() >= 100 || HAS_TRAIT(M, TRAIT_HUSK)) //body is too damaged to be revived
			M.visible_message("<span class='warning'>[M]'s body convulses a bit, and then falls still once more.</span>")
			M.do_jitter_animation(10)
			return
		else
			M.visible_message("<span class='warning'>[M]'s body starts convulsing!</span>")
			M.notify_ghost_cloning(source = M)
			M.do_jitter_animation(10)
			addtimer(CALLBACK(M, /mob/living/carbon.proc/do_jitter_animation, 10), 40) //jitter immediately, then again after 4 and 8 seconds
			addtimer(CALLBACK(M, /mob/living/carbon.proc/do_jitter_animation, 10), 80)

			spawn(100) //so the ghost has time to re-enter
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(!(C.dna && C.dna.species && (NOBLOOD in C.dna.species.species_traits)))
						C.blood_volume = max(C.blood_volume, BLOOD_VOLUME_NORMAL*C.blood_ratio) //so you don't instantly re-die from a lack of blood
					for(var/organ in C.internal_organs)
						var/obj/item/organ/O = organ
						if(O.damage > O.maxHealth/2)
							O.setOrganDamage(O.maxHealth/2) //so you don't instantly die from organ damage when being revived

				M.adjustOxyLoss(-20, 0)
				M.adjustToxLoss(-20, 0)
				M.updatehealth()
				var/tplus = world.time - M.timeofdeath
				if(M.revive())
					M.grab_ghost()
					M.emote("gasp")
					log_combat(M, M, "revived", src)
					var/list/policies = CONFIG_GET(keyed_list/policyconfig)
					var/timelimit = CONFIG_GET(number/defib_cmd_time_limit) * 10 //the config is in seconds, not deciseconds
					var/late = timelimit && (tplus > timelimit)
					var/policy = late? policies[POLICYCONFIG_ON_DEFIB_LATE] : policies[POLICYCONFIG_ON_DEFIB_INTACT]
					if(policy)
						to_chat(M, policy)
					M.log_message("revived using strange reagent, [tplus] deciseconds from time of death, considered [late? "late" : "memory-intact"] revival under configured policy limits.", LOG_GAME)
	..()


/datum/reagent/medicine/strange_reagent/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(0.5*REM, 0)
	M.adjustFireLoss(0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/mannitol
	name = "Mannitol"
	description = "Efficiently restores brain damage."
	color = "#DCDCFF"
	pH = 10.4

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/carbon/C)
	C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -2*REM)
	if(prob(10))
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	..()

/datum/reagent/medicine/neurine
	name = "Neurine"
	description = "Reacts with neural tissue, helping reform damaged connections. Can cure minor traumas."
	color = "#EEFF8F"

/datum/reagent/medicine/neurine/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!(method == INJECT))
		return
	var/obj/item/organ/brain/B = M.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B || (!(B.organ_flags & ORGAN_FAILING)))
		return
	B.applyOrganDamage(-20)
	if(prob(80))
		B.gain_trauma_type(BRAIN_TRAUMA_MILD)
	else if(prob(50))
		B.gain_trauma_type(BRAIN_TRAUMA_SEVERE)
	else
		B.gain_trauma_type(BRAIN_TRAUMA_SPECIAL)


/datum/reagent/medicine/neurine/on_mob_life(mob/living/carbon/C)
	if(holder.has_reagent(/datum/reagent/consumable/ethanol/neurotoxin))
		holder.remove_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 5)
	if(prob(15))
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	..()

/datum/reagent/medicine/mutadone
	name = "Mutadone"
	description = "Removes jitteriness and restores genetic defects."
	color = "#5096C8"
	taste_description = "acid"
	pH = 2

/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/M)
	M.jitteriness = 0
	if(M.has_dna())
		M.dna.remove_all_mutations(mutadone = TRUE)
	if(!QDELETED(M)) //We were a monkey, now a human
		..()

/datum/reagent/medicine/antihol
	name = "Antihol"
	description = "Purges alcoholic substance from the patient's body and eliminates its side effects."
	color = "#00B4C8"
	taste_description = "raw egg"
	pH = 4

/datum/reagent/medicine/antihol/on_mob_life(mob/living/carbon/M)
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3*REM, 0, 1)
	M.adjustToxLoss(-0.2*REM, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.drunkenness = max(H.drunkenness - 10, 0)
	..()
	. = 1

/datum/reagent/medicine/stimulants
	name = "Stimulants"
	description = "Increases stun resistance and movement speed in addition to restoring minor damage and weakness. Overdose causes weakness and toxin damage."
	color = "#78008C"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	pH = 8.7
	value = REAGENT_VALUE_RARE

/datum/reagent/medicine/stimulants/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	ADD_TRAIT(L, TRAIT_TASED_RESISTANCE, type)

/datum/reagent/medicine/stimulants/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/stimulants)
	REMOVE_TRAIT(L, TRAIT_TASED_RESISTANCE, type)
	..()

/datum/reagent/medicine/stimulants/on_mob_life(mob/living/carbon/M)
	if(M.health < 50 && M.health > 0)
		M.adjustOxyLoss(-1*REM, FALSE)
		M.adjustToxLoss(-1*REM, FALSE)
		M.adjustBruteLoss(-1*REM, FALSE)
		M.adjustFireLoss(-1*REM, FALSE)
	M.AdjustAllImmobility(-60, FALSE)
	M.AdjustUnconscious(-60, FALSE)
	M.adjustStaminaLoss(-20*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/stimulants/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM, FALSE)
		M.adjustToxLoss(1*REM, FALSE)
		M.losebreath++
		. = 1
	..()

/datum/reagent/medicine/insulin
	name = "Insulin"
	description = "Increases sugar depletion rates."
	reagent_state = LIQUID
	color = "#FFFFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	pH = 6.7

/datum/reagent/medicine/insulin/on_mob_life(mob/living/carbon/M)
	if(M.AdjustSleeping(-20, FALSE))
		. = 1
	M.reagents.remove_reagent(/datum/reagent/consumable/sugar, 3)
	..()

//Trek Chems, used primarily by medibots. Only heals a specific damage type, but is very efficient.
/datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	description = "Restores bruising. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#fc2626"
	overdose_threshold = 30
	pH = 5

/datum/reagent/medicine/bicaridine/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-2*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/bicaridine/overdose_process(mob/living/M)
	M.adjustBruteLoss(4*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/dexalin
	name = "Dexalin"
	description = "Restores oxygen loss. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#13d2f0"
	overdose_threshold = 30
	pH = 9.7

/datum/reagent/medicine/dexalin/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-2*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/dexalin/overdose_process(mob/living/M)
	M.adjustOxyLoss(4*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/kelotane
	name = "Kelotane"
	description = "Restores fire damage. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#ffc400"
	overdose_threshold = 30
	pH = 9

/datum/reagent/medicine/kelotane/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-2*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/kelotane/overdose_process(mob/living/M)
	M.adjustFireLoss(4*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/antitoxin
	name = "Anti-Toxin"
	description = "Heals toxin damage and removes toxins in the bloodstream. Overdose causes toxin damage."
	reagent_state = LIQUID
	color = "#6aff00"
	overdose_threshold = 30
	taste_description = "a roll of gauze"
	pH = 10

/datum/reagent/medicine/antitoxin/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-2*REM, FALSE)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,1)
	..()
	. = 1

/datum/reagent/medicine/antitoxin/overdose_process(mob/living/M)
	M.adjustToxLoss(4*REM, FALSE) // End result is 2 toxin loss taken, because it heals 2 and then removes 4.
	..()
	. = 1

// Antitoxin binds plants pretty well. So the tox goes significantly down
/datum/reagent/medicine/antitoxin/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	mytray.adjustToxic(-round(chems.get_reagent_amount(type) * 2))

/datum/reagent/medicine/inaprovaline
	name = "Inaprovaline"
	description = "Stabilizes the breathing of patients. Good for those in critical condition."
	reagent_state = LIQUID
	pH = 8.5
	color = "#5dc1f0"

/datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/carbon/M)
	if(M.losebreath >= 5)
		M.losebreath -= 5
	..()

/datum/reagent/medicine/tricordrazine
	name = "Tricordrazine"
	description = "Has a high chance to heal all types of damage. Overdose instead causes it."
	reagent_state = LIQUID
	color = "#e650c0"
	overdose_threshold = 30
	taste_description = "grossness"

/datum/reagent/medicine/tricordrazine/on_mob_life(mob/living/carbon/M)
	if(prob(80))
		M.adjustBruteLoss(-1*REM, FALSE)
		M.adjustFireLoss(-1*REM, FALSE)
		M.adjustOxyLoss(-1*REM, FALSE)
		M.adjustToxLoss(-1*REM, FALSE)
		. = 1
	..()

/datum/reagent/medicine/tricordrazine/overdose_process(mob/living/M)
	M.adjustToxLoss(2*REM, FALSE)
	M.adjustOxyLoss(2*REM, FALSE)
	M.adjustBruteLoss(2*REM, FALSE)
	M.adjustFireLoss(2*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/regen_jelly
	name = "Regenerative Jelly"
	description = "Gradually regenerates all types of damage, without harming slime anatomy."
	reagent_state = LIQUID
	color = "#91D865"
	taste_description = "jelly"
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/regen_jelly/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-1.5*REM, FALSE)
	M.adjustFireLoss(-1.5*REM, FALSE)
	M.adjustOxyLoss(-1.5*REM, FALSE)
	M.adjustToxLoss(-1.5*REM, 0, TRUE) //heals TOXINLOVERs
	. = 1
	..()

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	description = "Miniature medical robots that swiftly restore bodily damage."
	reagent_state = SOLID
	color = "#555555"
	pH = 11
	value = REAGENT_VALUE_EXCEPTIONAL

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-5*REM, FALSE) //A ton of healing - this is a 50 telecrystal investment.
	M.adjustFireLoss(-5*REM, FALSE)
	M.adjustOxyLoss(-15, FALSE)
	M.adjustToxLoss(-5*REM, FALSE)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -15*REM)
	M.adjustCloneLoss(-3*REM, FALSE)
	M.adjustStaminaLoss(-25*REM,FALSE)
	if(M.blood_volume < (BLOOD_VOLUME_NORMAL*M.blood_ratio))
		M.AddIntegrationBlood(40) // blood fall out man bad
	..()
	. = 1

/datum/reagent/medicine/lesser_syndicate_nanites // the one in the injector
	name = "Regenerative Nanites"
	description = "Miniature medical robots that restore damage and get operatives back in the fight."
	reagent_state = SOLID
	color = "#555555"
	pH = 11
	value = REAGENT_VALUE_VERY_RARE

/datum/reagent/medicine/lesser_syndicate_nanites/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-2*REM, FALSE)
	M.adjustFireLoss(-2*REM, FALSE)
	M.adjustOxyLoss(-5*REM, FALSE)
	M.adjustToxLoss(-2*REM, FALSE)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -5*REM)
	M.adjustCloneLoss(-1.25*REM, FALSE)
	M.adjustStaminaLoss(-4*REM,FALSE)
	if(M.blood_volume < (BLOOD_VOLUME_NORMAL*M.blood_ratio))
		M.AddIntegrationBlood(3)
	..()
	. = 1

/datum/reagent/medicine/neo_jelly
	name = "Neo Jelly"
	description = "Gradually regenerates all types of damage, without harming slime anatomy.Can OD"
	reagent_state = LIQUID
	metabolization_rate = 1 * REAGENTS_METABOLISM
	color = "#91D865"
	overdose_threshold = 30
	taste_description = "jelly"
	pH = 11.8
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/medicine/neo_jelly/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-1.5*REM, FALSE)
	M.adjustFireLoss(-1.5*REM, FALSE)
	M.adjustOxyLoss(-1.5*REM, FALSE)
	M.adjustToxLoss(-1.5*REM, 0, TRUE) //heals TOXINLOVERs
	. = 1
	..()

/datum/reagent/medicine/neo_jelly/overdose_process(mob/living/M)
	M.adjustOxyLoss(2.6*REM, FALSE)
	M.adjustBruteLoss(3.5*REM, FALSE)
	M.adjustFireLoss(3.5*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Earthsblood"
	description = "Ichor from an extremely powerful plant. Great for restoring wounds, but it's a little heavy on the brain."
	color = rgb(255, 175, 0)
	overdose_threshold = 25
	pH = 11
	value = REAGENT_VALUE_COMMON //not any higher. Ambrosia is a milestone for hydroponics already.


//Earthsblood is still a wonderdrug. Just... don't expect to be able to mutate something that makes plants so healthy.
/datum/reagent/medicine/earthsblood/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjustHealth(round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjustPests(-rand(1,3))
		mytray.adjustWeeds (-rand(1,3))
		if(myseed)
			myseed.adjust_instability(-round(chems.get_reagent_amount(src.type) * 1.3))
			myseed.adjust_potency(round(chems.get_reagent_amount(src.type) *1))
			myseed.adjust_yield(round(chems.get_reagent_amount(src.type) * 1))
			myseed.adjust_endurance(round(chems.get_reagent_amount(src.type) * 0.5))
			myseed.adjust_production(-round(chems.get_reagent_amount(src.type) * 0.5))

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-3 * REM, FALSE)
	M.adjustFireLoss(-3 * REM, FALSE)
	M.adjustOxyLoss(-15 * REM, FALSE)
	M.adjustToxLoss(-3 * REM, FALSE, TRUE) //Heals TOXINLOVERS
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM, 150) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	M.adjustCloneLoss(-1 * REM, FALSE)
	M.adjustStaminaLoss(-13 * REM, FALSE)
	M.jitteriness = min(max(0, M.jitteriness + 3), 30)
	M.druggy = min(max(0, M.druggy + 10), 15) //See above
	..()
	. = 1

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/M)
	M.hallucination = min(max(0, M.hallucination + 5), 60)
	M.adjustToxLoss(8 * REM, FALSE, TRUE) //Hurts TOXINLOVERS
	..()
	. = 1

/datum/reagent/medicine/haloperidol
	name = "Haloperidol"
	description = "Increases depletion rates for most stimulating/hallucinogenic drugs. Reduces druggy effects and jitteriness. Severe stamina regeneration penalty, causes drowsiness. Small chance of brain damage."
	reagent_state = LIQUID
	color = "#27870a"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	pH = 4.3
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/drug/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,5)
	M.drowsyness += 2
	if(M.jitteriness >= 3)
		M.jitteriness -= 3
	if (M.hallucination >= 5)
		M.hallucination -= 5
	if(prob(20))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1*REM, 50)
	M.adjustStaminaLoss(2.5*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/lavaland_extract
	name = "Lavaland Extract"
	description = "An extract of lavaland atmospheric and mineral elements. Heals the user in small doses, but is extremely toxic otherwise."
	color = "#a1a1a1"
	overdose_threshold = 3 //To prevent people stacking massive amounts of a very strong healing reagent
	can_synth = FALSE
	pH = 14
	value = REAGENT_VALUE_AMAZING

/datum/reagent/medicine/lavaland_extract/on_mob_life(mob/living/carbon/M)
	M.heal_bodypart_damage(5,5)
	..()
	return TRUE

/datum/reagent/medicine/lavaland_extract/overdose_process(mob/living/M)
	M.adjustBruteLoss(3*REM, 0)
	M.adjustFireLoss(3*REM, 0)
	M.adjustToxLoss(3*REM, 0)
	..()
	return TRUE

//used for changeling's adrenaline power
/datum/reagent/medicine/changelingadrenaline
	name = "Changeling Adrenaline"
	description = "Reduces the duration of unconciousness, knockdown and stuns. Restores stamina, but deals toxin damage when overdosed."
	color = "#918e53"
	overdose_threshold = 30
	value = REAGENT_VALUE_VERY_RARE

/datum/reagent/medicine/changelingadrenaline/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_TASED_RESISTANCE, type)

/datum/reagent/medicine/changelingadrenaline/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_TASED_RESISTANCE, type)
	..()

/datum/reagent/medicine/changelingadrenaline/on_mob_life(mob/living/carbon/M as mob)
	M.AdjustUnconscious(-20, 0)
	M.AdjustAllImmobility(-20, 0)
	M.AdjustSleeping(-20, 0)
	M.adjustStaminaLoss(-30, 0)
	..()
	return TRUE

/datum/reagent/medicine/changelingadrenaline/overdose_process(mob/living/M as mob)
	M.adjustToxLoss(5, 0) //let's make this mildly more toxic because of the stamina buff
	..()
	return TRUE

/datum/reagent/medicine/changelinghaste
	name = "Changeling Haste"
	description = "Drastically increases movement speed, but deals toxin damage."
	color = "#669153"
	metabolization_rate = 1
	value = REAGENT_VALUE_VERY_RARE

/datum/reagent/medicine/changelinghaste/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)

/datum/reagent/medicine/changelinghaste/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/changelinghaste)
	..()

/datum/reagent/medicine/changelinghaste/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(2, 0)
	..()
	return TRUE

/datum/reagent/medicine/corazone
	// Heart attack code will not do damage if corazone is present
	// because it's SPACE MAGIC ASPIRIN
	name = "Corazone"
	description = "A medication used to treat pain, fever, and inflammation, along with heart attacks."
	color = "#F5F5F5"
	self_consuming = TRUE
	pH = 12.5

/datum/reagent/medicine/corazone/on_mob_metabolize(mob/living/M)
	..()
	ADD_TRAIT(M, TRAIT_STABLEHEART, type)
	ADD_TRAIT(M, TRAIT_STABLELIVER, type)

/datum/reagent/medicine/corazone/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_STABLEHEART, type)
	REMOVE_TRAIT(M, TRAIT_STABLELIVER, type)
	..()

/datum/reagent/medicine/muscle_stimulant
	name = "Muscle Stimulant"
	description = "A potent chemical that allows someone under its influence to be at full physical ability even when under massive amounts of pain."
	value = REAGENT_VALUE_RARE

/datum/reagent/medicine/muscle_stimulant/on_mob_metabolize(mob/living/M)
	. = ..()
	M.add_movespeed_mod_immunities(type, list(/datum/movespeed_modifier/damage_slowdown, /datum/movespeed_modifier/damage_slowdown_flying, /datum/movespeed_modifier/monkey_health_speedmod))

/datum/reagent/medicine/muscle_stimulant/on_mob_end_metabolize(mob/living/M)
	. = ..()
	M.remove_movespeed_mod_immunities(type, list(/datum/movespeed_modifier/damage_slowdown, /datum/movespeed_modifier/damage_slowdown_flying, /datum/movespeed_modifier/monkey_health_speedmod))

/datum/reagent/medicine/modafinil
	name = "Modafinil"
	description = "Long-lasting sleep suppressant that very slightly reduces stun and knockdown times. Overdosing has horrendous side effects and deals lethal oxygen damage, will knock you unconscious if not dealt with."
	reagent_state = LIQUID
	color = "#BEF7D8" // palish blue white
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 20 // with the random effects this might be awesome or might kill you at less than 10u (extensively tested)
	taste_description = "salt" // it actually does taste salty
	value = REAGENT_VALUE_RARE
	var/overdose_progress = 0 // to track overdose progress
	pH = 7.89

/datum/reagent/medicine/modafinil/on_mob_metabolize(mob/living/M)
	ADD_TRAIT(M, TRAIT_SLEEPIMMUNE, type)
	..()

/datum/reagent/medicine/modafinil/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_SLEEPIMMUNE, type)
	..()

/datum/reagent/medicine/modafinil/on_mob_life(mob/living/carbon/M)
	if(!overdosed) // We do not want any effects on OD
		overdose_threshold = overdose_threshold + rand(-10,10)/10 // for extra fun
		M.AdjustAllImmobility(-5, 0)
		M.AdjustUnconscious(-5, 0)
		M.adjustStaminaLoss(-1*REM, 0)
		M.Jitter(1)
		metabolization_rate = 0.01 * REAGENTS_METABOLISM * rand(5,20) // randomizes metabolism between 0.02 and 0.08 per tick
		. = TRUE
	..()

/datum/reagent/medicine/modafinil/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You feel awfully out of breath and jittery!</span>")
	metabolization_rate = 0.025 * REAGENTS_METABOLISM // sets metabolism to 0.01 per tick on overdose

/datum/reagent/medicine/modafinil/overdose_process(mob/living/M)
	overdose_progress++
	switch(overdose_progress)
		if(1 to 40)
			M.jitteriness = min(M.jitteriness+1, 10)
			M.stuttering = min(M.stuttering+1, 10)
			M.Dizzy(5)
			if(prob(50))
				M.losebreath++
		if(41 to 80)
			M.adjustOxyLoss(0.1*REM, 0)
			M.adjustStaminaLoss(0.1*REM, 0)
			M.jitteriness = min(M.jitteriness+1, 20)
			M.stuttering = min(M.stuttering+1, 20)
			M.Dizzy(10)
			if(prob(50))
				M.losebreath++
			if(prob(20))
				to_chat(M, "You have a sudden fit!")
				M.emote("moan")
				M.DefaultCombatKnockdown(20, 1, 0) // you should be in a bad spot at this point unless epipen has been used
		if(81)
			to_chat(M, "You feel too exhausted to continue!") // at this point you will eventually die unless you get charcoal
			M.adjustOxyLoss(0.1*REM, 0)
			M.adjustStaminaLoss(0.1*REM, 0)
		if(82 to INFINITY)
			M.Sleeping(100, 0, TRUE)
			M.adjustOxyLoss(1.5*REM, 0)
			M.adjustStaminaLoss(1.5*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/psicodine
	name = "Psicodine"
	description = "Suppresses anxiety and other various forms of mental distress. Overdose causes hallucinations and minor toxin damage."
	reagent_state = LIQUID
	color = "#07E79E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	pH = 9.12
	value = REAGENT_VALUE_COMMON

/datum/reagent/medicine/psicodine/on_mob_add(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)

/datum/reagent/medicine/psicodine/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	..()

/datum/reagent/medicine/psicodine/on_mob_life(mob/living/carbon/M)
	M.jitteriness = max(0, M.jitteriness-6)
	M.dizziness = max(0, M.dizziness-6)
	M.confused = max(0, M.confused-6)
	M.disgust = max(0, M.disgust-6)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	if(mood.sanity <= SANITY_NEUTRAL) // only take effect if in negative sanity and then...
		mood.setSanity(min(mood.sanity+5, SANITY_NEUTRAL)) // set minimum to prevent unwanted spiking over neutral
	..()
	. = 1

/datum/reagent/medicine/psicodine/overdose_process(mob/living/M)
	M.hallucination = min(max(0, M.hallucination + 5), 60)
	M.adjustToxLoss(1, 0)
	..()
	. = 1

/datum/reagent/medicine/silibinin
	name = "Silibinin"
	description = "A thistle derrived hepatoprotective flavolignan mixture that help reverse damage to the liver."
	reagent_state = SOLID
	color = "#FFFFD0"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	value = REAGENT_VALUE_UNCOMMON

/datum/reagent/medicine/silibinin/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, -2)//Add a chance to cure liver trauma once implemented.
	..()
	. = 1

/datum/reagent/medicine/polypyr  //This is intended to be an ingredient in advanced chems.
	name = "Polypyrylium Oligomers"
	description = "A purple mixture of short polyelectrolyte chains not easily synthesized in the laboratory. It is valued as an intermediate in the synthesis of the cutting edge pharmaceuticals."
	reagent_state = SOLID
	color = "#9423FF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 50
	taste_description = "numbing bitterness"
	value = REAGENT_VALUE_RARE

/datum/reagent/medicine/polypyr/on_mob_life(mob/living/carbon/M) //I wanted a collection of small positive effects, this is as hard to obtain as coniine after all.
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.25)
	M.adjustBruteLoss(-0.35, 0)
	..()
	. = 1

/datum/reagent/medicine/polypyr/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M) && reac_volume >= 0.5)
			var/mob/living/carbon/human/H = M
			H.hair_color = "92f"
			H.facial_hair_color = "92f"
			H.update_hair()

/datum/reagent/medicine/polypyr/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5)
	..()
	. = 1

/datum/reagent/medicine/liquid_wisdom
	name = "liquid wisdom"
	description = "the physical representation of wisdom, in liquid form"
	taste_mult = 4
	can_synth = FALSE
	overdose_threshold = 30
	value = REAGENT_VALUE_UNCOMMON // while it's 'rare', it can be milked from the wisdom cow

/datum/reagent/medicine/liquid_wisdom/on_mob_life(mob/living/carbon/C) //slightly stronger mannitol, from the wisdom cow
	C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3*REM)
	if(prob(20))
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	if(prob(3))
		to_chat(C, "[pick(GLOB.wisdoms)]") //give them a random wisdom
	..()

// helps bleeding wounds clot faster
/datum/reagent/medicine/coagulant
	name = "Sanguirite"
	description = "A proprietary coagulant used to help bleeding wounds clot faster."
	reagent_state = LIQUID
	color = "#bb2424"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 20
	/// How much base clotting we do per bleeding wound, multiplied by the below number for each bleeding wound
	var/clot_rate = 0.25
	/// If we have multiple bleeding wounds, we count the number of bleeding wounds, then multiply the clot rate by this^(n) before applying it to each cut, so more cuts = less clotting per cut (though still more total clotting)
	var/clot_coeff_per_wound = 0.9

/datum/reagent/medicine/coagulant/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(!M.blood_volume || !M.all_wounds)
		return

	var/effective_clot_rate = clot_rate

	for(var/i in M.all_wounds)
		var/datum/wound/iter_wound = i
		if(iter_wound.blood_flow)
			effective_clot_rate *= clot_coeff_per_wound

	for(var/i in M.all_wounds)
		var/datum/wound/iter_wound = i
		iter_wound.blood_flow = max(0, iter_wound.blood_flow - effective_clot_rate)

/datum/reagent/medicine/coagulant/overdose_process(mob/living/M)
	. = ..()
	if(!M.blood_volume)
		return

	if(prob(15))
		M.losebreath += rand(2,4)
		M.adjustOxyLoss(rand(1,3))
		if(prob(30))
			to_chat(M, "<span class='danger'>You can feel your blood clotting up in your veins!</span>")
		else if(prob(10))
			to_chat(M, "<span class='userdanger'>You feel like your blood has stopped moving!</span>")
		if(prob(50))
			var/obj/item/organ/lungs/our_lungs = M.getorganslot(ORGAN_SLOT_LUNGS)
			our_lungs.applyOrganDamage(1)
		else
			var/obj/item/organ/heart/our_heart = M.getorganslot(ORGAN_SLOT_HEART)
			our_heart.applyOrganDamage(1)

// can be synthesized on station rather than bought. made by grinding a banana peel, heating it up, then mixing the banana peel powder with salglu
/datum/reagent/medicine/coagulant/weak
	name = "Synthi-Sanguirite"
	description = "A synthetic coagulant used to help bleeding wounds clot faster. Not quite as effective as name brand Sanguirite, especially on patients with lots of cuts."
	clot_coeff_per_wound = 0.8

//Sloowly heals system corruption in robotic organisms. Causes mild toxins damage in nonrobots.
/datum/reagent/medicine/system_cleaner
	name = "System Cleaner"
	description = "A reagent with special properties causing it to slowly reduce corruption in robots. Mildly toxic for organics."
	reagent_state = LIQUID
	color = "#D7C9C6"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/system_cleaner/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(HAS_TRAIT(M, TRAIT_ROBOTIC_ORGANISM))
		M.adjustToxLoss(-0.2, toxins_type = TOX_SYSCORRUPT)
	else
		M.adjustToxLoss(0.5)

/datum/reagent/medicine/system_cleaner/overdose_process(mob/living/carbon/M)
	. = ..()
	if(HAS_TRAIT(M, TRAIT_ROBOTIC_ORGANISM))
		M.adjustToxLoss(0.4, toxins_type = TOX_SYSCORRUPT) //inverts its positive effect on overdose, for organics it's just more toxic
	else
		M.adjustToxLoss(0.5)
