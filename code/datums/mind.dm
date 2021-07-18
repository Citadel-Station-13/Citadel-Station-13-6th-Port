/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transferring the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event), use this mob proc.

			mob.transfer_ckey(new_mob)

		The Login proc will handle making a new mind for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

//ambition start
#define AMBITION_COOLDOWN_TIME (5 SECONDS)
#define OBJECTIVES_COOLDOWN_TIME (2 SECONDS)
#define ADMIN_PING_COOLDOWN_TIME (10 MINUTES)
//ambition end

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/active = 0

	var/memory

	var/assigned_role
	var/special_role
	var/list/restricted_roles = list()

	var/hide_ckey = FALSE //hide ckey from round-end report

	var/list/spell_list = list() // Wizard mode & "Give Spell" badmin button.

	var/linglink
	var/datum/martial_art/martial_art
	var/static/default_martial_art = new/datum/martial_art
	var/miming = 0 // Mime's vow of silence
	var/list/antag_datums
	var/antag_hud_icon_state = null //this mind's ANTAG_HUD should have this icon_state
	var/datum/atom_hud/antag/antag_hud = null //this mind's antag HUD
	var/damnation_type = 0
	var/datum/mind/soulOwner //who owns the soul.  Under normal circumstances, this will point to src
	var/hasSoul = TRUE // If false, renders the character unable to sell their soul.
	var/isholy = FALSE //is this person a chaplain or admin role allowed to use bibles

	var/mob/living/enslaved_to //If this mind's master is another mob (i.e. adamantine golems)
	var/datum/language_holder/language_holder
	var/unconvertable = FALSE
	var/late_joiner = FALSE

	var/force_escaped = FALSE  // Set by Into The Sunset command of the shuttle manipulator
	var/list/learned_recipes //List of learned recipe TYPES.

	/// Our skill holder.
	var/datum/skill_holder/skill_holder

//ambition start
	/// Lazy list for antagonists to set goals they wish to achieve, to be shown at the round-end report.
	var/list/ambitions
//ambition end

	///What character we spawned in as- either at roundstart or latejoin, so we know for persistent scars if we ended as the same person or not
	var/mob/original_character


/datum/mind/New(var/key)
	skill_holder = new(src)
	src.key = key
	soulOwner = src
	martial_art = default_martial_art

/datum/mind/Destroy()
	SSticker.minds -= src
	if(islist(antag_datums))
		for(var/i in antag_datums)
			var/datum/antagonist/antag_datum = i
			if(antag_datum.delete_on_mind_deletion)
				qdel(i)
		antag_datums = null
	QDEL_NULL(skill_holder)
	return ..()

/datum/mind/proc/get_language_holder()
	if(!language_holder)
		language_holder = new (src)

	return language_holder

/datum/mind/proc/transfer_to(mob/new_character, var/force_key_move = 0)
	var/old_character = current
	var/signals = SEND_SIGNAL(new_character, COMSIG_MOB_PRE_PLAYER_CHANGE, new_character, old_character) | SEND_SIGNAL(src, COMSIG_PRE_MIND_TRANSFER, new_character, old_character)
	if(signals & COMPONENT_STOP_MIND_TRANSFER)
		return
	if(current)	// remove ourself from our old body's mind variable
		current.mind = null
		SStgui.on_transfer(current, new_character)

	if(key)
		if(new_character.key != key)					//if we're transferring into a body with a key associated which is not ours
			new_character.ghostize(TRUE, TRUE)						//we'll need to ghostize so that key isn't mobless.
	else
		key = new_character.key

	if(new_character.mind)								//disassociate any mind currently in our new body's mind variable
		new_character.mind.current = null

	var/datum/atom_hud/antag/hud_to_transfer = antag_hud//we need this because leave_hud() will clear this list
	var/mob/living/old_current = current
	if(current)
		current.transfer_observers_to(new_character)	//transfer anyone observing the old character to the new one
	current = new_character								//associate ourself with our new body
	new_character.mind = src							//and associate our new body with ourself
	for(var/a in antag_datums)	//Makes sure all antag datums effects are applied in the new body
		var/datum/antagonist/A = a
		A.on_body_transfer(old_current, current)
	if(iscarbon(new_character))
		var/mob/living/carbon/C = new_character
		C.last_mind = src
	transfer_antag_huds(hud_to_transfer)				//inherit the antag HUD
	transfer_actions(new_character)
	transfer_martial_arts(new_character)
	if(active || force_key_move)
		new_character.key = key		//now transfer the key to link the client to our new body
	if(new_character.client)
		LAZYCLEARLIST(new_character.client.recent_examines)
		new_character.client.init_verbs() // re-initialize character specific verbs
	current.update_atom_languages()

//CIT CHANGE - makes arousal update when transfering bodies
	if(isliving(new_character)) //New humans and such are by default enabled arousal. Let's always use the new mind's prefs.
		var/mob/living/L = new_character
		if(L.client?.prefs && L.client.prefs.auto_ooc && L.client.prefs.chat_toggles & CHAT_OOC)
			DISABLE_BITFIELD(L.client.prefs.chat_toggles,CHAT_OOC)

	hide_ckey = current.client?.prefs?.hide_ckey

	SEND_SIGNAL(src, COMSIG_MIND_TRANSFER, new_character, old_character)
	SEND_SIGNAL(new_character, COMSIG_MOB_ON_NEW_MIND)

/datum/mind/proc/store_memory(new_text)
	if((length_char(memory) + length_char(new_text)) <= MAX_MESSAGE_LEN)
		memory += "[new_text]<BR>"

/datum/mind/proc/wipe_memory()
	memory = null

// Datum antag mind procs
/datum/mind/proc/add_antag_datum(datum_type_or_instance, team)
	if(!datum_type_or_instance)
		return
	var/datum/antagonist/A
	if(!ispath(datum_type_or_instance))
		A = datum_type_or_instance
		if(!istype(A))
			return
	else
		A = new datum_type_or_instance()
	//Choose snowflake variation if antagonist handles it
	var/datum/antagonist/S = A.specialization(src)
	if(S && S != A)
		qdel(A)
		A = S
	if(!A.can_be_owned(src))
		qdel(A)
		return
	A.owner = src
//ambition start
	do_add_antag_datum(A)
//ambition end
	A.create_team(team)
	var/datum/team/antag_team = A.get_team()
	if(antag_team)
		antag_team.add_member(src)
	A.on_gain()
	return A

//ambition start
/datum/mind/proc/do_add_antag_datum(instanced_datum)
	. = LAZYLEN(antag_datums)
	LAZYADD(antag_datums, instanced_datum)
	if(!.)
		current.verbs += /mob/proc/edit_objectives_and_ambitions
//ambition end

/datum/mind/proc/remove_antag_datum(datum_type)
	if(!datum_type)
		return
	var/datum/antagonist/A = has_antag_datum(datum_type)
	if(A)
		A.on_removal()
		return TRUE

//ambition start
/datum/mind/proc/do_remove_antag_datum(instanced_datum)
	. = LAZYLEN(antag_datums)
	LAZYREMOVE(antag_datums, instanced_datum)
	if(. && !LAZYLEN(antag_datums))
		ambitions = null
		current.verbs -= /mob/proc/edit_objectives_and_ambitions
//ambition end

/datum/mind/proc/remove_all_antag_datums() //For the Lazy amongst us.
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		A.on_removal()

/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	if(!datum_type)
		return
	. = FALSE
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		if(check_subtypes && istype(A, datum_type))
			return A
		else if(A.type == datum_type)
			return A

/*
	Removes antag type's references from a mind.
	objectives, uplinks, powers etc are all handled.
*/

/datum/mind/proc/remove_changeling()
	var/datum/antagonist/changeling/C = has_antag_datum(/datum/antagonist/changeling)
	if(C)
		remove_antag_datum(/datum/antagonist/changeling)
		special_role = null

/datum/mind/proc/remove_traitor()
	remove_antag_datum(/datum/antagonist/traitor)

/datum/mind/proc/remove_brother()
	if(src in SSticker.mode.brothers)
		remove_antag_datum(/datum/antagonist/brother)
	SSticker.mode.update_brother_icons_removed(src)

/datum/mind/proc/remove_nukeop()
	var/datum/antagonist/nukeop/nuke = has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(nuke)
		remove_antag_datum(nuke.type)
		special_role = null

/datum/mind/proc/remove_wizard()
	remove_antag_datum(/datum/antagonist/wizard)
	special_role = null

/datum/mind/proc/remove_cultist()
	if(src in SSticker.mode.cult)
		SSticker.mode.remove_cultist(src, 0, 0)
	special_role = null
	remove_antag_equip()

/datum/mind/proc/remove_rev()
	var/datum/antagonist/rev/rev = has_antag_datum(/datum/antagonist/rev)
	if(rev)
		remove_antag_datum(rev.type)
		special_role = null


