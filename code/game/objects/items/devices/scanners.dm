
/*

CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
SLIME SCANNER
NANITE SCANNER
GENETICS SCANNER

*/

// Describes the three modes of scanning available for health analyzers
#define SCANMODE_HEALTH		0
#define SCANMODE_CHEMICAL 	1
#define SCANMODE_WOUND	 	2
#define SCANNER_CONDENSED 	0
#define SCANNER_VERBOSE 	1

/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	custom_price = PRICE_REALLY_CHEAP
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = FALSE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=150)

/obj/item/t_scanner/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to emit terahertz-rays into [user.p_their()] brain with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS

/obj/item/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = copytext_char(icon_state, 1, -1) + "[on]"

	if(on)
		START_PROCESSING(SSobj, src)

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/proc/t_ray_scan(mob/viewer, flick_time = 8, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(distance, viewer) )
		if(O.level != 1)
			continue

		if(O.invisibility == INVISIBILITY_MAXIMUM)
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I
	if(t_ray_images.len)
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)
	var/mode = 1
	var/scanmode = SCANMODE_HEALTH
	var/advanced = FALSE

/obj/item/healthanalyzer/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!</span>")
	return BRUTELOSS

/obj/item/healthanalyzer/attack_self(mob/user)
	scanmode = (scanmode + 1) % 3
	switch(scanmode)
		if(SCANMODE_HEALTH)
			to_chat(user, "<span class='notice'>You switch the health analyzer to check physical health.</span>")
		if(SCANMODE_CHEMICAL)
			to_chat(user, "<span class='notice'>You switch the health analyzer to scan chemical contents.</span>")
		if(SCANMODE_WOUND)
			to_chat(user, "<span class='notice'>You switch the health analyzer to report extra info on wounds.</span>")

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
	flick("[icon_state]-scan", src)	//makes it so that it plays the scan animation upon scanning, including clumsy scanning

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		user.visible_message("<span class='warning'>[user] analyzes the floor's vitals!</span>", \
							"<span class='notice'>You stupidly try to analyze the floor's vitals!</span>")
		to_chat(user, "<span class='info'>Analyzing results for The floor:\n\tOverall status: <b>Healthy</b></span>\
					 \n<span class='info'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>\
					 \n<span class='info'>\tDamage specifics: <font color='blue'>0</font>-<font color='green'>0</font>-<font color='#FF8000'>0</font>-<font color='red'>0</font></span>\
					 \n<span class='info'>Body temperature: ???</span>")
		return

	user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", \
						"<span class='notice'>You analyze [M]'s vitals.</span>")

	if(scanmode == SCANMODE_HEALTH)
		healthscan(user, M, mode, advanced)
	else if(scanmode == SCANMODE_CHEMICAL)
		chemscan(user, M)
	else
		woundscan(user, M, src)

	add_fingerprint(user)

