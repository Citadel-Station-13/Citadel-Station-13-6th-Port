//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	18

//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX	52

/*
SAVEFILE UPDATING/VERSIONING - 'Simplified', or rather, more coder-friendly ~Carn
	This proc checks if the current directory of the savefile S needs updating
	It is to be used by the load_character and load_preferences procs.
	(S.cd=="/" is preferences, S.cd=="/character[integer]" is a character slot, etc)

	if the current directory's version is below SAVEFILE_VERSION_MIN it will simply wipe everything in that directory
	(if we're at root "/" then it'll just wipe the entire savefile, for instance.)

	if its version is below SAVEFILE_VERSION_MAX but above the minimum, it will load data but later call the
	respective update_preferences() or update_character() proc.
	Those procs allow coders to specify format changes so users do not lose their setups and have to redo them again.

	Failing all that, the standard sanity checks are performed. They simply check the data is suitable, reverting to
	initial() values if necessary.
*/
/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	S["version"] >> savefile_version

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return -2
	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version
	return -1

//should these procs get fairly long
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from these procs.
//This only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.

/datum/preferences/proc/update_preferences(current_version, savefile/S)
	if(current_version < 46)	//If you remove this, remove force_reset_keybindings() too.
		force_reset_keybindings_direct(TRUE)
		addtimer(CALLBACK(src, .proc/force_reset_keybindings), 30)	//No mob available when this is run, timer allows user choice.

