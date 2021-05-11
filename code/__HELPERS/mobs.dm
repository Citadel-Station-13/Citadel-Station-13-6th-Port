/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/proc/random_eye_color()
	switch(pick(20;"brown",20;"hazel",20;"grey",15;"blue",15;"green",1;"amber",1;"albino"))
		if("brown")
			return "630"
		if("hazel")
			return "542"
		if("grey")
			return pick("666","777","888","999","aaa","bbb","ccc")
		if("blue")
			return "36c"
		if("green")
			return "060"
		if("amber")
			return "fc0"
		if("albino")
			return pick("c","d","e","f") + pick("0","1","2","3","4","5","6","7","8","9") + pick("0","1","2","3","4","5","6","7","8","9")
		else
			return "000"

/proc/random_underwear(gender)
	if(!GLOB.underwear_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear/bottom, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	switch(gender)
		if(MALE)
			return pick(GLOB.underwear_m)
		if(FEMALE)
			return pick(GLOB.underwear_f)
		else
			return pick(GLOB.underwear_list)

/proc/random_undershirt(gender)
	if(!GLOB.undershirt_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear/top, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	switch(gender)
		if(MALE)
			return pick(GLOB.undershirt_m)
		if(FEMALE)
			return pick(GLOB.undershirt_f)
		else
			return pick(GLOB.undershirt_list)

/proc/random_socks()
	if(!GLOB.socks_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear/socks, GLOB.socks_list)
	return pick(GLOB.socks_list)

/proc/random_features(intendedspecies, intended_gender)
	if(!GLOB.tails_list_human.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_list_human)
	if(!GLOB.tails_list_lizard.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, GLOB.tails_list_lizard)
	if(!GLOB.snouts_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list)
	if(!GLOB.horns_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, GLOB.horns_list)
	if(!GLOB.ears_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.ears_list)
	if(!GLOB.frills_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list)
	if(!GLOB.spines_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, GLOB.spines_list)
	if(!GLOB.legs_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list)
	if(!GLOB.body_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings_list)
	if(!GLOB.wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list)
	if(!GLOB.deco_wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/deco_wings, GLOB.deco_wings_list)
	if(!GLOB.insect_wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/insect_wings, GLOB.insect_wings_list)
	if(!GLOB.insect_fluffs_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/insect_fluff, GLOB.insect_fluffs_list)
	if(!GLOB.insect_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/insect_markings, GLOB.insect_markings_list)
	if(!GLOB.arachnid_legs_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/arachnid_legs, GLOB.arachnid_legs_list)
	if(!GLOB.arachnid_spinneret_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/arachnid_spinneret, GLOB.arachnid_spinneret_list)
	if(!GLOB.arachnid_mandibles_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/arachnid_mandibles, GLOB.arachnid_mandibles_list)

	//CIT CHANGES - genitals and such
	if(!GLOB.cock_shapes_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/penis, GLOB.cock_shapes_list)
	if(!GLOB.balls_shapes_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/testicles, GLOB.balls_shapes_list)
	if(!GLOB.vagina_shapes_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/vagina, GLOB.vagina_shapes_list)
	if(!GLOB.breasts_shapes_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/breasts, GLOB.breasts_shapes_list)
	if(!GLOB.ipc_screens_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/screen, GLOB.ipc_screens_list)
	if(!GLOB.ipc_antennas_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/antenna, GLOB.ipc_antennas_list)
	if(!GLOB.mam_body_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/mam_body_markings, GLOB.mam_body_markings_list)
	if(!GLOB.mam_tails_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/mam_tails, GLOB.mam_tails_list)
	if(!GLOB.mam_ears_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ears/mam_ears, GLOB.mam_ears_list)
	if(!GLOB.mam_snouts_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts/mam_snouts, GLOB.mam_snouts_list)

	//snowflake check so people's ckey features don't get randomly put on unmonkeys/spawns
	var/list/snowflake_mam_tails_list = list()
	for(var/mtpath in GLOB.mam_tails_list)
		var/datum/sprite_accessory/tails/mam_tails/instance = GLOB.mam_tails_list[mtpath]
		if(istype(instance, /datum/sprite_accessory))
			var/datum/sprite_accessory/S = instance
			if(intendedspecies && S.recommended_species && !S.recommended_species.Find(intendedspecies))
				continue
			if(!S.ckeys_allowed)
				snowflake_mam_tails_list[S.name] = mtpath
	var/list/snowflake_markings_list = list()
	for(var/mmpath in GLOB.mam_body_markings_list)
		var/datum/sprite_accessory/mam_body_markings/instance = GLOB.mam_body_markings_list[mmpath]
		if(istype(instance, /datum/sprite_accessory))
			var/datum/sprite_accessory/S = instance
			if(intendedspecies && S.recommended_species && !S.recommended_species.Find(intendedspecies))
				continue
			if(!S.ckeys_allowed)
				snowflake_markings_list[S.name] = mmpath
	var/list/snowflake_ears_list = list()
	for(var/mepath in GLOB.mam_ears_list)
		var/datum/sprite_accessory/ears/mam_ears/instance = GLOB.mam_ears_list[mepath]
		if(istype(instance, /datum/sprite_accessory))
			var/datum/sprite_accessory/S = instance
			if(intendedspecies && S.recommended_species && !S.recommended_species.Find(intendedspecies))
				continue
			if(!S.ckeys_allowed)
				snowflake_ears_list[S.name] = mepath
	var/list/snowflake_mam_snouts_list = list()
	for(var/mspath in GLOB.mam_snouts_list)
		var/datum/sprite_accessory/snouts/mam_snouts/instance = GLOB.mam_snouts_list[mspath]
		if(istype(instance, /datum/sprite_accessory))
			var/datum/sprite_accessory/S = instance
			if(intendedspecies && S.recommended_species && !S.recommended_species.Find(intendedspecies))
				continue
			if(!S.ckeys_allowed)
				snowflake_mam_snouts_list[S.name] = mspath
	var/list/snowflake_ipc_antenna_list = list()
	for(var/mspath in GLOB.ipc_antennas_list)
		var/datum/sprite_accessory/snouts/mam_snouts/instance = GLOB.ipc_antennas_list[mspath]
		if(istype(instance, /datum/sprite_accessory))
			var/datum/sprite_accessory/S = instance
			if(intendedspecies && S.recommended_species && !S.recommended_species.Find(intendedspecies))
				continue
			if(!S.ckeys_allowed)
				snowflake_ipc_antenna_list[S.name] = mspath
	var/color1 = random_color()
	var/color2 = random_color()
	var/color3 = random_color()

	var/body_model = MALE
	switch(intended_gender)
		if(MALE, FEMALE)
			body_model = intended_gender
		if(PLURAL)
			body_model = pick(MALE,FEMALE)

	return(list(
		"mcolor"			= color1,
		"mcolor2"			= color2,
		"mcolor3"			= color3,
		"tail_lizard"		= pick(GLOB.tails_list_lizard),
		"tail_human"		= "None",
		"wings"				= "None",
		"wings_color"		= "FFF",
		"deco_wings"		= "None",
		"snout"				= pick(GLOB.snouts_list),
		"horns"				= "None",
		"horns_color"		= "85615a",
		"ears"				= "None",
		"frills"			= pick(GLOB.frills_list),
		"spines"			= pick(GLOB.spines_list),
		"body_markings"		= pick(GLOB.body_markings_list),
		"legs"				= pick("Plantigrade","Digitigrade"),
		"caps"				= pick(GLOB.caps_list),
		"insect_wings"		= pick(GLOB.insect_wings_list),
		"insect_fluff"		= "None",
		"insect_markings"	= pick(GLOB.insect_markings_list),
		"arachnid_legs"		= pick(GLOB.arachnid_legs_list),
		"arachnid_spinneret"	= pick(GLOB.arachnid_spinneret_list),
		"arachnid_mandibles"	= pick(GLOB.arachnid_mandibles_list),
		"taur"				= "None",
		"mam_body_markings" = snowflake_markings_list.len ? pick(snowflake_markings_list) : "None",
		"mam_ears" 			= snowflake_ears_list ? pick(snowflake_ears_list) : "None",
		"mam_snouts"		= snowflake_mam_snouts_list ? pick(snowflake_mam_snouts_list) : "None",
		"mam_tail"			= snowflake_mam_tails_list ? pick(snowflake_mam_tails_list) : "None",
		"mam_tail_animated" = "None",
		"xenodorsal" 		= "Standard",
		"xenohead" 			= "Standard",
		"xenotail" 			= "Xenomorph Tail",
		"genitals_use_skintone"	= FALSE,
		"has_cock"			= FALSE,
		"cock_shape"		= pick(GLOB.cock_shapes_list),
		"cock_length"		= COCK_SIZE_DEF,
		"cock_diameter_ratio"	= COCK_DIAMETER_RATIO_DEF,
		"cock_color"		= pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F"),
		"cock_taur"			= FALSE,
		"has_balls" 		= FALSE,
		"balls_color" 		= pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F"),
		"balls_size"		= BALLS_SIZE_DEF,
		"balls_shape"		= DEF_BALLS_SHAPE,
		"balls_cum_rate"	= CUM_RATE,
		"balls_cum_mult"	= CUM_RATE_MULT,
		"balls_efficiency"	= CUM_EFFICIENCY,
		"has_breasts" 		= FALSE,
		"breasts_color" 	= pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F"),
		"breasts_size" 		= pick(CONFIG_GET(keyed_list/breasts_cups_prefs)),
		"breasts_shape"		= DEF_BREASTS_SHAPE,
		"breasts_producing" = FALSE,
		"has_vag"			= FALSE,
		"vag_shape"			= pick(GLOB.vagina_shapes_list),
		"vag_color"			= pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F"),
		"has_womb"			= FALSE,
		"balls_visibility"	= GEN_VISIBLE_NO_UNDIES,
		"breasts_visibility"= GEN_VISIBLE_NO_UNDIES,
		"cock_visibility"	= GEN_VISIBLE_NO_UNDIES,
		"vag_visibility"	= GEN_VISIBLE_NO_UNDIES,
		"ipc_screen"		= snowflake_ipc_antenna_list ? pick(snowflake_ipc_antenna_list) : "None",
		"ipc_antenna"		= "None",
		"flavor_text"		= "",
		"silicon_flavor_text"		= "",
		"meat_type"			= "Mammalian",
		"body_model"		= body_model,
		"body_size"			= RESIZE_DEFAULT_SIZE
		))

/proc/random_hair_style(gender)
	switch(gender)
		if(MALE)
			return pick(GLOB.hair_styles_male_list)
		if(FEMALE)
			return pick(GLOB.hair_styles_female_list)
		else
			return pick(GLOB.hair_styles_list)

/proc/random_facial_hair_style(gender)
	switch(gender)
		if(MALE)
			return pick(GLOB.facial_hair_styles_male_list)
		if(FEMALE)
			return pick(GLOB.facial_hair_styles_female_list)
		else
			return pick(GLOB.facial_hair_styles_list)

/proc/random_unique_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		if(gender==FEMALE)
			. = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			. = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

		if(!findname(.))
			break

/proc/random_unique_lizard_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(lizard_name(gender))

		if(!findname(.))
			break

/proc/random_unique_plasmaman_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(plasmaman_name())

		if(!findname(.))
			break

/proc/random_unique_ethereal_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(ethereal_name())

		if(!findname(.))
			break

/proc/random_unique_moth_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(pick(GLOB.moth_first)) + " " + capitalize(pick(GLOB.moth_last))

		if(!findname(.))
			break

/proc/random_unique_arachnid_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(pick(GLOB.arachnid_first)) + " " + capitalize(pick(GLOB.arachnid_last))

		if(!findname(.))
			break

#define SKINTONE2HEX(skin_tone) GLOB.skin_tones[skin_tone] || skin_tone

/proc/random_skin_tone()
	return pick(GLOB.skin_tones - GLOB.nonstandard_skin_tones)

//ordered by amount of tan. Keep the nonstandard skin tones last.
GLOBAL_LIST_INIT(skin_tones, list(
	"albino" = "#fff4e6",
	"caucasian1" = "#ffe0d1",
	"caucasian2" = "#fcccb3",
	"caucasian3" = "#e8b59b",
	"latino" = "#d9ae96",
	"mediterranean" = "#c79b8b",
	"asian1" = "#ffdeb3",
	"asian2" = "#e3ba84",
	"arab" = "#c4915e",
	"indian" = "#b87840",
	"african1" = "#754523",
	"african2" = "#471c18",
	"orange" = "#ffc905" //Spray tan overdose.
	))

GLOBAL_LIST_INIT(nonstandard_skin_tones, list("orange"))

GLOBAL_LIST_EMPTY(species_list)

GLOBAL_LIST_EMPTY(species_datums)

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)
			return "infant"
		if(1 to 3)
			return "toddler"
		if(3 to 13)
			return "child"
		if(13 to 19)
			return "teenager"
		if(19 to 30)
			return "young adult"
		if(30 to 45)
			return "adult"
		if(45 to 60)
			return "middle-aged"
		if(60 to 70)
			return "aging"
		if(70 to INFINITY)
			return "elderly"
		else
			return "unknown"

///Timed action involving two mobs, the user and the target. interaction_key is the assoc key under which the do_after is capped under, and the max interaction count is how many of this interaction you can do at once.
/proc/do_mob(mob/user, mob/target, time = 3 SECONDS, timed_action_flags = NONE, progress = TRUE, datum/callback/extra_checks, interaction_key, max_interact_count = 1)
	if(!user || !target)
		return FALSE
	var/user_loc = user.loc

	var/drifting = FALSE
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = TRUE

	var/target_loc = target.loc

	if(!interaction_key && target)
		interaction_key = target //Use the direct ref to the target
	if(interaction_key) //Do we have a interaction_key now?
		var/current_interaction_count = LAZYACCESS(user.do_afters, interaction_key) || 0
		if(current_interaction_count >= max_interact_count) //We are at our peak
			return
		LAZYSET(user.do_afters, interaction_key, current_interaction_count + 1)

	var/holding = user.get_active_held_item()
	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, time, target)
	if(target.pixel_x != 0) //shifts the progress bar if target has an offset sprite
		progbar.bar.pixel_x -= target.pixel_x

	var/endtime = world.time+time
	var/starttime = world.time
	. = TRUE

	while (world.time < endtime)
		stoplag(1)

		if(!QDELETED(progbar))
			progbar.update(world.time - starttime)

		if(drifting && !user.inertia_dir)
			drifting = FALSE
			user_loc = user.loc

		if(
			QDELETED(user) || QDELETED(target) \
			|| (!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && !drifting && user.loc != user_loc) \
			|| (!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && target.loc != target_loc) \
			|| (!(timed_action_flags & IGNORE_HELD_ITEM) && user.get_active_held_item() != holding) \
			|| (!(timed_action_flags & IGNORE_INCAPACITATED) && user.incapacitated()) \
			|| (extra_checks && !extra_checks.Invoke()) \
			)
			. = FALSE
			break

	if(!QDELETED(progbar))
		progbar.end_progress()

	if(interaction_key)
		LAZYREMOVE(user.do_afters, interaction_key)

