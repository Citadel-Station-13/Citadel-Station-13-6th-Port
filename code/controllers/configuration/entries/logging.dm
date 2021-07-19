/datum/config_entry/flag/log_ooc	// log OOC channel
	config_entry_value = TRUE

/datum/config_entry/flag/log_access	// log login/logout
	config_entry_value = TRUE

/datum/config_entry/flag/log_say	// log client say
	config_entry_value = TRUE

/datum/config_entry/flag/log_admin	// log admin actions
	protection = CONFIG_ENTRY_LOCKED
	config_entry_value = TRUE

/datum/config_entry/flag/log_prayer	// log prayers
	config_entry_value = TRUE

/datum/config_entry/flag/log_law	// log lawchanges
	config_entry_value = TRUE

/datum/config_entry/flag/log_game	// log game events
	config_entry_value = TRUE

/datum/config_entry/flag/log_virus	// log virology data
	config_entry_value = TRUE

/datum/config_entry/flag/log_vote	// log voting
	config_entry_value = TRUE

/datum/config_entry/flag/log_craft	// log crafting
	config_entry_value = TRUE

/datum/config_entry/flag/log_whisper	// log client whisper
	config_entry_value = TRUE

/datum/config_entry/flag/log_attack	// log attack messages
	config_entry_value = TRUE

/datum/config_entry/flag/log_emote	// log emotes
	config_entry_value = TRUE

/datum/config_entry/flag/log_adminchat	// log admin chat messages
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/log_shuttle // log shuttle related actions, ie shuttle computers, shuttle manipulator, emergency console
	config_entry_value = TRUE

/datum/config_entry/flag/log_pda	// log pda messages
	config_entry_value = TRUE

/datum/config_entry/flag/log_telecomms	// log telecomms messages
	config_entry_value = TRUE

/datum/config_entry/flag/log_twitter	// log certain expliotable parrots and other such fun things in a JSON file of twitter valid phrases.
	config_entry_value = TRUE

/datum/config_entry/flag/log_world_topic	// log all world.Topic() calls
	config_entry_value = TRUE

/datum/config_entry/flag/log_manifest	// log crew manifest to seperate file
	config_entry_value = TRUE

/datum/config_entry/flag/log_job_debug	// log roundstart divide occupations debug information to a file
	config_entry_value = TRUE

/datum/config_entry/flag/log_pictures

/datum/config_entry/flag/picture_logging_camera

/// forces log_href for tgui
/datum/config_entry/flag/emergency_tgui_logging
	config_entry_value = FALSE

/datum/config_entry/number/error_cooldown	// The "cooldown" time for each occurrence of a unique error
	config_entry_value = 600
	min_val = 0

/datum/config_entry/number/error_limit	// How many occurrences before the next will silence them
	config_entry_value = 50

/datum/config_entry/number/error_silence_time	// How long a unique error will be silenced for
	config_entry_value = 6000

/datum/config_entry/number/error_msg_delay	// How long to wait between messaging admins about occurrences of a unique error
	config_entry_value = 50
