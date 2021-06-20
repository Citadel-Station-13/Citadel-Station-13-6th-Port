#define REVENANT_SPAWN_THRESHOLD 20
#define ABDUCTOR_MAX_TEAMS 4 // blame TG for not using the defines files

//////////////////////////////////////////////
//                                          //
//            MIDROUND RULESETS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround // Can be drafted once in a while during a round
	ruletype = "Midround"
	/// If the ruleset should be restricted from ghost roles.
	var/restrict_ghost_roles = TRUE
	/// What mob type the ruleset is restricted to.
	var/required_type = /mob/living/carbon/human
	var/list/living_players = list()
	var/list/living_antags = list()
	var/list/dead_players = list()
	var/list/list_observers = list()
	var/list/ghost_eligible = list()

/datum/dynamic_ruleset/midround/from_ghosts
	weight = 0
	/// Whether the ruleset should call generate_ruleset_body or not.
	var/makeBody = TRUE

/datum/dynamic_ruleset/midround/trim_candidates()
	//
	// All you need to know is that here, the candidates list contains 4 lists itself, indexed with the following defines:
	// Candidates = list(CURRENT_LIVING_PLAYERS, CURRENT_LIVING_ANTAGS, CURRENT_DEAD_PLAYERS, CURRENT_OBSERVERS)
	// So for example you can get the list of all current dead players with var/list/dead_players = candidates[CURRENT_DEAD_PLAYERS]
	// Make sure to properly typecheck the mobs in those lists, as the dead_players list could contain ghosts, or dead players still in their bodies.
	// We're still gonna trim the obvious (mobs without clients, jobbanned players, etc)
	living_players = trim_list(mode.current_players[CURRENT_LIVING_PLAYERS])
	living_antags = trim_list(mode.current_players[CURRENT_LIVING_ANTAGS])
	list_observers = trim_list(mode.current_players[CURRENT_OBSERVERS])
	ghost_eligible = trim_list(get_all_ghost_role_eligible())

/datum/dynamic_ruleset/midround/proc/trim_list(list/L = list())
	var/list/trimmed_list = L.Copy()
	for(var/mob/M in trimmed_list)
		if (!istype(M, required_type))
			trimmed_list.Remove(M)
			continue
		if (HAS_TRAIT(M, TRAIT_NO_MIDROUND_ANTAG))
			trimmed_list.Remove(M)
			continue
		if (!M.client) // Are they connected?
			trimmed_list.Remove(M)
			continue
		if(M.client.prefs && M.client.prefs.toggles & MIDROUND_ANTAG)
			trimmed_list.Remove(M)
			continue
		if(!mode.check_age(M.client, minimum_required_age))
			trimmed_list.Remove(M)
			continue
		if(antag_flag_override)
			if(!(antag_flag_override in M.client.prefs.be_special) || jobban_isbanned(M.ckey, antag_flag_override))
				trimmed_list.Remove(M)
				continue
		else
			if(!(antag_flag in M.client.prefs.be_special) || jobban_isbanned(M.ckey, antag_flag))
				trimmed_list.Remove(M)
				continue
		if (M.mind)
			if (restrict_ghost_roles && (M.mind.assigned_role in GLOB.exp_specialmap[EXP_TYPE_SPECIAL])) // Are they playing a ghost role?
				trimmed_list.Remove(M)
				continue
			if (M.mind.assigned_role in restricted_roles) // Does their job allow it?
				trimmed_list.Remove(M)
				continue
			if ((exclusive_roles.len > 0) && !(M.mind.assigned_role in exclusive_roles)) // Is the rule exclusive to their job?
				trimmed_list.Remove(M)
				continue
	return trimmed_list

/datum/dynamic_ruleset/midround/from_ghosts/trim_list(list/L = list())
	var/list/trimmed_list = L.Copy()
	for(var/mob/M in trimmed_list)
		if (!M.client) // Are they connected?
			trimmed_list.Remove(M)
			continue
		if(!mode.check_age(M.client, minimum_required_age))
			trimmed_list.Remove(M)
			continue
		if(antag_flag_override)
			if(!(antag_flag_override in M.client.prefs.be_special) || jobban_isbanned(M.ckey, antag_flag_override))
				trimmed_list.Remove(M)
				continue
		else
			if(!(antag_flag in M.client.prefs.be_special) || jobban_isbanned(M.ckey, antag_flag))
				trimmed_list.Remove(M)
				continue
	return trimmed_list

