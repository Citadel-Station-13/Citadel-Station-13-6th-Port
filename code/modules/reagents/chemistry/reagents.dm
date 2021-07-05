#define REM REAGENTS_EFFECT_MULTIPLIER
GLOBAL_LIST_INIT(name2reagent, build_name2reagent())

/proc/build_name2reagent()
	. = list()
	for (var/t in subtypesof(/datum/reagent))
		var/datum/reagent/R = t
		if (length(initial(R.name)))
			.[ckey(initial(R.name))] = t


//Various reagents
//Toxin & acid reagents
//Hydroponics stuff

/datum/reagent
	var/name = "Reagent"
	var/description = ""
	var/specific_heat = SPECIFIC_HEAT_DEFAULT		//J/(K*mol)
	var/taste_description = "metaphorical salt"
	var/taste_mult = 1 //how this taste compares to others. Higher values means it is more noticable
	var/glass_name = "glass of ...what?" // use for specialty drinks.
	var/glass_desc = "You can't really tell what this is."
	var/glass_icon_state = null // Otherwise just sets the icon to a normal glass with the mixture of the reagents in the glass.
	var/shot_glass_icon_state = null
	var/datum/reagents/holder = null
	var/reagent_state = LIQUID
	var/list/data
	var/current_cycle = 0
	var/volume = 0									//pretend this is moles
	var/color = "#000000" // rgb: 0, 0, 0
	var/can_synth = TRUE // can this reagent be synthesized? (for example: odysseus syringe gun)
	var/metabolization_rate = REAGENTS_METABOLISM //how fast the reagent is metabolized by the mob
	var/overrides_metab = 0
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/addiction_stage1_end = 10
	var/addiction_stage2_end = 20
	var/addiction_stage3_end = 30
	var/addiction_stage4_end = 40
	var/overdosed = 0 // You fucked up and this is now triggering its overdose effects, purge that shit quick.
	var/self_consuming = FALSE  //I think this uhhh, makes weird stuff happen when metabolising, but... doesn't seem to do what I think, so I'm gonna leave it.
	//Fermichem vars:
	var/purity 				= 1 		//How pure a chemical is from 0 - 1.
	var/cached_purity		= 1
	var/turf/loc = null 				//Should be the creation location!
	var/pH = 7							//pH of the specific reagent, used for calculating the sum pH of a holder.
	//var/SplitChem			= FALSE		//If the chem splits on metabolism
	var/impure_chem						// What chemical is metabolised with an inpure reaction
	var/inverse_chem_val 		= 0			// If the impurity is below 0.5, replace ALL of the chem with inverse_chemupon metabolising
	var/inverse_chem					// What chem is metabolised when purity is below inverse_chem_val, this shouldn't be made, but if it does, well, I guess I'll know about it.
	var/metabolizing = FALSE
	var/chemical_flags // See fermi/readme.dm REAGENT_DEAD_PROCESS, REAGENT_DONOTSPLIT, REAGENT_ONLYINVERSE, REAGENT_ONMOBMERGE, REAGENT_INVISIBLE, REAGENT_FORCEONNEW, REAGENT_SNEAKYNAME
	var/value = REAGENT_VALUE_NONE //How much does it sell for in cargo?
	var/datum/material/material //are we made of material?
	var/gas //do we have an associated gas?
	var/boiling_point = null // point at which this gas boils; if null, will never boil (and thus not become a gas)
	var/condensation_amount = 1

/datum/reagent/New()
	. = ..()

	if(material)
		material = SSmaterials.GetMaterialRef(material)


/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/datum/reagent/proc/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(M))
		return 0
	if(method == VAPOR) //smoke, foam, spray
		if(M.reagents)
			var/modifier = clamp((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume*modifier, 0.1)
			if(amount >= 0.5)
				M.reagents.add_reagent(type, amount)
	return 1

/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume, show_message, from_gas)
	if(!from_gas && boiling_point)
		var/temp = holder?.chem_temp
		if(!temp)
			if(isopenturf(T))
				var/turf/open/O = T
				var/datum/gas_mixture/air = O.return_air()
				temp = air.return_temperature()
			else
				temp = T20C
		if(temp > boiling_point)
			T.atmos_spawn_air("[get_gas()]=[volume/2];TEMP=[temp]")