/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 19)
		pda_style = "mono"
	if(current_version < 20)
		pda_color = "#808000"
	if((current_version < 21) && features["meat_type"] && (features["meat_type"] == null))
		features["meat_type"] = "Mammalian"
	if(current_version < 22)

		job_preferences = list() //It loaded null from nonexistant savefile field.

		var/job_civilian_high = 0
		var/job_civilian_med = 0
		var/job_civilian_low = 0

		var/job_medsci_high = 0
		var/job_medsci_med = 0
		var/job_medsci_low = 0

		var/job_engsec_high = 0
		var/job_engsec_med = 0
		var/job_engsec_low = 0

		S["job_civilian_high"]	>> job_civilian_high
		S["job_civilian_med"]	>> job_civilian_med
		S["job_civilian_low"]	>> job_civilian_low
		S["job_medsci_high"]	>> job_medsci_high
		S["job_medsci_med"]		>> job_medsci_med
		S["job_medsci_low"]		>> job_medsci_low
		S["job_engsec_high"]	>> job_engsec_high
		S["job_engsec_med"]		>> job_engsec_med
		S["job_engsec_low"]		>> job_engsec_low

		//Can't use SSjob here since this happens right away on login
		for(var/job in subtypesof(/datum/job))
			var/datum/job/J = job
			var/new_value
			var/fval = initial(J.flag)
			switch(initial(J.department_flag))
				if(CIVILIAN)
					if(job_civilian_high & fval)
						new_value = JP_HIGH
					else if(job_civilian_med & fval)
						new_value = JP_MEDIUM
					else if(job_civilian_low & fval)
						new_value = JP_LOW
				if(MEDSCI)
					if(job_medsci_high & fval)
						new_value = JP_HIGH
					else if(job_medsci_med & fval)
						new_value = JP_MEDIUM
					else if(job_medsci_low & fval)
						new_value = JP_LOW
				if(ENGSEC)
					if(job_engsec_high & fval)
						new_value = JP_HIGH
					else if(job_engsec_med & fval)
						new_value = JP_MEDIUM
					else if(job_engsec_low & fval)
						new_value = JP_LOW
			if(new_value)
				job_preferences["[initial(J.title)]"] = new_value
	else if(current_version < 23) // we are fixing a gamebreaking bug.
		job_preferences = list() //It loaded null from nonexistant savefile field.

	if(current_version < 25)
		var/digi
		S["feature_lizard_legs"] >> digi
		if(digi == "Digitigrade Legs")
			WRITE_FILE(S["feature_lizard_legs"], "Digitigrade")

	if(current_version < 26)
		var/vr_path = "data/player_saves/[parent.ckey[1]]/[parent.ckey]/vore/character[default_slot].json"
		if(fexists(vr_path))
			var/list/json_from_file = json_decode(file2text(vr_path))
			if(json_from_file)
				if(json_from_file["digestable"])
					ENABLE_BITFIELD(vore_flags,DIGESTABLE)
				if(json_from_file["devourable"])
					ENABLE_BITFIELD(vore_flags,DEVOURABLE)
				if(json_from_file["feeding"])
					ENABLE_BITFIELD(vore_flags,FEEDING)
				if(json_from_file["lickable"])
					ENABLE_BITFIELD(vore_flags,LICKABLE)
				belly_prefs = json_from_file["belly_prefs"]
				vore_taste = json_from_file["vore_taste"]

		for(var/V in all_quirks) // quirk migration
			switch(V)
				if("Acute hepatic pharmacokinesis")
					DISABLE_BITFIELD(cit_toggles, PENIS_ENLARGEMENT)
					DISABLE_BITFIELD(cit_toggles, BREAST_ENLARGEMENT)
					ENABLE_BITFIELD(cit_toggles,FORCED_FEM)
					ENABLE_BITFIELD(cit_toggles,FORCED_MASC)
					all_quirks -= V
				if("Crocin Immunity")
					ENABLE_BITFIELD(cit_toggles,NO_APHRO)
					all_quirks -= V
				if("Buns of Steel")
					ENABLE_BITFIELD(cit_toggles,NO_ASS_SLAP)
					all_quirks -= V

		if(features["meat_type"] == "Inesct")
			features["meat_type"] = "Insect"

	if(current_version < 27)
		var/tennis
		S["feature_balls_shape"] >> tennis
		if(tennis == "Hidden")
			features["balls_visibility"] = GEN_VISIBLE_NEVER

	if(current_version < 28)
		var/hockey
		S["feature_cock_shape"] >> hockey
		var/list/malformed_hockeys = list("Taur, Flared" = "Flared", "Taur, Knotted" = "Knotted", "Taur, Tapered" = "Tapered")
		if(malformed_hockeys[hockey])
			features["cock_shape"] = malformed_hockeys[hockey]
			features["cock_taur"] = TRUE

	if(current_version < 29)
		var/digestable
		var/devourable
		var/feeding
		var/lickable
		S["digestable"]						>> digestable
		S["devourable"]						>> devourable
		S["feeding"]						>> feeding
		S["lickable"]						>> lickable
		if(digestable)
			ENABLE_BITFIELD(vore_flags,DIGESTABLE)
		if(devourable)
			ENABLE_BITFIELD(vore_flags,DEVOURABLE)
		if(feeding)
			ENABLE_BITFIELD(vore_flags,FEEDING)
		if(lickable)
			ENABLE_BITFIELD(vore_flags,LICKABLE)

	if(current_version < 30)
		switch(features["taur"])
			if("Husky", "Lab", "Shepherd", "Fox", "Wolf")
				features["taur"] = "Canine"
			if("Panther", "Tiger")
				features["taur"] = "Feline"
			if("Cow")
				features["taur"] = "Cow (Spotted)"

	if(current_version < 31)
		S["wing_color"]			>> features["wings_color"]
		S["horn_color"]			>> features["horns_color"]

	if(current_version < 33)
		features["flavor_text"] = html_encode(features["flavor_text"])
		features["silicon_flavor_text"] = html_encode(features["silicon_flavor_text"])
		features["ooc_notes"] = html_encode(features["ooc_notes"])

	if(current_version < 35)
		if(S["species"] == "lizard")
			features["mam_snouts"] = features["snout"]

	if(current_version < 36) //introduction of heterochromia
		left_eye_color = S["eye_color"]
		right_eye_color = S["eye_color"]

	if(current_version < 37) //introduction of chooseable eye types/sprites
		if(S["species"] == "insect")
			left_eye_color = "#000000"
			right_eye_color = "#000000"
			if(chosen_limb_id == "moth" || chosen_limb_id == "moth_not_greyscale") //these actually have slightly different eyes!
				eye_type = "moth"
			else
				eye_type = "insect"

	if(current_version < 38) //further eye sprite changes
		if(S["species"] == "plasmaman")
			left_eye_color = "#FFC90E"
			right_eye_color = "#FFC90E"
		else
			if(S["species"] == "skeleton")
				left_eye_color = "#BAB99E"
				right_eye_color = "#BAB99E"

	if(current_version < 43) //extreme changes to how things are coloured (the introduction of the advanced coloring system)
		features["color_scheme"] = OLD_CHARACTER_COLORING //disable advanced coloring system by default
		for(var/feature in features)
			var/feature_value = features[feature]
			if(feature_value)
				var/ref_list = GLOB.mutant_reference_list[feature]
				if(ref_list)
					var/datum/sprite_accessory/accessory = ref_list[feature_value]
					if(accessory)
						var/mutant_string = accessory.mutant_part_string
						if(!mutant_string)
							if(istype(accessory, /datum/sprite_accessory/mam_body_markings))
								mutant_string = "mam_body_markings"
						var/primary_string = "[mutant_string]_primary"
						var/secondary_string = "[mutant_string]_secondary"
						var/tertiary_string = "[mutant_string]_tertiary"
						if(accessory.color_src == MATRIXED && !accessory.matrixed_sections && feature_value != "None")
							message_admins("Sprite Accessory Failure (migration from [current_version] to 39): Accessory [accessory.type] is a matrixed item without any matrixed sections set!")
							continue
						var/primary_exists = features[primary_string]
						var/secondary_exists = features[secondary_string]
						var/tertiary_exists = features[tertiary_string]
						if(accessory.color_src == MATRIXED && !primary_exists && !secondary_exists && !tertiary_exists)
							features[primary_string] = features["mcolor"]
							features[secondary_string] = features["mcolor2"]
							features[tertiary_string] = features["mcolor3"]
						else if(accessory.color_src == MUTCOLORS && !primary_exists)
							features[primary_string] = features["mcolor"]
						else if(accessory.color_src == MUTCOLORS2 && !secondary_exists)
							features[secondary_string] = features["mcolor2"]
						else if(accessory.color_src == MUTCOLORS3 && !tertiary_exists)
							features[tertiary_string] = features["mcolor3"]

		features["color_scheme"] = OLD_CHARACTER_COLORING //advanced is off by default

	if(current_version < 47) //loadout save gets changed to json
		var/text_to_load
		S["loadout"] >> text_to_load
		var/list/saved_loadout_paths = splittext(text_to_load, "|")
		//MAXIMUM_LOADOUT_SAVES save slots per loadout now
		for(var/i=1, i<= MAXIMUM_LOADOUT_SAVES, i++)
			loadout_data["SAVE_[i]"] = list()
		for(var/some_gear_item in saved_loadout_paths)
			if(!ispath(text2path(some_gear_item)))
				log_game("Failed to copy item [some_gear_item] to new loadout system when migrating from version [current_version] to 40, issue: item is not a path")
				continue
			var/datum/gear/gear_item = text2path(some_gear_item)
			if(!(initial(gear_item.loadout_flags) & LOADOUT_CAN_COLOR_POLYCHROMIC))
				loadout_data["SAVE_1"] += list(list(LOADOUT_ITEM = some_gear_item)) //for the migration we put their old save into the first save slot, which is loaded by default!
			else
				//the same but we setup some new polychromic data  (you can't get the initial value for a list so we have to do this horrible thing here)
				var/datum/gear/temporary_gear_item = new gear_item
				loadout_data["SAVE_1"] += list(list(LOADOUT_ITEM = some_gear_item, LOADOUT_COLOR = temporary_gear_item.loadout_initial_colors))
				qdel(temporary_gear_item)
			//it's double packed into a list because += will union the two lists contents

		S["loadout"] = loadout_data

	if(current_version < 48) //unlockable loadout items but we need to clear bad data from a mistake
		S["unlockable_loadout"] = list()

	if(current_version < 50)
		var/list/L
		S["be_special"] >> L
		if(islist(L))
			L -= ROLE_SYNDICATE
		S["be_special"] << L

	if(current_version < 51) //humans can have digi legs now, make sure they dont default to them or human players will murder me in my sleep
		if(S["species"] == SPECIES_HUMAN)
			features["legs"] = "Plantigrade"

	if(current_version < 52) // rp markings means markings are now stored as a list, lizard markings now mam like the rest
		var/marking_type
		var/species_id = S["species"]
		var/datum/species/actual_species = GLOB.species_datums[species_id]

		// convert lizard markings to lizard markings
		if(species_id == SPECIES_LIZARD && S["feature_lizard_body_markings"])
			features["mam_body_markings"] = features["body_markings"]

		// convert mam body marking data to the new rp marking data
		if(actual_species.mutant_bodyparts["mam_body_markings"] && S["feature_mam_body_markings"]) marking_type = "feature_mam_body_markings"

		if(marking_type)
			var/old_marking_value = S[marking_type]
			var/list/color_list = list("#FFFFFF","#FFFFFF","#FFFFFF")

			if(S["feature_mcolor"]) color_list[1] = "#" + S["feature_mcolor"]
			if(S["feature_mcolor2"]) color_list[2] = "#" + S["feature_mcolor2"]
			if(S["feature_mcolor3"]) color_list[3] = "#" + S["feature_mcolor3"]

			var/list/marking_list = list()
			for(var/part in list(ARM_LEFT, ARM_RIGHT, LEG_LEFT, LEG_RIGHT, CHEST, HEAD))
				var/list/copied_color_list = color_list.Copy()
				var/datum/sprite_accessory/mam_body_markings/mam_marking = GLOB.mam_body_markings_list[old_marking_value]
				var/part_name = GLOB.bodypart_names[num2text(part)]
				if(length(mam_marking.covered_limbs) && mam_marking.covered_limbs[part_name])
					var/matrixed_sections = mam_marking.covered_limbs[part_name]
					// just trust me this is fine
					switch(matrixed_sections)
						if(MATRIX_GREEN)
							copied_color_list[1] = copied_color_list[2]
						if(MATRIX_BLUE)
							copied_color_list[1] = copied_color_list[3]
						if(MATRIX_RED_BLUE)
							copied_color_list[2] = copied_color_list[3]
						if(MATRIX_GREEN_BLUE)
							copied_color_list[1] = copied_color_list[2]
							copied_color_list[2] = copied_color_list[3]
				marking_list += list(list(part, old_marking_value, copied_color_list))
			features["mam_body_markings"] = marking_list

/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[ckey[1]]/[ckey]/[filename]"
	vr_path = "data/player_saves/[ckey[1]]/[ckey]/vore"

