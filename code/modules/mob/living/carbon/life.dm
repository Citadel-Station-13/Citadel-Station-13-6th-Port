/mob/living/carbon/BiologicalLife(seconds, times_fired)
	//Reagent processing needs to come before breathing, to prevent edge cases.
	handle_organs(seconds, times_fired)
	. = ..()		// if . is false, we are dead.
	if(stat == DEAD)
		stop_sound_channel(CHANNEL_HEARTBEAT)
		handle_death()
		rot()
		. = FALSE
	if(!.)
		return
	handle_blood()
	// handle_blood *could* kill us.
	// we should probably have a better system for if we need to check for death or something in the future hmw
	if(stat != DEAD)
		var/bprv = handle_bodyparts()
		if(bprv & BODYPART_LIFE_UPDATE_HEALTH)
			updatehealth()
	update_stamina()
	doSprintBufferRegen()

	if(stat != DEAD)
		handle_brain_damage()

	if(stat != DEAD)
		handle_liver(seconds, times_fired)

	if(stat != DEAD)
		handle_corruption()


/mob/living/carbon/PhysicalLife(seconds, times_fired)
	if(!(. = ..()))
		return
	if(damageoverlaytemp)
		damageoverlaytemp = 0
		update_damage_hud()

//Procs called while dead
/mob/living/carbon/proc/handle_death()
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.chemical_flags & REAGENT_DEAD_PROCESS)
			R.on_mob_dead(src)