// Used by the PDA medical scanner too
/proc/healthscan(mob/user, mob/living/M, mode = 1, advanced = FALSE)
	if(isliving(user) && (user.incapacitated() || user.eye_blind))
		return
	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()
	var/mob_status = (M.stat == DEAD ? "<span class='alert'><b>Deceased</b></span>" : "<b>[round(M.health/M.maxHealth,0.01)*100] % healthy</b>")

	if(HAS_TRAIT(M, TRAIT_FAKEDEATH) && !advanced)
		mob_status = "<span class='alert'><b>Deceased</b></span>"
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	var/msg = "<span class='info'>*---------*\nAnalyzing results for [M]:\n\tOverall status: [mob_status]"

	// Damage descriptions
	if(brute_loss > 10)
		msg += "\n\t<span class='alert'>[brute_loss > 50 ? "Severe" : "Minor"] tissue damage detected.</span>"
	if(fire_loss > 10)
		msg += "\n\t<span class='alert'>[fire_loss > 50 ? "Severe" : "Minor"] burn damage detected.</span>"
	if(oxy_loss > 10)
		msg += "\n\t<span class='info'><span class='alert'>[oxy_loss > 50 ? "Severe" : "Minor"] oxygen deprivation detected.</span>"
	if(tox_loss > 10)
		msg += "\n\t<span class='alert'>[tox_loss > 50 ? "Severe" : "Minor"] amount of [HAS_TRAIT(M, TRAIT_ROBOTIC_ORGANISM) ? "system corruption" : "toxin damage"] detected.</span>"
	if(M.getStaminaLoss())
		msg += "\n\t<span class='alert'>Subject appears to be suffering from fatigue.</span>"
		if(advanced)
			msg += "\n\t<span class='info'>Fatigue Level: [M.getStaminaLoss()]%.</span>"
	if (M.getCloneLoss())
		msg += "\n\t<span class='alert'>Subject appears to have [M.getCloneLoss() > 30 ? "Severe" : "Minor"] cellular damage.</span>"
		if(advanced)
			msg += "\n\t<span class='info'>Cellular Damage Level: [M.getCloneLoss()].</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(advanced && H.has_dna())
			msg += "\n\t<span class='info'>Genetic Stability: [H.dna.stability]%.</span>"

	to_chat(user, msg)
	msg = ""

	// Body part damage report
	var/list/dmgreport = list()
	if(iscarbon(M) && mode == 1)
		var/mob/living/carbon/C = M
		var/list/damaged = C.get_damaged_bodyparts(1,1)
		if(length(damaged)>0 || oxy_loss>0 || tox_loss>0 || fire_loss>0)
			dmgreport += "<table style='margin-left:33px'><tr><font face='Verdana'>\
							<td style='width: 90px;'><font color='#0000CC'>Damage:</font></td>\
							<td style='width: 55px;'><font color='red'><b>Brute</b></font></td>\
							<td style='width: 45px;'><font color='orange'><b>Burn</b></font></td>\
							<td style='width: 45px;'><font color='green'><b>[HAS_TRAIT(C, TRAIT_ROBOTIC_ORGANISM) ? "Corruption" :"Toxin"]</b></font></td>\
							<td style='width: 90px;'><font color='purple'><b>Suffocation</b></font></td></tr>\
							<tr><td><font color='#0000CC'>Overall:</font></td>\
							<td><font color='red'>[brute_loss]</font></td>\
							<td><font color='orange'>[fire_loss]</font></td>\
							<td><font color='green'>[tox_loss]</font></td>\
							<td><font color='purple'>[oxy_loss]</font></td></tr>"

			for(var/o in damaged)
				var/obj/item/bodypart/org = o //head, left arm, right arm, etc.
				dmgreport += "<tr><td><font color='#0000CC'>[capitalize(org.name)]:</font></td>\
								<td><font color='red'>[(org.brute_dam > 0) ? "[org.brute_dam]" : "0"]</font></td>\
								<td><font color='orange'>[(org.burn_dam > 0) ? "[org.burn_dam]" : "0"]</font></td></tr>"
			dmgreport += "</table>"
			to_chat(user, dmgreport.Join())


	//Organ damages report
	var/heart_ded = FALSE
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/mob/living/carbon/human/H = M
		for(var/organ in C.internal_organs)
			var/temp_message
			var/damage_message
			var/obj/item/organ/O = organ

			//EYES
			if(istype(O, /obj/item/organ/eyes))
				var/obj/item/organ/eyes/eyes = O
				if(advanced)
					if(HAS_TRAIT(C, TRAIT_BLIND))
						temp_message += " <span class='alert'>Subject is blind.</span>"
					if(HAS_TRAIT(C, TRAIT_NEARSIGHT))
						temp_message += " <span class='alert'>Subject is nearsighted.</span>"
					if(eyes.damage > 30)
						damage_message += " <span class='alert'>Subject has severe eye damage.</span>"
					else if(eyes.damage > 20)
						damage_message += " <span class='alert'>Subject has significant eye damage.</span>"
					else if(eyes.damage)
						damage_message += " <span class='alert'>Subject has minor eye damage.</span>"


			//EARS
			else if(istype(O, /obj/item/organ/ears))
				var/obj/item/organ/ears/ears = O
				if(advanced)
					if(HAS_TRAIT_FROM(C, TRAIT_DEAF, GENETIC_MUTATION))
						temp_message += " <span class='alert'>Subject is genetically deaf.</span>"
					else if(HAS_TRAIT(C, TRAIT_DEAF))
						temp_message += " <span class='alert'>Subject is deaf.</span>"
					else
						if(ears.damage)
							damage_message += " <span class='alert'>Subject has [ears.damage > ears.maxHealth ? "permanent ": "temporary "]hearing damage.</span>"
						if(ears.deaf)
							damage_message += " <span class='alert'>Subject is [ears.damage > ears.maxHealth ? "permanently ": "temporarily "] deaf.</span>"


			//BRAIN
			else if(istype(O, /obj/item/organ/brain))
				if (C.getOrganLoss(ORGAN_SLOT_BRAIN) >= 200)
					damage_message += " <span class='alert'>Subject's brain non-functional. Neurine injection recomended.</span>"
				else if (C.getOrganLoss(ORGAN_SLOT_BRAIN) >= 120)
					damage_message += " <span class='alert'>Severe brain damage detected. Subject likely to have mental traumas.</span>"
				else if (C.getOrganLoss(ORGAN_SLOT_BRAIN) >= 45)
					damage_message += " <span class='alert'>Brain damage detected.</span>"
				if(advanced)
					temp_message += " <span class='info'>Brain Activity Level: [(200 - M.getOrganLoss(ORGAN_SLOT_BRAIN))/2]%.</span>"

				//TRAUMAS
				if(LAZYLEN(C.get_traumas()))
					var/list/trauma_text = list()
					for(var/datum/brain_trauma/B in C.get_traumas())
						var/trauma_desc = ""
						switch(B.resilience)
							if(TRAUMA_RESILIENCE_SURGERY)
								trauma_desc += "severe "
							if(TRAUMA_RESILIENCE_LOBOTOMY)
								trauma_desc += "deep-rooted "
							if(TRAUMA_RESILIENCE_MAGIC, TRAUMA_RESILIENCE_ABSOLUTE)
								trauma_desc += "permanent "
						trauma_desc += B.scan_desc
						trauma_text += trauma_desc
					temp_message += " <span class='alert'>Cerebral traumas detected: subject appears to be suffering from [english_list(trauma_text)].</span>"
				if(C.roundstart_quirks.len)
					temp_message += " <span class='info'>Subject has the following physiological traits: [C.get_trait_string()].</span>"

				if(ishuman(C) && advanced)
					//MON PETIT CHAUFFEUR
					if(H.hallucinating())
						temp_message += " <span class='info'>Subject is hallucinating.</span>"

					//MKUltra
					if(H.has_status_effect(/datum/status_effect/chem/enthrall))
						temp_message += " <span class='info'>Subject has abnormal brain fuctions.</span>"

					//Astrogen shenanigans
					if(H.reagents.has_reagent(/datum/reagent/fermi/astral))
						if(H.mind)
							temp_message += " <span class='danger'>Warning: subject may be possesed.</span>"
						else
							temp_message += " <span class='notice'>Subject appears to be astrally projecting.</span>"


			//LIVER
			else if(istype(O, /obj/item/organ/liver))
				var/obj/item/organ/liver/L = O
				if(L.organ_flags & ORGAN_FAILING && H.stat != DEAD) //might be depreciated
					temp_message += "<span class='danger'>Subject is suffering from liver failure: Apply Corazone and begin a liver transplant immediately!</span>"

			//HEART
			else if(ishuman(M) && (istype(O, /obj/item/organ/heart)))
				var/obj/item/organ/heart/He = O
				if(H.undergoing_cardiac_arrest() && H.stat != DEAD)
					temp_message += " <span class='danger'>Subject suffering from heart attack: Apply defibrillation or other electric shock <b>immediately!</b></span>"
				if(He.organ_flags & ORGAN_FAILING)
					heart_ded = TRUE

			//TONGUE
			else if(istype(O, /obj/item/organ/tongue))
				var/obj/item/organ/tongue/T = O
				if(T.name == "fluffy tongue")
					temp_message += " <span class='danger'>Subject is suffering from a fluffified tongue. Suggested cure: Yamerol or a tongue transplant.</span>"


			//GENERAL HANDLER
			if(!damage_message)
				if(O.organ_flags & ORGAN_FAILING)
					damage_message += " <span class='alert'><b>Chronic [O.name] failure detected.</b></span>"
				else if(O.damage > O.high_threshold)
					damage_message += " <span class='alert'>Acute [O.name] failure detected.</span>"
				else if(O.damage > O.low_threshold && advanced)
					damage_message += " <font color='red'>Minor [O.name] failure detected.</span>"

			if(temp_message || damage_message)
				msg += "\t<b><span class='info'>[uppertext(O.name)]:</b></span> [damage_message] [temp_message]\n"



		//END; LOOK FOR MISSING ORGANS?
		var/breathes = TRUE
		var/blooded = TRUE
		if(C.dna && C.dna.species)
			if(HAS_TRAIT_FROM(C, TRAIT_NOBREATH, SPECIES_TRAIT))
				breathes = FALSE
			if(NOBLOOD in C.dna.species.species_traits)
				blooded = FALSE
		var/has_liver = C.dna && !(NOLIVER in C.dna.species.species_traits)
		var/has_stomach = C.dna && !(NOSTOMACH in C.dna.species.species_traits)
		if(!M.getorganslot(ORGAN_SLOT_EYES))
			msg += "\t<span class='alert'><b>Subject does not have eyes.</b></span>\n"
		if(!M.getorganslot(ORGAN_SLOT_EARS))
			msg += "\t<span class='alert'><b>Subject does not have ears.</b></span>\n"
		if(!M.getorganslot(ORGAN_SLOT_BRAIN))
			msg += "\t<span class='alert'><b>Subject's brain function is non-existent!</b></span>\n"
		if(has_liver && !M.getorganslot(ORGAN_SLOT_LIVER))
			msg += "\t<span class='alert'><b>Subject's liver is missing!</b></span>\n"
		if(blooded && !M.getorganslot(ORGAN_SLOT_HEART))
			msg += "\t<span class='alert'><b>Subject's heart is missing!</b></span>\n"
		if(breathes && !M.getorganslot(ORGAN_SLOT_LUNGS))
			msg += "\t<span class='alert'><b>Subject's lungs have collapsed from trauma!</b></span>\n"
		if(has_stomach && !M.getorganslot(ORGAN_SLOT_STOMACH))
			msg += "\t<span class='alert'><b>Subject's stomach is missing!</span>\n"


		if(M.radiation)
			msg += "\t<span class='alert'>Subject is irradiated.</span>\n"
			msg += "\t<span class='info'>Radiation Level: [M.radiation] rad</span>\n"



	// Species and body temperature
	var/mob/living/carbon/human/H = M //Start to use human only stuff here
	if(ishuman(M))
		var/datum/species/S = H.dna.species
		var/mutant = FALSE
		if (H.dna.check_mutation(HULK))
			mutant = TRUE
		else if (S.mutantlungs != initial(S.mutantlungs))
			mutant = TRUE
		else if (S.mutant_brain != initial(S.mutant_brain))
			mutant = TRUE
		else if (S.mutant_heart != initial(S.mutant_heart))
			mutant = TRUE
		else if (S.mutanteyes != initial(S.mutanteyes))
			mutant = TRUE
		else if (S.mutantears != initial(S.mutantears))
			mutant = TRUE
		else if (S.mutanthands != initial(S.mutanthands))
			mutant = TRUE
		else if (S.mutanttongue != initial(S.mutanttongue))
			mutant = TRUE
		else if (S.mutanttail != initial(S.mutanttail))
			mutant = TRUE
		else if (S.mutantliver != initial(S.mutantliver))
			mutant = TRUE
		else if (S.mutantstomach != initial(S.mutantstomach))
			mutant = TRUE

		msg += "\t<span class='info'>Reported Species: [H.spec_trait_examine_font()][H.dna.custom_species ? H.dna.custom_species : S.name]</font></span>\n"
		msg += "\t<span class='info'>Base Species: [H.spec_trait_examine_font()][S.name]</font></span>\n"
		if(mutant)
			msg += "\t<span class='info'>Subject has mutations present.</span>\n"
	msg += "\t<span class='info'>Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)</span>\n"

	// Time of death
	if(M.tod && (M.stat == DEAD || ((HAS_TRAIT(M, TRAIT_FAKEDEATH)) && !advanced)))
		msg += "<span class='info'>Time of Death:</span> [M.tod]\n"
		var/tdelta = round(world.time - M.timeofdeath)
		if(tdelta < (DEFIB_TIME_LIMIT * 10))
			if(heart_ded)
				msg += "<span class='danger'>Subject died [DisplayTimeText(tdelta)] ago, heart requires surgical intervention for defibrillation.</span>"
			else
				msg += "<span class='danger'>Subject died [DisplayTimeText(tdelta)] ago, defibrillation may be possible!</span>"
			if(advanced)
				if(H.get_ghost() || H.key || H.client)//Since it can last a while.
					msg += "<span class='danger'> Intervention recommended.</span>\n"
				else
					msg += "\n"
	// Wounds
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/list/wounded_parts = C.get_wounded_bodyparts()
		for(var/i in wounded_parts)
			var/obj/item/bodypart/wounded_part = i
			msg += "<span class='alert ml-1'><b>Warning: Physical trauma[LAZYLEN(wounded_part.wounds) > 1? "s" : ""] detected in [wounded_part.name]</b>"
			for(var/k in wounded_part.wounds)
				var/datum/wound/W = k
				msg += "<div class='ml-2'>Type: [W.name]\nSeverity: [W.severity_text()]\nRecommended Treatment: [W.treat_text]</div>\n" // less lines than in woundscan() so we don't overload people trying to get basic med info
			msg += "</span>\n"

	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			msg += "<span class='alert'><b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</span>\n"

	// Blood Level
	if(M.has_dna())
		var/mob/living/carbon/C = M
		var/blood_typepath = C.get_blood_id()
		if(blood_typepath)
			if(ishuman(C))
				if(H.is_bleeding())
					msg += "<span class='danger'>Subject is bleeding!</span>\n"
			var/blood_percent =  round((C.scan_blood_volume() / (BLOOD_VOLUME_NORMAL * C.blood_ratio))*100)
			var/blood_type = C.dna.blood_type
			if(!(blood_typepath in GLOB.blood_reagent_types))
				var/datum/reagent/R = GLOB.chemical_reagents_list[blood_typepath]
				if(R)
					blood_type = R.name
			if(C.integrating_blood)
				msg += "<span class='info'>[C.integrating_blood] cl of blood is being integrated into their bloodstream</span>\n"
			if(C.scan_blood_volume() <= (BLOOD_VOLUME_SAFE*C.blood_ratio) && C.scan_blood_volume() > (BLOOD_VOLUME_OKAY*C.blood_ratio))
				msg += "<span class='danger'>LOW blood level [blood_percent] %, [C.scan_blood_volume()] cl,</span> <span class='info'>type: [blood_type]</span>\n"
			else if(C.scan_blood_volume() <= (BLOOD_VOLUME_OKAY*C.blood_ratio))
				msg += "<span class='danger'>CRITICAL blood level [blood_percent] %, [C.scan_blood_volume()] cl,</span> <span class='info'>type: [blood_type]</span>\n"
			else
				msg += "<span class='info'>Blood level [blood_percent] %, [C.scan_blood_volume()] cl, type: [blood_type]</span>\n"

		var/cyberimp_detect
		for(var/obj/item/organ/cyberimp/CI in C.internal_organs)
			if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
				cyberimp_detect += "[C.name] is modified with a [CI.name].<br>"
		if(cyberimp_detect)
			msg += "<span class='notice'>Detected cybernetic modifications:</span>\n"
			msg += "<span class='notice'>[cyberimp_detect]</span>\n"
	msg += "<span class='notice'>*---------*</span>"
	to_chat(user, msg)
	SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, FALSE)