/datum/preferences/proc/load_preferences(bypass_cooldown = FALSE)
	if(!path)
		return FALSE
	if(!bypass_cooldown)
		if(world.time < loadprefcooldown)
			if(istype(parent))
				to_chat(parent, "<span class='warning'>You're attempting to load your preferences a little too fast. Wait half a second, then try again.</span>")
			return FALSE
		loadprefcooldown = world.time + PREF_SAVELOAD_COOLDOWN
	if(!fexists(path))
		return FALSE

	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		var/bacpath = "[path].updatebac" //todo: if the savefile version is higher then the server, check the backup, and give the player a prompt to load the backup
		if (fexists(bacpath))
			fdel(bacpath) //only keep 1 version of backup
		fcopy(S, bacpath) //byond helpfully lets you use a savefile for the first arg.
		return FALSE

	. = TRUE

	//general preferences
	S["ooccolor"]			>> ooccolor
	S["lastchangelog"]		>> lastchangelog
	S["UI_style"]			>> UI_style
	S["hotkeys"]			>> hotkeys
	S["chat_on_map"]		>> chat_on_map
	S["max_chat_length"]	>> max_chat_length
	S["see_chat_non_mob"] 	>> see_chat_non_mob
	S["tgui_fancy"]			>> tgui_fancy
	S["tgui_lock"]			>> tgui_lock
	S["buttons_locked"]		>> buttons_locked
	S["windowflash"]		>> windowflashing
	S["be_special"] 		>> be_special


	S["default_slot"]		>> default_slot
	S["chat_toggles"]		>> chat_toggles
	S["toggles"]			>> toggles
	S["ghost_form"]			>> ghost_form
	S["ghost_orbit"]		>> ghost_orbit
	S["ghost_accs"]			>> ghost_accs
	S["ghost_others"]		>> ghost_others
	S["preferred_map"]		>> preferred_map
	S["ignoring"]			>> ignoring
	S["ghost_hud"]			>> ghost_hud
	S["inquisitive_ghost"]	>> inquisitive_ghost
	S["uses_glasses_colour"]>> uses_glasses_colour
	S["clientfps"]			>> clientfps
	S["parallax"]			>> parallax
	S["ambientocclusion"]	>> ambientocclusion
	S["auto_fit_viewport"]	>> auto_fit_viewport
	S["widescreenpref"]		>> widescreenpref
	S["pixel_size"]	    	>> pixel_size
	S["scaling_method"]	    >> scaling_method
	S["hud_toggle_flash"]	>> hud_toggle_flash
	S["hud_toggle_color"]	>> hud_toggle_color
	S["menuoptions"]		>> menuoptions
	S["enable_tips"]		>> enable_tips
	S["tip_delay"]			>> tip_delay
	S["pda_style"]			>> pda_style
	S["pda_color"]			>> pda_color
	S["pda_skin"]			>> pda_skin

	// Custom hotkeys
	S["key_bindings"]		>> key_bindings
	S["modless_key_bindings"]		>> modless_key_bindings

	//citadel code
	S["arousable"]			>> arousable
	S["screenshake"]		>> screenshake
	S["damagescreenshake"]	>> damagescreenshake
	S["autostand"]			>> autostand
	S["cit_toggles"]		>> cit_toggles
	S["preferred_chaos"]	>> preferred_chaos
	S["auto_ooc"]			>> auto_ooc
	S["no_tetris_storage"]		>> no_tetris_storage

	//favorite outfits
	S["favorite_outfits"]	>> favorite_outfits

	var/list/parsed_favs = list()
	for(var/typetext in favorite_outfits)
		var/datum/outfit/path = text2path(typetext)
		if(ispath(path)) //whatever typepath fails this check probably doesn't exist anymore
			parsed_favs += path
	favorite_outfits = uniqueList(parsed_favs)

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		var/bacpath = "[path].updatebac" //todo: if the savefile version is higher then the server, check the backup, and give the player a prompt to load the backup
		if (fexists(bacpath))
			fdel(bacpath) //only keep 1 version of backup
		fcopy(S, bacpath) //byond helpfully lets you use a savefile for the first arg.
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

	//Sanitize
	ooccolor		= sanitize_ooccolor(sanitize_hexcolor(ooccolor, 6, 1, initial(ooccolor)))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, GLOB.available_ui_styles, GLOB.available_ui_styles[1])
	hotkeys			= sanitize_integer(hotkeys, 0, 1, initial(hotkeys))
	chat_on_map		= sanitize_integer(chat_on_map, 0, 1, initial(chat_on_map))
	max_chat_length = sanitize_integer(max_chat_length, 1, CHAT_MESSAGE_MAX_LENGTH, initial(max_chat_length))
	see_chat_non_mob	= sanitize_integer(see_chat_non_mob, 0, 1, initial(see_chat_non_mob))
	tgui_fancy		= sanitize_integer(tgui_fancy, 0, 1, initial(tgui_fancy))
	tgui_lock		= sanitize_integer(tgui_lock, 0, 1, initial(tgui_lock))
	buttons_locked	= sanitize_integer(buttons_locked, 0, 1, initial(buttons_locked))
	windowflashing		= sanitize_integer(windowflashing, 0, 1, initial(windowflashing))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 16777215, initial(toggles))
	clientfps		= sanitize_integer(clientfps, 0, 1000, 0)
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)
	ambientocclusion	= sanitize_integer(ambientocclusion, 0, 1, initial(ambientocclusion))
	auto_fit_viewport	= sanitize_integer(auto_fit_viewport, 0, 1, initial(auto_fit_viewport))
	widescreenpref		= sanitize_integer(widescreenpref, 0, 1, initial(widescreenpref))
	pixel_size		= sanitize_integer(pixel_size, PIXEL_SCALING_AUTO, PIXEL_SCALING_3X, initial(pixel_size))
	scaling_method  = sanitize_text(scaling_method, initial(scaling_method))
	hud_toggle_flash = sanitize_integer(hud_toggle_flash, 0, 1, initial(hud_toggle_flash))
	hud_toggle_color = sanitize_hexcolor(hud_toggle_color, 6, 1, initial(hud_toggle_color))
	ghost_form		= sanitize_inlist(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_orbit 	= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_accs		= sanitize_inlist(ghost_accs, GLOB.ghost_accs_options, GHOST_ACCS_DEFAULT_OPTION)
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, GHOST_OTHERS_DEFAULT_OPTION)
	menuoptions		= SANITIZE_LIST(menuoptions)
	be_special		= SANITIZE_LIST(be_special)
	pda_style		= sanitize_inlist(pda_style, GLOB.pda_styles, initial(pda_style))
	pda_color		= sanitize_hexcolor(pda_color, 6, 1, initial(pda_color))
	pda_skin		= sanitize_inlist(pda_skin, GLOB.pda_reskins, PDA_SKIN_ALT)
	screenshake			= sanitize_integer(screenshake, 0, 800, initial(screenshake))
	damagescreenshake	= sanitize_integer(damagescreenshake, 0, 2, initial(damagescreenshake))
	autostand			= sanitize_integer(autostand, 0, 1, initial(autostand))
	cit_toggles			= sanitize_integer(cit_toggles, 0, 16777215, initial(cit_toggles))
	auto_ooc			= sanitize_integer(auto_ooc, 0, 1, initial(auto_ooc))
	no_tetris_storage		= sanitize_integer(no_tetris_storage, 0, 1, initial(no_tetris_storage))
	key_bindings 			= sanitize_islist(key_bindings, list())
	modless_key_bindings 	= sanitize_islist(modless_key_bindings, list())
	favorite_outfits = SANITIZE_LIST(favorite_outfits)

	verify_keybindings_valid()		// one of these days this will runtime and you'll be glad that i put it in a different proc so no one gets their saves wiped

	if(S["unlockable_loadout"])
		try
			unlockable_loadout_data = safe_json_decode(S["unlockable_loadout"])
		catch
			unlockable_loadout_data = list()
	else
		unlockable_loadout_data = list()

	if(needs_update >= 0) //save the updated version
		var/old_default_slot = default_slot
		var/old_max_save_slots = max_save_slots

		for (var/slot in S.dir) //but first, update all current character slots.
			if (copytext(slot, 1, 10) != "character")
				continue
			var/slotnum = text2num(copytext(slot, 10))
			if (!slotnum)
				continue
			max_save_slots = max(max_save_slots, slotnum) //so we can still update byond member slots after they lose memeber status
			default_slot = slotnum
			if (load_character(null, TRUE)) // this updtates char slots
				save_character(TRUE)
		default_slot = old_default_slot
		max_save_slots = old_max_save_slots
		save_preferences(TRUE)

	return TRUE

