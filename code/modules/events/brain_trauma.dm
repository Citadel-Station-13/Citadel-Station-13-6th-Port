/datum/round_event_control/brain_trauma
	name = "Spontaneous Brain Trauma"
	typepath = /datum/round_event/brain_trauma
	weight = 25
	min_players = 5

/datum/round_event_control/brain_trauma/canSpawnEvent(var/players_amt, var/gamemode)
	var/list/enemy_roles = list("Medical Doctor","Chief Medical Officer","Paramedic")
	for (var/mob/M in GLOB.alive_mob_list)
		if(M.stat != DEAD && (M.mind?.assigned_role in enemy_roles))
			return TRUE
	return FALSE

/datum/round_event/brain_trauma
	fakeable = FALSE

/datum/round_event/brain_trauma/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		if(H.stat == DEAD) // What are you doing in this list
			continue
		if(!H.getorgan(/obj/item/organ/brain)) // If only I had a brain
			continue
		if(HAS_TRAIT(H,TRAIT_EXEMPT_HEALTH_EVENTS))
			continue
		if(!is_station_level(H.z))
			continue
		if(H.prob_if_lucky(10))
			continue
		traumatize(H)
		announce_to_ghosts(H)
		break

/datum/round_event/brain_trauma/proc/traumatize(mob/living/carbon/human/H)
	var/resistance = pick(
		65;TRAUMA_RESILIENCE_BASIC,
		35;TRAUMA_RESILIENCE_SURGERY)

	var/trauma_type = pickweight(list(
		BRAIN_TRAUMA_MILD = 80,
		BRAIN_TRAUMA_SEVERE = 10,
		BRAIN_TRAUMA_SPECIAL = 10
	))

	H.gain_trauma_type(trauma_type, resistance)
