/datum/movespeed_modifier/status_effect/bloodchill
	multiplicative_slowdown = 3

/datum/movespeed_modifier/status_effect/bonechill
	multiplicative_slowdown = 3

/datum/movespeed_modifier/status_effect/tarfoot
	multiplicative_slowdown = 0.5
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/status_effect/sepia
	variable = TRUE
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/status_effect/mesmerize
	blacklisted_movetypes = CRAWLING
	multiplicative_slowdown = 5
	priority = 64

/datum/movespeed_modifier/status_effect/tased
	multiplicative_slowdown = 1.5
	priority = 50

/datum/movespeed_modifier/status_effect/domain
	multiplicative_slowdown = 3

/datum/movespeed_modifier/status_effect/tased/no_combat_mode
	multiplicative_slowdown = 8
	priority = 100

/datum/movespeed_modifier/status_effect/electrostaff
	multiplicative_slowdown = 1
	movetypes = GROUND

//no comment.
/datum/movespeed_modifier/status_effect/breast_hypertrophy
	blacklisted_movetypes = FLOATING
	variable = TRUE

//this shouldn't even exist.
/datum/movespeed_modifier/status_effect/penis_hypertrophy
	blacklisted_movetypes = FLOATING
	variable = TRUE

/datum/movespeed_modifier/status_effect/mkultra
	multiplicative_slowdown = -2
	blacklisted_movetypes= FLYING|FLOATING

/datum/movespeed_modifier/status_effect/stagger
	variable = TRUE

/datum/movespeed_modifier/status_effect/off_balance
	variable = TRUE

/datum/movespeed_modifier/status_effect/slime/light_pink
	// decently good painkiller + speedup effect
	blacklisted_movetypes = FLYING | FLOATING
	priority = -150		// someday we really need to make these defines lmao
	multiplicative_slowdown = -2
	complex_calculation = TRUE
	absolute_max_tiles_per_second = 7