/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna && istype(H.dna.species, species_datum))
			. = TRUE

/proc/spawn_atom_to_turf(spawn_type, target, amount, admin_spawn=FALSE, list/extra_args)
	var/turf/T = get_turf(target)
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/new_args = list(T)
	if(extra_args)
		new_args += extra_args

	for(var/j in 1 to amount)
		var/atom/X = new spawn_type(arglist(new_args))
		if (admin_spawn)
			X.flags_1 |= ADMIN_SPAWNED_1

/proc/spawn_and_random_walk(spawn_type, target, amount, walk_chance=100, max_walk=3, always_max_walk=FALSE, admin_spawn=FALSE)
	var/turf/T = get_turf(target)
	var/step_count = 0
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	for(var/j in 1 to amount)
		var/atom/movable/X = new spawn_type(T)
		if (admin_spawn)
			X.flags_1 |= ADMIN_SPAWNED_1

		if(always_max_walk || prob(walk_chance))
			if(always_max_walk)
				step_count = max_walk
			else
				step_count = rand(1, max_walk)

			for(var/i in 1 to step_count)
				step(X, pick(NORTH, SOUTH, EAST, WEST))

/proc/deadchat_broadcast(message, mob/follow_target=null, turf/turf_target=null, speaker_key=null, message_type=DEADCHAT_REGULAR)
	message = "<span class='linkify'>[message]</span>"
	for(var/mob/M in GLOB.player_list)
		var/datum/preferences/prefs
		if(M.client && M.client.prefs)
			prefs = M.client.prefs
		else
			prefs = new

		var/override = FALSE
		if(M.client && M.client.holder && (prefs.chat_toggles & CHAT_DEAD))
			override = TRUE
		if(HAS_TRAIT(M, TRAIT_SIXTHSENSE))
			override = TRUE
		if(SSticker.current_state == GAME_STATE_FINISHED)
			override = TRUE
		if(isnewplayer(M) && !override)
			continue
		if(M.stat != DEAD && !override)
			continue
		if(speaker_key && (speaker_key in prefs.ignoring))
			continue

		switch(message_type)
			if(DEADCHAT_DEATHRATTLE)
				if(prefs.toggles & DISABLE_DEATHRATTLE)
					continue
			if(DEADCHAT_ARRIVALRATTLE)
				if(prefs.toggles & DISABLE_ARRIVALRATTLE)
					continue

		if(isobserver(M))
			var/rendered_message = message

			if(follow_target)
				var/F
				if(turf_target)
					F = FOLLOW_OR_TURF_LINK(M, follow_target, turf_target)
				else
					F = FOLLOW_LINK(M, follow_target)
				rendered_message = "[F] [message]"
			else if(turf_target)
				var/turf_link = TURF_LINK(M, turf_target)
				rendered_message = "[turf_link] [message]"

			to_chat(M, rendered_message)
		else
			to_chat(M, message)

