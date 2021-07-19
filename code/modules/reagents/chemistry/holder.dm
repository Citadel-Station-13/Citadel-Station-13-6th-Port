#define CHEMICAL_QUANTISATION_LEVEL 0.001

/proc/build_chemical_reagent_list()
	//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id

	if(GLOB.chemical_reagents_list)
		return

	var/paths = subtypesof(/datum/reagent)
	GLOB.chemical_reagents_list = list()

	for(var/path in paths)
		var/datum/reagent/D = new path()
		GLOB.chemical_reagents_list[path] = D

/proc/build_chemical_reactions_list()
	//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
	// It is filtered into multiple lists within a list.
	// For example:
	// chemical_reaction_list[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma

	if(GLOB.chemical_reactions_list)
		return


	//Randomized need to go last since they need to check against conflicts with normal recipes
	var/paths = subtypesof(/datum/chemical_reaction) - typesof(/datum/chemical_reaction/randomized) + subtypesof(/datum/chemical_reaction/randomized)
	GLOB.chemical_reactions_list = list()

	for(var/path in paths)

		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()

		if(D.required_reagents && D.required_reagents.len)
			for(var/reaction in D.required_reagents)
				reaction_ids += reaction

		// Create filters based on each reagent type in the required reagents list
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list[id])
				GLOB.chemical_reactions_list[id] = list()
			GLOB.chemical_reactions_list[id] += D
			break // Don't bother adding ourselves to other reagent ids, it is redundant

///////////////////////////////////////////////////////////////////////////////////

/datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/chem_temp = 150
	var/pH = REAGENT_NORMAL_PH//Potential of hydrogen. Edited on adding new reagents, deleting reagents, and during fermi reactions.
	var/overallPurity = 1
	var/last_tick = 1
	var/addiction_tick = 1
	var/list/datum/reagent/addiction_list = new/list()
	var/reagents_holder_flags
	var/targetVol = 0 //the target volume, i.e. the total amount that can be created during a fermichem reaction.
	var/reactedVol = 0 //how much of the reagent is reacted during a fermireaction
	var/fermiIsReacting = FALSE //that prevents multiple reactions from occurring (i.e. add_reagent calls to process_reactions(), this stops any extra reactions.)
	var/fermiReactID //instance of the chem reaction used during a fermireaction, kept here so it's cache isn't lost between loops/procs.
	var/value_multiplier = DEFAULT_REAGENTS_VALUE //used for cargo reagents selling.

/datum/reagents/New(maximum=100, new_flags = NONE, new_value = DEFAULT_REAGENTS_VALUE)
	maximum_volume = maximum

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!GLOB.chemical_reagents_list)
		build_chemical_reagent_list()
	if(!GLOB.chemical_reactions_list)
		build_chemical_reactions_list()

	reagents_holder_flags = new_flags
	value_multiplier = new_value

/datum/reagents/Destroy()
	. = ..()
	//We're about to delete all reagents, so lets cleanup
	addiction_list.Cut()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		qdel(R)
	cached_reagents.Cut()
	cached_reagents = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null
	my_atom = null

// Used in attack logs for reagents in pills and such
/datum/reagents/proc/log_list()
	if(!length(reagent_list))
		return "no reagents"

	var/list/data = list()
	for(var/r in reagent_list) //no reagents will be left behind
		var/datum/reagent/R = r
		data += "[R.type] ([round(R.volume, CHEMICAL_QUANTISATION_LEVEL)]u)"
		//Using IDs because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)

/datum/reagents/proc/remove_any(amount = 1)
	var/list/cached_reagents = reagent_list
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1, cached_reagents.len)

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break
		if(total_volume <= 0 || !cached_reagents.len)
			break

		if(current_list_element > cached_reagents.len)
			current_list_element = 1

		var/datum/reagent/R = cached_reagents[current_list_element]
		remove_reagent(R.type, 1)

		current_list_element++
		total_transfered++
		update_total()

	handle_reactions()
	return total_transfered

/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			remove_reagent(R.type, R.volume * part, ignore_pH = TRUE)
		pH = REAGENT_NORMAL_PH
		update_total()
		handle_reactions()
		return amount

/datum/reagents/proc/get_master_reagent_name()
	var/list/cached_reagents = reagent_list
	var/name
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			name = R.name

	return name

/datum/reagents/proc/get_master_reagent_id()
	var/list/cached_reagents = reagent_list
	var/max_type
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			max_type = R.type

	return max_type

/datum/reagents/proc/get_master_reagent()
	var/list/cached_reagents = reagent_list
	var/datum/reagent/master
	var/max_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume > max_volume)
			max_volume = R.volume
			master = R

	return master