/datum/preferences/proc/verify_keybindings_valid()
	// Sanitize the actual keybinds to make sure they exist.
	for(var/key in key_bindings)
		if(!islist(key_bindings[key]))
			key_bindings -= key
		var/list/binds = key_bindings[key]
		for(var/bind in binds)
			if(!GLOB.keybindings_by_name[bind])
				binds -= bind
		if(!length(binds))
			key_bindings -= key
	// End
	// I hate copypaste but let's do it again but for modless ones
	for(var/key in modless_key_bindings)
		var/bindname = modless_key_bindings[key]
		if(!GLOB.keybindings_by_name[bindname])
			modless_key_bindings -= key

/datum/preferences/proc/save_preferences(bypass_cooldown = FALSE)
	if(!path)
		return 0
	if(!bypass_cooldown)
		if(world.time < saveprefcooldown)
			if(istype(parent))
				to_chat(parent, "<span class='warning'>You're attempting to save your preferences a little too fast. Wait half a second, then try again.</span>")
			return 0
		saveprefcooldown = world.time + PREF_SAVELOAD_COOLDOWN
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	WRITE_FILE(S["version"] , SAVEFILE_VERSION_MAX)		//updates (or failing that the sanity checks) will ensure data is not invalid at load. Assume up-to-date

	//general preferences
	WRITE_FILE(S["ooccolor"], ooccolor)
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["UI_style"], UI_style)
	WRITE_FILE(S["hotkeys"], hotkeys)
	WRITE_FILE(S["chat_on_map"], chat_on_map)
	WRITE_FILE(S["max_chat_length"], max_chat_length)
	WRITE_FILE(S["see_chat_non_mob"], see_chat_non_mob)
	WRITE_FILE(S["tgui_fancy"], tgui_fancy)
	WRITE_FILE(S["tgui_lock"], tgui_lock)
	WRITE_FILE(S["buttons_locked"], buttons_locked)
	WRITE_FILE(S["windowflash"], windowflashing)
	WRITE_FILE(S["be_special"], be_special)
	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["toggles"], toggles)
	WRITE_FILE(S["chat_toggles"], chat_toggles)
	WRITE_FILE(S["ghost_form"], ghost_form)
	WRITE_FILE(S["ghost_orbit"], ghost_orbit)
	WRITE_FILE(S["ghost_accs"], ghost_accs)
	WRITE_FILE(S["ghost_others"], ghost_others)
	WRITE_FILE(S["preferred_map"], preferred_map)
	WRITE_FILE(S["ignoring"], ignoring)
	WRITE_FILE(S["ghost_hud"], ghost_hud)
	WRITE_FILE(S["inquisitive_ghost"], inquisitive_ghost)
	WRITE_FILE(S["uses_glasses_colour"], uses_glasses_colour)
	WRITE_FILE(S["clientfps"], clientfps)
	WRITE_FILE(S["parallax"], parallax)
	WRITE_FILE(S["ambientocclusion"], ambientocclusion)
	WRITE_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	WRITE_FILE(S["hud_toggle_flash"], hud_toggle_flash)
	WRITE_FILE(S["hud_toggle_color"], hud_toggle_color)
	WRITE_FILE(S["menuoptions"], menuoptions)
	WRITE_FILE(S["enable_tips"], enable_tips)
	WRITE_FILE(S["tip_delay"], tip_delay)
	WRITE_FILE(S["pda_style"], pda_style)
	WRITE_FILE(S["pda_color"], pda_color)
	WRITE_FILE(S["pda_skin"], pda_skin)
	WRITE_FILE(S["key_bindings"], key_bindings)
	WRITE_FILE(S["modless_key_bindings"], modless_key_bindings)
	WRITE_FILE(S["favorite_outfits"], favorite_outfits)

	//citadel code
	WRITE_FILE(S["screenshake"], screenshake)
	WRITE_FILE(S["damagescreenshake"], damagescreenshake)
	WRITE_FILE(S["arousable"], arousable)
	WRITE_FILE(S["widescreenpref"], widescreenpref)
	WRITE_FILE(S["autostand"], autostand)
	WRITE_FILE(S["cit_toggles"], cit_toggles)
	WRITE_FILE(S["preferred_chaos"], preferred_chaos)
	WRITE_FILE(S["auto_ooc"], auto_ooc)
	WRITE_FILE(S["no_tetris_storage"], no_tetris_storage)

	if(length(unlockable_loadout_data))
		WRITE_FILE(S["unlockable_loadout"], safe_json_encode(unlockable_loadout_data))
	else
		WRITE_FILE(S["unlockable_loadout"], safe_json_encode(list()))

	return 1

