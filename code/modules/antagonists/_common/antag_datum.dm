GLOBAL_LIST_EMPTY(antagonists)

/datum/antagonist
	var/name = "Antagonist"
	var/roundend_category = "other antagonists"				//Section of roundend report, datums with same category will be displayed together, also default header for the section
	var/show_in_roundend = TRUE								//Set to false to hide the antagonists from roundend report
	var/datum/mind/owner						//Mind that owns this datum
	var/silent = FALSE							//Silent will prevent the gain/lose texts to show
	var/can_coexist_with_others = TRUE			//Whether or not the person will be able to have more than one datum
	var/list/typecache_datum_blacklist = list()	//List of datums this type can't coexist with
	var/delete_on_mind_deletion = TRUE
	var/job_rank
	var/replace_banned = TRUE //Should replace jobbaned player with ghosts if granted.
	var/list/objectives = list()
	var/antag_memory = ""//These will be removed with antag datum
	var/antag_moodlet //typepath of moodlet that the mob will gain with their status
	var/antag_hud_type
	var/antag_hud_name
	/// If above 0, this is the multiplier for the speed at which we hijack the shuttle. Do not directly read, use hijack_speed().
	var/hijack_speed = 0

	//Antag panel properties
	var/show_in_antagpanel = TRUE	//This will hide adding this antag type in antag panel, use only for internal subtypes that shouldn't be added directly but still show if possessed by mind
	var/antagpanel_category = "Uncategorized"	//Antagpanel will display these together, REQUIRED
	var/show_name_in_check_antagonists = FALSE //Will append antagonist name in admin listings - use for categories that share more than one antag type
	var/list/blacklisted_quirks = list(/datum/quirk/nonviolent,/datum/quirk/mute) // Quirks that will be removed upon gaining this antag. Pacifist and mute are default.
	var/threat = 0 // Amount of threat this antag poses, for dynamic mode
//ambition start
	/// Lazy list for antagonists to request the admins objectives.
	var/list/requested_objective_changes
//ambition end
	var/show_to_ghosts = FALSE // Should this antagonist be shown as antag to ghosts? Shouldn't be used for stealthy antagonists like traitors

	var/list/skill_modifiers

/datum/antagonist/New()
	GLOB.antagonists += src
	typecache_datum_blacklist = typecacheof(typecache_datum_blacklist)

/datum/antagonist/Destroy()
	GLOB.antagonists -= src
//ambition start
	owner?.do_remove_antag_datum(src)
//ambition end
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	. = TRUE
	var/datum/mind/tested = new_owner || owner
	if(tested.has_antag_datum(type))
		return FALSE
	for(var/i in tested.antag_datums)
		var/datum/antagonist/A = i
		if(is_type_in_typecache(src, A.typecache_datum_blacklist))
			return FALSE

//This will be called in add_antag_datum before owner assignment.
//Should return antag datum without owner.
/datum/antagonist/proc/specialization(datum/mind/new_owner)
	return src

/datum/antagonist/proc/on_body_transfer(mob/living/old_body, mob/living/new_body)
	remove_innate_effects(old_body)
	apply_innate_effects(new_body)

//This handles the application of antag huds/special abilities
/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	return

//This handles the removal of antag huds/special abilities
/datum/antagonist/proc/remove_innate_effects(mob/living/mob_override)
	return

// Adds the specified antag hud to the player. Usually called in an antag datum file
/datum/antagonist/proc/add_antag_hud(antag_hud_type, antag_hud_name, mob/living/mob_override)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(mob_override)
	set_antag_hud(mob_override, antag_hud_name)

// Removes the specified antag hud from the player. Usually called in an antag datum file
/datum/antagonist/proc/remove_antag_hud(antag_hud_type, mob/living/mob_override)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.leave_hud(mob_override)
	set_antag_hud(mob_override, null)

// Handles adding and removing the clumsy mutation from clown antags. Gets called in apply/remove_innate_effects
/datum/antagonist/proc/handle_clown_mutation(mob/living/mob_override, message, removing = TRUE)
	var/mob/living/carbon/human/H = mob_override
	if(H && istype(H) && owner.assigned_role == "Clown")
		if(removing) // They're a clown becoming an antag, remove clumsy
			H.dna.remove_mutation(CLOWNMUT)
			if(!silent && message)
				to_chat(H, "<span class='boldnotice'>[message]</span>")
		else
			H.dna.add_mutation(CLOWNMUT) // We're removing their antag status, add back clumsy