//Used in chemical_mob_spawn. Generates a random mob based on a given gold_core_spawnable value.
/proc/create_random_mob(spawn_location, mob_class = HOSTILE_SPAWN)
	var/static/list/mob_spawn_meancritters = list() // list of possible hostile mobs
	var/static/list/mob_spawn_nicecritters = list() // and possible friendly mobs

	if(mob_spawn_meancritters.len <= 0 || mob_spawn_nicecritters.len <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += T
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += T

	var/chosen
	if(mob_class == FRIENDLY_SPAWN)
		chosen = pick(mob_spawn_nicecritters)
	else
		chosen = pick(mob_spawn_meancritters)
	var/mob/living/simple_animal/C = new chosen(spawn_location)
	return C

/proc/passtable_on(target, source)
	var/mob/living/L = target
	if(!HAS_TRAIT(L, TRAIT_PASSTABLE) && L.pass_flags & PASSTABLE)
		ADD_TRAIT(L, TRAIT_PASSTABLE, INNATE_TRAIT)
	ADD_TRAIT(L, TRAIT_PASSTABLE, source)
	L.pass_flags |= PASSTABLE

/proc/passtable_off(target, source)
	var/mob/living/L = target
	REMOVE_TRAIT(L, TRAIT_PASSTABLE, source)
	if(!HAS_TRAIT(L, TRAIT_PASSTABLE))
		L.pass_flags &= ~PASSTABLE

/// Gets the client of the mob, allowing for mocking of the client.
/// You only need to use this if you know you're going to be mocking clients somewhere else.
#define GET_CLIENT(mob) (##mob.client) // huwhe??  || ##mob.mock_client