/proc/chemscan(mob/living/user, mob/living/M)
	if(istype(M))
		if(M.reagents)
			var/msg = "<span class='info'>*---------*\n"
			if(M.reagents.reagent_list.len)
				var/list/datum/reagent/reagents = list()
				for(var/datum/reagent/R in M.reagents.reagent_list)
					if(R.chemical_flags & REAGENT_INVISIBLE)
						continue
					reagents += R

				if(length(reagents))
					msg += "<span class='notice'>Subject contains the following reagents:</span>\n"
					for(var/datum/reagent/R in reagents)
						msg += "<span class='notice'>[R.volume] units of [R.name][R.overdosed == 1 ? "</span> - <span class='boldannounce'>OVERDOSING</span>" : ".</span>"]\n"
				else
					msg += "<span class='notice'>Subject contains no reagents.</span>\n"

			else
				msg += "<span class='notice'>Subject contains no reagents.</span>\n"
			if(M.reagents.addiction_list.len)
				msg += "<span class='boldannounce'>Subject is addicted to the following reagents:</span>\n"
				for(var/datum/reagent/R in M.reagents.addiction_list)
					msg += "<span class='danger'>[R.name]</span>\n"
			else
				msg += "<span class='notice'>Subject is not addicted to any reagents.</span>\n"

			var/datum/reagent/impure/fermiTox/F = M.reagents.has_reagent(/datum/reagent/impure/fermiTox)
			if(istype(F,/datum/reagent/impure/fermiTox))
				switch(F.volume)
					if(5 to 10)
						msg += "<span class='notice'>Subject contains a low amount of toxic isomers.</span>\n"
					if(10 to 25)
						msg += "<span class='danger'>Subject contains toxic isomers.</span>\n"
					if(25 to 50)
						msg += "<span class='danger'>Subject contains a substantial amount of toxic isomers.</span>\n"
					if(50 to 95)
						msg += "<span class='danger'>Subject contains a high amount of toxic isomers.</span>\n"
					if(95 to INFINITY)
						msg += "<span class='danger'>Subject contains a extremely dangerous amount of toxic isomers.</span>\n"

			msg += "*---------*</span>"
			to_chat(user, msg)

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	var/mob/living/L = usr
	if(!istype(L) || !CHECK_MOBILITY(L, MOBILITY_USE))
		return

	mode = !mode
	switch (mode)
		if(1)
			to_chat(usr, "The scanner now shows specific limb damage.")
		if(0)
			to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	advanced = TRUE