/datum/preferences/proc/load_character(slot, bypass_cooldown = FALSE)
	if(!path)
		return FALSE
	if(!bypass_cooldown)
		if(world.time < loadcharcooldown) //This is before the check to see if the filepath exists to ensure that BYOND can't get hung up on read attempts when the hard drive is a little slow
			if(istype(parent))
				to_chat(parent, "<span class='warning'>You're attempting to load your character a little too fast. Wait half a second, then try again.</span>")
			return "SLOW THE FUCK DOWN" //the reason this isn't null is to make sure that people don't have their character slots overridden by random chars if they accidentally double-click a slot
		loadcharcooldown = world.time + PREF_SAVELOAD_COOLDOWN
	if(!fexists(path))
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	features = list("mcolor" = "FFFFFF", "mcolor2" = "FFFFFF", "mcolor3" = "FFFFFF", "tail_lizard" = "Smooth", "tail_human" = "None", "snout" = "Round", "horns" = "None", "horns_color" = "85615a", "ears" = "None", "wings" = "None", "wings_color" = "FFF", "frills" = "None", "deco_wings" = "None", "spines" = "None", "legs" = "Plantigrade", "insect_wings" = "Plain", "insect_fluff" = "None", "insect_markings" = "None", "arachnid_legs" = "Plain", "arachnid_spinneret" = "Plain", "arachnid_mandibles" = "Plain", "mam_body_markings" = "Plain", "mam_ears" = "None", "mam_snouts" = "None", "mam_tail" = "None", "mam_tail_animated" = "None", "xenodorsal" = "Standard", "xenohead" = "Standard", "xenotail" = "Xenomorph Tail", "taur" = "None", "genitals_use_skintone" = FALSE, "has_cock" = FALSE, "cock_shape" = DEF_COCK_SHAPE, "cock_length" = COCK_SIZE_DEF, "cock_diameter_ratio" = COCK_DIAMETER_RATIO_DEF, "cock_color" = "ffffff", "cock_taur" = FALSE, "has_balls" = FALSE, "balls_color" = "ffffff", "balls_shape" = DEF_BALLS_SHAPE, "balls_size" = BALLS_SIZE_DEF, "balls_cum_rate" = CUM_RATE, "balls_cum_mult" = CUM_RATE_MULT, "balls_efficiency" = CUM_EFFICIENCY, "has_breasts" = FALSE, "breasts_color" = "ffffff", "breasts_size" = BREASTS_SIZE_DEF, "breasts_shape" = DEF_BREASTS_SHAPE, "breasts_producing" = FALSE, "has_vag" = FALSE, "vag_shape" = DEF_VAGINA_SHAPE, "vag_color" = "ffffff", "has_womb" = FALSE, "balls_visibility"	= GEN_VISIBLE_NO_UNDIES, "breasts_visibility"= GEN_VISIBLE_NO_UNDIES, "cock_visibility"	= GEN_VISIBLE_NO_UNDIES, "vag_visibility"	= GEN_VISIBLE_NO_UNDIES, "ipc_screen" = "Sunburst", "ipc_antenna" = "None", "flavor_text" = "", "silicon_flavor_text" = "", "ooc_notes" = "", "meat_type" = "Mammalian", "body_model" = MALE, "body_size" = RESIZE_DEFAULT_SIZE, "color_scheme" = OLD_CHARACTER_COLORING)

	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		WRITE_FILE(S["default_slot"] , slot)

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return FALSE

	. = TRUE

	//Species
	var/species_id
	S["species"]			>> species_id
	if(species_id)
		if(species_id == "avian" || species_id == "aquatic")
			species_id = "mammal"
		else if(species_id == "moth")
			species_id = "insect"

		var/newtype = GLOB.species_list[species_id]
		if(newtype)
			pref_species = new newtype


	scars_index = rand(1,5) // WHY

	//Character
	S["real_name"]				>> real_name
	S["nameless"]				>> nameless
	S["custom_species"]			>> custom_species
	S["name_is_always_random"]	>> be_random_name
	S["body_is_always_random"]	>> be_random_body
	S["gender"]					>> gender
	S["body_model"]				>> features["body_model"]
	S["body_size"]				>> features["body_size"]
	S["age"]					>> age
	S["hair_color"]				>> hair_color
	S["facial_hair_color"]		>> facial_hair_color
	S["eye_type"]				>> eye_type
	S["left_eye_color"]			>> left_eye_color
	S["right_eye_color"]		>> right_eye_color
	S["use_custom_skin_tone"]	>> use_custom_skin_tone
	S["skin_tone"]				>> skin_tone
	S["hair_style_name"]		>> hair_style
	S["facial_style_name"]		>> facial_hair_style
	S["underwear"]				>> underwear
	S["undie_color"]			>> undie_color
	S["undershirt"]				>> undershirt
	S["shirt_color"]			>> shirt_color
	S["socks"]					>> socks
	S["socks_color"]			>> socks_color
	S["backbag"]				>> backbag
	S["jumpsuit_style"]			>> jumpsuit_style
	S["uplink_loc"]				>> uplink_spawn_loc
	S["custom_speech_verb"]		>> custom_speech_verb
	S["custom_tongue"]			>> custom_tongue
	S["additional_language"]	>> additional_language
	S["feature_mcolor"]					>> features["mcolor"]
	S["feature_lizard_tail"]			>> features["tail_lizard"]
	S["feature_lizard_snout"]			>> features["snout"]
	S["feature_lizard_horns"]			>> features["horns"]
	S["feature_lizard_frills"]			>> features["frills"]
	S["feature_lizard_spines"]			>> features["spines"]
	S["feature_lizard_legs"]			>> features["legs"]
	S["feature_human_tail"]				>> features["tail_human"]
	S["feature_human_ears"]				>> features["ears"]
	S["feature_deco_wings"]				>> features["deco_wings"]
	S["feature_insect_wings"]			>> features["insect_wings"]
	S["feature_insect_fluff"]			>> features["insect_fluff"]
	S["feature_insect_markings"]		>> features["insect_markings"]
	S["feature_arachnid_legs"]			>> features["arachnid_legs"]
	S["feature_arachnid_spinneret"]		>> features["arachnid_spinneret"]
	S["feature_arachnid_mandibles"]		>> features["arachnid_mandibles"]
	S["feature_horns_color"]			>> features["horns_color"]
	S["feature_wings_color"]			>> features["wings_color"]
	S["feature_color_scheme"]			>> features["color_scheme"]
	S["persistent_scars"] 				>> persistent_scars
	S["scars1"]							>> scars_list["1"]
	S["scars2"]							>> scars_list["2"]
	S["scars3"]							>> scars_list["3"]
	S["scars4"]							>> scars_list["4"]
	S["scars5"]							>> scars_list["5"]
	var/limbmodstr
	S["modified_limbs"] >> limbmodstr
	if(length(limbmodstr))
		try
			modified_limbs = safe_json_decode(limbmodstr)
		catch
			modified_limbs = list()
	else
		modified_limbs = list()

	var/tcgcardstr
	S["tcg_cards"] >> tcgcardstr
	if(length(tcgcardstr))
		try
			tcg_cards = safe_json_decode(tcgcardstr)
		catch
			tcg_cards = list()
	else
		tcg_cards = list()

	var/tcgdeckstr
	S["tcg_decks"] >> tcgdeckstr
	if(length(tcgdeckstr))
		try
			tcg_decks = safe_json_decode(tcgdeckstr)
		catch
			tcg_decks = list()
	else
		tcg_decks = list()

	S["chosen_limb_id"]					>> chosen_limb_id
	S["hide_ckey"]						>> hide_ckey //saved per-character

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		S[savefile_slot_name] >> custom_names[custom_name_id]

	S["preferred_ai_core_display"]		>> preferred_ai_core_display
	S["prefered_security_department"]	>> prefered_security_department

	//Jobs
	S["joblessrole"]		>> joblessrole

	//Load prefs
	S["job_preferences"]	>> job_preferences

	//Quirks
	S["all_quirks"]			>> all_quirks

	//Records
	S["security_records"]			>>			security_records
	S["medical_records"]			>>			medical_records

	//Citadel code
	S["feature_genitals_use_skintone"]	>> features["genitals_use_skintone"]
	S["feature_mcolor2"]				>> features["mcolor2"]
	S["feature_mcolor3"]				>> features["mcolor3"]
	// note safe json decode will runtime the first time it migrates but this is fine and it solves itself don't worry about it if you see it error
	features["mam_body_markings"] = safe_json_decode(S["feature_mam_body_markings"])
	S["feature_mam_tail"]				>> features["mam_tail"]
	S["feature_mam_ears"]				>> features["mam_ears"]
	S["feature_mam_tail_animated"]		>> features["mam_tail_animated"]
	S["feature_taur"]					>> features["taur"]
	S["feature_mam_snouts"]				>> features["mam_snouts"]
	S["feature_meat"]					>> features["meat_type"]
	//Xeno features
	S["feature_xeno_tail"]				>> features["xenotail"]
	S["feature_xeno_dors"]				>> features["xenodorsal"]
	S["feature_xeno_head"]				>> features["xenohead"]
	//cock features
	S["feature_has_cock"]				>> features["has_cock"]
	S["feature_cock_shape"]				>> features["cock_shape"]
	S["feature_cock_color"]				>> features["cock_color"]
	S["feature_cock_length"]			>> features["cock_length"]
	S["feature_cock_diameter"]			>> features["cock_diameter"]
	S["feature_cock_taur"]				>> features["cock_taur"]
	S["feature_cock_visibility"]		>> features["cock_visibility"]
	//balls features
	S["feature_has_balls"]				>> features["has_balls"]
	S["feature_balls_color"]			>> features["balls_color"]
	S["feature_balls_size"]				>> features["balls_size"]
	S["feature_balls_visibility"]		>> features["balls_visibility"]
	//breasts features
	S["feature_has_breasts"]			>> features["has_breasts"]
	S["feature_breasts_size"]			>> features["breasts_size"]
	S["feature_breasts_shape"]			>> features["breasts_shape"]
	S["feature_breasts_color"]			>> features["breasts_color"]
	S["feature_breasts_producing"]		>> features["breasts_producing"]
	S["feature_breasts_visibility"]		>> features["breasts_visibility"]
	//vagina features
	S["feature_has_vag"]				>> features["has_vag"]
	S["feature_vag_shape"]				>> features["vag_shape"]
	S["feature_vag_color"]				>> features["vag_color"]
	S["feature_vag_visibility"]			>> features["vag_visibility"]
	//womb features
	S["feature_has_womb"]				>> features["has_womb"]

	//flavor text
	//Let's make our players NOT cry desperately as we wipe their savefiles of their special snowflake texts:
	if((S["flavor_text"] != "") && (S["flavor_text"] != null) && S["flavor_text"]) //If old text isn't null and isn't "" but still exists.
		S["flavor_text"]				>> features["flavor_text"] //Load old flavortext as current dna-based flavortext

		WRITE_FILE(S["feature_flavor_text"], features["flavor_text"]) //Save it in our new type of flavor-text
		WRITE_FILE(S["flavor_text"]	, "") //Remove old flavortext, completing the cut-and-paste into the new format.

	else //We have no old flavortext, default to new
		S["feature_flavor_text"]		>> features["flavor_text"]


	S["silicon_feature_flavor_text"]		>> features["silicon_flavor_text"]

	S["feature_ooc_notes"]				>> features["ooc_notes"]
	S["silicon_flavor_text"] >> features["silicon_flavor_text"]

	S["vore_flags"]						>> vore_flags
	S["vore_taste"]						>> vore_taste
	var/char_vr_path = "[vr_path]/character_[default_slot]_v2.json"
	if(fexists(char_vr_path))
		var/list/json_from_file = json_decode(file2text(char_vr_path))
		if(json_from_file)
			belly_prefs = json_from_file["belly_prefs"]

	//gear loadout
	if(S["loadout"])
		try
			loadout_data = safe_json_decode(S["loadout"])
		catch
			loadout_data = list()
	else
		loadout_data = list()

	//try to fix any outdated data if necessary
	//preference updating will handle saving the updated data for us.
	if(needs_update >= 0)
		update_character(needs_update, S)		//needs_update == savefile_version if we need an update (positive integer)

	//Sanitize

	real_name	= reject_bad_name(real_name)
	gender		= sanitize_gender(gender, TRUE, TRUE)
	features["body_model"] = sanitize_gender(features["body_model"], FALSE, FALSE, gender == FEMALE ? FEMALE : MALE)
	if(!real_name)
		real_name	= random_unique_name(gender)
	custom_species	= reject_bad_name(custom_species)
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_names[custom_name_id] = reject_bad_name(custom_names[custom_name_id],namedata["allow_numbers"])
		if(!custom_names[custom_name_id])
			custom_names[custom_name_id] = get_default_name(custom_name_id)

	nameless		= sanitize_integer(nameless, 0, 1, initial(nameless))
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))

	hair_style					= sanitize_inlist(hair_style, GLOB.hair_styles_list)
	facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_list)
	underwear					= sanitize_inlist(underwear, GLOB.underwear_list)
	undershirt 					= sanitize_inlist(undershirt, GLOB.undershirt_list)
	undie_color						= sanitize_hexcolor(undie_color, 6, FALSE, initial(undie_color))
	shirt_color						= sanitize_hexcolor(shirt_color, 6, FALSE, initial(shirt_color))
	socks							= sanitize_inlist(socks, GLOB.socks_list)
	socks_color						= sanitize_hexcolor(socks_color, 6, FALSE, initial(socks_color))
	age								= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	hair_color						= sanitize_hexcolor(hair_color, 6, FALSE)
	facial_hair_color				= sanitize_hexcolor(facial_hair_color, 6, FALSE)
	eye_type						= sanitize_inlist(eye_type, GLOB.eye_types, DEFAULT_EYES_TYPE)
	left_eye_color					= sanitize_hexcolor(left_eye_color, 6, FALSE)
	right_eye_color					= sanitize_hexcolor(right_eye_color, 6, FALSE)

	var/static/allow_custom_skintones
	if(isnull(allow_custom_skintones))
		allow_custom_skintones = CONFIG_GET(flag/allow_custom_skintones)
	use_custom_skin_tone			= allow_custom_skintones ? sanitize_integer(use_custom_skin_tone, FALSE, TRUE, initial(use_custom_skin_tone)) : FALSE
	if(use_custom_skin_tone)
		skin_tone					= sanitize_hexcolor(skin_tone, 6, TRUE, "#FFFFFF")
	else
		skin_tone					= sanitize_inlist(skin_tone, GLOB.skin_tones - GLOB.nonstandard_skin_tones, initial(skin_tone))

	features["horns_color"]			= sanitize_hexcolor(features["horns_color"], 6, FALSE, "85615a")
	features["wings_color"]			= sanitize_hexcolor(features["wings_color"], 6, FALSE, "FFFFFF")
	backbag							= sanitize_inlist(backbag, GLOB.backbaglist, initial(backbag))
	jumpsuit_style					= sanitize_inlist(jumpsuit_style, GLOB.jumpsuitlist, initial(jumpsuit_style))
	uplink_spawn_loc				= sanitize_inlist(uplink_spawn_loc, GLOB.uplink_spawn_loc_list, initial(uplink_spawn_loc))
	features["mcolor"]				= sanitize_hexcolor(features["mcolor"], 6, FALSE)
	features["tail_lizard"]			= sanitize_inlist(features["tail_lizard"], GLOB.tails_list_lizard)
	features["tail_human"]			= sanitize_inlist(features["tail_human"], GLOB.tails_list_human)
	features["snout"]				= sanitize_inlist(features["snout"], GLOB.snouts_list)
	features["horns"]				= sanitize_inlist(features["horns"], GLOB.horns_list)
	features["ears"]				= sanitize_inlist(features["ears"], GLOB.ears_list)
	features["frills"]				= sanitize_inlist(features["frills"], GLOB.frills_list)
	features["spines"]				= sanitize_inlist(features["spines"], GLOB.spines_list)
	features["legs"]				= sanitize_inlist(features["legs"], GLOB.legs_list, "Plantigrade")
	features["deco_wings"] 			= sanitize_inlist(features["deco_wings"], GLOB.deco_wings_list, "None")
	features["insect_fluff"]		= sanitize_inlist(features["insect_fluff"], GLOB.insect_fluffs_list)
	features["insect_markings"] 	= sanitize_inlist(features["insect_markings"], GLOB.insect_markings_list, "None")
	features["insect_wings"] 		= sanitize_inlist(features["insect_wings"], GLOB.insect_wings_list)
	features["arachnid_legs"] 		= sanitize_inlist(features["arachnid_legs"], GLOB.arachnid_legs_list, "Plain")
	features["arachnid_spinneret"] 	= sanitize_inlist(features["arachnid_spinneret"], GLOB.arachnid_spinneret_list, "Plain")
	features["arachnid_mandibles"]	= sanitize_inlist(features["arachnid_mandibles"], GLOB.arachnid_mandibles_list, "Plain")

	var/static/size_min
	if(!size_min)
		size_min = CONFIG_GET(number/body_size_min)
	var/static/size_max
	if(!size_max)
		size_max = CONFIG_GET(number/body_size_max)
	features["body_size"]			= sanitize_num_clamp(features["body_size"], size_min, size_max, RESIZE_DEFAULT_SIZE, 0.01)

	var/static/list/B_sizes
	if(!B_sizes)
		var/list/L = CONFIG_GET(keyed_list/breasts_cups_prefs)
		B_sizes = L.Copy()
	var/static/min_D
	if(!min_D)
		min_D = CONFIG_GET(number/penis_min_inches_prefs)
	var/static/max_D
	if(!max_D)
		max_D = CONFIG_GET(number/penis_max_inches_prefs)
	var/static/safe_visibilities
	if(!safe_visibilities)
		var/list/L = CONFIG_GET(keyed_list/safe_visibility_toggles)
		safe_visibilities = L.Copy()

	features["breasts_size"]		= sanitize_inlist(features["breasts_size"], B_sizes, BREASTS_SIZE_DEF)
	features["cock_length"]			= sanitize_integer(features["cock_length"], min_D, max_D, COCK_SIZE_DEF)
	features["breasts_shape"]		= sanitize_inlist(features["breasts_shape"], GLOB.breasts_shapes_list, DEF_BREASTS_SHAPE)
	features["cock_shape"]			= sanitize_inlist(features["cock_shape"], GLOB.cock_shapes_list, DEF_COCK_SHAPE)
	features["balls_shape"]			= sanitize_inlist(features["balls_shape"], GLOB.balls_shapes_list, DEF_BALLS_SHAPE)
	features["vag_shape"]			= sanitize_inlist(features["vag_shape"], GLOB.vagina_shapes_list, DEF_VAGINA_SHAPE)
	features["breasts_color"]		= sanitize_hexcolor(features["breasts_color"], 6, FALSE, "FFFFFF")
	features["cock_color"]			= sanitize_hexcolor(features["cock_color"], 6, FALSE, "FFFFFF")
	features["balls_color"]			= sanitize_hexcolor(features["balls_color"], 6, FALSE, "FFFFFF")
	features["vag_color"]			= sanitize_hexcolor(features["vag_color"], 6, FALSE, "FFFFFF")
	features["breasts_visibility"]	= sanitize_inlist(features["breasts_visibility"], safe_visibilities, GEN_VISIBLE_NO_UNDIES)
	features["cock_visibility"]		= sanitize_inlist(features["cock_visibility"], safe_visibilities, GEN_VISIBLE_NO_UNDIES)
	features["balls_visibility"]	= sanitize_inlist(features["balls_visibility"], safe_visibilities, GEN_VISIBLE_NO_UNDIES)
	features["vag_visibility"]		= sanitize_inlist(features["vag_visibility"], safe_visibilities, GEN_VISIBLE_NO_UNDIES)

	custom_speech_verb				= sanitize_inlist(custom_speech_verb, GLOB.speech_verbs, "default")
	custom_tongue					= sanitize_inlist(custom_tongue, GLOB.roundstart_tongues, "default")
	additional_language				= sanitize_inlist(additional_language, GLOB.roundstart_languages, "None")

	security_records				= copytext(security_records, 1, MAX_FLAVOR_LEN)
	medical_records					= copytext(medical_records, 1, MAX_FLAVOR_LEN)

	features["flavor_text"]			= copytext(features["flavor_text"], 1, MAX_FLAVOR_LEN)
	features["silicon_flavor_text"]			= copytext(features["silicon_flavor_text"], 1, MAX_FLAVOR_LEN)
	features["ooc_notes"]			= copytext(features["ooc_notes"], 1, MAX_FLAVOR_LEN)

	//load every advanced coloring mode thing in one go
	//THIS MUST BE DONE AFTER ALL FEATURE SAVES OR IT WILL NOT WORK
	for(var/feature in features)
		var/feature_value = features[feature]
		if(feature_value)
			var/ref_list = GLOB.mutant_reference_list[feature]
			if(ref_list)
				var/datum/sprite_accessory/accessory = ref_list[feature_value]
				if(accessory)
					var/mutant_string = accessory.mutant_part_string
					if(!mutant_string)
						if(istype(accessory, /datum/sprite_accessory/mam_body_markings))
							mutant_string = "mam_body_markings"
					var/primary_string = "[mutant_string]_primary"
					var/secondary_string = "[mutant_string]_secondary"
					var/tertiary_string = "[mutant_string]_tertiary"
					if(accessory.color_src == MATRIXED && !accessory.matrixed_sections && feature_value != "None")
						message_admins("Sprite Accessory Failure (loading data): Accessory [accessory.type] is a matrixed item without any matrixed sections set!")
						continue
					if(S["feature_[primary_string]"])
						S["feature_[primary_string]"]		>> features[primary_string]
					if(S["feature_[secondary_string]"])
						S["feature_[secondary_string]"]		>> features[secondary_string]
					if(S["feature_[tertiary_string]"])
						S["feature_[tertiary_string]"]		>> features[tertiary_string]

	persistent_scars = sanitize_integer(persistent_scars)
	scars_list["1"] = sanitize_text(scars_list["1"])
	scars_list["2"] = sanitize_text(scars_list["2"])
	scars_list["3"] = sanitize_text(scars_list["3"])
	scars_list["4"] = sanitize_text(scars_list["4"])
	scars_list["5"] = sanitize_text(scars_list["5"])

	joblessrole	= sanitize_integer(joblessrole, 1, 3, initial(joblessrole))
	//Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences["[j]"] != JP_LOW && job_preferences["[j]"] != JP_MEDIUM && job_preferences["[j]"] != JP_HIGH)
			job_preferences -= j

	all_quirks = SANITIZE_LIST(all_quirks)

	vore_flags						= sanitize_integer(vore_flags, 0, MAX_VORE_FLAG, 0)
	vore_taste						= copytext(vore_taste, 1, MAX_TASTE_LEN)
	belly_prefs 					= SANITIZE_LIST(belly_prefs)

	cit_character_pref_load(S)

	return 1