/datum/reagents/proc/trans_to(obj/target, amount = 1, multiplier = 1, preserve_data = 1, no_react = 0, log = FALSE)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return
	if(amount < 0)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	var/list/transferred = list()
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		var/transfer_amount = T.volume * part
		if(preserve_data)
			trans_data = copy_data(T)
		transferred += "[T] - [transfer_amount]"

		R.add_reagent(T.type, transfer_amount * multiplier, trans_data, chem_temp, T.purity, pH, no_react = TRUE, ignore_pH = TRUE) //we only handle reaction after every reagent has been transfered.
		remove_reagent(T.type, transfer_amount, ignore_pH = TRUE)

	if(log && amount > 0)
		var/atom/us = my_atom
		var/atom/them = R.my_atom
		var/location_string = "FROM [(us && "[us] ([REF(us)]) [COORD(us)]") || "NULL"] TO [(them && "[them] ([REF(them)]) [COORD(them)]") || "NULL"]"
		log_reagent_transfer("[location_string] - [key_name(usr)][istext(log) ? " - [log]" : ""]: trans_to with arguments [target] [amount] [multiplier] [preserve_data] [no_react] and reagents [english_list(transferred)]")

	update_total()
	R.update_total()
	if(!no_react)
		R.handle_reactions()
		src.handle_reactions()
	return amount

/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1)
	var/list/cached_reagents = reagent_list
	if(!target || !total_volume)
		return

	var/datum/reagents/R
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents

	if(amount < 0)
		return
	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/reagent in cached_reagents)
		var/datum/reagent/T = reagent
		var/copy_amount = T.volume * part
		if(preserve_data)
			trans_data = T.data
		R.add_reagent(T.type, copy_amount * multiplier, trans_data)

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount

/datum/reagents/proc/trans_id_to(obj/target, reagent, amount = 1, preserve_data = TRUE, log = FALSE)//Not sure why this proc didn't exist before. It does now! /N
	var/list/cached_reagents = reagent_list
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return
	if(amount < 0)
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/CR in cached_reagents)
		var/datum/reagent/current_reagent = CR
		if(current_reagent.type == reagent)
			if(preserve_data)
				trans_data = current_reagent.data
			R.add_reagent(current_reagent.type, amount, trans_data, chem_temp, current_reagent.purity, pH, no_react = TRUE)
			remove_reagent(current_reagent.type, amount, 1)
			if(log && amount > 0)
				var/atom/us = my_atom
				var/atom/them = R.my_atom
				var/location_string = "FROM [(us && "[us] ([REF(us)]) [COORD(us)]") || "NULL"] TO [(them && "[them] ([REF(them)]) [COORD(them)]") || "NULL"]"
				log_reagent_transfer("[location_string] - [key_name(usr)][istext(log) ? " - [log]" : ""]: trans_id_to with arguments [target] [reagent] [amount] [preserve_data]")
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	return amount

/**
 * Triggers metabolizing for all the reagents in this holder
 *
 * Arguments:
 * * mob/living/carbon/carbon - The mob to metabolize in, if null it uses [/datum/reagents/var/my_atom]
 * * delta_time - the time in server seconds between proc calls (when performing normally it will be 2)
 * * times_fired - the number of times the owner's life() tick has been called aka The number of times SSmobs has fired
 * * can_overdose - Allows overdosing
 * * liverless - Stops reagents that aren't set as [/datum/reagent/var/self_consuming] from metabolizing
 */
/datum/reagents/proc/metabolize(mob/living/carbon/owner, delta_time, times_fired, can_overdose = FALSE, liverless = FALSE)
	var/list/cached_reagents = reagent_list
	if(owner)
		expose_temperature(owner.bodytemperature, 0.25)
	var/need_mob_update = FALSE
	for(var/datum/reagent/reagent as anything in cached_reagents)
		need_mob_update += metabolize_reagent(owner, reagent, delta_time, times_fired, can_overdose, liverless)
	if(can_overdose)
		if(addiction_tick == 6)
			addiction_tick = 1
			for(var/addiction in addiction_list)
				var/datum/reagent/R = addiction
				if(owner && R)
					R.addiction_stage++
					if(1 <= R.addiction_stage && R.addiction_stage <= R.addiction_stage1_end)
						need_mob_update += R.addiction_act_stage1(owner)
					else if(R.addiction_stage1_end < R.addiction_stage && R.addiction_stage <= R.addiction_stage2_end)
						need_mob_update += R.addiction_act_stage2(owner)
					else if(R.addiction_stage2_end < R.addiction_stage && R.addiction_stage <= R.addiction_stage3_end)
						need_mob_update += R.addiction_act_stage3(owner)
					else if(R.addiction_stage3_end < R.addiction_stage && R.addiction_stage <= R.addiction_stage4_end)
						need_mob_update += R.addiction_act_stage4(owner)
					else if(R.addiction_stage4_end < R.addiction_stage)
						remove_addiction(R)
					else
						SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "[R.type]_overdose")
		addiction_tick++
	if(owner && need_mob_update) //some of the metabolized reagents had effects on the mob that requires some updates.
		owner.updatehealth()
		owner.update_mobility()
		owner.update_stamina()
	update_total()

/*
 * Metabolises a single reagent for a target owner carbon mob. See above.
 *
 * Arguments:
 * * mob/living/carbon/owner - The mob to metabolize in, if null it uses [/datum/reagents/var/my_atom]
 * * delta_time - the time in server seconds between proc calls (when performing normally it will be 2)
 * * times_fired - the number of times the owner's life() tick has been called aka The number of times SSmobs has fired
 * * can_overdose - Allows overdosing
 * * liverless - Stops reagents that aren't set as [/datum/reagent/var/self_consuming] from metabolizing
 */
