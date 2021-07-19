/// Amount of dirtyness tiles need to spawn dirt.
/datum/config_entry/number/turf_dirt_threshold
	config_entry_value = 100
	min_val = 1
	integer = TRUE

/// Alpha dirt starts at
/datum/config_entry/number/dirt_alpha_starting
	config_entry_value = 127
	max_val = 255
	min_val = 0
	integer = TRUE

/// Dirtyness multiplier for making turfs dirty
/datum/config_entry/number/turf_dirty_multiplier
	config_entry_value = 1