// You can then for example prompt dead players in execute() to join as strike teams or whatever
// Or autotator someone

// IMPORTANT, since /datum/dynamic_ruleset/midround may accept candidates from both living, dead, and even antag players, you need to manually check whether there are enough candidates
// (see /datum/dynamic_ruleset/midround/autotraitor/ready(var/forced = FALSE) for example)
/datum/dynamic_ruleset/midround/ready(forced = FALSE)
	if (!forced)
		var/job_check = 0
		if (enemy_roles.len > 0)
			for (var/mob/M in mode.current_players[CURRENT_LIVING_PLAYERS])
				if (M.stat == DEAD)
					continue // Dead players cannot count as opponents
				if (M.mind && M.mind.assigned_role && (M.mind.assigned_role in enemy_roles) && (!(M in candidates) || (M.mind.assigned_role in restricted_roles)))
					job_check++ // Checking for "enemies" (such as sec officers). To be counters, they must either not be candidates to that rule, or have a job that restricts them from it

		var/threat = clamp(round(mode.threat_level/10),1,10)
		if (job_check < required_enemies[threat])
			SSblackbox.record_feedback("tally","dynamic",1,"Times rulesets rejected due to not enough enemy roles")
			return FALSE
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/ready(forced = FALSE)
	if (required_candidates > ghost_eligible.len)
		SSblackbox.record_feedback("tally","dynamic",1,"Times rulesets rejected due to not enough ghosts")
		return FALSE
	return ..()


/datum/dynamic_ruleset/midround/from_ghosts/execute()
	var/application_successful = send_applications(ghost_eligible)
	return assigned.len > 0 && application_successful

/// This sends a poll to ghosts if they want to be a ghost spawn from a ruleset.
/datum/dynamic_ruleset/midround/from_ghosts/proc/send_applications(list/possible_volunteers = list())
	if (possible_volunteers.len <= 0) // This shouldn't happen, as ready() should return FALSE if there is not a single valid candidate
		message_admins("Possible volunteers was 0. This shouldn't appear, because of ready(), unless you forced it!")
		return
	message_admins("Polling [possible_volunteers.len] players to apply for the [name] ruleset.")
	log_game("DYNAMIC: Polling [possible_volunteers.len] players to apply for the [name] ruleset.")

	candidates = pollGhostCandidates("The mode is looking for volunteers to become a [name]", antag_flag, SSticker.mode, antag_flag, poll_time = 300)

	if(!candidates || candidates.len < required_candidates)
		message_admins("The ruleset [name] did not receive enough applications.")
		if(candidates)
			message_admins("Only received [candidates.len], needed [required_candidates].")
		else
			message_admins("There were no candidates.")
		log_game("DYNAMIC: The ruleset [name] did not receive enough applications.")
		return FALSE

	message_admins("[candidates.len] players volunteered for the ruleset [name].")
	log_game("DYNAMIC: [candidates.len] players volunteered for [name].")
	review_applications()
	return TRUE

/// Here is where you can check if your ghost applicants are valid for the ruleset.
/// Called by send_applications().
/datum/dynamic_ruleset/midround/from_ghosts/proc/review_applications()
	for (var/i = 1, i <= required_candidates, i++)
		if(candidates.len <= 0)
			break
		var/mob/applicant = pick(candidates)
		candidates -= applicant
		if(!isobserver(applicant))
			if(applicant.stat == DEAD) // Not an observer? If they're dead, make them one.
				applicant = applicant.ghostize(FALSE)
			else // Not dead? Disregard them, pick a new applicant
				i--
				continue

		if(!applicant)
			i--
			continue

		var/mob/new_character = applicant

		if (makeBody)
			new_character = generate_ruleset_body(applicant)

		finish_setup(new_character, i)
		assigned += applicant
		notify_ghosts("[new_character] has been picked for the ruleset [name]!", source = new_character, action = NOTIFY_ORBIT)

/datum/dynamic_ruleset/midround/from_ghosts/proc/generate_ruleset_body(mob/applicant)
	var/mob/living/carbon/human/new_character = makeBody(applicant)
	new_character.dna.remove_all_mutations()
	return new_character

/datum/dynamic_ruleset/midround/from_ghosts/proc/finish_setup(mob/new_character, index)
	var/datum/antagonist/new_role = new antag_datum()
	setup_role(new_role)
	new_character.mind.add_antag_datum(new_role)
	new_character.mind.special_role = antag_flag