/datum/reagents/proc/metabolize_reagent(mob/living/carbon/owner, datum/reagent/reagent, delta_time, times_fired, can_overdose = FALSE, liverless = FALSE)
	var/need_mob_update = FALSE
	if(QDELETED(reagent.holder))
		return FALSE

	if(!owner)
		owner = reagent.holder.my_atom

	if(owner && reagent)
		if(!owner.reagent_check(reagent, delta_time, times_fired) != TRUE)
			return
		if(liverless && !reagent.self_consuming) //need to be metabolized
			return
		if(!reagent.metabolizing)
			reagent.metabolizing = TRUE
			reagent.on_mob_metabolize(owner)
		if(can_overdose)
			if(reagent.overdose_threshold)
				if(reagent.volume >= reagent.overdose_threshold && !reagent.overdosed)
					reagent.overdosed = TRUE
					need_mob_update += reagent.overdose_start(owner)
					log_game("[key_name(owner)] has started overdosing on [reagent.name] at [reagent.volume] units.")

			// for(var/addiction in reagent.addiction_types)
			// 	owner.mind?.add_addiction_points(addiction, reagent.addiction_types[addiction] * REAGENTS_METABOLISM)
			if(reagent.addiction_threshold)
				if(reagent.volume > reagent.addiction_threshold && !is_type_in_list(reagent, addiction_list))
					var/datum/reagent/new_reagent = new reagent.type()
					addiction_list.Add(new_reagent)
			if(is_type_in_list(reagent, addiction_list))
				for(var/addiction in addiction_list)
					var/datum/reagent/A = addiction
					if(istype(reagent, A))
						A.addiction_stage = -15 // you're satisfied for a good while.

			if(reagent.overdosed)
				need_mob_update += reagent.overdose_process(owner, delta_time, times_fired)

		need_mob_update += reagent.on_mob_life(owner, delta_time, times_fired)
	return need_mob_update

/// Signals that metabolization has stopped, triggering the end of trait-based effects
/datum/reagents/proc/end_metabolization(mob/living/carbon/C, keep_liverless = TRUE)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/reagent as anything in cached_reagents)
		if(QDELETED(reagent.holder))
			continue
		if(keep_liverless && reagent.self_consuming) //Will keep working without a liver
			continue
		if(!C)
			C = reagent.holder.my_atom
		if(reagent.metabolizing)
			reagent.metabolizing = FALSE
			reagent.on_mob_end_metabolize(C)

/datum/reagents/proc/remove_addiction(datum/reagent/R)
	to_chat(my_atom, "<span class='notice'>You feel like you've gotten over your need for [R.name].</span>")
	SEND_SIGNAL(my_atom, COMSIG_CLEAR_MOOD_EVENT, "[R.type]_overdose")
	if(ismob(my_atom))
		var/turf/T = get_turf(my_atom)
		log_reagent("OVERDOSE STOP: [key_name(my_atom)] at [AREACOORD(T)] got over their need for [R].")
	addiction_list.Remove(R)
	qdel(R)

/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_move (A, Running)
	update_total()

/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		R.on_update (A)
	update_total()