//Assign default team and creates one for one of a kind team antagonists
/datum/antagonist/proc/create_team(datum/team/team)
	return

//Proc called when the datum is given to a mind.
/datum/antagonist/proc/on_gain()
	set waitfor = FALSE
	if(!(owner?.current))
		return
	if(!silent)
		greet()
	apply_innate_effects()
	give_antag_moodies()
	remove_blacklisted_quirks()
	if(is_banned(owner.current) && replace_banned)
		replace_banned_player()
	if(skill_modifiers)
		for(var/A in skill_modifiers)
			ADD_SINGLETON_SKILL_MODIFIER(owner, A, type)
			var/datum/skill_modifier/job/M = GLOB.skill_modifiers[GET_SKILL_MOD_ID(A, type)]
			if(istype(M))
				M.name = "[name] Training"
	owner.current.AddComponent(/datum/component/activity)
	SEND_SIGNAL(owner.current, COMSIG_MOB_ANTAG_ON_GAIN, src)

/datum/antagonist/proc/is_banned(mob/M)
	if(!M)
		return FALSE
	. = (jobban_isbanned(M, ROLE_SYNDICATE) || QDELETED(M) || (job_rank && (jobban_isbanned(M,job_rank) || QDELETED(M))))

/datum/antagonist/proc/replace_banned_player()
	set waitfor = FALSE

	var/list/mob/candidates = pollCandidatesForMob("Do you want to play as a [name]?", "[name]", null, job_rank, 50, owner.current)
	if(LAZYLEN(candidates))
		var/mob/C = pick(candidates)
		to_chat(owner, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(owner.current)]) to replace a jobbaned player.")
		owner.current.ghostize(0)
		C.transfer_ckey(owner.current, FALSE)

/datum/antagonist/proc/on_removal()
	remove_innate_effects()
	clear_antag_moodies()
	if(owner)
//ambition start
		owner.do_remove_antag_datum(src)
//ambition end
		for(var/A in skill_modifiers)
			owner.remove_skill_modifier(GET_SKILL_MOD_ID(A, type))
		if(!silent && owner.current)
			farewell()
	var/datum/team/team = get_team()
	if(team)
		team.remove_member(owner)
	// we don't remove the activity component on purpose--no real point to it
	qdel(src)

/datum/antagonist/proc/greet()
	return

/datum/antagonist/proc/farewell()
	return

/datum/antagonist/proc/give_antag_moodies()
	if(!antag_moodlet)
		return
	SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "antag_moodlet", antag_moodlet)

/datum/antagonist/proc/clear_antag_moodies()
	if(!antag_moodlet)
		return
	SEND_SIGNAL(owner.current, COMSIG_CLEAR_MOOD_EVENT, "antag_moodlet")

/datum/antagonist/proc/remove_blacklisted_quirks()
	var/mob/living/L = owner.current
	if(istype(L))
		for(var/q in L.roundstart_quirks)
			var/datum/quirk/Q = q
			if(Q.type in blacklisted_quirks)
				if(initial(Q.antag_removal_text))
					to_chat(L, "<span class='boldannounce'>[initial(Q.antag_removal_text)]</span>")
				qdel(Q)

//Returns the team antagonist belongs to if any.
/datum/antagonist/proc/get_team()
	return

