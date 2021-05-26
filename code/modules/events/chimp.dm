/datum/round_event_control/chimp
	name = "Random Chimp Event"
	typepath = /datum/round_event/ghost_role/chimp
	max_occurrences = 1
	earliest_start = 35 MINUTES
	gamemode_blacklist = list("dynamic")
	min_players = 25
	weight = 8

/datum/round_event/ghost_role/chimp
	role_name = "monkey"
	minimum_required = 1
	var/spawn_loc
	var/success_spawn

/datum/round_event/ghost_role/chimp/kill()
	if(!success_spawn && control)	// just to be sure, if we kill this event without spawning, lets not consider it
		control.occurrences--
	return ..()

/datum/round_event/ghost_role/chimp/spawn_role()
	// get that candidate!
	// perhaps in the future lets add more than just one monkey
	var/list/candidates = get_candidates(ROLE_MONKEY, null, ROLE_MONKEY)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/selected = pick(candidates)

	// mind setup
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	// lets pick a vent
	var/list/spawn_locs = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		var/turf/T = get_turf(temp_vent)
		var/area/A = T.loc
		if(T && is_station_level(T.z) && !temp_vent.welded && !A.safe)
			spawn_locs += temp_vent

	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	// time to spawn our monkee
	var/mob/living/carbon/monkey/S = new ((pick(spawn_locs)))
	player_mind.transfer_to(S)

	// give the datum already
	add_monkey_leader(S.mind)

	// give it the disease
	var/datum/disease/transformation/D = new /datum/disease/transformation/jungle_fever()
	S.ForceContractDisease(D, FALSE)

	//tweak stats and fluff
	if(D)
		D.disease_flags = CAN_CARRY		// no cure for patient zero
		D.stage = 5						// it starts as monkey so no need to advance stages
		D.stage_prob = 0 					// same as above
		D.agent = "Kongey Vibrion R-909"	// the agent is different to make sure people notice this is another strain
		D.cure_text = "Incurable strain."	// another thing to tip out players, if everything fails
		D.desc = "The root of the simean revolution. Monkeys with this disease will bite humans, causing humans to mutate into a monkey."

	// logging = good
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Monkey by an event.")
	log_game("[key_name(S)] was spawned as a Monkey by an event.")

	spawned_mobs += S
	success_spawn = TRUE
	return SUCCESSFUL_SPAWN