/datum/reagents/proc/handle_reactions()//HERE EDIT HERE THE MAIN REACTION
	if(fermiIsReacting) //This ARRESTS other reactions. If you don't want this, then remove it.
		return

	if(reagents_holder_flags & NO_REACT)
		return //Yup, no reactions here. No siree.

	var/list/cached_reagents = reagent_list
	var/list/cached_reactions = GLOB.chemical_reactions_list
	var/datum/cached_my_atom = my_atom

	var/reaction_occurred = 0 // checks if reaction, binary variable
	var/continue_reacting = FALSE //Helps keep track what kind of reaction is occuring; standard or fermi.

	do
		var/list/possible_reactions = list()
		reaction_occurred = 0
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			for(var/reaction in cached_reactions[R.type]) // Was a big list but now it should be smaller since we filtered it with our reagent type
				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction
				var/list/cached_required_reagents = C.required_reagents
				var/total_required_reagents = cached_required_reagents.len
				var/total_matching_reagents = 0
				var/list/cached_required_catalysts = C.required_catalysts
				var/total_required_catalysts = cached_required_catalysts.len
				var/total_matching_catalysts= 0
				var/matching_container = 0
				var/matching_other = 0
				var/required_temp = C.required_temp
				var/is_cold_recipe = C.is_cold_recipe
				var/meets_temp_requirement = 0
				var/has_special_react = C.special_react
				var/can_special_react = 0


				for(var/B in cached_required_reagents)
					if(!has_reagent(B, cached_required_reagents[B]))//Allows vols at less than 1 to react.
						break
					total_matching_reagents++
				for(var/B in cached_required_catalysts)
					if(!has_reagent(B, cached_required_catalysts[B]))
						break
					total_matching_catalysts++
				if(cached_my_atom)
					if(!C.required_container)
						matching_container = 1

					else
						if(cached_my_atom.type == C.required_container)
							matching_container = 1
					if (isliving(cached_my_atom) && !C.mob_react) //Makes it so certain chemical reactions don't occur in mobs
						return
					if(!C.required_other)
						matching_other = 1

					else if(istype(cached_my_atom, /obj/item/slime_extract))//if the object is a slime_extract.
						var/obj/item/slime_extract/M = cached_my_atom

						if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1
				else
					if(!C.required_container)
						matching_container = 1
					if(!C.required_other)
						matching_other = 1

				if(required_temp == 0 || (is_cold_recipe && chem_temp <= required_temp) || (!is_cold_recipe && chem_temp >= required_temp))//Temperature check!!
					meets_temp_requirement = 1

				if(!has_special_react || C.check_special_react(src))
					can_special_react = 1

				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && meets_temp_requirement && can_special_react)
					possible_reactions  += C

		sortTim(possible_reactions, /proc/cmp_chemical_reactions_default, FALSE)

		if(possible_reactions.len)
			var/datum/chemical_reaction/selected_reaction = possible_reactions[1]
			var/list/cached_required_reagents = selected_reaction.required_reagents//update reagents list
			var/list/cached_results = selected_reaction.results//resultant chemical list
			var/special_react_result = selected_reaction.check_special_react(src)
			var/list/multiplier = INFINITY

			//Splits reactions into two types; FermiChem is advanced reaction mechanics, Other is default reaction.
			//FermiChem relies on two additional properties; pH and impurity
			//Temperature plays into a larger role too.
			var/datum/chemical_reaction/C = selected_reaction

			if (C.FermiChem && !continue_reacting)
				if (chem_temp > C.ExplodeTemp) //This is first to ensure explosions.
					var/datum/chemical_reaction/Ferm = selected_reaction
					fermiIsReacting = FALSE
					SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[Ferm] explosion"))
					Ferm.FermiExplode(src, my_atom, volume = total_volume, temp = chem_temp, pH = pH)
					return 0

				//This is just to calc the on_reaction multiplier, and is a candidate for removal.
				for(var/B in cached_required_reagents)
					multiplier = min(multiplier, round((get_reagent_amount(B) / cached_required_reagents[B]), 0.0001))
				for(var/P in selected_reaction.results)
					targetVol = cached_results[P]*multiplier

				if(!((chem_temp <= C.ExplodeTemp) && (chem_temp >= C.OptimalTempMin)))
					return 0 //Not hot enough
				if(! ((pH >= (C.OptimalpHMin - C.ReactpHLim)) && (pH <= (C.OptimalpHMax + C.ReactpHLim)) ))//To prevent pointless reactions
					return 0
				if (fermiIsReacting)
					return 0
				else
					START_PROCESSING(SSprocessing, src)
					selected_reaction.on_reaction(src, my_atom, multiplier)
					fermiIsReacting = TRUE
					fermiReactID = selected_reaction
					reaction_occurred = 1

		//Standard reaction mechanics:
			else
				if (C.FermiChem)//Just to make sure, should only proc when grenades are combining.
					if (chem_temp > C.ExplodeTemp) //To allow fermigrenades
						var/datum/chemical_reaction/fermi/Ferm = selected_reaction
						fermiIsReacting = FALSE
						SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[Ferm] explosion"))
						Ferm.FermiExplode(src, my_atom, volume = total_volume, temp = chem_temp, pH = pH)
					return 0

				for(var/B in cached_required_reagents) //
					multiplier = min(multiplier, round((get_reagent_amount(B) / cached_required_reagents[B]), CHEMICAL_QUANTISATION_LEVEL))


				for(var/B in cached_required_reagents)
					remove_reagent(B, (multiplier * cached_required_reagents[B]), safety = 1, ignore_pH = TRUE)

				for(var/P in selected_reaction.results)
					multiplier = max(multiplier, 1) //this shouldnt happen ...
					SSblackbox.record_feedback("tally", "chemical_reaction", cached_results[P]*multiplier, P)//log
					add_reagent(P, cached_results[P]*multiplier, null, chem_temp)


				var/list/seen = fov_viewers(4, get_turf(my_atom))//Sound and sight checkers
				var/iconhtml = icon2html(cached_my_atom, seen)
				if(cached_my_atom)
					if(!ismob(cached_my_atom)) // No bubbling mobs
						if(selected_reaction.mix_sound)
							playsound(get_turf(cached_my_atom), selected_reaction.mix_sound, 80, 1)

						for(var/mob/M in seen)
							to_chat(M, "<span class='notice'>[iconhtml] [selected_reaction.mix_message]</span>")

					if(istype(cached_my_atom, /obj/item/slime_extract))//if there's an extract and it's used up.
						var/obj/item/slime_extract/ME2 = my_atom
						ME2.Uses--
						if(ME2.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in seen)
								to_chat(M, "<span class='notice'>[iconhtml] \The [my_atom]'s power is consumed in the reaction.</span>")
								ME2.name = "used slime extract"
								ME2.desc = "This extract has been used up."

				selected_reaction.on_reaction(src, multiplier, special_react_result)
				reaction_occurred = 1
				continue_reacting = TRUE

	while(reaction_occurred)
	update_total()
	return 0