///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/handle_breathing(times_fired)
	var/next_breath = 4
	var/obj/item/organ/lungs/L = getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/heart/H = getorganslot(ORGAN_SLOT_HEART)
	if(L)
		if(L.damage > L.high_threshold)
			next_breath--
	if(H)
		if(H.damage > H.high_threshold)
			next_breath--

	if((times_fired % next_breath) == 0 || failed_last_breath)
		breathe() //Breathe per 4 ticks if healthy, down to 2 if our lungs or heart are damaged, unless suffocating
		if(failed_last_breath)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "suffocation", /datum/mood_event/suffocation)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")
	else
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe()
	var/obj/item/organ/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(reagents.has_reagent(/datum/reagent/toxin/lexorin))
		return
	if(istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return
	if(istype(loc, /obj/item/dogborg/sleeper))
		return
	if(ismob(loc))
		return
	if(isbelly(loc))
		return

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(!getorganslot(ORGAN_SLOT_BREATHING_TUBE))
		if(health <= HEALTH_THRESHOLD_FULLCRIT || (pulledby && pulledby.grab_state >= GRAB_KILL) || HAS_TRAIT(src, TRAIT_MAGIC_CHOKE) || (lungs && lungs.organ_flags & ORGAN_FAILING))
			losebreath++  //You can't breath at all when in critical or when being choked, so you're going to miss a breath

		else if(health <= crit_threshold)
			losebreath += 0.25 //You're having trouble breathing in soft crit, so you'll miss a breath one in four times

	//Suffocate
	if(losebreath >= 1) //You've missed a breath, take oxy damage
		losebreath--
		if(prob(10))
			emote("gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src,0)
	else
		//Breathe from internal
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(isnull(breath)) //in case of 0 pressure internals

			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_VOLUME)

			else if(isturf(loc)) //Breathe from loc as turf
				var/breath_ratio = 0
				if(environment)
					breath_ratio = BREATH_VOLUME/environment.return_volume()

				breath = loc.remove_air_ratio(breath_ratio)
		else //Breathe from loc as obj again
			if(istype(loc, /obj/))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	if(breath)
		breath.set_volume(BREATH_VOLUME)
	check_breath(breath)

	if(breath)
		loc.assume_air(breath)
		air_update_turf()

/mob/living/carbon/proc/has_smoke_protection()
	if(HAS_TRAIT(src, TRAIT_NOBREATH))
		return TRUE
	return FALSE


//Third link in a breath chain, calls handle_breath_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if((status_flags & GODMODE))
		return

	var/obj/item/organ/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		adjustOxyLoss(2)

	//CRIT
	if(!breath || (breath.total_moles() == 0) || !lungs)
		if(reagents.has_reagent(/datum/reagent/medicine/epinephrine) && lungs)
			return
		adjustOxyLoss(1)

		failed_last_breath = 1
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		return 0

	var/safe_oxy_min = 16
	var/safe_oxy_max = 50
	var/safe_co2_max = 10
	var/safe_tox_max = 0.05
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/moles = breath.total_moles()
	var/breath_pressure = (moles*R_IDEAL_GAS_EQUATION*breath.return_temperature())/BREATH_VOLUME
	var/O2_partialpressure = ((breath.get_moles(GAS_O2)/moles)*breath_pressure) + (((breath.get_moles(GAS_PLUOXIUM)*8)/moles)*breath_pressure)
	var/Toxins_partialpressure = (breath.get_moles(GAS_PLASMA)/moles)*breath_pressure
	var/CO2_partialpressure = (breath.get_moles(GAS_CO2)/moles)*breath_pressure


	//OXYGEN
	if(O2_partialpressure > safe_oxy_max) // Too much Oxygen - blatant CO2 effect copy/pasta
		if(!o2overloadtime)
			o2overloadtime = world.time
		else if(world.time - o2overloadtime > 120)
			Dizzy(10)	// better than a minute of you're fucked KO, but certainly a wake up call. Honk.
			adjustOxyLoss(3)
			if(world.time - o2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			emote("cough")
		throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "suffocation", /datum/mood_event/suffocation)

	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(prob(20))
			emote("gasp")
		if(O2_partialpressure > 0)
			var/ratio = 1 - O2_partialpressure/safe_oxy_min
			adjustOxyLoss(min(5*ratio, 3))
			failed_last_breath = 1
			oxygen_used = breath.get_moles(GAS_O2)*ratio
		else
			adjustOxyLoss(3)
			failed_last_breath = 1
		throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "suffocation", /datum/mood_event/suffocation)

	else //Enough oxygen
		failed_last_breath = 0
		o2overloadtime = 0 //reset our counter for this too
		if(health >= crit_threshold)
			adjustOxyLoss(-5)
		oxygen_used = breath.get_moles(GAS_O2)
		clear_alert("not_enough_oxy")
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")

	breath.adjust_moles(GAS_O2, -oxygen_used)
	breath.adjust_moles(GAS_CO2, oxygen_used)

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Unconscious(60)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			emote("cough")

	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max)
		var/ratio = (breath.get_moles(GAS_PLASMA)/safe_tox_max) * 10
		adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
	else
		clear_alert("too_much_tox")

	//NITROUS OXIDE
	if(breath.get_moles(GAS_NITROUS))
		var/SA_partialpressure = (breath.get_moles(GAS_NITROUS)/breath.total_moles())*breath_pressure
		if(SA_partialpressure > SA_para_min)
			Unconscious(60)
			if(SA_partialpressure > SA_sleep_min)
				Sleeping(max(AmountSleeping() + 40, 200))
		else if(SA_partialpressure > 0.01)
			if(prob(20))
				emote(pick("giggle","laugh"))
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")

	//BZ (Facepunch port of their Agent B)
	if(breath.get_moles(GAS_BZ))
		var/bz_partialpressure = (breath.get_moles(GAS_BZ)/breath.total_moles())*breath_pressure
		if(bz_partialpressure > 1)
			hallucination += 10
		else if(bz_partialpressure > 0.01)
			hallucination += 5

	//TRITIUM
	if(breath.get_moles(GAS_TRITIUM))
		var/tritium_partialpressure = (breath.get_moles(GAS_TRITIUM)/breath.total_moles())*breath_pressure
		radiation += tritium_partialpressure/10

	//NITRYL
	if(breath.get_moles(GAS_NITRYL))
		var/nitryl_partialpressure = (breath.get_moles(GAS_NITRYL)/breath.total_moles())*breath_pressure
		adjustFireLoss(nitryl_partialpressure/4)

	//MIASMA
	if(breath.get_moles(GAS_MIASMA))
		var/miasma_partialpressure = (breath.get_moles(GAS_MIASMA)/breath.total_moles())*breath_pressure
		if(miasma_partialpressure > MINIMUM_MOLES_DELTA_TO_MOVE)

			if(prob(0.05 * miasma_partialpressure))
				var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(TRUE, 2,3)
				miasma_disease.name = "Unknown"
				ForceContractDisease(miasma_disease, TRUE, TRUE)

			//Miasma side effects
			switch(miasma_partialpressure)
				if(1 to 5)
					// At lower pp, give out a little warning
					SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")
					if(prob(5))
						to_chat(src, "<span class='notice'>There is an unpleasant smell in the air.</span>")
				if(5 to 20)
					//At somewhat higher pp, warning becomes more obvious
					if(prob(15))
						to_chat(src, "<span class='warning'>You smell something horribly decayed inside this room.</span>")
						SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
				if(15 to 30)
					//Small chance to vomit. By now, people have internals on anyway
					if(prob(5))
						to_chat(src, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
						SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
						vomit()
				if(30 to INFINITY)
					//Higher chance to vomit. Let the horror start
					if(prob(25))
						to_chat(src, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
						SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
						vomit()
				else
					SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")


	//Clear all moods if no miasma at all
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")

	//BREATH TEMPERATURE
	handle_breath_temperature(breath)

	return 1

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_breath_temperature(datum/gas_mixture/breath)
	return

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	var/obj/item/clothing/check
	var/internals = FALSE

	if(!HAS_TRAIT(src, TRAIT_NO_INTERNALS))
		for(check in GET_INTERNAL_SLOTS(src))
			if(CHECK_BITFIELD(check.clothing_flags, ALLOWINTERNALS))
				internals = TRUE
	if(internal)
		if(internal.loc != src)
			internal = null
			update_internals_hud_icon(0)
		else if (!internals && !getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			internal = null
			update_internals_hud_icon(0)
		else
			update_internals_hud_icon(1)
			. = internal.remove_air_volume(volume_needed)
			if(!.)
				return FALSE //to differentiate between no internals and active, but empty internals

// Make corpses rot, emitting miasma
/mob/living/carbon/proc/rot()
	// Properly stored corpses shouldn't create miasma
	if(istype(loc, /obj/structure/closet/crate/coffin)|| istype(loc, /obj/structure/closet/body_bag) || istype(loc, /obj/structure/bodycontainer))
		return

	// No decay if formaldehyde/preservahyde in corpse or when the corpse is charred
	if(reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 1) || HAS_TRAIT(src, TRAIT_HUSK) || reagents.has_reagent(/datum/reagent/preservahyde, 1))
		return

	// Also no decay if corpse chilled or not organic/undead
	if((bodytemperature <= T0C-10) || !(mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)))
		return

	// Wait a bit before decaying
	if(world.time - timeofdeath < 1200)
		return

	var/deceasedturf = get_turf(src)

	// Closed turfs don't have any air in them, so no gas building up
	if(!istype(deceasedturf,/turf/open))
		return

	var/turf/open/miasma_turf = deceasedturf

	var/datum/gas_mixture/stank = new

	stank.set_moles(GAS_MIASMA,0.1)

	stank.set_temperature(BODYTEMP_NORMAL)

	miasma_turf.assume_air(stank)

	miasma_turf.air_update_turf()

/mob/living/carbon/proc/handle_blood()
	return

/mob/living/carbon/proc/handle_bodyparts(seconds, times_fired)
	for(var/I in bodyparts)
		var/obj/item/bodypart/BP = I
		if(BP.needs_processing)
			. |= BP.on_life(seconds, times_fired)

/mob/living/carbon/proc/handle_organs(seconds, times_fired)
	if(stat != DEAD)
		for(var/V in internal_organs)
			var/obj/item/organ/O = V
			if(O)
				O.on_life(seconds, times_fired)
	else
		if(reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 1) || reagents.has_reagent(/datum/reagent/preservahyde, 1)) // No organ decay if the body contains formaldehyde. Or preservahyde.
			return
		for(var/V in internal_organs)
			var/obj/item/organ/O = V
			if(O)
				O.on_death(seconds, times_fired) //Needed so organs decay while inside the body.