/datum/preferences/proc/save_character(bypass_cooldown = FALSE)
	if(!path)
		return 0
	if(!bypass_cooldown)
		if(world.time < savecharcooldown)
			if(istype(parent))
				to_chat(parent, "<span class='warning'>You're attempting to save your character a little too fast. Wait half a second, then try again.</span>")
			return 0
		savecharcooldown = world.time + PREF_SAVELOAD_COOLDOWN
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/character[default_slot]"

	WRITE_FILE(S["version"]			, SAVEFILE_VERSION_MAX)	//load_character will sanitize any bad data, so assume up-to-date.)

	//Character
	WRITE_FILE(S["real_name"]				, real_name)
	WRITE_FILE(S["nameless"]				, nameless)
	WRITE_FILE(S["custom_species"]			, custom_species)
	WRITE_FILE(S["name_is_always_random"]	, be_random_name)
	WRITE_FILE(S["body_is_always_random"]	, be_random_body)
	WRITE_FILE(S["gender"]					, gender)
	WRITE_FILE(S["body_model"]				, features["body_model"])
	WRITE_FILE(S["body_size"]				, features["body_size"])
	WRITE_FILE(S["age"]						, age)
	WRITE_FILE(S["hair_color"]				, hair_color)
	WRITE_FILE(S["facial_hair_color"]		, facial_hair_color)
	WRITE_FILE(S["eye_type"]				, eye_type)
	WRITE_FILE(S["left_eye_color"]			, left_eye_color)
	WRITE_FILE(S["right_eye_color"]			, right_eye_color)
	WRITE_FILE(S["use_custom_skin_tone"]	, use_custom_skin_tone)
	WRITE_FILE(S["skin_tone"]				, skin_tone)
	WRITE_FILE(S["hair_style_name"]			, hair_style)
	WRITE_FILE(S["facial_style_name"]		, facial_hair_style)
	WRITE_FILE(S["underwear"]				, underwear)
	WRITE_FILE(S["undie_color"]				, undie_color)
	WRITE_FILE(S["undershirt"]				, undershirt)
	WRITE_FILE(S["shirt_color"]				, shirt_color)
	WRITE_FILE(S["socks"]					, socks)
	WRITE_FILE(S["socks_color"]				, socks_color)
	WRITE_FILE(S["backbag"]					, backbag)
	WRITE_FILE(S["jumpsuit_style"]			, jumpsuit_style)
	WRITE_FILE(S["uplink_loc"]				, uplink_spawn_loc)
	WRITE_FILE(S["species"]					, pref_species.id)
	WRITE_FILE(S["custom_speech_verb"]		, custom_speech_verb)
	WRITE_FILE(S["custom_tongue"]			, custom_tongue)
	WRITE_FILE(S["additional_language"]		, additional_language)

	// records
	WRITE_FILE(S["security_records"]		, security_records)
	WRITE_FILE(S["medical_records"]			, medical_records)

	WRITE_FILE(S["feature_mcolor"]					, features["mcolor"])
	WRITE_FILE(S["feature_lizard_tail"]				, features["tail_lizard"])
	WRITE_FILE(S["feature_human_tail"]				, features["tail_human"])
	WRITE_FILE(S["feature_lizard_snout"]			, features["snout"])
	WRITE_FILE(S["feature_lizard_horns"]			, features["horns"])
	WRITE_FILE(S["feature_human_ears"]				, features["ears"])
	WRITE_FILE(S["feature_lizard_frills"]			, features["frills"])
	WRITE_FILE(S["feature_lizard_spines"]			, features["spines"])
	WRITE_FILE(S["feature_lizard_legs"]				, features["legs"])
	WRITE_FILE(S["feature_deco_wings"]				, features["deco_wings"])
	WRITE_FILE(S["feature_horns_color"]				, features["horns_color"])
	WRITE_FILE(S["feature_wings_color"]				, features["wings_color"])
	WRITE_FILE(S["feature_insect_wings"]			, features["insect_wings"])
	WRITE_FILE(S["feature_insect_fluff"]			, features["insect_fluff"])
	WRITE_FILE(S["feature_insect_markings"]			, features["insect_markings"])
	WRITE_FILE(S["feature_arachnid_legs"]			, features["arachnid_legs"])
	WRITE_FILE(S["feature_arachnid_spinneret"]		, features["arachnid_spinneret"])
	WRITE_FILE(S["feature_arachnid_mandibles"]		, features["arachnid_mandibles"])
	WRITE_FILE(S["feature_meat"]					, features["meat_type"])

	WRITE_FILE(S["feature_has_cock"], features["has_cock"])
	WRITE_FILE(S["feature_cock_shape"], features["cock_shape"])
	WRITE_FILE(S["feature_cock_color"], features["cock_color"])
	WRITE_FILE(S["feature_cock_length"], features["cock_length"])
	WRITE_FILE(S["feature_cock_taur"], features["cock_taur"])
	WRITE_FILE(S["feature_cock_visibility"], features["cock_visibility"])

	WRITE_FILE(S["feature_has_balls"], features["has_balls"])
	WRITE_FILE(S["feature_balls_color"], features["balls_color"])
	WRITE_FILE(S["feature_balls_size"], features["balls_size"])
	WRITE_FILE(S["feature_balls_visibility"], features["balls_visibility"])

	WRITE_FILE(S["feature_has_breasts"], features["has_breasts"])
	WRITE_FILE(S["feature_breasts_size"], features["breasts_size"])
	WRITE_FILE(S["feature_breasts_shape"], features["breasts_shape"])
	WRITE_FILE(S["feature_breasts_color"], features["breasts_color"])
	WRITE_FILE(S["feature_breasts_producing"], features["breasts_producing"])
	WRITE_FILE(S["feature_breasts_visibility"], features["breasts_visibility"])

	WRITE_FILE(S["feature_has_vag"], features["has_vag"])
	WRITE_FILE(S["feature_vag_shape"], features["vag_shape"])
	WRITE_FILE(S["feature_vag_color"], features["vag_color"])
	WRITE_FILE(S["feature_vag_visibility"], features["vag_visibility"])

	WRITE_FILE(S["feature_has_womb"], features["has_womb"])

	WRITE_FILE(S["feature_ooc_notes"], features["ooc_notes"])

	WRITE_FILE(S["feature_color_scheme"], features["color_scheme"])

	//save every advanced coloring mode thing in one go
	for(var/feature in features)
		var/feature_value = features[feature]
		if(feature_value)
			var/ref_list = GLOB.mutant_reference_list[feature]
			if(ref_list)
				var/datum/sprite_accessory/accessory = ref_list[feature_value]
				if(accessory)
					var/mutant_string = accessory.mutant_part_string
					if(!mutant_string)
						if(istype(accessory, /datum/sprite_accessory/mam_body_markings))
							mutant_string = "mam_body_markings"
					var/primary_string = "[mutant_string]_primary"
					var/secondary_string = "[mutant_string]_secondary"
					var/tertiary_string = "[mutant_string]_tertiary"
					if(accessory.color_src == MATRIXED && !accessory.matrixed_sections && feature_value != "None")
						message_admins("Sprite Accessory Failure (saving data): Accessory [accessory.type] is a matrixed item without any matrixed sections set!")
						continue
					if(features[primary_string])
						WRITE_FILE(S["feature_[primary_string]"], features[primary_string])
					if(features[secondary_string])
						WRITE_FILE(S["feature_[secondary_string]"], features[secondary_string])
					if(features[tertiary_string])
						WRITE_FILE(S["feature_[tertiary_string]"], features[tertiary_string])

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		WRITE_FILE(S[savefile_slot_name],custom_names[custom_name_id])

	WRITE_FILE(S["preferred_ai_core_display"]		,  preferred_ai_core_display)
	WRITE_FILE(S["prefered_security_department"]	, prefered_security_department)

	//Jobs
	WRITE_FILE(S["joblessrole"]		, joblessrole)
	//Write prefs
	WRITE_FILE(S["job_preferences"] , job_preferences)
	WRITE_FILE(S["hide_ckey"]		, hide_ckey)

	//Quirks
	WRITE_FILE(S["all_quirks"]			, all_quirks)

	WRITE_FILE(S["vore_flags"]			, vore_flags)
	WRITE_FILE(S["vore_taste"]			, vore_taste)
	var/char_vr_path = "[vr_path]/character_[default_slot]_v2.json"
	var/belly_prefs_json = safe_json_encode(list("belly_prefs" = belly_prefs))
	if(fexists(char_vr_path))
		fdel(char_vr_path)
	text2file(belly_prefs_json,char_vr_path)

	WRITE_FILE(S["persistent_scars"]			, persistent_scars)
	WRITE_FILE(S["scars1"]						, scars_list["1"])
	WRITE_FILE(S["scars2"]						, scars_list["2"])
	WRITE_FILE(S["scars3"]						, scars_list["3"])
	WRITE_FILE(S["scars4"]						, scars_list["4"])
	WRITE_FILE(S["scars5"]						, scars_list["5"])
	if(islist(modified_limbs))
		WRITE_FILE(S["modified_limbs"]				, safe_json_encode(modified_limbs))
	WRITE_FILE(S["chosen_limb_id"],   chosen_limb_id)


	//gear loadout
	if(length(loadout_data))
		S["loadout"] << safe_json_encode(loadout_data)
	else
		S["loadout"] << safe_json_encode(list())

	if(length(tcg_cards))
		S["tcg_cards"] << safe_json_encode(tcg_cards)
	else
		S["tcg_cards"] << safe_json_encode(list())

	if(length(tcg_decks))
		S["tcg_decks"] << safe_json_encode(tcg_decks)
	else
		S["tcg_decks"] << safe_json_encode(list())

	cit_character_pref_save(S)

	return 1


#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN

#ifdef TESTING
//DEBUG
//Some crude tools for testing savefiles
//path is the savefile path
/client/verb/savefile_export(path as text)
	var/savefile/S = new /savefile(path)
	S.ExportText("/",file("[path].txt"))
//path is the savefile path
/client/verb/savefile_import(path as text)
	var/savefile/S = new /savefile(path)
	S.ImportText("/",file("[path].txt"))

#endif