/// Displays wounds with extended information on their status vs medscanners
/proc/woundscan(mob/user, mob/living/carbon/patient, obj/item/healthanalyzer/wound/scanner)
	if(!istype(patient))
		return

	var/render_list = ""
	for(var/i in patient.get_wounded_bodyparts())
		var/obj/item/bodypart/wounded_part = i
		render_list += "<span class='alert ml-1'><b>Warning: Physical trauma[LAZYLEN(wounded_part.wounds) > 1? "s" : ""] detected in [wounded_part.name]</b>"
		for(var/k in wounded_part.wounds)
			var/datum/wound/W = k
			render_list += "<div class='ml-2'>[W.get_scanner_description()]</div>\n"
		render_list += "</span>"

	if(render_list == "")
		if(istype(scanner))
			// Only emit the cheerful scanner message if this scan came from a scanner
			playsound(scanner, 'sound/machines/ping.ogg', 50, FALSE)
			to_chat(user, "<span class='notice'>\The [scanner] makes a happy ping and briefly displays a smiley face with several exclamation points! It's really excited to report that [patient] has no wounds!</span>")
		else
			to_chat(user, "<span class='notice ml-1'>No wounds detected in subject.</span>")
	else
		to_chat(user, jointext(render_list, ""))

/obj/item/healthanalyzer/wound
	name = "first aid analyzer"
	icon_state = "adv_spectrometer"
	desc = "A prototype MeLo-Tech medical scanner used to diagnose injuries and recommend treatment for serious wounds, but offers no further insight into the patient's health. You hope the final version is less annoying to read!"
	var/next_encouragement
	var/greedy