/datum/reagents/process()
	var/datum/chemical_reaction/C = fermiReactID

	var/list/cached_required_reagents = C.required_reagents//update reagents list
	var/list/cached_results = C.results//resultant chemical list
	var/multiplier = INFINITY
	for(var/B in cached_required_reagents) //
		multiplier = min(multiplier, round((get_reagent_amount(B) / cached_required_reagents[B]), 0.0001))
	if (multiplier <= 0)//clarity
		fermiEnd()
		return

	if(C.required_catalysts)
		for(var/P in C.required_catalysts)
			if(!has_reagent(P))
				fermiEnd()
				return

	if (!fermiIsReacting)
		CRASH("Fermi has refused to stop reacting even though we asked her nicely.")

	if (!(chem_temp >= C.OptimalTempMin))//To prevent pointless reactions
		fermiEnd()
		return

	if (!( (pH >= (C.OptimalpHMin - C.ReactpHLim)) && (pH <= (C.OptimalpHMax + C.ReactpHLim)) )) //if pH is too far out, (could possibly allow reactions at this point, after the reaction has started, but make purity = 0)
		fermiEnd()
		return

	reactedVol = fermiReact(fermiReactID, chem_temp, pH, reactedVol, targetVol, cached_required_reagents, cached_results, multiplier)
	if(round(reactedVol, CHEMICAL_QUANTISATION_LEVEL) == round(targetVol, CHEMICAL_QUANTISATION_LEVEL))
		fermiEnd()
	if(!reactedVol)//Maybe unnessicary.
		fermiEnd()
	return