/mob/living/carbon/handle_diseases()
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(prob(D.infectivity))
			D.spread()

		if(stat != DEAD || D.process_dead)
			D.stage_act()

/mob/living/carbon/handle_wounds()
	for(var/thing in all_wounds)
		var/datum/wound/W = thing
		if(W.processes) // meh
			W.handle_process()

/mob/living/carbon/handle_mutations_and_radiation()
	if(dna && dna.temporary_mutations.len)
		for(var/mut in dna.temporary_mutations)
			if(dna.temporary_mutations[mut] < world.time)
				if(mut == UI_CHANGED)
					if(dna.previous["UI"])
						dna.uni_identity = merge_text(dna.uni_identity,dna.previous["UI"])
						updateappearance(mutations_overlay_update=1)
						dna.previous.Remove("UI")
					dna.temporary_mutations.Remove(mut)
					continue
				if(mut == UE_CHANGED)
					if(dna.previous["name"])
						real_name = dna.previous["name"]
						name = real_name
						dna.previous.Remove("name")
					if(dna.previous["UE"])
						dna.unique_enzymes = dna.previous["UE"]
						dna.previous.Remove("UE")
					if(dna.previous["blood_type"])
						dna.blood_type = dna.previous["blood_type"]
						dna.previous.Remove("blood_type")
					dna.temporary_mutations.Remove(mut)
					continue
		for(var/datum/mutation/human/HM in dna.mutations)
			if(HM && HM.timed)
				dna.remove_mutation(HM.type)

	radiation -= min(radiation, RAD_LOSS_PER_TICK)
	if(radiation > RAD_MOB_SAFE)
		if(!HAS_TRAIT(src, TRAIT_ROBOTIC_ORGANISM))
			adjustToxLoss(log(radiation-RAD_MOB_SAFE)*RAD_TOX_COEFFICIENT)
		else
			var/rad_threshold = HAS_TRAIT(src, TRAIT_ROBOT_RADSHIELDING) ? RAD_UPGRADED_ROBOT_SAFE : RAD_DEFAULT_ROBOT_SAFE
			if(radiation > rad_threshold)
				adjustToxLoss(log(radiation-rad_threshold)*RAD_TOX_COEFFICIENT, toxins_type = TOX_SYSCORRUPT) //Robots are less resistant to rads, unless upgraded in which case they are fine at higher levels than organics.