/obj/item/healthanalyzer/wound/attack_self(mob/user)
	if(next_encouragement < world.time)
		playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		var/list/encouragements = list("briefly displays a happy face, gazing emptily at you", "briefly displays a spinning cartoon heart", "displays an encouraging message about eating healthy and exercising", \
				"reminds you that everyone is doing their best", "displays a message wishing you well", "displays a sincere thank-you for your interest in first-aid", "formally absolves you of all your sins")
		to_chat(user, "<span class='notice'>\The [src] makes a happy ping and [pick(encouragements)]!</span>")
		next_encouragement = world.time + 10 SECONDS
		greedy = FALSE
	else if(!greedy)
		to_chat(user, "<span class='warning'>\The [src] displays an eerily high-definition frowny face, chastizing you for asking it for too much encouragement.</span>")
		greedy = TRUE
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		if(isliving(user))
			var/mob/living/L = user
			to_chat(L, "<span class='warning'>\The [src] makes a disappointed buzz and pricks your finger for being greedy. Ow!</span>")
			L.adjustBruteLoss(4)
			L.dropItemToGround(src)

/obj/item/healthanalyzer/wound/attack(mob/living/carbon/patient, mob/living/carbon/human/user)
	add_fingerprint(user)
	user.visible_message("<span class='notice'>[user] scans [patient] for serious injuries.</span>", "<span class='notice'>You scan [patient] for serious injuries.</span>")

	if(!istype(patient))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		to_chat(user, "<span class='notice'>\The [src] makes a sad buzz and briefly displays a frowny face, indicating it can't scan [patient].</span>")
		return

	woundscan(user, patient, src)