//Individual roundend report
/datum/antagonist/proc/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += printplayer(owner)

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(objective.completable && !objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//Displayed at the start of roundend_category section, default to roundend_category header
/datum/antagonist/proc/roundend_report_header()
	return 	"<span class='header'>The [roundend_category] were:</span><br>"

//Displayed at the end of roundend_category section
/datum/antagonist/proc/roundend_report_footer()
	return


//ADMIN TOOLS

//Called when using admin tools to give antag status
/datum/antagonist/proc/admin_add(datum/mind/new_owner,mob/admin)
	message_admins("[key_name_admin(admin)] made [new_owner.current] into [name].")
	log_admin("[key_name(admin)] made [new_owner.current] into [name].")
	new_owner.add_antag_datum(src)

//Called when removing antagonist using admin tools
/datum/antagonist/proc/admin_remove(mob/user)
	if(!user)
		return
	message_admins("[key_name_admin(user)] has removed [name] antagonist status from [owner.current].")
	log_admin("[key_name(user)] has removed [name] antagonist status from [owner.current].")
	on_removal()

//gamemode/proc/is_mode_antag(antagonist/A) => TRUE/FALSE

//Additional data to display in antagonist panel section
//nuke disk code, genome count, etc
/datum/antagonist/proc/antag_panel_data()
	return ""

/datum/antagonist/proc/enabled_in_preferences(datum/mind/M)
	if(job_rank)
		if(M.current && M.current.client && (job_rank in M.current.client.prefs.be_special))
			return TRUE
		else
			return FALSE
	return TRUE

// List if ["Command"] = CALLBACK(), user will be appeneded to callback arguments on execution
/datum/antagonist/proc/get_admin_commands()
	. = list()

/datum/antagonist/Topic(href,href_list)
	if(!check_rights(R_ADMIN))
		return
	//Antag memory edit
	if (href_list["memory_edit"])
		edit_memory(usr)
		owner.traitor_panel()
		return

	//Some commands might delete/modify this datum clearing or changing owner
	var/datum/mind/persistent_owner = owner

	var/commands = get_admin_commands()
	for(var/admin_command in commands)
		if(href_list["command"] == admin_command)
			var/datum/callback/C = commands[admin_command]
			C.Invoke(usr)
			persistent_owner.traitor_panel()
			return

/datum/antagonist/proc/edit_memory(mob/user)
	var/new_memo = stripped_multiline_input(user, "Write new memory", "Memory", antag_memory, MAX_MESSAGE_LEN)
	if (isnull(new_memo))
		return
	antag_memory = new_memo

/// Gets how fast we can hijack the shuttle, return 0 for can not hijack. Defaults to hijack_speed var, override for custom stuff like buffing hijack speed for hijack objectives or something.
/datum/antagonist/proc/hijack_speed()
	var/datum/objective/hijack/H = locate() in objectives
	if(!isnull(H?.hijack_speed_override))
		return H.hijack_speed_override
	return hijack_speed

/// Gets our threat level. Defaults to threat var, override for custom stuff like different traitor goals having different threats.
/datum/antagonist/proc/threat()
	. = CONFIG_GET(keyed_list/antag_threat)[lowertext(name)]
	if(. == null)
		return threat

//This one is created by admin tools for custom objectives
/datum/antagonist/custom
	antagpanel_category = "Custom"
	show_name_in_check_antagonists = TRUE //They're all different

/datum/antagonist/custom/admin_add(datum/mind/new_owner,mob/admin)
	var/custom_name = stripped_input(admin, "Custom antagonist name:", "Custom antag", "Antagonist")
	if(custom_name)
		name = custom_name
	else
		return
	..()

///Clears change requests from deleted objectives to avoid broken references.
/datum/antagonist/proc/clean_request_from_del_objective(datum/objective/source, force)
	var/objective_reference = REF(source)
	for(var/uid in requested_objective_changes)
		var/list/change_request = requested_objective_changes[uid]
		if(change_request["target"] != objective_reference)
			continue
		LAZYREMOVE(requested_objective_changes, uid)


/datum/antagonist/proc/add_objective_change(uid, list/additions)
	LAZYADD(requested_objective_changes, uid)
	var/datum/objective/request_target = additions["target"]
	if(!ispath(request_target))
		request_target = locate(request_target) in objectives
		if(istype(request_target))
			RegisterSignal(request_target, COMSIG_PARENT_QDELETING, .proc/clean_request_from_del_objective)
	requested_objective_changes[uid] = additions


/datum/antagonist/proc/remove_objective_change(uid)
	if(!LAZYACCESS(requested_objective_changes, uid))
		return
	var/datum/objective/request_target = requested_objective_changes[uid]["target"]
	if(!ispath(request_target))
		request_target = locate(request_target) in objectives
		if(istype(request_target))
			UnregisterSignal(request_target, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(requested_objective_changes, uid)
