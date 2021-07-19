/datum/config_entry/flag/allow_vote_restart	// allow votes to restart

/datum/config_entry/flag/allow_vote_mode	// allow votes to change mode

/datum/config_entry/number/vote_delay	// minimum time between voting sessions (deciseconds, 10 minute default)
	config_entry_value = 6000
	min_val = 0

/datum/config_entry/number/vote_period  // length of voting period (deciseconds, default 1 minute)
	config_entry_value = 600
	min_val = 0

/// Length of time before the first autotransfer vote is called (deciseconds, default 2 hours)
/// Set to 0 to disable the subsystem altogether.
/datum/config_entry/number/vote_autotransfer_initial
	config_entry_value = 72000
	min_val = 0

///length of time to wait before subsequent autotransfer votes (deciseconds, default 30 minutes)
/datum/config_entry/number/vote_autotransfer_interval
	config_entry_value = 18000
	min_val = 0

/// maximum extensions until the round autoends.
/// Set to 0 to force automatic crew transfer after the 'vote_autotransfer_initial' elapsed.
/// Set to -1 to disable the maximum extensions cap.
/datum/config_entry/number/vote_autotransfer_maximum
	config_entry_value = 4
	min_val = -1

/datum/config_entry/flag/default_no_vote	// vote does not default to nochange/norestart

/datum/config_entry/flag/no_dead_vote	// dead people can't vote

/datum/config_entry/flag/maprotation

/datum/config_entry/flag/tgstyle_maprotation

/datum/config_entry/string/map_vote_type
	config_entry_value = APPROVAL_VOTING

/datum/config_entry/number/maprotatechancedelta
	config_entry_value = 0.75
	min_val = 0
	max_val = 1
	integer = FALSE

/datum/config_entry/flag/allow_map_voting

/datum/config_entry/flag/modetier_voting

/datum/config_entry/number/dropped_modes
	config_entry_value = 3

/datum/config_entry/flag/must_be_readied_to_vote_gamemode