/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels. Alt-Click to use the built in barometer function."
	name = "analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "analyzer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	tool_behaviour = TOOL_ANALYZER
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)
	grind_results = list(/datum/reagent/mercury = 5, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click [src] to activate the barometer function.</span>"

/obj/item/analyzer/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!</span>")
	return BRUTELOSS

/obj/item/analyzer/attack_self(mob/user)
	add_fingerprint(user)

	if (user.stat || user.eye_blind)
		return

	//Functionality moved down to proc/scan_turf()
	var/turf/location = get_turf(user)
	if(!istype(location))
		return

	scan_turf(user, location)

/obj/item/analyzer/AltClick(mob/user) //Barometer output for measuring when the next storm happens
	. = ..()

	if(user.canUseTopic(src))
		. = TRUE
		if(cooldown)
			to_chat(user, "<span class='warning'>[src]'s barometer function is preparing itself.</span>")
			return

		var/turf/T = get_turf(user)
		if(!T)
			return

		playsound(src, 'sound/effects/pop.ogg', 100)
		var/area/user_area = T.loc
		var/datum/weather/ongoing_weather = null

		if(!user_area.outdoors)
			to_chat(user, "<span class='warning'>[src]'s barometer function won't work indoors!</span>")
			return

		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
				ongoing_weather = W
				break

		if(ongoing_weather)
			if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
				to_chat(user, "<span class='warning'>[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]</span>")
				return

			to_chat(user, "<span class='notice'>The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)].</span>")
			if(ongoing_weather.aesthetic)
				to_chat(user, "<span class='warning'>[src]'s barometer function says that the next storm will breeze on by.</span>")
		else
			var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
			var/fixed = next_hit ? next_hit - world.time : -1
			if(fixed < 0)
				to_chat(user, "<span class='warning'>[src]'s barometer function was unable to trace any weather patterns.</span>")
			else
				to_chat(user, "<span class='warning'>[src]'s barometer function says a storm will land in approximately [butchertime(fixed)].</span>")
		cooldown = TRUE
		addtimer(CALLBACK(src,/obj/item/analyzer/proc/ping), cooldown_time)

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='notice'>[src]'s barometer function is ready!</span>")
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/inaccurate = round(accuracy*(1/3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1,amount))

/proc/atmosanalyzer_scan(mixture, mob/living/user, atom/target = src, visible = TRUE)
	var/icon = target
	if(visible)
		user.visible_message("[user] has used the analyzer on [icon2html(icon, viewers(user))] [target].", "<span class='notice'>You use the analyzer on [icon2html(icon, user)] [target].</span>")
	to_chat(user, "<span class='boldnotice'>Results of analysis of [icon2html(icon, user)] [target].</span>")

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/g in airs)
		if(airs.len > 1) //not a unary gas mixture
			to_chat(user, "<span class='boldnotice'>Node [airs.Find(g)]</span>")
		var/datum/gas_mixture/air_contents = g

		var/total_moles = air_contents.total_moles()
		var/pressure = air_contents.return_pressure()
		var/volume = air_contents.return_volume() //could just do mixture.volume... but safety, I guess?
		var/temperature = air_contents.return_temperature()
		var/cached_scan_results = air_contents.analyzer_results

		if(total_moles > 0)
			to_chat(user, "<span class='notice'>Moles: [round(total_moles, 0.01)] mol</span>")
			to_chat(user, "<span class='notice'>Volume: [volume] L</span>")
			to_chat(user, "<span class='notice'>Pressure: [round(pressure,0.01)] kPa</span>")

			for(var/id in air_contents.get_gases())
				if(air_contents.get_moles(id) >= 0.005)
					var/gas_concentration = air_contents.get_moles(id)/total_moles
					to_chat(user, "<span class='notice'>[GLOB.meta_gas_names[id]]: [round(gas_concentration*100, 0.01)] % ([round(air_contents.get_moles(id), 0.01)] mol)</span>")
			to_chat(user, "<span class='notice'>Temperature: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)</span>")

		else
			if(airs.len > 1)
				to_chat(user, "<span class='notice'>This node is empty!</span>")
			else
				to_chat(user, "<span class='notice'>[target] is empty!</span>")

		if(cached_scan_results && cached_scan_results["fusion"]) //notify the user if a fusion reaction was detected
			var/instability = round(cached_scan_results["fusion"], 0.01)
			var/tier = instability2text(instability)
			to_chat(user, "<span class='boldnotice'>Large amounts of free neutrons detected in the air indicate that a fusion reaction took place.</span>")
			to_chat(user, "<span class='notice'>Instability of the last fusion reaction: [instability]\n This indicates it was [tier].</span>")
	return