/datum/mind/proc/remove_antag_equip()
	var/list/Mob_Contents = current.get_contents()
	for(var/obj/item/I in Mob_Contents)
		var/datum/component/uplink/O = I.GetComponent(/datum/component/uplink)
//Todo make this reset signal
		if(O)
			O.unlock_code = null

/datum/mind/proc/remove_all_antag() //For the Lazy amongst us.
	remove_changeling()
	remove_traitor()
	remove_nukeop()
	remove_wizard()
	remove_cultist()
	remove_rev()
	SSticker.mode.update_cult_icons_removed(src)

/datum/mind/proc/equip_traitor(datum/traitor_class/traitor_class, silent = FALSE, datum/antagonist/uplink_owner)
	if(!current)
		return
	if(!traitor_class)
		traitor_class = GLOB.traitor_classes[TRAITOR_HUMAN]
	var/mob/living/carbon/human/traitor_mob = current
	if (!istype(traitor_mob))
		return

	var/list/all_contents = traitor_mob.GetAllContents()
	var/obj/item/pda/PDA = locate() in all_contents
	var/obj/item/radio/R = locate() in all_contents
	var/obj/item/pen/P

	if (PDA) // Prioritize PDA pen, otherwise the pocket protector pens will be chosen, which causes numerous ahelps about missing uplink
		P = locate() in PDA
	if (!P) // If we couldn't find a pen in the PDA, or we didn't even have a PDA, do it the old way
		P = locate() in all_contents
		if(!P) // I do not have a pen.
			var/obj/item/pen/inowhaveapen
			if(istype(traitor_mob.back,/obj/item/storage)) //ok buddy you better have a backpack!
				inowhaveapen = new /obj/item/pen(traitor_mob.back)
			else
				inowhaveapen = new /obj/item/pen(traitor_mob.loc)
				traitor_mob.put_in_hands(inowhaveapen) // I hope you don't have arms and your traitor pen gets stolen for all this trouble you've caused.
			P = inowhaveapen

	var/obj/item/uplink_loc

	if(traitor_mob.client && traitor_mob.client.prefs)
		switch(traitor_mob.client.prefs.uplink_spawn_loc)
			if(UPLINK_PDA)
				uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = R
				if(!uplink_loc)
					uplink_loc = P
			if(UPLINK_RADIO)
				uplink_loc = R
				if(!uplink_loc)
					uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = P
			if(UPLINK_PEN)
				uplink_loc = P
				if(!uplink_loc)
					uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = R

	if (!uplink_loc)
		if(!silent)
			to_chat(traitor_mob, "Unfortunately, [traitor_class.employer] wasn't able to get you an Uplink.")
		. = 0
	else
		. = uplink_loc
		var/datum/component/uplink/U = uplink_loc.AddComponent(/datum/component/uplink, traitor_mob.key,traitor_class)
		if(!U)
			CRASH("Uplink creation failed.")
		U.setup_unlock_code()
		if(!silent)
			if(uplink_loc == R)
				to_chat(traitor_mob, "[traitor_class.employer] has cunningly disguised a Syndicate Uplink as your [R.name]. Simply dial the frequency [format_frequency(U.unlock_code)] to unlock its hidden features.")
			else if(uplink_loc == PDA)
				to_chat(traitor_mob, "[traitor_class.employer] has cunningly disguised a Syndicate Uplink as your [PDA.name]. Simply enter the code \"[U.unlock_code]\" into the ringtone select to unlock its hidden features.")
			else if(uplink_loc == P)
				to_chat(traitor_mob, "[traitor_class.employer] has cunningly disguised a Syndicate Uplink as your [P.name]. Simply twist the top of the pen [U.unlock_code] from its starting position to unlock its hidden features.")

		if(uplink_owner)
			uplink_owner.antag_memory += U.unlock_note + "<br>"
		else
			traitor_mob.mind.store_memory(U.unlock_note)

//Link a new mobs mind to the creator of said mob. They will join any team they are currently on, and will only switch teams when their creator does.

/datum/mind/proc/enslave_mind_to_creator(mob/living/creator)
	if(iscultist(creator))
		if(iscultist(creator, TRUE))
			SSticker.mode.add_cultist(src)
		else
			src.add_antag_datum(/datum/antagonist/cult/neutered/traitor)

	else if(is_revolutionary(creator))
		var/datum/antagonist/rev/converter = creator.mind.has_antag_datum(/datum/antagonist/rev,TRUE)
		converter.add_revolutionary(src,FALSE)

	else if(is_servant_of_ratvar(creator))
		if(is_servant_of_ratvar(creator, TRUE))
			add_servant_of_ratvar(current)
		else
			add_servant_of_ratvar(current, FALSE, FALSE, /datum/antagonist/clockcult/neutered/traitor)

	else if(is_nuclear_operative(creator))
		var/datum/antagonist/nukeop/converter = creator.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE)
		var/datum/antagonist/nukeop/N = new()
		N.send_to_spawnpoint = FALSE
		N.nukeop_outfit = null
		add_antag_datum(N,converter.nuke_team)


	enslaved_to = creator

	current.faction |= creator.faction
	creator.faction |= current.faction

	if(creator.mind.special_role)
		message_admins("[ADMIN_LOOKUPFLW(current)] has been created by [ADMIN_LOOKUPFLW(creator)], an antagonist.")
		to_chat(current, "<span class='userdanger'>Despite your creators current allegiances, your true master remains [creator.real_name]. If their loyalties change, so do yours. This will never change unless your creator's body is destroyed.</span>")

//ambition start
/datum/mind/proc/show_memory()
	var/list/output = list("<B>[current.real_name]'s Memories:</B><br>")
//ambition end
	output += memory


	var/list/all_objectives = list()
	for(var/datum/antagonist/A in antag_datums)
		output += A.antag_memory
		all_objectives |= A.objectives

	if(all_objectives.len)
		output += "<B>Objectives:</B>"
		var/obj_count = 1
		for(var/datum/objective/objective in all_objectives)
			output += "<br><B>Objective #[obj_count++]</B>: [objective.explanation_text]"
			var/list/datum/mind/other_owners = objective.get_owners() - src
			if(other_owners.len)
				output += "<ul>"
				for(var/datum/mind/M in other_owners)
					output += "<li>Conspirator: [M.name]</li>"
				output += "</ul>"

//ambition port start
	if(LAZYLEN(ambitions))
		for(var/count in 1 to LAZYLEN(ambitions))
			output += "<br><B>Ambition #[count]</B>: [ambitions[count]]"

	if(!memory && !length(all_objectives) && !LAZYLEN(ambitions))
		output += "<ul><li><I><B>NONE</B></I></ul>"

	return output.Join()