/mob/living/carbon/handle_stomach()
	set waitfor = 0
	for(var/mob/living/M in stomach_contents)
		if(M.loc != src)
			stomach_contents.Remove(M)
			continue
		if(iscarbon(M) && stat != DEAD)
			if(M.stat == DEAD)
				M.death(1)
				stomach_contents.Remove(M)
				qdel(M)
				continue
			if(SSmobs.times_fired%3==1)
				if(!(M.status_flags & GODMODE))
					M.adjustBruteLoss(5)
				adjust_nutrition(10)


/*
Alcohol Poisoning Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occassional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - light brain damage, passing out
91-100: Dangerously toxic - swift death
*/
#define BALLMER_POINTS 5
GLOBAL_LIST_INIT(ballmer_good_msg, list("Hey guys, what if we rolled out a bluespace wiring system so mice can't destroy the powergrid anymore?",
										"Hear me out here. What if, and this is just a theory, we made R&D controllable from our PDAs?",
										"I'm thinking we should roll out a git repository for our research under the AGPLv3 license so that we can share it among the other stations freely.",
										"I dunno about you guys, but IDs and PDAs being separate is clunky as fuck. Maybe we should merge them into a chip in our arms? That way they can't be stolen easily.",
										"Why the fuck aren't we just making every pair of shoes into galoshes? We have the technology.",
										"We can link the Ore Silo to our protolathes, so why don't we also link it to autolathes?",
										"If we can make better bombs with heated plasma, oxygen, and tritium, then why do station nukes still use plutonium?",
 										"We should port all our NT programs to modular consoles and do away with computers. They're way more customizable, support cross-platform usage, and would allow crazy amounts of multitasking.",
										"Wait, if we use more manipulators in something, then it prints for cheaper, right? So what if we just made a new type of printer that has like 12 manipulators inside of it to print stuff for really cheap?"
										))
GLOBAL_LIST_INIT(ballmer_windows_me_msg, list("Yo man, what if, we like, uh, put a webserver that's automatically turned on with default admin passwords into every PDA?",
											"So like, you know how we separate our codebase from the master copy that runs on our consumer boxes? What if we merged the two and undid the separation between codebase and server?",
											"Dude, radical idea: H.O.N.K mechs but with no bananium required.",
											"Best idea ever: Disposal pipes instead of hallways.",
											"What if we use a language that was written on a napkin and created over 1 weekend for all of our servers?",
											"What if we took a locker, some random trash, and made an exosuit out of it? Wouldn't that be like, super cool and stuff?",
											"Okay, hear me out, what if we make illegal things not illegal, so that sec stops arresting us for having it?",
											"I have a crazy idea, guys. Rather than having monkeys to test on, what if we only used apes?",
											"Woh man ok, what if we took slime cores and smashed them into other slimes, be kinda cool to see what happens.",
											"We're NANOtrasen but we need to unlock nano parts, what's the deal with that?"
											))