/obj/item/analyzer/proc/scan_turf(mob/user, turf/location)

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()
	var/cached_scan_results = environment.analyzer_results

	to_chat(user, "<span class='info'><B>Results:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(user, "<span class='info'>Pressure: [round(pressure, 0.01)] kPa</span>")
	else
		to_chat(user, "<span class='alert'>Pressure: [round(pressure, 0.01)] kPa</span>")
	if(total_moles)

		var/o2_concentration = environment.get_moles(/datum/gas/oxygen)/total_moles
		var/n2_concentration = environment.get_moles(/datum/gas/nitrogen)/total_moles
		var/co2_concentration = environment.get_moles(/datum/gas/carbon_dioxide)/total_moles
		var/plasma_concentration = environment.get_moles(/datum/gas/plasma)/total_moles

		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(user, "<span class='info'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/nitrogen), 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='alert'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/nitrogen), 0.01)] mol)</span>")

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(user, "<span class='info'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/oxygen), 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='alert'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/oxygen), 0.01)] mol)</span>")

		if(co2_concentration > 0.01)
			to_chat(user, "<span class='alert'>CO2: [round(co2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/carbon_dioxide), 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='info'>CO2: [round(co2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/carbon_dioxide), 0.01)] mol)</span>")

		if(plasma_concentration > 0.005)
			to_chat(user, "<span class='alert'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/plasma), 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='info'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/plasma), 0.01)] mol)</span>")

		for(var/id in environment.get_gases())
			if(id in GLOB.hardcoded_gases)
				continue
			var/gas_concentration = environment.get_moles(id)/total_moles
			to_chat(user, "<span class='alert'>[GLOB.meta_gas_names[id]]: [round(gas_concentration*100, 0.01)] % ([round(environment.get_moles(id), 0.01)] mol)</span>")
		to_chat(user, "<span class='info'>Temperature: [round(environment.return_temperature()-T0C, 0.01)] &deg;C ([round(environment.return_temperature(), 0.01)] K)</span>")

		if(cached_scan_results && cached_scan_results["fusion"]) //notify the user if a fusion reaction was detected
			var/instability = round(cached_scan_results["fusion"], 0.01)
			var/tier = instability2text(instability)
			to_chat(user, "<span class='boldnotice'>Large amounts of free neutrons detected in the air indicate that a fusion reaction took place.</span>")
			to_chat(user, "<span class='notice'>Instability of the last fusion reaction: [instability]\n This indicates it was [tier].</span>")

/obj/item/analyzer/ranged
	desc = "A hand-held scanner which uses advanced spectroscopy and infrared readings to analyze gases as a distance. Alt-Click to use the built in barometer function."
	name = "long-range analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "ranged_analyzer"

/obj/item/analyzer/ranged/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(target.tool_act(user, src, tool_behaviour))
		return
	// Tool act didn't scan it, so let's get it's turf.
	var/turf/location = get_turf(target)
	scan_turf(user, location)

//slime scanner

/obj/item/slime_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)