/datum/mind/proc/show_editable_objectives_and_ambitions()
	var/is_admin = check_rights(R_ADMIN, FALSE)
	var/self_mind = usr == current
	if(!is_admin && !self_mind)
		return ""
	var/list/output = list()
	for(var/a in antag_datums)
		var/datum/antagonist/antag_datum = a
		output += "<i><b>Objectives</b></i>:"
		if(is_admin)
			output += " <a href='?src=[REF(antag_datum.owner)];obj_add=[REF(antag_datum)];ambition_panel=1'>Add Objective</a>"
		output += "<ul>"
		if(!length(antag_datum.objectives))
			output += "<li><i><b>NONE</b></i>"
		else
			for(var/count in 1 to length(antag_datum.objectives))
				var/datum/objective/objective = antag_datum.objectives[count]
				output += "<li><B>[count]</B>: [objective.explanation_text]"
				if(self_mind)
					output += " <a href='?src=[REF(antag_datum.owner)];req_obj_delete=[REF(objective)];target_antag=[REF(antag_datum)]'>Request Remove</a> <a href='?src=[REF(antag_datum.owner)];req_obj_completed=[REF(objective)];target_antag=[REF(antag_datum)]'><font color=[objective.completed ? "green" : "red"]>[objective.completed ? "Request incompletion" : "Request completion"]</font></a><br>"
				if(is_admin)
					output += " <a href='?src=[REF(antag_datum.owner)];obj_edit=[REF(objective)];target_antag=[REF(antag_datum)]'>Edit</a> <a href='?src=[REF(antag_datum.owner)];obj_panel_delete=[REF(objective)];target_antag=[REF(antag_datum)]'>Remove</a> <a href='?src=[REF(antag_datum.owner)];obj_panel_complete_toggle=[REF(objective)];target_antag=[REF(antag_datum)]'><font color=[objective.completed ? "green" : "red"]>[objective.completed ? "Mark as incomplete" : "Mark as complete"]</font></a><br>"
		output += "</ul>"
		if(is_admin)
			output += "<a href='?src=[REF(antag_datum.owner)];obj_announce=1;ambition_panel=1'>Announce objectives</a><br>"
		output += "<br><i><b>Requested Objective Changes</b></i>:"
		if(self_mind)
			output += " <a href='?src=[REF(antag_datum.owner)];req_obj_add=1;target_antag=[REF(antag_datum)]'>Request objective</a>"
		output += "<ul>"
		if(!LAZYLEN(antag_datum.requested_objective_changes))
			output += "<li><i><b>NONE</b></i></ul><br>"
		else
			for(var/uid in antag_datum.requested_objective_changes)
				var/list/objectives_info = antag_datum.requested_objective_changes[uid]
				var/obj_request = objectives_info["request"]
				switch(obj_request)
					if(REQUEST_NEW_OBJECTIVE)
						var/datum/objective/type_cast_objective = objectives_info["target"]
						var/objective_text = objectives_info["text"]
						output += "<li><B>Request #[uid]</B>: ADD [initial(type_cast_objective.name)] - [objective_text]"
						if(self_mind)
							output += " <a href='?src=[REF(antag_datum.owner)];req_obj_cancel=[uid];target_antag=[REF(antag_datum)]'>Cancel Request</a>"
						if(is_admin)
							output += " <a href='?src=[REF(antag_datum.owner)];req_obj_accept=[REF(antag_datum)];req_obj_id=[uid]'>Accept</a> <a href='?src=[REF(antag_datum.owner)];req_obj_edit=[REF(antag_datum)];req_obj_id=[uid]'>Edit</a> <a href='?src=[REF(antag_datum.owner)];req_obj_deny=[REF(antag_datum)];req_obj_id=[uid]'>Deny</a>"
					if(REQUEST_DEL_OBJECTIVE)
						var/datum/objective/objective_ref = locate(objectives_info["target"]) in antag_datum.objectives
						if(QDELETED(objective_ref))
							stack_trace("Objective request found with deleted reference. UID: [uid] | Antag: [antag_datum] | Mind: [src] | User: [usr]")
							antag_datum.remove_objective_change(uid)
							continue
						output += "<li><B>Request #[uid]</B>: DEL [objective_ref.name] - [objective_ref.explanation_text] - [objectives_info["text"]]"
						if(self_mind)
							output += " <a href='?src=[REF(antag_datum.owner)];req_obj_cancel=[uid];target_antag=[REF(antag_datum)]'>Cancel Request</a>"
						if(is_admin)
							output += " <a href='?src=[REF(antag_datum.owner)];req_obj_accept=[REF(antag_datum)];req_obj_id=[uid]'>Accept</a> <a href='?src=[REF(antag_datum.owner)];req_obj_deny=[REF(antag_datum)];req_obj_id=[uid]'>Deny</a>"
					if(REQUEST_WIN_OBJECTIVE, REQUEST_LOSE_OBJECTIVE)
						var/datum/objective/objective_ref = locate(objectives_info["target"]) in antag_datum.objectives
						if(QDELETED(objective_ref))
							stack_trace("Objective request found with deleted reference. UID: [uid] | Antag: [antag_datum] | Mind: [src] | User: [usr]")
							antag_datum.remove_objective_change(uid)
							continue
						output += "<li><B>Request #[uid]</B>: [obj_request == REQUEST_WIN_OBJECTIVE ? "WIN" : "LOSE"] [objective_ref.name] - [objective_ref.explanation_text] - [objectives_info["text"]]"
						if(self_mind)
							output += " <a href='?src=[REF(antag_datum.owner)];req_obj_cancel=[uid];target_antag=[REF(antag_datum)]'>Cancel Request</a>"
						if(is_admin)
							output += " <a href='?src=[REF(antag_datum.owner)];req_obj_accept=[REF(antag_datum)];req_obj_id=[uid]'>Accept</a> <a href='?src=[REF(antag_datum.owner)];req_obj_deny=[REF(antag_datum)];req_obj_id=[uid]'>Deny</a>"
					else
						stack_trace("Objective request found with no request index. UID: [uid] | Antag: [antag_datum] | Mind: [src] | User: [usr]")
						continue
			output += "</ul><br>"
			if(self_mind)
				output += "<a href='?src=[REF(src)];req_obj_ping=1'>Ping the admins</a><br>"
			if(is_admin)
				output += "<a href='?src=[REF(src)];req_obj_ping_cd_clear=1'>Clear ping cooldown</a><br>"
	output += "<br><b>[current.real_name]'s Ambitions:</b>"
	if(LAZYLEN(ambitions) < CONFIG_GET(number/max_ambitions))
		output += " <a href='?src=[REF(src)];add_ambition=1'>Add Ambition</a>"
	output += "<ul>"
	if(!LAZYLEN(ambitions))
		output += "<li><i><b>NONE</b></i>"
	else
		for(var/count in 1 to LAZYLEN(ambitions))
			output += "<li><B>Ambition #[count]</B> (<a href='?src=[REF(src)];edit_ambition=[count]'>Edit</a>) (<a href='?src=[REF(src)];remove_ambition=[count]'>Remove</a>):<br>[ambitions[count]]"
	output += "</ul><br>(<a href='?src=[REF(src)];refresh_obj_amb=1'>Refresh</a>)"
	return output.Join()


/mob/proc/edit_objectives_and_ambitions()
	set name = "Objectives and Ambitions"
	set category = "IC"
	set desc = "View and edit your character's objectives and ambitions."
	mind.do_edit_objectives_ambitions()


/datum/mind/proc/do_edit_objectives_ambitions()
	var/datum/browser/popup = new(usr, "objectives and ambitions", "Objectives and Ambitions")
	popup.set_content(show_editable_objectives_and_ambitions())
	popup.open()


GLOBAL_VAR_INIT(requested_objective_uid, 0)


GLOBAL_LIST(objective_player_choices)

/proc/populate_objective_player_choices()
	GLOB.objective_player_choices = list()
	var/list/allowed_types = list(
		/datum/objective/custom,
		/datum/objective/assassinate/once,
		/datum/objective/protect,
		/datum/objective/escape,
		/datum/objective/survive,
		/datum/objective/martyr,
		/datum/objective/steal,
		/datum/objective/download,
		)

	for(var/t in allowed_types)
		var/datum/objective/type_cast = t
		GLOB.objective_player_choices[initial(type_cast.name)] = t


GLOBAL_LIST(objective_choices)

/proc/populate_objective_choices()
	GLOB.objective_choices = list()
	var/list/allowed_types = list(
		/datum/objective/custom,
		/datum/objective/assassinate,
		/datum/objective/assassinate/once,
		/datum/objective/maroon,
		/datum/objective/debrain,
		/datum/objective/protect,
		/datum/objective/destroy,
		/datum/objective/hijack,
		/datum/objective/escape,
		/datum/objective/survive,
		/datum/objective/martyr,
		/datum/objective/steal,
		/datum/objective/download,
		/datum/objective/nuclear,
		/datum/objective/absorb,
		)

	for(var/t in allowed_types)
		var/datum/objective/type_cast = t
		GLOB.objective_choices[initial(type_cast.name)] = t


/datum/mind/proc/on_objectives_request_cd_end(datum/source)
	UnregisterSignal(src, list(COMSIG_CD_STOP(COOLDOWN_OBJ_ADMIN_PING), COMSIG_CD_RESET(COOLDOWN_OBJ_ADMIN_PING)))
	if(!antag_datums)
		return
	to_chat(current, "<span class='boldnotice'>You are now again able to ping the admins objective changes review requests.</span>")
	for(var/a in antag_datums)
		var/datum/antagonist/antag_datum = a
		if(!antag_datum.requested_objective_changes)
			continue
		to_chat(current, "<span class='boldnotice'>You seem to have unanswered change requests. If there are online admins another gentle reminder might be in order.</span>")
		break
//ambition port end