//this updates all special effects: stun, sleeping, knockdown, druggy, stuttering, etc..
/mob/living/carbon/handle_status_effects()
	..()
	if(getStaminaLoss() && !HAS_TRAIT(src, TRAIT_NO_STAMINA_REGENERATION))
		adjustStaminaLoss((!CHECK_MOBILITY(src, MOBILITY_STAND) ? ((combat_flags & COMBAT_FLAG_HARD_STAMCRIT) ? STAM_RECOVERY_STAM_CRIT : STAM_RECOVERY_RESTING) : STAM_RECOVERY_NORMAL))

	if(!(combat_flags & COMBAT_FLAG_HARD_STAMCRIT) && incomingstammult != 1)
		incomingstammult = max(0.01, incomingstammult)
		incomingstammult = min(1, incomingstammult*2)

	var/restingpwr = 1 + 4 * !CHECK_MOBILITY(src, MOBILITY_STAND)

	//Dizziness
	if(dizziness)
		var/client/C = client
		var/pixel_x_diff = 0
		var/pixel_y_diff = 0
		var/temp
		var/saved_dizz = dizziness
		if(C)
			var/oldsrc = src
			var/amplitude = dizziness*(sin(dizziness * world.time) + 1) // This shit is annoying at high strength
			src = null
			spawn(0)
				if(C)
					temp = amplitude * sin(saved_dizz * world.time)
					pixel_x_diff += temp
					C.pixel_x += temp
					temp = amplitude * cos(saved_dizz * world.time)
					pixel_y_diff += temp
					C.pixel_y += temp
					sleep(3)
					if(C)
						temp = amplitude * sin(saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
					sleep(3)
					if(C)
						C.pixel_x -= pixel_x_diff
						C.pixel_y -= pixel_y_diff
			src = oldsrc
		dizziness = max(dizziness - restingpwr, 0)

	if(drowsyness)
		drowsyness = max(drowsyness - restingpwr, 0)
		blur_eyes(2)
		if(prob(5))
			AdjustSleeping(20)
			Unconscious(100)

	//Jitteriness
	if(jitteriness)
		do_jitter_animation(jitteriness)
		jitteriness = max(jitteriness - restingpwr, 0)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "jittery", /datum/mood_event/jittery)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "jittery")

	if(stuttering)
		stuttering = max(stuttering-1, 0)

	if(slurring || drunkenness)
		slurring = max(slurring-1,0,drunkenness)

	if(cultslurring)
		cultslurring = max(cultslurring-1, 0)

	if(clockcultslurring)
		clockcultslurring = max(clockcultslurring-1, 0)

	if(silent)
		silent = max(silent-1, 0)

	if(druggy)
		adjust_drugginess(-1)

	if(hallucination)
		handle_hallucinations()

	if(drunkenness)
		drunkenness = max(drunkenness - (drunkenness * 0.04), 0)
		if(drunkenness >= 6)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "drunk", /datum/mood_event/drunk)
			if(prob(25))
				slurring += 2
			jitteriness = max(jitteriness - 3, 0)
			// throw_alert("drunk", /atom/movable/screen/alert/drunk)
			if(HAS_TRAIT(src, TRAIT_DRUNK_HEALING))
				adjustBruteLoss(-0.12, FALSE)
				adjustFireLoss(-0.06, FALSE)
			sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "drunk")
			clear_alert("drunk")
			sound_environment_override = SOUND_ENVIRONMENT_NONE

		if(mind && (mind.assigned_role == "Scientist" || mind.assigned_role == "Research Director"))
			if(SSresearch.science_tech)
				if(drunkenness >= 12.9 && drunkenness <= 13.8)
					drunkenness = round(drunkenness, 0.01)
					var/ballmer_percent = 0
					if(drunkenness == 13.35) // why run math if I dont have to
						ballmer_percent = 1
					else
						ballmer_percent = (-abs(drunkenness - 13.35) / 0.9) + 1
					if(prob(5))
						say(pick(GLOB.ballmer_good_msg), forced = "ballmer")
					SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = BALLMER_POINTS * ballmer_percent))
				if(drunkenness > 26) // by this point you're into windows ME territory
					if(prob(5))
						SSresearch.science_tech.remove_point_list(list(TECHWEB_POINT_TYPE_GENERIC = BALLMER_POINTS))
						say(pick(GLOB.ballmer_windows_me_msg), forced = "ballmer")

		if(drunkenness >= 41)
			if(prob(25))
				confused += 2
			Dizzy(10)
			if(HAS_TRAIT(src, TRAIT_DRUNK_HEALING)) // effects stack with lower tiers
				adjustBruteLoss(-0.3, FALSE)
				adjustFireLoss(-0.15, FALSE)

		if(drunkenness >= 51)
			if(prob(5))
				confused += 10
				vomit()
			Dizzy(25)

		if(drunkenness >= 61)
			if(prob(50))
				blur_eyes(5)
			if(HAS_TRAIT(src, TRAIT_DRUNK_HEALING))
				adjustBruteLoss(-0.4, FALSE)
				adjustFireLoss(-0.2, FALSE)

		if(drunkenness >= 71)
			blur_eyes(5)

		if(drunkenness >= 81)
			adjustToxLoss(0.2)
			if(prob(5) && !stat)
				to_chat(src, "<span class='warning'>Maybe you should lie down for a bit...</span>")

		if(drunkenness >= 91)
			adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.4, 60)
			if(prob(20) && !stat)
				if(SSshuttle.emergency.mode == SHUTTLE_DOCKED && is_station_level(z)) //QoL mainly
					to_chat(src, "<span class='warning'>You're so tired... but you can't miss that shuttle...</span>")
				else
					to_chat(src, "<span class='warning'>Just a quick nap...</span>")
					Sleeping(900)

		if(drunkenness >= 101)
			adjustToxLoss(4) //Let's be honest you shouldn't be alive by now
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "drunk")