/datum/reagent/proc/on_mob_life(mob/living/carbon/M)
	current_cycle++
	if(holder)
		holder.remove_reagent(type, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.

//called when a mob processes chems when dead.
/datum/reagent/proc/on_mob_dead(mob/living/carbon/M)
	if(!(chemical_flags & REAGENT_DEAD_PROCESS)) //justincase
		return
	current_cycle++
	if(holder)
		holder.remove_reagent(type, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.

// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/L, amount)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/M = L
	var/turf/T = get_turf(M)
	log_reagent("MOB ADD: on_mob_add(): [key_name(M)] at [AREACOORD(T)] - [volume] of [type] with [purity] purity")
	if (purity == 1)
		return
	if(cached_purity == 1)
		cached_purity = purity
	else if(purity < 0)
		CRASH("Purity below 0 for chem: [type], Please let Fermis Know!")
	if(chemical_flags & REAGENT_DONOTSPLIT)
		return

	if ((inverse_chem_val > purity) && (inverse_chem))//Turns all of a added reagent into the inverse chem
		M.reagents.remove_reagent(type, amount, FALSE)
		M.reagents.add_reagent(inverse_chem, amount, FALSE, other_purity = 1-cached_purity)
		var/datum/reagent/R = M.reagents.has_reagent(inverse_chem)
		if(R.chemical_flags & REAGENT_SNEAKYNAME)
			R.name = name//Negative effects are hidden
			if(R.chemical_flags & REAGENT_INVISIBLE)
				R.chemical_flags |= (REAGENT_INVISIBLE)
		log_reagent("MOB ADD: on_mob_add() (impure): merged [volume] of [inverse_chem]")
	else if (impure_chem)
		var/impureVol = amount * (1 - purity) //turns impure ratio into impure chem
		if(!(chemical_flags & REAGENT_SPLITRETAINVOL))
			M.reagents.remove_reagent(type, (impureVol), FALSE)
		M.reagents.add_reagent(impure_chem, impureVol, FALSE, other_purity = 1-cached_purity)
		log_reagent("MOB ADD: on_mob_add() (mixed purity): merged [volume - impureVol] of [type] and [volume] of [impure_chem]")

// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/living/L)
	var/turf/T = get_turf(L)
	log_reagent("MOB DELETE: on_mob_delete: [key_name(L)] at [AREACOORD(T)] - [type]")

// Called when this reagent first starts being metabolized by a liver
/datum/reagent/proc/on_mob_metabolize(mob/living/L)
	return

// Called when this reagent stops being metabolized by a liver
/datum/reagent/proc/on_mob_end_metabolize(mob/living/L)
	return

/datum/reagent/proc/on_move(mob/M)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data, amount, mob/living/carbon/M, purity)
	if(!iscarbon(M))
		return
	var/turf/T = get_turf(M)
	log_reagent("MOB ADD: on_merge(): [key_name(M)] at [AREACOORD(T)] - [volume] of [type] with [purity] purity")
	if (purity == 1)
		return
	cached_purity = purity //purity SHOULD be precalculated from the add_reagent, update cache.
	if (purity < 0)
		CRASH("Purity below 0 for chem: [type], Please let Fermis Know!")
	if(chemical_flags & REAGENT_DONOTSPLIT)
		return

	if ((inverse_chem_val > purity) && (inverse_chem)) //INVERT
		M.reagents.remove_reagent(type, amount, FALSE)
		M.reagents.add_reagent(inverse_chem, amount, FALSE, other_purity = 1-cached_purity)
		var/datum/reagent/R = M.reagents.has_reagent(inverse_chem)
		if(R.chemical_flags & REAGENT_SNEAKYNAME)
			R.name = name//Negative effects are hidden
			if(R.chemical_flags & REAGENT_INVISIBLE)
				R.chemical_flags |= (REAGENT_INVISIBLE)
		log_reagent("MOB ADD: on_merge() (impure): merged [volume] of [inverse_chem]")
	else if (impure_chem) //SPLIT
		var/impureVol = amount * (1 - purity)
		if(!(chemical_flags & REAGENT_SPLITRETAINVOL))
			M.reagents.remove_reagent(type, impureVol, FALSE)
		M.reagents.add_reagent(impure_chem, impureVol, FALSE, other_purity = 1-cached_purity)
		log_reagent("MOB ADD: on_merge() (mixed purity): merged [volume - impureVol] of [type] and [volume] of [impure_chem]")

/datum/reagent/proc/on_update(atom/A)
	return

// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/M)
	return

/datum/reagent/proc/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You feel like you took too much of [name]!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/proc/addiction_act_stage1(mob/living/M)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_light, name)
	if(prob(30))
		to_chat(M, "<span class='notice'>You feel like having some [name] right about now.</span>")