/datum/mind/Topic(href, href_list)
//ambition start

	if (href_list["refresh_obj_amb"])
		do_edit_objectives_ambitions()
		return

	else if (href_list["add_ambition"])
		if(!check_rights(R_ADMIN, FALSE))
			if(usr != current)
				return
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_AMBITION))
				to_chat(usr, "<span class='warning'>You must wait [AMBITION_COOLDOWN_TIME * 0.1] seconds between changes.</span>")
				return
		if(!isliving(current))
			return
		if(!antag_datums)
			return
		var/max_ambitions = CONFIG_GET(number/max_ambitions)
		if(LAZYLEN(ambitions) >= max_ambitions)
			to_chat(usr, "<span class='warning'>There's a limit of [max_ambitions] ambitions. Edit or remove some to accomodate for your new additions.</span>")
			do_edit_objectives_ambitions()
			return
		var/new_ambition = stripped_multiline_input(usr, "Write new ambition", "Ambition", "", MAX_AMBITION_LEN)
		if(isnull(new_ambition))
			return
		if(!check_rights(R_ADMIN, FALSE))
			if(usr != current)
				return
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_AMBITION))
				to_chat(usr, "<span class='warning'>You must wait [AMBITION_COOLDOWN_TIME * 0.1] seconds between changes.</span>")
				return
		if(!isliving(current))
			to_chat(usr, "<span class='warning'>The mind holder is no longer a living creature.</span>")
			return
		if(!antag_datums)
			to_chat(usr, "<span class='warning'>The mind holder is no longer an antagonist.</span>")
			return
		if(LAZYLEN(ambitions) >= max_ambitions)
			to_chat(usr, "<span class='warning'>There's a limit of [max_ambitions] ambitions. Edit or remove some to accomodate for your new additions.</span>")
			do_edit_objectives_ambitions()
			return
		TIMER_COOLDOWN_START(src, COOLDOWN_AMBITION, AMBITION_COOLDOWN_TIME)
		LAZYADD(ambitions, new_ambition)
		if(usr == current)
			log_game("[key_name(usr)] has created their ambition of index [LAZYLEN(ambitions)].\nNEW AMBITION:\n[new_ambition]")
		else
			log_game("[key_name(usr)] has created [key_name(current)]'s ambition of index [LAZYLEN(ambitions)].\nNEW AMBITION:\n[new_ambition]")
			message_admins("[ADMIN_TPMONTY(usr)] has created [ADMIN_TPMONTY(current)]'s ambition of index [LAZYLEN(ambitions)].")
		do_edit_objectives_ambitions()
		return

	else if (href_list["edit_ambition"])
		if(!check_rights(R_ADMIN, FALSE))
			if(usr != current)
				return
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_AMBITION))
				to_chat(usr, "<span class='warning'>You must wait [AMBITION_COOLDOWN_TIME * 0.1] seconds between changes.</span>")
				return
		if(!isliving(current))
			return
		if(!antag_datums)
			return
		var/ambition_index = text2num(href_list["edit_ambition"])
		if(!isnum(ambition_index) || ambition_index < 0 || ambition_index % 1)
			log_admin_private("[key_name(usr)] attempted to edit their ambitions with and invalid ambition_index ([ambition_index]) at [AREACOORD(usr.loc)].")
			message_admins("[ADMIN_TPMONTY(usr)] attempted to edit their ambitions with and invalid ambition_index ([ambition_index]). Possible HREF exploit.")
			return
		if(ambition_index > LAZYLEN(ambitions))
			return
		var/old_ambition = ambitions[ambition_index]
		var/new_ambition = stripped_multiline_input(usr, "Write new ambition", "Ambition", ambitions[ambition_index], MAX_AMBITION_LEN)
		if(isnull(new_ambition))
			return
		if(!check_rights(R_ADMIN, FALSE))
			if(usr != current)
				return
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_AMBITION))
				to_chat(usr, "<span class='warning'>You must wait [AMBITION_COOLDOWN_TIME * 0.1] seconds between changes.</span>")
				return
		if(!isliving(current))
			to_chat(usr, "<span class='warning'>The mind holder is no longer a living creature.</span>")
			return
		if(!antag_datums)
			to_chat(usr, "<span class='warning'>The mind holder is no longer an antagonist.</span>")
			return
		if(ambition_index > LAZYLEN(ambitions))
			to_chat(usr, "<span class='warning'>The ambition we were editing was deleted before we finished. Aborting.</span>")
			do_edit_objectives_ambitions()
			return
		if(old_ambition != ambitions[ambition_index])
			to_chat(usr, "<span class='warning'>The ambition has changed since we started editing it. Aborting to prevent data loss.</span>")
			do_edit_objectives_ambitions()
			return
		TIMER_COOLDOWN_START(src, COOLDOWN_AMBITION, AMBITION_COOLDOWN_TIME)
		ambitions[ambition_index] = new_ambition
		if(usr == current)
			log_game("[key_name(usr)] has edited their ambition of index [ambition_index].\nOLD AMBITION:\n[old_ambition]\nNEW AMBITION:\n[new_ambition]")
		else
			log_game("[key_name(usr)] has edited [key_name(current)]'s ambition of index [ambition_index].\nOLD AMBITION:\n[old_ambition]\nNEW AMBITION:\n[new_ambition]")
			message_admins("[ADMIN_TPMONTY(usr)] has edited [ADMIN_TPMONTY(current)]'s ambition of index [ambition_index].")
		do_edit_objectives_ambitions()
		return

	else if (href_list["remove_ambition"])
		if(!check_rights(R_ADMIN, FALSE))
			if(usr != current)
				return
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_AMBITION))
				to_chat(usr, "<span class='warning'>You must wait [AMBITION_COOLDOWN_TIME * 0.1] seconds between changes.</span>")
				return
		if(!isliving(current))
			return
		if(!antag_datums)
			return
		var/ambition_index = text2num(href_list["remove_ambition"])
		if(ambition_index > LAZYLEN(ambitions))
			do_edit_objectives_ambitions()
			return
		if(!isnum(ambition_index) || ambition_index < 0 || ambition_index % 1)
			log_admin_private("[key_name(usr)] attempted to remove an ambition with and invalid ambition_index ([ambition_index]) at [AREACOORD(usr.loc)].")
			message_admins("[ADMIN_TPMONTY(usr)] attempted to remove an ambition with and invalid ambition_index ([ambition_index]). Possible HREF exploit.")
			return
		var/old_ambition = ambitions[ambition_index]
		if(alert(usr, "Are you sure you want to delete this ambition?", "Delete ambition", "Yes", "No") != "Yes")
			return
		if(!check_rights(R_ADMIN, FALSE))
			if(usr != current)
				return
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_AMBITION))
				to_chat(usr, "<span class='warning'>You must wait [AMBITION_COOLDOWN_TIME * 0.1] seconds between changes.</span>")
				return
		if(!isliving(current))
			to_chat(usr, "<span class='warning'>The mind holder is no longer a living creature. The ambition we were deleting should no longer exist already.</span>")
			return
		if(!antag_datums)
			to_chat(usr, "<span class='warning'>The mind holder is no longer an antagonist. The ambition we were deleting should no longer exist already.</span>")
			return
		if(ambition_index > LAZYLEN(ambitions))
			to_chat(usr, "<span class='warning'>The ambition we were deleting was deleted before we finished. No need to continue.</span>")
			do_edit_objectives_ambitions()
			return
		if(old_ambition != ambitions[ambition_index])
			to_chat(usr, "<span class='warning'>The ambition has changed since we started considering its deletion. Aborting to prevent conflicts.</span>")
			do_edit_objectives_ambitions()
			return
		TIMER_COOLDOWN_START(src, COOLDOWN_AMBITION, AMBITION_COOLDOWN_TIME)
		LAZYCUT(ambitions, ambition_index, ambition_index + 1)
		if(usr == current)
			log_game("[key_name(usr)] has deleted their ambition of index [ambition_index].\nDELETED AMBITION:\n[old_ambition]")
		else
			log_game("[key_name(usr)] has deleted [key_name(current)]'s ambition of index [ambition_index].\nDELETED AMBITION:\n[old_ambition]")
			message_admins("[ADMIN_TPMONTY(usr)] has deleted [ADMIN_TPMONTY(current)]'s ambition of index [ambition_index].")
		do_edit_objectives_ambitions()
		return

	else if (href_list["req_obj_ping"])
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJ_ADMIN_PING))
			to_chat(usr, "<span class='warning'>You must wait [S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_OBJ_ADMIN_PING) * 0.1] seconds before your next admin ping.</span>")
			do_edit_objectives_ambitions()
			return
		if(!antag_datums)
			return
		var/pending_request = FALSE
		for(var/a in antag_datums)
			var/datum/antagonist/antag_datum = a
			if(antag_datum.requested_objective_changes)
				pending_request = TRUE
				break
		if(!pending_request)
			to_chat(usr, "<span class='warning'>You have no pending requests to warn the admins about. Request changes for them to review before poking them.</span>")
			do_edit_objectives_ambitions()
			return
		var/justification = stripped_multiline_input(usr,
			"Send a message to the admins requesting a review of your objective change requests.\
			There's a [ADMIN_PING_COOLDOWN_TIME * 0.1] seconds cooldown between requests, so try to think it through before sending it. Cancelling this does not trigger the cooldown.",
			"Request Admin Review", max_length = MAX_MESSAGE_LEN)
		if(isnull(justification))
			return
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJ_ADMIN_PING))
			to_chat(usr, "<span class='warning'>You must wait [S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_OBJ_ADMIN_PING) * 0.1] seconds before your next admin ping.</span>")
			do_edit_objectives_ambitions()
			return
		if(!antag_datums)
			return
		pending_request = FALSE
		for(var/a in antag_datums)
			var/datum/antagonist/antag_datum = a
			if(antag_datum.requested_objective_changes)
				pending_request = TRUE
				break
		if(!pending_request)
			return
		if(!length(GLOB.admins))
			to_chat(usr, "<span class='warning'>No admins currently connected, failed to notify them. Wait for one to connect before trying to ping them again.</span>")
			do_edit_objectives_ambitions()
			return
		S_TIMER_COOLDOWN_START(src, COOLDOWN_OBJ_ADMIN_PING, ADMIN_PING_COOLDOWN_TIME)
		RegisterSignal(src, list(COMSIG_CD_STOP(COOLDOWN_OBJ_ADMIN_PING), COMSIG_CD_RESET(COOLDOWN_OBJ_ADMIN_PING)), .proc/on_objectives_request_cd_end)
		log_admin("Objectives review request - [key_name(usr)] has requested a review of their objective changes, pinging the admins.")
		for(var/a in GLOB.admins)
			var/client/admin_client = a
			if(admin_client.prefs.toggles & SOUND_ADMINHELP)
				SEND_SOUND(admin_client, sound('sound/effects/adminhelp.ogg'))
			window_flash(admin_client)
		message_admins("<span class='adminhelp'>[ADMIN_TPMONTY(usr)] has requested a review of their objective changes. (<a href='?_src_=holder;[HrefToken(TRUE)];ObjectiveRequest=[REF(src)]'>RPLY</a>)</span>")
		do_edit_objectives_ambitions()
		return

	else if (href_list["req_obj_add"])
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
			to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
			do_edit_objectives_ambitions()
			return
		var/datum/antagonist/target_antag = locate(href_list["target_antag"]) in antag_datums
		if(QDELETED(target_antag))
			to_chat(usr, "<span class='warning'>No antagonist found for this objective.</span>")
			do_edit_objectives_ambitions()
			return
		if(!GLOB.objective_player_choices)
			populate_objective_player_choices()
		var/choice = input("Select desired objective type:", "Objective type") as null|anything in GLOB.objective_player_choices
		var/selected_type = GLOB.objective_player_choices[choice]
		if(!selected_type)
			return
		var/new_objective = stripped_multiline_input(usr,\
			selected_type == /datum/objective/custom\
			? "Write the custom objective you'd like to request the admins to grant you. Remember they can edit or deny your request at their own discretion."\
			: "Justify your request for a new objective to the admins. Add the required clarifations, if you have a specific targets in mind and the likes.",\
			"New Objective", max_length = MAX_MESSAGE_LEN)
		if(isnull(new_objective))
			return
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
			to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME] minutes between request changes.</span>")
			return
		if(QDELETED(target_antag))
			return
		TIMER_COOLDOWN_START(src, COOLDOWN_OBJECTIVES, OBJECTIVES_COOLDOWN_TIME)
		var/uid = "[GLOB.requested_objective_uid++]"
		target_antag.add_objective_change(uid, list("request" = REQUEST_NEW_OBJECTIVE, "target" = selected_type, "text" = new_objective))
		log_admin("Objectives request [uid] - [key_name(usr)] has requested a [choice] objective: [new_objective]")
		do_edit_objectives_ambitions()
		return

	else if (href_list["req_obj_cancel"])
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
			to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
			return
		var/datum/antagonist/target_antag = locate(href_list["target_antag"]) in antag_datums
		if(QDELETED(target_antag))
			to_chat(usr, "<span class='warning'>No antagonist found for this objective.</span>")
			do_edit_objectives_ambitions()
			return
		var/uid = href_list["req_obj_cancel"]
		if(!LAZYACCESS(target_antag.requested_objective_changes, uid))
			to_chat(usr, "<span class='warning'>No requested objective change found. Perhaps it was deleted already?</span>")
			do_edit_objectives_ambitions()
			return
		if(alert(usr, "Are you sure you want to delete this change request?", "Delete change request", "Yes", "No") != "Yes")
			return
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
			to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
			return
		if(QDELETED(target_antag))
			do_edit_objectives_ambitions()
			return
		if(!LAZYACCESS(target_antag.requested_objective_changes, uid))
			do_edit_objectives_ambitions()
			return
		TIMER_COOLDOWN_START(src, COOLDOWN_OBJECTIVES, OBJECTIVES_COOLDOWN_TIME)
		log_admin("Objectives request deletion - [key_name(usr)] has deleted the objective change request of UID [uid].")
		target_antag.remove_objective_change(uid)
		do_edit_objectives_ambitions()
		return

	else if (href_list["req_obj_delete"])
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
			to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
			return
		var/datum/antagonist/target_antag = locate(href_list["target_antag"]) in antag_datums
		if(QDELETED(target_antag))
			to_chat(usr, "<span class='warning'>No antagonist found for this objective.</span>")
			do_edit_objectives_ambitions()
			return
		var/objective_reference = href_list["req_obj_delete"]
		var/datum/objective/objective_to_delete = locate(objective_reference) in target_antag.objectives
		if(!istype(objective_to_delete) || QDELETED(objective_to_delete))
			to_chat(usr, "<span class='warning'>No objective found. Perhaps it was already deleted?</span>")
			do_edit_objectives_ambitions()
			return
		var/justification = stripped_multiline_input(usr,
			"Justify your request for a deleting this objective to the admins.",
			"Objective Deletion", max_length = MAX_MESSAGE_LEN)
		if(isnull(justification))
			return
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
			to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
			return
		if(QDELETED(objective_to_delete) || QDELETED(target_antag))
			do_edit_objectives_ambitions()
			return
		var/matching_request = FALSE
		for(var/index in target_antag.requested_objective_changes)
			var/list/change_request = target_antag.requested_objective_changes[index]
			if(change_request["target"] != objective_reference)
				continue
			matching_request = TRUE
			break
		if(matching_request)
			if(alert(usr, "There is already a change request tied to this objective waiting to be processed. Adding this request will delete the old ones.", "Delete matching objective requests?", "Yes", "No") != "Yes")
				do_edit_objectives_ambitions()
				return
			if(usr != current)
				return
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
				to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
				return
			if(QDELETED(objective_to_delete) || QDELETED(target_antag))
				do_edit_objectives_ambitions()
				return
			for(var/index in target_antag.requested_objective_changes)
				var/list/change_request = target_antag.requested_objective_changes[index]
				if(change_request["target"] != objective_reference)
					continue
				target_antag.remove_objective_change(index)
		TIMER_COOLDOWN_START(src, COOLDOWN_OBJECTIVES, OBJECTIVES_COOLDOWN_TIME)
		var/uid = "[GLOB.requested_objective_uid++]"
		target_antag.add_objective_change(uid, list("request" = REQUEST_DEL_OBJECTIVE, "target" = objective_reference, "text" = justification))
		log_admin("Objectives request [uid] - [key_name(usr)] has requested the deletion of the following objective: [objective_to_delete.explanation_text].\nTheir justification is as follows: [justification]")
		do_edit_objectives_ambitions()
		return

	else if (href_list["req_obj_completed"])
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
			to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
			return
		var/datum/antagonist/target_antag = locate(href_list["target_antag"]) in antag_datums
		if(QDELETED(target_antag))
			to_chat(usr, "<span class='warning'>No antagonist found for this objective.</span>")
			do_edit_objectives_ambitions()
			return
		var/objective_reference = href_list["req_obj_completed"]
		var/datum/objective/objective_to_complete = locate(objective_reference) in target_antag.objectives
		if(!istype(objective_to_complete) || QDELETED(objective_to_complete))
			to_chat(usr, "<span class='warning'>No objective found. Perhaps it was deleted?</span>")
			do_edit_objectives_ambitions()
			return
		var/justification = stripped_multiline_input(usr,
			"Justify to the admins your request to mark this objective as [objective_to_complete.completed ? "incomplete" : "completed"].",
			"Objective [objective_to_complete.completed ? "Incompletion" : "Completion"]", max_length = MAX_MESSAGE_LEN)
		if(isnull(justification))
			return
		if(usr != current)
			return
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
			to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
			return
		if(QDELETED(objective_to_complete) || QDELETED(target_antag))
			do_edit_objectives_ambitions()
			return
		var/matching_request = FALSE
		for(var/index in target_antag.requested_objective_changes)
			var/list/change_request = target_antag.requested_objective_changes[index]
			if(change_request["target"] != objective_reference)
				continue
			matching_request = TRUE
			break
		if(matching_request)
			if(alert(usr, "There is already a change request tied to this objective waiting to be processed. Adding this request will delete the old ones.", "Delete matching objective requests?", "Yes", "No") != "Yes")
				return
			if(usr != current)
				return
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJECTIVES))
				to_chat(usr, "<span class='warning'>You must wait [OBJECTIVES_COOLDOWN_TIME * 0.1] seconds between request changes.</span>")
				return
			if(QDELETED(objective_to_complete) || QDELETED(target_antag))
				do_edit_objectives_ambitions()
				return
			for(var/index in target_antag.requested_objective_changes)
				var/list/change_request = target_antag.requested_objective_changes[index]
				if(change_request["target"] != objective_reference)
					continue
				target_antag.remove_objective_change(index)
		TIMER_COOLDOWN_START(src, COOLDOWN_OBJECTIVES, OBJECTIVES_COOLDOWN_TIME)
		var/uid = "[GLOB.requested_objective_uid++]"
		target_antag.add_objective_change(uid, list("request" = (objective_to_complete.completed ? REQUEST_LOSE_OBJECTIVE : REQUEST_WIN_OBJECTIVE), "target" = objective_reference, "text" = justification))
		log_admin("Objectives request [uid] - [key_name(usr)] has requested the [objective_to_complete.completed ? "incompletion" : "completion"] of the following objective: [objective_to_complete.explanation_text].\nTheir justification is as follows: [justification]")
		do_edit_objectives_ambitions()
		return
	if(!check_rights(R_ADMIN))
		return

	var/self_antagging = usr == current
	if(href_list["edit_ambitions_panel"])
		do_edit_objectives_ambitions()
		return

	else if(href_list["req_obj_ping_cd_clear"])
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJ_ADMIN_PING))
			to_chat(usr, "<span class='warning'>Mind is not under a cooldown.</span>")
			do_edit_objectives_ambitions()
			return
		if(alert(usr, "Are you sure you want reset this cooldown, letting the user ping the admins again?", "Clear ping cooldown", "Yes", "No") != "Yes")
			do_edit_objectives_ambitions()
			return
		if(!check_rights(R_ADMIN))
			return
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_OBJ_ADMIN_PING))
			do_edit_objectives_ambitions()
			return
		S_TIMER_COOLDOWN_RESET(src, COOLDOWN_OBJ_ADMIN_PING)
		do_edit_objectives_ambitions()
		return

	else if(href_list["refresh_antag_panel"])
		traitor_panel()
		return

	else if (href_list["req_obj_edit"])
		var/datum/antagonist/antag_datum = locate(href_list["req_obj_edit"]) in antag_datums
		if(QDELETED(antag_datum))
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>No antag found.</span>")
			return
		if(antag_datum.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid antag reference.</span>")
			return
		var/uid = href_list["req_obj_id"]
		var/list/requested_obj_change = LAZYACCESS(antag_datum.requested_objective_changes, uid)
		if(!requested_obj_change)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid requested objective reference.</span>")
			return
		if(requested_obj_change["request"] != REQUEST_NEW_OBJECTIVE)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>This is not an editable request. How did you even got here?</span>")
			return
		switch(alert(usr, "Do you want to edit the requested objective type or text?", "Edit requested objective", "Type", "Text", "Cancel"))
			if("Type")
				if(!check_rights(R_ADMIN))
					return
				if(QDELETED(antag_datum))
					to_chat(usr, "<span class='warning'>No antag found.</span>")
					do_edit_objectives_ambitions()
					return
				if(!LAZYACCESS(antag_datum.requested_objective_changes, uid))
					to_chat(usr, "<span class='warning'>Invalid requested objective change reference.</span>")
					do_edit_objectives_ambitions()
					return
				var/datum/objective/type_cast = requested_obj_change["target"]
				var/selected_type = input("Select new requested objective type:", "Requested Objective type", initial(type_cast.name)) as null|anything in GLOB.objective_choices
				selected_type = GLOB.objective_choices[selected_type]
				if(!selected_type)
					return
				if(!check_rights(R_ADMIN))
					return
				if(QDELETED(antag_datum))
					to_chat(usr, "<span class='warning'>No antag found.</span>")
					do_edit_objectives_ambitions()
					return
				if(!LAZYACCESS(antag_datum.requested_objective_changes, uid))
					to_chat(usr, "<span class='warning'>Invalid requested objective change reference.</span>")
					do_edit_objectives_ambitions()
					return
				log_admin("[key_name(usr)] has edited the requested objective type for [current], of UID [uid], from [requested_obj_change["target"]] to [selected_type]")
				message_admins("[key_name_admin(usr)] has edited the requested objective type for [current], of UID [uid], from [requested_obj_change["target"]] to [selected_type]")
				requested_obj_change["target"] = selected_type
			if("Text")
				if(!check_rights(R_ADMIN))
					return
				if(QDELETED(antag_datum))
					to_chat(usr, "<span class='warning'>No antag found.</span>")
					do_edit_objectives_ambitions()
					return
				if(!LAZYACCESS(antag_datum.requested_objective_changes, uid))
					to_chat(usr, "<span class='warning'>Invalid requested objective change reference.</span>")
					do_edit_objectives_ambitions()
					return
				var/new_text = stripped_multiline_input(usr, "Input new requested objective text", "Requested Objective Text", requested_obj_change["text"], MAX_MESSAGE_LEN)
				if (isnull(new_text))
					return
				if(!check_rights(R_ADMIN))
					return
				if(QDELETED(antag_datum))
					to_chat(usr, "<span class='warning'>No antag found.</span>")
					do_edit_objectives_ambitions()
					return
				if(!LAZYACCESS(antag_datum.requested_objective_changes, uid))
					to_chat(usr, "<span class='warning'>Invalid requested objective change reference.</span>")
					do_edit_objectives_ambitions()
					return
				log_admin("[key_name(usr)] has edited the requested objective text for [current], of UID [uid], from [requested_obj_change["text"]] to [new_text]")
				message_admins("[key_name_admin(usr)] has edited the requested objective text for [current], of UID [uid], from [requested_obj_change["text"]] to [new_text]")
				requested_obj_change["text"] = new_text
		do_edit_objectives_ambitions()
		return

	else if (href_list["req_obj_accept"])
		var/datum/antagonist/antag_datum = locate(href_list["req_obj_accept"]) in antag_datums
		if(QDELETED(antag_datum))
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>No antag found.</span>")
			return
		if(antag_datum.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid antag reference.</span>")
			return
		var/uid = href_list["req_obj_id"]
		var/list/requested_obj_change = LAZYACCESS(antag_datum.requested_objective_changes, uid)
		if(!requested_obj_change)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid requested objective reference.</span>")
			return

		var/datum/objective/request_target
		var/request_type = requested_obj_change["request"]
		switch(request_type)
			if(REQUEST_NEW_OBJECTIVE)
				request_target = requested_obj_change["target"]
				if(!ispath(request_target, /datum/objective))
					to_chat(usr, "<span class='warning'>Invalid requested objective target path.</span>")
					return
			if(REQUEST_DEL_OBJECTIVE, REQUEST_WIN_OBJECTIVE, REQUEST_LOSE_OBJECTIVE)
				request_target = locate(requested_obj_change["target"]) in antag_datum.objectives
				if(QDELETED(request_target))
					to_chat(usr, "<span class='warning'>Invalid requested objective target reference.</span>")
					return
			else
				to_chat(usr, "<span class='warning'>Invalid request type.</span>")
				return
		if(alert(usr, "Are you sure you want to approve this objective change?", "Approve objective change", "Yes", "No") != "Yes")
			return
		if(!check_rights(R_ADMIN))
			return
		if(QDELETED(antag_datum))
			to_chat(usr, "<span class='warning'>No antag found.</span>")
			do_edit_objectives_ambitions()
			return
		if(!LAZYACCESS(antag_datum.requested_objective_changes, uid))
			to_chat(usr, "<span class='warning'>Invalid requested objective change reference.</span>")
			do_edit_objectives_ambitions()
			return
		switch(request_type) //Last checks
			if(REQUEST_NEW_OBJECTIVE)
				if(!ispath(request_target, /datum/objective))
					stack_trace("Invalid target on objective change request: [request_target]")
					do_edit_objectives_ambitions()
					return
			if(REQUEST_DEL_OBJECTIVE, REQUEST_WIN_OBJECTIVE, REQUEST_LOSE_OBJECTIVE)
				if(QDELETED(request_target))
					to_chat(usr, "<span class='warning'>Invalid requested objective target reference.</span>")
					return
			else
				to_chat(usr, "<span class='warning'>Invalid request type.</span>")
				return
		antag_datum.remove_objective_change(uid)
		switch(request_type) //All is clear, let get things done.
			if(REQUEST_NEW_OBJECTIVE)
				request_target = new request_target()
				request_target.owner = src
				if(istype(request_target, /datum/objective/custom))
					request_target.explanation_text = requested_obj_change["text"]
				else
					request_target.admin_edit(usr)
				antag_datum.objectives += request_target
				message_admins("[key_name_admin(usr)] approved a requested objective from [current]: [request_target.explanation_text]")
				log_admin("[key_name(usr)] approved a requested objective from [current]: [request_target.explanation_text]")
			if(REQUEST_DEL_OBJECTIVE)
				message_admins("[key_name_admin(usr)] approved the request to delete an objective from [current]: [request_target.explanation_text]")
				log_admin("[key_name(usr)] approved the request to delete an objective from [current]: [request_target.explanation_text]")
				qdel(request_target)
			if(REQUEST_WIN_OBJECTIVE)
				message_admins("[key_name_admin(usr)] approved the victory request for an objective from [current]: [request_target.explanation_text]")
				log_admin("[key_name(usr)] approved the victory request for an objective from [current]: [request_target.explanation_text]")
				request_target.completed = TRUE
			if(REQUEST_LOSE_OBJECTIVE)
				message_admins("[key_name_admin(usr)] approved the defeat request for an objective from [current]: [request_target.explanation_text]")
				log_admin("[key_name(usr)] approved the defeat request for an objective from [current]: [request_target.explanation_text]")
				request_target.completed = FALSE
		to_chat(current, "<span class='boldnotice'>Your objective change request has been approved.</span>")
		do_edit_objectives_ambitions()
		return

	else if (href_list["req_obj_deny"])
		var/datum/antagonist/antag_datum = locate(href_list["req_obj_deny"]) in antag_datums
		if(QDELETED(antag_datum))
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>No antag found.</span>")
			return
		if(antag_datum.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid antag reference.</span>")
			return
		var/uid = href_list["req_obj_id"]
		var/list/requested_obj_change = LAZYACCESS(antag_datum.requested_objective_changes, uid)
		if(!requested_obj_change)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid requested objective change reference.</span>")
			return
		var/justification = stripped_multiline_input(usr, "Justify why you are denying this objective request change.", "Deny", memory, MAX_MESSAGE_LEN)
		if(isnull(justification))
			return
		if(!check_rights(R_ADMIN))
			return
		if(QDELETED(antag_datum))
			to_chat(usr, "<span class='warning'>No antag found.</span>")
			do_edit_objectives_ambitions()
			return
		if(!LAZYACCESS(antag_datum.requested_objective_changes, uid))
			to_chat(usr, "<span class='warning'>Invalid requested objective change reference.</span>")
			do_edit_objectives_ambitions()
			return
		var/datum/objective/type_cast = requested_obj_change["target"]
		var/objective_name = initial(type_cast.name)
		message_admins("[key_name_admin(usr)] denied a requested [objective_name] objective from [current]: [requested_obj_change["text"]]")
		log_admin("[key_name(usr)] denied a requested [objective_name] objective from [current]: [requested_obj_change["text"]]")
		to_chat(current, "<span class='boldwarning'>Your objective request has been denied for the following reason: [justification]</span>")
		antag_datum.remove_objective_change(uid)
		do_edit_objectives_ambitions()
		return

	else if (href_list["obj_panel_complete_toggle"])
		var/datum/antagonist/antag_datum = locate(href_list["target_antag"]) in antag_datums
		if(QDELETED(antag_datum))
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>No antag found.</span>")
			return
		if(antag_datum.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid antag reference.</span>")
			return
		var/datum/objective/objective_to_toggle = locate(href_list["obj_panel_complete_toggle"]) in antag_datum.objectives
		if(QDELETED(objective_to_toggle))
			to_chat(usr, "<span class='warning'>No objective found. Perhaps it was already deleted?</span>")
			do_edit_objectives_ambitions()
			return
		if(objective_to_toggle.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid objective reference.</span>")
			return
		objective_to_toggle.completed = !objective_to_toggle.completed
		message_admins("[key_name_admin(usr)] toggled the win state for [current]'s objective: [objective_to_toggle.explanation_text]")
		log_admin("[key_name(usr)] toggled the win state for [current]'s objective: [objective_to_toggle.explanation_text]")
		if(alert(usr, "Would you like to alert the player of the change?", "Deny objective", "Yes", "No") == "Yes")
			to_chat(current, "[objective_to_toggle.completed ? "<span class='boldnotice'>" : "<span class='boldwarning'>"]Your objective status has changed!</span>")
		do_edit_objectives_ambitions()
		return

	else if (href_list["obj_panel_delete"])
		var/datum/antagonist/antag_datum = locate(href_list["target_antag"]) in antag_datums
		if(QDELETED(antag_datum))
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>No antag found.</span>")
			return
		if(antag_datum.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid antag reference.</span>")
			return
		var/datum/objective/objective_to_delete = locate(href_list["obj_panel_delete"]) in antag_datum.objectives
		if(QDELETED(objective_to_delete))
			to_chat(usr, "<span class='warning'>No objective found. Perhaps it was already deleted?</span>")
			do_edit_objectives_ambitions()
			return
		if(objective_to_delete.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid objective reference.</span>")
			return
		if(alert(usr, "Are you sure you want to delete this objective?", "Delete objective", "Yes", "No") != "Yes")
			return
		if(!check_rights(R_ADMIN))
			return
		if(QDELETED(objective_to_delete))
			return
		message_admins("[key_name_admin(usr)] removed an objective from [current]: [objective_to_delete.explanation_text]")
		log_admin("[key_name(usr)] removed an objective from [current]: [objective_to_delete.explanation_text]")
		qdel(objective_to_delete)
		do_edit_objectives_ambitions()
		return

	else if (href_list["obj_panel_edit"])
		var/datum/antagonist/antag_datum = locate(href_list["target_antag"]) in antag_datums
		if(QDELETED(antag_datum))
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>No antag found.</span>")
			return
		if(antag_datum.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid antag reference.</span>")
			return
		var/datum/objective/objective_to_edit = locate(href_list["obj_panel_edit"]) in antag_datum.objectives
		if(QDELETED(objective_to_edit))
			to_chat(usr, "<span class='warning'>No objective found. Perhaps it was already deleted?</span>")
			do_edit_objectives_ambitions()
			return
		if(objective_to_edit.owner != src)
			do_edit_objectives_ambitions()
			to_chat(usr, "<span class='warning'>Invalid objective reference.</span>")
			return
		var/explanation_before = objective_to_edit.explanation_text
		objective_to_edit.admin_edit(usr)
		if(QDELETED(objective_to_edit))
			return
		message_admins("[key_name_admin(usr)] edited an objective from [current]:\
		Before: [explanation_before]\
		After: [objective_to_edit.explanation_text]")
		log_admin("[key_name(usr)] edited an objective from [current]:\
		Before: [explanation_before]\
		After: [objective_to_edit.explanation_text]")
		do_edit_objectives_ambitions()
		return
//ambition end

	if(href_list["add_antag"])
		add_antag_wrapper(text2path(href_list["add_antag"]),usr)
	if(href_list["remove_antag"])
		var/datum/antagonist/A = locate(href_list["remove_antag"]) in antag_datums
		if(!istype(A))
			to_chat(usr,"<span class='warning'>Invalid antagonist ref to be removed.</span>")
			return
		A.admin_remove(usr)

	if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in get_all_jobs()
		if (!new_role)
			return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = stripped_multiline_input(usr, "Write new memory", "Memory", memory, MAX_MESSAGE_LEN)
		if (isnull(new_memo))
			return
		memory = new_memo

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/objective_pos //Edited objectives need to keep same order in antag objective list
		var/def_value
		var/datum/antagonist/target_antag
		var/datum/objective/old_objective //The old objective we're replacing/editing
		var/datum/objective/new_objective //New objective we're be adding

		if(href_list["obj_edit"])
			for(var/datum/antagonist/A in antag_datums)
				old_objective = locate(href_list["obj_edit"]) in A.objectives
				if(old_objective)
					target_antag = A
					objective_pos = A.objectives.Find(old_objective)
					break
			if(!old_objective)
				to_chat(usr,"Invalid objective.")
				return

		else
			if(href_list["target_antag"])
				var/datum/antagonist/X = locate(href_list["target_antag"]) in antag_datums
				if(X)
					target_antag = X
			if(!target_antag)
				switch(antag_datums.len)
					if(0)
						target_antag = add_antag_datum(/datum/antagonist/custom)
					if(1)
						target_antag = antag_datums[1]
					else
						var/datum/antagonist/target = input("Which antagonist gets the objective:", "Antagonist", "(new custom antag)") as null|anything in antag_datums + "(new custom antag)"
						if (QDELETED(target))
							return
						else if(target == "(new custom antag)")
							target_antag = add_antag_datum(/datum/antagonist/custom)
						else
							target_antag = target

//ambition start
		if(!GLOB.objective_choices)
			populate_objective_choices()

		if(old_objective && GLOB.objective_choices[old_objective.name])
			def_value = old_objective.name

		var/selected_type = input("Select objective type:", "Objective type", def_value) as null|anything in GLOB.objective_choices
		selected_type = GLOB.objective_choices[selected_type]
//ambition end
		if (!selected_type)
			return

		if(!old_objective)
			//Add new one
			new_objective = new selected_type
			new_objective.owner = src
			new_objective.admin_edit(usr)
			target_antag.objectives += new_objective

			message_admins("[key_name_admin(usr)] added a new objective for [current]: [new_objective.explanation_text]")
			log_admin("[key_name(usr)] added a new objective for [current]: [new_objective.explanation_text]")
		else
			if(old_objective.type == selected_type)
				//Edit the old
				old_objective.admin_edit(usr)
				new_objective = old_objective
			else
				//Replace the old
				new_objective = new selected_type
				new_objective.owner = src
				new_objective.admin_edit(usr)
				target_antag.objectives -= old_objective
				target_antag.objectives.Insert(objective_pos, new_objective)
			message_admins("[key_name_admin(usr)] edited [current]'s objective to [new_objective.explanation_text]")
			log_admin("[key_name(usr)] edited [current]'s objective to [new_objective.explanation_text]")

//ambition start
		if(href_list["ambition_panel"])
			do_edit_objectives_ambitions()
			return
//ambition end

	else if(href_list["traitor_class"])
		var/static/list/choices
		if(!choices)
			choices = list()
			for(var/C in GLOB.traitor_classes)
				var/datum/traitor_class/t = C
				choices[initial(t.employer)] = C
		var/datum/antagonist/traitor/T = locate(href_list["target_antag"]) in antag_datums
		if(T)
			var/selected_type = input("Select traitor class:", "Traitor class", T.traitor_kind.employer) as null|anything in choices
			selected_type = choices[selected_type]
			T.set_traitor_kind(selected_type)

	else if (href_list["obj_delete"])
		var/datum/objective/objective

		for(var/datum/antagonist/A in antag_datums)
			objective = locate(href_list["obj_delete"]) in A.objectives
			if(istype(objective))
				break
		if(!objective)
			to_chat(usr,"Invalid objective.")
			return
		qdel(objective) //TODO: Needs cleaning objective destroys (whatever that means)
		message_admins("[key_name_admin(usr)] removed an objective for [current]: [objective.explanation_text]")
		log_admin("[key_name(usr)] removed an objective for [current]: [objective.explanation_text]")

	else if(href_list["obj_completed"])
		var/datum/objective/objective
		for(var/datum/antagonist/A in antag_datums)
			objective = locate(href_list["obj_completed"]) in A.objectives
			if(istype(objective))
				objective = objective
				break
		if(!objective)
			to_chat(usr,"Invalid objective.")
			return
		objective.completed = !objective.completed
		log_admin("[key_name(usr)] toggled the win state for [current]'s objective: [objective.explanation_text]")

	else if (href_list["silicon"])
		switch(href_list["silicon"])
			if("unemag")
				var/mob/living/silicon/robot/R = current
				if (istype(R))
					R.SetEmagged(0)
					message_admins("[key_name_admin(usr)] has unemag'ed [R].")
					log_admin("[key_name(usr)] has unemag'ed [R].")

			if("unemagcyborgs")
				if(isAI(current))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.SetEmagged(0)
					message_admins("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")
					log_admin("[key_name(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.dropItemToGround(W, TRUE) //The 1 forces all items to drop, since this is an admin undress.
			if("takeuplink")
				take_uplink()
				memory = null//Remove any memory they may have had.
				log_admin("[key_name(usr)] removed [current]'s uplink.")
			if("crystals")
				if(check_rights(R_FUN, 0))
					var/datum/component/uplink/U = find_syndicate_uplink()
					if(U)
						var/crystals = input("Amount of telecrystals for [key]","Syndicate uplink", U.telecrystals) as null | num
						if(!isnull(crystals))
							U.telecrystals = crystals
							message_admins("[key_name_admin(usr)] changed [current]'s telecrystal count to [crystals].")
							log_admin("[key_name(usr)] changed [current]'s telecrystal count to [crystals].")
			if("uplink")
				if(!equip_traitor())
					to_chat(usr, "<span class='danger'>Equipping a syndicate failed!</span>")
					log_admin("[key_name(usr)] tried and failed to give [current] an uplink.")
				else
					log_admin("[key_name(usr)] gave [current] an uplink.")

	else if (href_list["obj_announce"])
		announce_objectives()
//ambition start
		if(href_list["ambition_panel"])
			do_edit_objectives_ambitions()
			return
//ambition end

	//Something in here might have changed your mob
	if(self_antagging && (!usr || !usr.client) && current.client)
		usr = current
	traitor_panel()

/datum/mind/proc/get_all_objectives()
	var/list/all_objectives = list()
	for(var/datum/antagonist/A in antag_datums)
		all_objectives |= A.objectives
	return all_objectives

/datum/mind/proc/announce_objectives()
	var/obj_count = 1
	to_chat(current, "<span class='notice'>Your current objectives:</span>")
	for(var/objective in get_all_objectives())
		var/datum/objective/O = objective
		to_chat(current, "<B>Objective #[obj_count]</B>: [O.explanation_text]")
		obj_count++

/datum/mind/proc/find_syndicate_uplink()
	var/list/L = current.GetAllContents()
	for (var/i in L)
		var/atom/movable/I = i
		. = I.GetComponent(/datum/component/uplink)
		if(.)
			break

/datum/mind/proc/take_uplink()
	qdel(find_syndicate_uplink())

/datum/mind/proc/make_Traitor()
	if(!(has_antag_datum(/datum/antagonist/traitor)))
		add_antag_datum(/datum/antagonist/traitor)

/datum/mind/proc/make_Contractor_Support()
	if(!(has_antag_datum(/datum/antagonist/traitor/contractor_support)))
		add_antag_datum(/datum/antagonist/traitor/contractor_support)

/datum/mind/proc/make_Changeling()
	var/datum/antagonist/changeling/C = has_antag_datum(/datum/antagonist/changeling)
	if(!C)
		C = add_antag_datum(/datum/antagonist/changeling)
		special_role = ROLE_CHANGELING
	return C

/datum/mind/proc/make_Wizard()
	if(!has_antag_datum(/datum/antagonist/wizard))
		special_role = ROLE_WIZARD
		assigned_role = ROLE_WIZARD
		add_antag_datum(/datum/antagonist/wizard)


/datum/mind/proc/make_Cultist()
	if(!has_antag_datum(/datum/antagonist/cult,TRUE))
		SSticker.mode.add_cultist(src,FALSE,equip=TRUE)
		special_role = ROLE_CULTIST
		to_chat(current, "<font color=\"purple\"><b><i>You catch a glimpse of the Realm of Nar'Sie, The Geometer of Blood. You now see how flimsy your world is, you see that it should be open to the knowledge of Nar'Sie.</b></i></font>")
		to_chat(current, "<font color=\"purple\"><b><i>Assist your new brethren in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>")

/datum/mind/proc/make_Rev()
	var/datum/antagonist/rev/head/head = new()
	head.give_flash = TRUE
	head.give_hud = TRUE
	add_antag_datum(head)
	special_role = ROLE_REV_HEAD

/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/S)
	spell_list += S
	S.action.Grant(current)

/datum/mind/proc/owns_soul()
	return soulOwner == src

//To remove a specific spell from a mind
/datum/mind/proc/RemoveSpell(obj/effect/proc_holder/spell/spell)
	if(!spell)
		return
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(istype(S, spell))
			spell_list -= S
			qdel(S)
	current?.client << output(null, "statbrowser:check_spells")

/datum/mind/proc/RemoveAllSpells()
	for(var/obj/effect/proc_holder/S in spell_list)
		RemoveSpell(S)

/datum/mind/proc/transfer_martial_arts(mob/living/new_character)
	if(!ishuman(new_character))
		return
	if(martial_art)
		if(martial_art.base) //Is the martial art temporary?
			martial_art.remove(new_character)
		else
			martial_art.teach(new_character)

/datum/mind/proc/transfer_actions(mob/living/new_character)
	if(current && current.actions)
		for(var/datum/action/A in current.actions)
			A.Grant(new_character)
	transfer_mindbound_actions(new_character)

/datum/mind/proc/transfer_mindbound_actions(mob/living/new_character)
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		S.action.Grant(new_character)
	var/datum/antagonist/changeling/changeling = new_character.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling &&(ishuman(new_character) || ismonkey(new_character)))
		for(var/P in changeling.purchasedpowers)
			var/obj/effect/proc_holder/changeling/I = P
			I.action.Grant(new_character)

/datum/mind/proc/disrupt_spells(delay, list/exceptions = New())
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		for(var/type in exceptions)
			if(istype(S, type))
				continue
		S.charge_counter = delay
		S.updateButtonIcon()
		INVOKE_ASYNC(S, /obj/effect/proc_holder/spell.proc/start_recharge)

/datum/mind/proc/get_ghost(even_if_they_cant_reenter)
	for(var/mob/dead/observer/G in GLOB.dead_mob_list)
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/dead/observer/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse()

/// Sets our can_hijack to the fastest speed our antag datums allow.
/datum/mind/proc/get_hijack_speed()
	. = 0
	for(var/datum/antagonist/A in antag_datums)
		. = max(., A.hijack_speed())

/datum/mind/proc/has_objective(objective_type)
	for(var/datum/antagonist/A in antag_datums)
		for(var/O in A.objectives)
			if(istype(O,objective_type))
				return TRUE

/mob/proc/sync_mind()
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

/datum/mind/proc/has_martialart(var/string)
	if(martial_art && martial_art.id == string)
		return martial_art
	return FALSE

/mob/dead/new_player/sync_mind()
	return

/mob/dead/observer/sync_mind()
	return

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key

	else
		mind = new /datum/mind(key)
		SSticker.minds += mind
		SEND_SIGNAL(src, COMSIG_MOB_ON_NEW_MIND)
	if(!mind.name)
		mind.name = real_name
	mind.current = src
	mind.hide_ckey = client?.prefs?.hide_ckey

/mob/living/carbon/mind_initialize()
	..()
	last_mind = mind

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = "Unassigned" //default

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "Cyborg"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = ROLE_PAI
	mind.special_role = ""

//ambition start
#undef AMBITION_COOLDOWN_TIME
//ambition end