/datum/dynamic_ruleset/midround/from_ghosts/proc/setup_role(datum/antagonist/new_role)
	return

//////////////////////////////////////////////
//                                          //
//           SYNDICATE TRAITORS             //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/autotraitor
	name = "Syndicate Sleeper Agent"
	config_tag = "midround_traitor"
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_TRAITOR
	restricted_roles = list("AI", "Cyborg", "Positronic Brain")
	protected_roles = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Chief Engineer", "Chief Medical Officer", "Research Director", "Quartermaster")
	required_candidates = 1
	weight = 7
	cost = 10
	requirements = list(30,25,20,15,15,15,15,15,15,15)
	repeatable = TRUE
	high_population_requirement = 15
	flags = TRAITOR_RULESET | MINOR_RULESET | ALWAYS_MAX_WEIGHT_RULESET
	property_weights = list("story_potential" = 2, "trust" = -1, "extended" = 1)

/datum/dynamic_ruleset/midround/autotraitor/acceptable(population = 0, threat = 0)
	var/player_count = mode.current_players[CURRENT_LIVING_PLAYERS].len
	var/antag_count = mode.current_players[CURRENT_LIVING_ANTAGS].len
	var/max_traitors = round(player_count / 10) + 1
	if ((antag_count < max_traitors) && prob(min(100,mode.threat_level)))//adding traitors if the antag population is getting low
		return ..()
	else
		return FALSE

/datum/dynamic_ruleset/midround/autotraitor/trim_candidates()
	..()
	for(var/mob/living/player in living_players)
		if(issilicon(player)) // Your assigned role doesn't change when you are turned into a silicon.
			living_players -= player
			continue
		if(is_centcom_level(player.z))
			living_players -= player // We don't autotator people in CentCom
			continue
		if(player.mind && (player.mind.special_role || player.mind.antag_datums?.len > 0))
			living_players -= player // We don't autotator people with roles already

/datum/dynamic_ruleset/midround/autotraitor/ready(forced = FALSE)
	if (required_candidates > living_players.len)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/autotraitor/execute()
	var/mob/M = pick(living_players)
	assigned += M
	living_players -= M
	var/datum/antagonist/traitor/newTraitor = new
	M.mind.add_antag_datum(newTraitor)
	log_admin("[M] was made into a traitor by dynamic.")
	message_admins("[M] was made into a traitor by dynamic.")
	return TRUE


//////////////////////////////////////////////
//                                          //
//         Malfunctioning AI                //
//                              		    //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/malf
	name = "Malfunctioning AI"
	config_tag = "midround_malf_ai"
	antag_datum = /datum/antagonist/traitor
	antag_flag = ROLE_MALF
	enemy_roles = list("Security Officer", "Warden","Detective","Head of Security", "Captain", "Scientist", "Chemist", "Research Director", "Chief Engineer")
	exclusive_roles = list("AI")
	required_enemies = list(6,6,6,4,4,4,2,2,2,1)
	required_candidates = 1
	weight = 2
	cost = 35
	requirements = list(101,101,70,50,50,50,40,30,30,30)
	high_population_requirement = 30
	required_type = /mob/living/silicon/ai
	property_weights = list("story_potential" = 2, "trust" = 1, "chaos" = 2)
	var/ion_announce = 33
	var/removeDontImproveChance = 10

/datum/dynamic_ruleset/midround/malf/ready()
	if(!candidates || !candidates.len)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/malf/trim_candidates()
	..()
	for(var/mob/living/player in living_players)
		if(!isAI(player))
			candidates -= player
			continue
		if(is_centcom_level(player.z))
			candidates -= player
			continue
		if(player.mind && (player.mind.special_role || player.mind.antag_datums?.len > 0))
			candidates -= player

/datum/dynamic_ruleset/midround/malf/execute()
	var/mob/living/silicon/ai/M = pick_n_take(candidates)
	assigned += M.mind
	var/datum/antagonist/traitor/AI = new
	M.mind.special_role = antag_flag
	M.mind.add_antag_datum(AI)
	log_admin("[M] was made into a malf AI by dynamic.")
	message_admins("[M] was made into a malf AI by dynamic.")
	if(prob(ion_announce))
		priority_announce("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", "ionstorm")
		if(prob(removeDontImproveChance))
			M.replace_random_law(generate_ion_law(), list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))
		else
			M.add_ion_law(generate_ion_law())
	return TRUE