//used in human and monkey handle_environment()
/mob/living/carbon/proc/natural_bodytemperature_stabilization()
	if (HAS_TRAIT(src, TRAIT_COLDBLOODED))
		return 0 //Return 0 as your natural temperature. Species proc handle_environment() will adjust your temperature based on this.

	var/body_temperature_difference = BODYTEMP_NORMAL - bodytemperature
	switch(bodytemperature)
		if(-INFINITY to BODYTEMP_COLD_DAMAGE_LIMIT) //Cold damage limit is 50 below the default, the temperature where you start to feel effects.
			return max((body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
		if(BODYTEMP_COLD_DAMAGE_LIMIT to BODYTEMP_NORMAL)
			return max(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, min(body_temperature_difference, BODYTEMP_AUTORECOVERY_MINIMUM/4))
		if(BODYTEMP_NORMAL to BODYTEMP_HEAT_DAMAGE_LIMIT) // Heat damage limit is 50 above the default, the temperature where you start to feel effects.
			return min(body_temperature_difference * metabolism_efficiency / BODYTEMP_AUTORECOVERY_DIVISOR, max(body_temperature_difference, -BODYTEMP_AUTORECOVERY_MINIMUM/4))
		if(BODYTEMP_HEAT_DAMAGE_LIMIT to INFINITY)
			return min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers
/////////
//LIVER//
/////////

/mob/living/carbon/proc/handle_liver(seconds, times_fired)
	var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if((!dna && !liver) || (NOLIVER in dna.species.species_traits))
		return
	if(!liver || liver.organ_flags & ORGAN_FAILING)
		liver_failure(seconds, times_fired)

/mob/living/carbon/proc/liver_failure(seconds, times_fired)
	reagents.end_metabolization(src, keep_liverless = TRUE) //Stops trait-based effects on reagents, to prevent permanent buffs
	reagents.metabolize(src, seconds, times_fired, can_overdose=FALSE, liverless = TRUE)
	if(HAS_TRAIT(src, TRAIT_STABLELIVER))
		return
	adjustToxLoss(4, TRUE,  TRUE)
	if(prob(15))
		to_chat(src, "<span class='danger'>You feel a stabbing pain in your abdomen!</span>")


////////////////
//BRAIN DAMAGE//
////////////////

/mob/living/carbon/proc/handle_brain_damage()
	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_life()

/////////////////////////////////////
//MONKEYS WITH TOO MUCH CHOLOESTROL//
/////////////////////////////////////

/mob/living/carbon/proc/can_heartattack()
	if(!needs_heart())
		return FALSE
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!heart || (heart.organ_flags & ORGAN_SYNTHETIC))
		return FALSE
	return TRUE

/mob/living/carbon/proc/needs_heart()
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE
	if(dna && dna.species && (NOBLOOD in dna.species.species_traits)) //not all carbons have species!
		return FALSE
	return TRUE

/mob/living/carbon/proc/undergoing_cardiac_arrest()
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(istype(heart) && heart.beating)
		return FALSE
	else if(!needs_heart())
		return FALSE
	return TRUE

/mob/living/carbon/proc/set_heartattack(status)
	if(!can_heartattack())
		return FALSE

	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!istype(heart))
		return

	heart.beating = !status