/datum/reagents/proc/fermiEnd()
	var/datum/chemical_reaction/C = fermiReactID
	STOP_PROCESSING(SSprocessing, src)
	fermiIsReacting = FALSE
	reactedVol = 0
	targetVol = 0
	//Cap off values
	for(var/datum/reagent/R in reagent_list)
		R.volume = round(R.volume, CHEMICAL_QUANTISATION_LEVEL)//To prevent runaways.
	//pH check, handled at the end to reduce calls.
	if(istype(my_atom, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = my_atom
		RC.pH_check()
	C.FermiFinish(src, my_atom, reactedVol)
	reactedVol = 0
	targetVol = 0
	handle_reactions()
	update_total()
	//Reaction sounds and words
	my_atom.visible_message("<span class='notice'>[icon2html(my_atom, viewers(DEFAULT_MESSAGE_RANGE, src))] [C.mix_message]</span>")

/datum/reagents/proc/fermiReact(selected_reaction, cached_temp, cached_pH, reactedVol, targetVol, cached_required_reagents, cached_results, multiplier)
	var/datum/chemical_reaction/C = selected_reaction
	var/deltaT = 0
	var/deltapH = 0
	var/stepChemAmmount = 0

	//get purity from combined beaker reactant purities HERE.
	var/purity = 1

	//Begin checks
	//For now, purity is handled elsewhere (on add)
	//Calculate DeltapH (Deviation of pH from optimal)
	//Lower range
	if (cached_pH < C.OptimalpHMin)
		if (cached_pH < (C.OptimalpHMin - C.ReactpHLim))
			deltapH = 0
			return//If outside pH range, no reaction
		else
			deltapH = (((cached_pH - (C.OptimalpHMin - C.ReactpHLim))**C.CurveSharppH)/((C.ReactpHLim**C.CurveSharppH)))
	//Upper range
	else if (cached_pH > C.OptimalpHMax)
		if (cached_pH > (C.OptimalpHMax + C.ReactpHLim))
			deltapH = 0
			return //If outside pH range, no reaction
		else
			deltapH = (((- cached_pH + (C.OptimalpHMax + C.ReactpHLim))**C.CurveSharppH)/(C.ReactpHLim**C.CurveSharppH))//Reverse - to + to prevent math operation failures.
	//Within mid range
	else if (cached_pH >= C.OptimalpHMin  && cached_pH <= C.OptimalpHMax)
		deltapH = 1
	//This should never proc:
	else
		WARNING("[my_atom] attempted to determine FermiChem pH for '[C.type]' which broke for some reason! ([usr])")

	//Calculate DeltaT (Deviation of T from optimal)
	if (cached_temp < C.OptimalTempMax && cached_temp >= C.OptimalTempMin)
		deltaT = (((cached_temp - C.OptimalTempMin)**C.CurveSharpT)/((C.OptimalTempMax - C.OptimalTempMin)**C.CurveSharpT))
	else if (cached_temp >= C.OptimalTempMax)
		deltaT = 1
	else
		deltaT = 0

	purity = (deltapH)//set purity equal to pH offset

	//Then adjust purity of result with reagent purity.
	purity *= reactant_purity(C)

	var/removeChemAmmount //remove factor
	var/addChemAmmount //add factor
	//ONLY WORKS FOR ONE PRODUCT AT THE MOMENT
	//Calculate how much product to make and how much reactant to remove factors..
	for(var/P in cached_results)
		stepChemAmmount = (multiplier*cached_results[P])
		if (stepChemAmmount > C.RateUpLim)
			stepChemAmmount = C.RateUpLim
		addChemAmmount = deltaT * stepChemAmmount
		if (addChemAmmount >= (targetVol - reactedVol))
			addChemAmmount = (targetVol - reactedVol)
		if (addChemAmmount < CHEMICAL_QUANTISATION_LEVEL)
			addChemAmmount = CHEMICAL_QUANTISATION_LEVEL
		removeChemAmmount = (addChemAmmount/cached_results[P])
		//keep limited.
		addChemAmmount = round(addChemAmmount, CHEMICAL_QUANTISATION_LEVEL)
		removeChemAmmount = round(removeChemAmmount, CHEMICAL_QUANTISATION_LEVEL)
		//This is kept for future bugtesters.
		//message_admins("Reaction vars: PreReacted: [reactedVol] of [targetVol]. deltaT [deltaT], multiplier [multiplier], Step [stepChemAmmount], uncapped Step [deltaT*(multiplier*cached_results[P])], addChemAmmount [addChemAmmount], removeFactor [removeChemAmmount] Pfactor [cached_results[P]], adding [addChemAmmount]")

	//remove reactants
	for(var/B in cached_required_reagents)
		remove_reagent(B, (removeChemAmmount * cached_required_reagents[B]), safety = 1, ignore_pH = TRUE)

	//add product
	var/TotalStep = 0
	for(var/P in cached_results)
		SSblackbox.record_feedback("tally", "chemical_reaction", addChemAmmount, P)//log
		SSblackbox.record_feedback("tally", "fermi_chem", addChemAmmount, P)
		add_reagent(P, (addChemAmmount), null, cached_temp, purity)
		TotalStep += addChemAmmount//for multiple products
		//Above should reduce yeild based on holder purity.
		//Purity Check
		for(var/datum/reagent/R in my_atom.reagents.reagent_list)
			if(P == R.type)
				if (R.purity < C.PurityMin)//If purity is below the min, blow it up.
					fermiIsReacting = FALSE
					SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[P] explosion"))
					C.FermiExplode(src, my_atom, (total_volume), cached_temp, pH)
					STOP_PROCESSING(SSprocessing, src)
					return

	C.FermiCreate(src, addChemAmmount, purity)//proc that calls when step is done

	//Apply pH changes and thermal output of reaction to beaker
	chem_temp = round(cached_temp + (C.ThermicConstant * addChemAmmount))
	pH += (C.HIonRelease * addChemAmmount)
	//keep track of the current reacted amount
	reactedVol = reactedVol + addChemAmmount

	//Check extremes
	if (chem_temp > C.ExplodeTemp)
		//go to explode proc
		fermiIsReacting = FALSE
		SSblackbox.record_feedback("tally", "fermi_chem", 1, ("[C] explosions"))
		C.FermiExplode(src, my_atom, (total_volume), chem_temp, pH)
		STOP_PROCESSING(SSprocessing, src)
		return

	//Make sure things are limited, but superacids/bases can push forward the reaction
	pH = clamp(pH, 0, 14)

	//return said amount to compare for next step.
	return (reactedVol)

//Currently calculates it irrespective of required reagents at the start
/datum/reagents/proc/reactant_purity(var/datum/chemical_reaction/C, holder)
	var/list/cached_reagents = reagent_list
	var/i = 0
	var/cachedPurity
	for(var/datum/reagent/R in my_atom.reagents.reagent_list)
		if (R in cached_reagents)
			cachedPurity += R.purity
			i++
	if(!i)//I've never seen it get here with 0, but in case
		CRASH("No reactants found mid reaction for [fermiReactID]/[C], how it got here is beyond me. Beaker: [holder]")
	return cachedPurity/i

/datum/reagents/proc/uncache_purity(id)
	var/datum/reagent/R = has_reagent(id)
	if(!R)
		return
	if(R.cached_purity == 1)
		return
	R.purity = R.cached_purity

/datum/reagents/proc/isolate_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type != reagent)
			del_reagent(R.type)
			update_total()

/datum/reagents/proc/del_reagent(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if(R.type == reagent)
			if(my_atom && isliving(my_atom))
				var/mob/living/M = my_atom
				if(R.metabolizing)
					R.metabolizing = FALSE
					R.on_mob_end_metabolize(M)
				R.on_mob_delete(M)
			//Clear from relevant lists
			addiction_list -= R
			qdel(R)
			reagent_list -= R
			update_total()
			if(my_atom)
				my_atom.on_reagent_change(DEL_REAGENT)
	return 1

/datum/reagents/proc/update_total()
	var/list/cached_reagents = reagent_list
	total_volume = 0
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.volume <= 0)//For clarity
			del_reagent(R.type)
		if((R.volume < 0.01) && !fermiIsReacting)
			del_reagent(R.type)
		else
			total_volume += R.volume
	if(!reagent_list || !total_volume)
		pH = REAGENT_NORMAL_PH
	return 0

/datum/reagents/proc/clear_reagents()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		del_reagent(R.type)
	pH = REAGENT_NORMAL_PH
	return 0

/datum/reagents/proc/reaction(atom/A, method = TOUCH, volume_modifier = 1, show_message = 1)
	var/react_type
	if(isliving(A))
		react_type = "LIVING"
		if(method == INGEST)
			var/mob/living/L = A
			L.taste(src)
	else if(isturf(A))
		react_type = "TURF"
	else if(isobj(A))
		react_type = "OBJ"
	else
		return
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		switch(react_type)
			if("LIVING")
				var/touch_protection = 0
				if(method == VAPOR)
					var/mob/living/L = A
					touch_protection = L.get_permeability_protection()
				R.reaction_mob(A, method, R.volume * volume_modifier, show_message, touch_protection)
			if("TURF")
				R.reaction_turf(A, R.volume * volume_modifier, show_message)
			if("OBJ")
				R.reaction_obj(A, R.volume * volume_modifier, show_message)

/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

//Returns the average specific heat for all reagents currently in this holder.
/datum/reagents/proc/specific_heat()
	. = 0
	var/cached_amount = total_volume		//cache amount
	var/list/cached_reagents = reagent_list		//cache reagents
	for(var/I in cached_reagents)
		var/datum/reagent/R = I
		. += R.specific_heat * (R.volume / cached_amount)

/datum/reagents/proc/adjust_thermal_energy(J, min_temp = 2.7, max_temp = 1000)
	var/S = specific_heat()
	chem_temp = clamp(chem_temp + (J / (S * total_volume)), min_temp, max_temp)
	if(istype(my_atom, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = my_atom
		RC.temp_check()

/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, reagtemp = 300, other_purity = 1, other_pH, no_react = 0, ignore_pH = FALSE)

	if(!isnum(amount) || !amount)
		return FALSE

	if(amount < CHEMICAL_QUANTISATION_LEVEL)//To prevent small ammount problems.
		return FALSE

	var/datum/reagent/D = GLOB.chemical_reagents_list[reagent]
	if(!D)
		WARNING("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")
		return FALSE

	if (D.type == /datum/reagent/water && !no_react && !istype(my_atom, /obj/item/reagent_containers/food)) //Do like an otter, add acid to water, but also don't blow up botany.
		if (pH < 2)
			SSblackbox.record_feedback("tally", "fermi_chem", 1, "water-acid explosions")
			var/datum/effect_system/smoke_spread/chem/s = new
			var/turf/T = get_turf(my_atom)
			var/datum/reagents/R = new/datum/reagents(3000)
			R.add_reagent(/datum/reagent/fermi/fermiAcid, amount)
			for (var/datum/reagent/reagentgas in reagent_list)
				R.add_reagent(reagentgas, amount/5)
				remove_reagent(reagentgas, amount/5)
			s.set_up(R, clamp(amount/10, 0, 2), T)
			s.start()
			return FALSE

	if(!pH)
		other_pH = D.pH

	update_total()
	var/cached_total = total_volume
	if(cached_total + amount > maximum_volume)
		amount = (maximum_volume - cached_total) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.
		if(amount <= 0)
			return FALSE
	var/new_total = cached_total + amount
	var/cached_temp = chem_temp
	var/list/cached_reagents = reagent_list
	var/cached_pH = pH



	//Equalize temperature - Not using specific_heat() because the new chemical isn't in yet.
	var/specific_heat = 0
	var/thermal_energy = 0
	for(var/i in cached_reagents)
		var/datum/reagent/R = i
		specific_heat += R.specific_heat * (R.volume / new_total)
		thermal_energy += R.specific_heat * R.volume * cached_temp
	specific_heat += D.specific_heat * (amount / new_total)
	thermal_energy += D.specific_heat * amount * reagtemp
	chem_temp = thermal_energy / (specific_heat * new_total)

	//cacluate reagent based pH shift.
	if(ignore_pH)
		pH = ((cached_pH * cached_total)+(other_pH * amount))/(cached_total + amount)//should be right
	else
		pH = ((cached_pH * cached_total)+(D.pH * amount))/(cached_total + amount)//should be right
	if(istype(my_atom, /obj/item/reagent_containers/))
		var/obj/item/reagent_containers/RC = my_atom
		RC.pH_check()//checks beaker resilience

	//add the reagent to the existing if it exists
	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if (R.type == reagent) //IF MERGING
			//Add amount and equalize purity
			R.volume += round(amount, CHEMICAL_QUANTISATION_LEVEL)
			R.purity = ((R.purity * R.volume) + (other_purity * amount)) /((R.volume + amount)) //This should add the purity to the product

			update_total()
			if(my_atom)
				my_atom.on_reagent_change(ADD_REAGENT)
			if(isliving(my_atom))
				if(R.chemical_flags & REAGENT_ONMOBMERGE)//Forces on_mob_add proc when a chem is merged
					R.on_mob_add(my_atom, amount)
			R.on_merge(data, amount, my_atom, other_purity)
			if(!no_react)
				handle_reactions()

			return TRUE


	//otherwise make a new one
	var/datum/reagent/R = new D.type(data)
	cached_reagents += R
	R.holder = src
	R.volume = round(amount, CHEMICAL_QUANTISATION_LEVEL)
	R.purity = other_purity
	R.loc = get_turf(my_atom)
	if(data)
		R.data = data
		R.on_new(data)
	if(R.chemical_flags & REAGENT_FORCEONNEW)//Allows on new without data overhead.
		R.on_new(pH) //Add more as desired.


	if(isliving(my_atom))
		R.on_mob_add(my_atom, amount)
	update_total()
	if(my_atom)
		my_atom.on_reagent_change(ADD_REAGENT)
	if(!no_react)
		handle_reactions()
	return TRUE


/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null) // Like add_reagent but you can enter a list. Format it like this: list(/datum/reagent/toxin = 10, /datum/reagent/consumable/ethanol/beer = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)

/datum/reagents/proc/remove_reagent(reagent, amount, safety, ignore_pH = FALSE)//Added a safety check for the trans_id_to

	if(isnull(amount))
		amount = 0
		CRASH("null amount passed to reagent code")

	if(!isnum(amount))
		return FALSE

	if(amount < 0)
		return FALSE

	var/list/cached_reagents = reagent_list

	for(var/A in cached_reagents)
		var/datum/reagent/R = A
		if (R.type == reagent)
			//In practice this is really confusing and players feel like it randomly melts their beakers, but I'm not sure how else to handle it. We'll see how it goes and I can remove this if it confuses people.
			if(!ignore_pH)
				//if (((pH > R.pH) && (pH <= 7)) || ((pH < R.pH) && (pH >= 7)))
				pH = (((pH - R.pH) / total_volume) * amount) + pH
			if(istype(my_atom, /obj/item/reagent_containers/))
				var/obj/item/reagent_containers/RC = my_atom
				RC.pH_check()//checks beaker resilience)
			//clamp the removal amount to be between current reagent amount
			//and zero, to prevent removing more than the holder has stored
			amount = clamp(amount, 0, R.volume)
			R.volume -= amount
			update_total()
			if(total_volume <= 0)//Because this can result in 0, I don't want it to crash.
				pH = REAGENT_NORMAL_PH
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change(REM_REAGENT)
			return TRUE

	return FALSE

/datum/reagents/proc/has_reagent(reagent, amount = -1)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			if(!amount)
				return R
			else
				if(round(R.volume, CHEMICAL_QUANTISATION_LEVEL) >= amount)
					return R
				else
					return 0

	return 0

/datum/reagents/proc/get_reagent_amount(reagent)
	var/list/cached_reagents = reagent_list
	for(var/_reagent in cached_reagents)
		var/datum/reagent/R = _reagent
		if (R.type == reagent)
			return round(R.volume, CHEMICAL_QUANTISATION_LEVEL)

	return 0

/datum/reagents/proc/get_reagents()
	var/list/names = list()
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		names += R.name

	return jointext(names, ",")

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount))
		return 1
	var/list/cached_reagents = reagent_list
	var/has_removed_reagent = 0

	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.type, amount, safety)

	return has_removed_reagent

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			return R.data