/datum/reagent/proc/addiction_act_stage2(mob/living/M)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_medium, name)
	if(prob(30))
		to_chat(M, "<span class='notice'>You feel like you need [name]. You just can't get enough.</span>")

/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_severe, name)
	if(prob(30))
		to_chat(M, "<span class='danger'>You have an intense craving for [name].</span>")

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_critical, name)
	if(prob(30))
		to_chat(M, "<span class='boldannounce'>You're not feeling good at all! You really need some [name].</span>")

/**
  * New, standardized method for chemicals to affect hydroponics trays.
  * Defined on a per-chem level as opposed to by the tray.
  * Can affect plant's health, stats, or cause the plant to react in certain ways.
  */
/datum/reagent/proc/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	if(!mytray || !chems)
		return
	return

/proc/pretty_string_from_reagent_list(list/reagent_list)
	//Convert reagent list to a printable string for logging etc
	var/list/rs = list()
	for (var/datum/reagent/R in reagent_list)
		rs += "[R.name], [R.volume]"

	return rs.Join(" | ")

/datum/reagent/proc/define_gas()
	if(reagent_state == SOLID)
		return null // doesn't make that much sense
	var/list/cached_reactions = GLOB.chemical_reactions_list
	for(var/reaction in cached_reactions[src.type])
		var/datum/chemical_reaction/C = reaction
		if(!istype(C))
			continue
		if(C.required_reagents.len < 2) // no reagents that react on their own
			return null
	var/datum/gas/G = new
	G.id = "[src.type]"
	G.name = name
	G.specific_heat = specific_heat / 10
	G.color = color
	G.breath_reagent = src.type
	G.turf_reagent = src.type
	return G

/datum/reagent/proc/create_gas()
	var/datum/gas/G = define_gas()
	if(istype(G)) // if this reagent should never be a gas, define_gas may return null
		GLOB.gas_data.add_gas(G)

/datum/reagent/proc/get_gas()
	if(gas)
		return gas
	else
		var/datum/auxgm/cached_gas_data = GLOB.gas_data
		. = "[src.type]"
		if(!(. in cached_gas_data.ids))
			var/datum/gas/G = define_gas()
			if(istype(G))
				cached_gas_data.add_gas(G)
			else // this codepath should probably not happen at all, since we never use get_gas() on anything with no boiling point
				return null




//For easy bloodsucker disgusting and blood removal
/datum/reagent/proc/disgust_bloodsucker(mob/living/carbon/C, disgust, blood_change, blood_puke = TRUE, force)
	if(AmBloodsucker(C))
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = C.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if(disgust)
			bloodsuckerdatum.handle_eat_human_food(disgust, blood_puke, force)
		if(blood_change)
			bloodsuckerdatum.AddBloodVolume(blood_change)