/obj/item/slime_scanner/attack(mob/living/M, mob/living/user)
	if(user.stat || user.eye_blind)
		return
	if (!isslime(M))
		to_chat(user, "<span class='warning'>This device can only scan slimes!</span>")
		return
	var/mob/living/simple_animal/slime/T = M
	slime_scan(T, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	to_chat(user, "========================")
	to_chat(user, "<b>Slime scan results:</b>")
	to_chat(user, "<span class='notice'>[T.colour] [T.is_adult ? "adult" : "baby"] slime</span>")
	to_chat(user, "Nutrition: [T.nutrition]/[T.get_max_nutrition()]")
	if (T.nutrition < T.get_starve_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is starving!</span>")
	else if (T.nutrition < T.get_hunger_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is hungry</span>")
	to_chat(user, "Electric change strength: [T.powerlevel]")
	to_chat(user, "Health: [round(T.health/T.maxHealth,0.01)*100]%")
	if (T.slime_mutation[4] == T.colour)
		to_chat(user, "This slime does not evolve any further.")
	else
		if (T.slime_mutation[3] == T.slime_mutation[4])
			if (T.slime_mutation[2] == T.slime_mutation[1])
				to_chat(user, "Possible mutation: [T.slime_mutation[3]]")
				to_chat(user, "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting")
			else
				to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)")
				to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
		else
			to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]")
			to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
	if (T.cores > 1)
		to_chat(user, "Multiple cores detected")
	to_chat(user, "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")
	if(T.effectmod)
		to_chat(user, "<span class='notice'>Core mutation in progress: [T.effectmod]</span>")
		to_chat(user, "<span class = 'notice'>Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]</span>")
	to_chat(user, "========================")


/obj/item/nanite_scanner
	name = "nanite scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_scanner"
	item_state = "nanite_remote"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner able to detect nanites and their programming."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)

/obj/item/nanite_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	user.visible_message("<span class='notice'>[user] has analyzed [M]'s nanites.</span>")

	add_fingerprint(user)

	var/response = SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, TRUE)
	if(!response)
		to_chat(user, "<span class='info'>No nanites detected in the subject.</span>")

/obj/item/sequence_scanner
	name = "genetic sequence scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "gene"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held scanner for analyzing someones gene sequence on the fly. Hold near a DNA console to update the internal database."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)
	var/list/discovered = list() //hit a dna console to update the scanners database
	buffer = list()
	var/ready = TRUE
	var/cooldown = 200

/obj/item/sequence_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	if (!HAS_TRAIT_NOT_FROM(M, TRAIT_RADIMMUNE,BLOODSUCKER_TRAIT)) //no scanning if its a husk or DNA-less Species
		user.visible_message("<span class='notice'>[user] analyzes [M]'s genetic sequence.</span>", \
							"<span class='notice'>You analyze [M]'s genetic sequence.</span>")
		gene_scan(M, user)

	else
		user.visible_message("<span class='notice'>[user] failed to analyse [M]'s genetic sequence.</span>", "<span class='warning'>[M] has no readable genetic sequence!</span>")

/obj/item/sequence_scanner/attack_self(mob/user)
	display_sequence(user)

/obj/item/sequence_scanner/attack_self_tk(mob/user)
	return

/obj/item/sequence_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/machinery/computer/scan_consolenew))
		var/obj/machinery/computer/scan_consolenew/C = O
		if(C.stored_research)
			to_chat(user, "<span class='notice'>[name] linked to central research database.</span>")
			discovered = C.stored_research.discovered_mutations
		else
			to_chat(user,"<span class='warning'>No database to update from.</span>")

/obj/item/sequence_scanner/proc/gene_scan(mob/living/carbon/C, mob/living/user)
	if(!iscarbon(C) || !C.has_dna())
		return
	buffer = C.dna.mutation_index
	to_chat(user, "<span class='notice'>Subject [C.name]'s DNA sequence has been saved to buffer.</span>")
	if(LAZYLEN(buffer))
		for(var/A in buffer)
			to_chat(user, "<span class='notice'>[get_display_name(A)]</span>")


/obj/item/sequence_scanner/proc/display_sequence(mob/living/user)
	if(!LAZYLEN(buffer) || !ready)
		return
	var/list/options = list()
	for(var/A in buffer)
		options += get_display_name(A)

	var/answer = input(user, "Analyze Potential", "Sequence Analyzer")  as null|anything in sortList(options)
	if(answer && ready && user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		var/sequence
		for(var/A in buffer) //this physically hurts but i dont know what anything else short of an assoc list
			if(get_display_name(A) == answer)
				sequence = buffer[A]
				break

		if(sequence)
			var/display
			for(var/i in 0 to length_char(sequence) / DNA_MUTATION_BLOCKS-1)
				if(i)
					display += "-"
				display += copytext_char(sequence, 1 + i*DNA_MUTATION_BLOCKS, DNA_MUTATION_BLOCKS*(1+i) + 1)

			to_chat(user, "<span class='boldnotice'>[display]</span><br>")

		ready = FALSE
		icon_state = "[icon_state]_recharging"
		addtimer(CALLBACK(src, .proc/recharge), cooldown, TIMER_UNIQUE)

/obj/item/sequence_scanner/proc/recharge()
	icon_state = initial(icon_state)
	ready = TRUE

/obj/item/sequence_scanner/proc/get_display_name(mutation)
	var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation)
	if(!HM)
		return "ERROR"
	if(mutation in discovered)
		return  "[HM.name] ([HM.alias])"
	else
		return HM.alias

#undef SCANMODE_HEALTH
#undef SCANMODE_CHEMICAL
#undef SCANMODE_WOUND
#undef SCANNER_CONDENSED
#undef SCANNER_VERBOSE