/datum/reagents/proc/set_data(reagent_id, new_data)
	var/list/cached_reagents = reagent_list
	for(var/reagent in cached_reagents)
		var/datum/reagent/R = reagent
		if(R.type == reagent_id)
			R.data = new_data

/datum/reagents/proc/copy_data(datum/reagent/current_reagent)
	if(!current_reagent || !current_reagent.data)
		return null
	if(!istype(current_reagent.data, /list))
		return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if(trans_data["viruses"])
		var/list/v = trans_data["viruses"]
		trans_data["viruses"] = v.Copy()

	return trans_data

/datum/reagents/proc/get_reagent(type)
	var/list/cached_reagents = reagent_list
	. = locate(type) in cached_reagents

/datum/reagents/proc/generate_taste_message(minimum_percent=15)
	// the lower the minimum percent, the more sensitive the message is.
	var/list/out = list()
	var/list/tastes = list() //descriptor = strength
	if(minimum_percent <= 100)
		for(var/datum/reagent/R in reagent_list)
			if(!R.taste_mult)
				continue

			if(istype(R, /datum/reagent/consumable/nutriment))
				var/list/taste_data = R.data
				for(var/taste in taste_data)
					var/ratio = taste_data[taste]
					var/amount = ratio * R.taste_mult * R.volume
					if(taste in tastes)
						tastes[taste] += amount
					else
						tastes[taste] = amount
			else
				var/taste_desc = R.taste_description
				var/taste_amount = R.volume * R.taste_mult
				if(taste_desc in tastes)
					tastes[taste_desc] += taste_amount
				else
					tastes[taste_desc] = taste_amount
		//deal with percentages
		// TODO it would be great if we could sort these from strong to weak
		var/total_taste = counterlist_sum(tastes)
		if(total_taste > 0)
			for(var/taste_desc in tastes)
				var/percent = tastes[taste_desc]/total_taste * 100
				if(percent < minimum_percent)
					continue
				var/intensity_desc = "a hint of"
				if(ISINRANGE(percent, minimum_percent * 2, minimum_percent * 3)|| percent == 100)
					intensity_desc = ""
				else if(percent > minimum_percent * 3)
					intensity_desc = "the strong flavor of"
				if(intensity_desc != "")
					out += "[intensity_desc] [taste_desc]"
				else
					out += "[taste_desc]"

	return english_list(out, "something indescribable")

/datum/reagents/proc/expose_temperature(var/temperature, var/coeff=0.02)
	var/temp_delta = (temperature - chem_temp) * coeff
	if(temp_delta > 0)
		chem_temp = min(chem_temp + max(temp_delta, 1), temperature)
	else
		chem_temp = max(chem_temp + min(temp_delta, -1), temperature)
	chem_temp = round(chem_temp)
	handle_reactions()

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol, flags, new_value)
	if(reagents)
		qdel(reagents)
	reagents = new/datum/reagents(max_vol, flags, new_value)
	reagents.my_atom = src

/proc/get_random_reagent_id()	// Returns a random reagent type minus blacklisted reagents
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing  in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.can_synth))
				random_reagents += R
	var/picked_reagent = pick(random_reagents)
	return picked_reagent

/proc/get_chem_id(chem_name)
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[X]
		if(ckey(chem_name) == ckey(lowertext(R.name)))
			return X
