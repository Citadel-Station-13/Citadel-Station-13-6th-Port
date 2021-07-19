/datum/movespeed_modifier/reagent
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/reagent/stimulants
	multiplicative_slowdown = -0.55

/datum/movespeed_modifier/reagent/ephedrine
	// strong painkiller effect that caps out at slightly above runspeed
	multiplicative_slowdown = -1.5
	priority = -100
	complex_calculation = TRUE
	absolute_max_tiles_per_second = 7

/datum/movespeed_modifier/reagent/pepperspray
	multiplicative_slowdown = 0.25

/datum/movespeed_modifier/reagent/monkey_energy
	multiplicative_slowdown = -0.35

/datum/movespeed_modifier/reagent/changelinghaste
	// extremely strong painkiller effect: allows user to run at old sprint speeds but not over by cancelling out slowdowns.
	// however, will not make user go faster than that
	multiplicative_slowdown = -4
	priority = -100
	complex_calculation = TRUE
	absolute_max_tiles_per_second = 8

/datum/movespeed_modifier/reagent/methamphetamine
	// very strong painkiller effect that caps out at slightly above runspeed
	multiplicative_slowdown = -2.5
	priority = -100
	complex_calculation = TRUE
	absolute_max_tiles_per_second = 7.5

/datum/movespeed_modifier/reagent/nitryl
	multiplicative_slowdown = -0.65

/datum/movespeed_modifier/reagent/freon
	multiplicative_slowdown = 1.6

/datum/movespeed_modifier/reagent/halon
	multiplicative_slowdown = 1.8

/datum/movespeed_modifier/reagent/lenturi
	multiplicative_slowdown = 1.5

/datum/movespeed_modifier/reagent/nuka_cola
	multiplicative_slowdown = -0.35

/datum/movespeed_modifier/reagent/nooartrium
	multiplicative_slowdown = 2

/datum/movespeed_modifier/reagent/skooma
	multiplicative_slowdown = -1