//////////////////////////////////////////////
//                                          //
//              WIZARD (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/wizard
	name = "Wizard"
	config_tag = "midround_wizard"
	antag_datum = /datum/antagonist/wizard
	antag_flag = ROLE_WIZARD
	enemy_roles = list("Security Officer","Detective","Head of Security", "Captain")
	required_enemies = list(4,4,3,2,2,1,1,0,0,0)
	required_candidates = 1
	weight = 1
	cost = 20
	requirements = list(90,90,70,50,50,50,50,40,30,30)
	high_population_requirement = 30
	repeatable = TRUE
	property_weights = list("story_potential" = 2, "trust" = 1, "chaos" = 2, "extended" = -2)
	var/datum/mind/wizard

/datum/dynamic_ruleset/midround/from_ghosts/wizard/ready(forced = FALSE)
	if(GLOB.wizardstart.len == 0)
		log_admin("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		message_admins("Cannot accept Wizard ruleset. Couldn't find any wizard spawn points.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/wizard/finish_setup(mob/new_character, index)
	..()
	new_character.forceMove(pick(GLOB.wizardstart))
	wizard = new_character.mind

/datum/dynamic_ruleset/midround/from_ghosts/wizard/rule_process() // i can literally copy this from are_special_antags_dead it's great
	if(isliving(wizard.current) && wizard.current.stat!=DEAD)
		return FALSE
	for(var/obj/item/phylactery/P in GLOB.poi_list) //TODO : IsProperlyDead()
		if(P.mind && P.mind.has_antag_datum(/datum/antagonist/wizard))
			return FALSE

	if(SSevents.wizardmode) //If summon events was active, turn it off
		SSevents.toggleWizardmode()
		SSevents.resetFrequency()

	return RULESET_STOP_PROCESSING

//////////////////////////////////////////////
//                                          //
//          NUCLEAR OPERATIVES (MIDROUND)   //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/nuclear
	name = "Nuclear Assault"
	config_tag = "midround_nuclear"
	antag_flag = ROLE_OPERATIVE
	antag_datum = /datum/antagonist/nukeop
	enemy_roles = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(5,5,4,3,3,2,2,2,1,1)
	required_candidates = 5
	weight = 5
	cost = 35
	requirements = list(90,90,90,80,70,60,50,40,40,40)
	high_population_requirement = 40
	property_weights = list("story_potential" = 2, "trust" = 2, "chaos" = 2, "extended" = -2, "valid" = 2)
	var/operative_cap = list(2,2,3,3,4,5,5,5,5,5)
	var/datum/team/nuclear/nuke_team
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/midround/from_ghosts/nuclear/acceptable(population=0, threat=0)
	if (locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return FALSE // Unavailable if nuke ops were already sent at roundstart
	indice_pop = min(10, round(living_players.len/5)+1)
	/*	NOTE: The above line's magic value of "10" is a hack due to the fact that byond was
		not recognizing operative_cap as a defined variable. It should be operative_cap.len--
		and yes, this means that if the len is changed, this variable must be changed along with it.
		One day, once the mystery of why this issue was occuring is figured out,
		we may change it back, but until this day comes, we must make it simply 10.
	*/
	required_candidates = operative_cap[indice_pop]
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/nuclear/finish_setup(mob/new_character, index)
	new_character.mind.special_role = "Nuclear Operative"
	new_character.mind.assigned_role = "Nuclear Operative"
	if (index == 1) // Our first guy is the leader
		var/datum/antagonist/nukeop/leader/new_role = new
		nuke_team = new_role.nuke_team
		new_character.mind.add_antag_datum(new_role)
	else
		return ..()

//////////////////////////////////////////////
//                                          //
//              BLOB (GHOST)                //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/blob
	name = "Blob"
	config_tag = "blob"
	antag_datum = /datum/antagonist/blob
	antag_flag = ROLE_BLOB
	enemy_roles = list("Security Officer", "Detective", "Head of Security", "Captain")
	required_enemies = list(3,3,2,2,2,1,1,1,1,0)
	required_candidates = 1
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/clockcult)
	weight = 4
	cost = 20
	requirements = list(101,101,101,80,60,50,50,50,50,50)
	high_population_requirement = 50
	repeatable = TRUE
	property_weights = list("story_potential" = -1, "trust" = 2, "chaos" = 2, "extended" = -2, "valid" = 2)

/datum/dynamic_ruleset/midround/from_ghosts/blob/generate_ruleset_body(mob/applicant)
	var/body = applicant.become_overmind()
	return body

//////////////////////////////////////////////
//                                          //
//           XENOMORPH (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph
	name = "Alien Infestation"
	config_tag = "xenos"
	antag_datum = /datum/antagonist/xeno
	antag_flag = ROLE_ALIEN
	enemy_roles = list("Security Officer", "Detective", "Head of Security", "Captain")
	required_enemies = list(3,3,2,2,1,1,1,1,1,0)
	required_candidates = 1
	weight = 3
	cost = 10
	requirements = list(101,101,101,70,50,50,50,50,50,50)
	high_population_requirement = 50
	repeatable_weight_decrease = 2
	repeatable = TRUE
	property_weights = list("story_potential" = -1, "trust" = 1, "chaos" = 2, "extended" = -2, "valid" = 2)
	var/list/vents = list()

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/ready()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			// Stops Aliens getting stuck in small networks.
			// See: Security, Virology
			if(temp_vent_parent.other_atmosmch.len > 20)
				vents += temp_vent
	if(!vents.len)
		return FALSE
	return ..()


/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/execute()
	// 50% chance of being incremented by one
	required_candidates += prob(50)
	. = ..()

/datum/dynamic_ruleset/midround/from_ghosts/xenomorph/generate_ruleset_body(mob/applicant)
	var/obj/vent = pick_n_take(vents)
	var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
	applicant.transfer_ckey(new_xeno, FALSE)
	message_admins("[ADMIN_LOOKUPFLW(new_xeno)] has been made into an alien by the midround ruleset.")
	log_game("DYNAMIC: [key_name(new_xeno)] was spawned as an alien by the midround ruleset.")
	return new_xeno

//////////////////////////////////////////////
//                                          //
//           NIGHTMARE (GHOST)              //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/nightmare
	name = "Nightmare"
	config_tag = "nightmare"
	antag_datum = /datum/antagonist/nightmare
	antag_flag = "Nightmare"
	antag_flag_override = ROLE_ALIEN
	enemy_roles = list("Security Officer", "Detective", "Head of Security", "Captain")
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 10
	flags = MINOR_RULESET
	requirements = list(101,101,101,70,50,40,20,15,15,15)
	high_population_requirement = 50
	repeatable_weight_decrease = 2
	repeatable = TRUE
	property_weights = list("story_potential" = 1, "trust" = 1, "extended" = 1, "valid" = 2, "integrity" = 1)
	var/list/spawn_locs = list()

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/ready()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T
	if(!spawn_locs.len)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/nightmare/generate_ruleset_body(mob/applicant)
	var/datum/mind/player_mind = new /datum/mind(applicant.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/S = new (pick(spawn_locs))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Nightmare"
	player_mind.special_role = "Nightmare"
	player_mind.add_antag_datum(/datum/antagonist/nightmare)
	S.set_species(/datum/species/shadow/nightmare)

	playsound(S, 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Nightmare by the midround ruleset.")
	log_game("DYNAMIC: [key_name(S)] was spawned as a Nightmare by the midround ruleset.")
	return S

//////////////////////////////////////////////
//                                          //
//            SLAUGHTER DEMON               //
//                                          //
//////////////////////////////////////////////


/datum/dynamic_ruleset/midround/from_ghosts/slaughter_demon
	name = "Slaughter Demon"
	config_tag = "slaughter_demon"
	antag_flag = ROLE_ALIEN
	enemy_roles = list("Security Officer","Shaft Miner","Head of Security","Captain","Janitor","AI","Cyborg","Bartender")
	required_enemies = list(3,2,2,2,2,1,1,1,1,0)
	required_candidates = 1
	weight = 4
	cost = 15
	requirements = list(101,101,101,90,80,70,60,50,40,30)
	property_weights = list("story_potential" = -2, "extended" = -2, "integrity" = 2, "valid" = 2, "trust" = 2)
	high_population_requirement = 30
	var/list/spawn_locs = list()

/datum/dynamic_ruleset/midround/from_ghosts/slaughter_demon/ready(forced = FALSE)
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		if(isturf(L.loc))
			spawn_locs += L.loc

	if(!spawn_locs.len)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/slaughter_demon/generate_ruleset_body(mob/applicant)
	var/datum/mind/player_mind = new /datum/mind(applicant.key)
	player_mind.active = 1
	var/obj/effect/dummy/phased_mob/slaughter/holder = new /obj/effect/dummy/phased_mob/slaughter((pick(spawn_locs)))
	var/mob/living/simple_animal/slaughter/S = new (holder)
	S.holder = holder
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Slaughter Demon"
	player_mind.special_role = "Slaughter Demon"
	player_mind.add_antag_datum(/datum/antagonist/slaughter)
	to_chat(S, S.playstyle_string)
	to_chat(S, "<B>You are currently not currently in the same plane of existence as the station. Blood Crawl near a blood pool to manifest.</B>")
	SEND_SOUND(S, 'sound/magic/demon_dies.ogg')
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a slaughter demon by dynamic.")
	log_game("[key_name(S)] was spawned as a slaughter demon by dynamic.")
	return S

//////////////////////////////////////////////
//                                          //
//               ABDUCTORS                  //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/abductors
	name = "Abductors"
	config_tag = "abductors"
	antag_flag = ROLE_ABDUCTOR
	// Has two antagonist flags, in fact
	enemy_roles = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(3,3,2,2,1,1,0,0,0,0)
	required_candidates = 2
	weight = 8
	cost = 10
	requirements = list(101,101,70,50,40,30,30,30,30,30)
	blocking_rules = list(/datum/dynamic_ruleset/roundstart/nuclear,/datum/dynamic_ruleset/midround/from_ghosts/nuclear)
	high_population_requirement = 15
	var/datum/team/abductor_team/team
	property_weights = list("extended" = -2, "valid" = 1, "trust" = -1, "chaos" = 2)
	repeatable_weight_decrease = 4
	repeatable = TRUE

/datum/dynamic_ruleset/midround/from_ghosts/abductors/ready(forced = FALSE)
	team = new /datum/team/abductor_team
	if(team.team_number > ABDUCTOR_MAX_TEAMS)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/abductors/finish_setup(mob/new_character, index)
	switch(index)
		if(1) // yeah this seems like a baffling anti-pattern but it's actually the best way to do this, shit you not
			var/mob/living/carbon/human/agent = new_character
			agent.mind.add_antag_datum(/datum/antagonist/abductor/agent, team)
			log_game("[key_name(agent)] has been selected as [team.name] abductor agent.")
		if(2)
			var/mob/living/carbon/human/scientist = new_character
			scientist.mind.add_antag_datum(/datum/antagonist/abductor/scientist, team)
			log_game("[key_name(scientist)] has been selected as [team.name] abductor scientist.")

//////////////////////////////////////////////
//                                          //
//              SPACE NINJA                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/ninja
	name = "Space Ninja"
	config_tag = "ninja"
	antag_flag = ROLE_NINJA
	enemy_roles = list("Security Officer","Head of Security","Captain","AI","Cyborg")
	required_enemies = list(3,2,2,2,2,1,1,1,1,0)
	required_candidates = 1
	weight = 4
	cost = 15
	flags = MINOR_RULESET
	requirements = list(101,101,101,90,80,70,60,50,40,30)
	high_population_requirement = 30
	property_weights = list("story_potential" = 1, "extended" = -2, "valid" = 2)
	var/list/spawn_locs = list()
	var/spawn_loc

/datum/dynamic_ruleset/midround/from_ghosts/ninja/ready(forced = FALSE)
	if(!spawn_loc)
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				spawn_locs += L.loc
		for(var/obj/effect/landmark/loneopspawn/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				spawn_locs += L.loc
		if(!spawn_locs.len)
			return FALSE
		spawn_loc = pick(spawn_locs)
	if(!spawn_loc)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/ninja/generate_ruleset_body(mob/applicant)
	var/key = applicant.key

	//Prepare ninja player mind
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.assigned_role = ROLE_NINJA
	Mind.special_role = ROLE_NINJA
	Mind.active = 1

	//spawn the ninja and assign the candidate
	var/mob/living/carbon/human/Ninja = create_space_ninja(spawn_loc)
	Mind.transfer_to(Ninja)
	var/datum/antagonist/ninja/ninjadatum = new
	Mind.add_antag_datum(ninjadatum)

	if(Ninja.mind != Mind)			//something has gone wrong!
		stack_trace("Ninja created with incorrect mind")

	message_admins("[ADMIN_LOOKUPFLW(Ninja)] has been made into a ninja by dynamic.")
	log_game("[key_name(Ninja)] was spawned as a ninja by dynamic.")
	return Ninja

/datum/dynamic_ruleset/midround/from_ghosts/ninja/finish_setup(mob/new_character, index)
	return

#undef ABDUCTOR_MAX_TEAMS
#undef REVENANT_SPAWN_THRESHOLD
