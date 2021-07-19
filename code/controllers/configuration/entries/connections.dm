/datum/config_entry/flag/panic_bunker	// prevents people the server hasn't seen before from connecting

/datum/config_entry/number/panic_bunker_living // living time in minutes that a player needs to pass the panic bunker

/datum/config_entry/string/panic_bunker_message
	config_entry_value = "Sorry but the server is currently not accepting connections from never before seen players."

/datum/config_entry/string/panic_server_name

/datum/config_entry/string/panic_server_name/ValidateAndSet(str_val)
	return str_val != "\[Put the name here\]" && ..()

/datum/config_entry/string/panic_server_address	//Reconnect a player this linked server if this server isn't accepting new players

/datum/config_entry/string/panic_server_address/ValidateAndSet(str_val)
	return str_val != "byond://address:port" && ..()

/datum/config_entry/number/max_bunker_days
	config_entry_value = 7
	min_val = 1

/datum/config_entry/number/notify_new_player_age	// how long do we notify admins of a new player
	min_val = -1

/datum/config_entry/number/notify_new_player_account_age	// how long do we notify admins of a new byond account
	min_val = 0

/datum/config_entry/flag/age_verification //are we using the automated age verification which asks users if they're 18+?
	config_entry_value = TRUE

/datum/config_entry/flag/irc_first_connection_alert	// do we notify the irc channel when somebody is connecting for the first time?

/datum/config_entry/flag/check_randomizer

/datum/config_entry/string/ipintel_email

/datum/config_entry/string/ipintel_email/ValidateAndSet(str_val)
	return str_val != "ch@nge.me" && ..()

/datum/config_entry/number/ipintel_rating_bad
	config_entry_value = 1
	integer = FALSE
	min_val = 0
	max_val = 1

/datum/config_entry/number/ipintel_save_good
	config_entry_value = 12
	min_val = 0

/datum/config_entry/number/ipintel_save_bad
	config_entry_value = 1
	min_val = 0

/datum/config_entry/string/ipintel_domain
	config_entry_value = "check.getipintel.net"

/datum/config_entry/flag/aggressive_changelog

/datum/config_entry/flag/allow_webclient

/datum/config_entry/flag/webclient_only_byond_members

/datum/config_entry/number/client_warn_version
	config_entry_value = null
	min_val = 500

/datum/config_entry/number/client_warn_version
	config_entry_value = null
	min_val = 500

/datum/config_entry/string/client_warn_message
	config_entry_value = "Your version of byond may have issues or be blocked from accessing this server in the future."

/datum/config_entry/flag/client_warn_popup

/datum/config_entry/number/client_error_version
	config_entry_value = null
	min_val = 500

/datum/config_entry/string/client_error_message
	config_entry_value = "Your version of byond is too old, may have issues, and is blocked from accessing this server."

/datum/config_entry/number/client_error_build
	config_entry_value = null
	min_val = 0

/datum/config_entry/number/soft_popcap
	config_entry_value = null
	min_val = 0

/datum/config_entry/number/hard_popcap
	config_entry_value = null
	min_val = 0

/datum/config_entry/number/extreme_popcap
	config_entry_value = null
	min_val = 0

/datum/config_entry/string/soft_popcap_message
	config_entry_value = "Be warned that the server is currently serving a high number of users, consider using alternative game servers."

/datum/config_entry/string/hard_popcap_message
	config_entry_value = "The server is currently serving a high number of users, You cannot currently join. You may wait for the number of living crew to decline, observe, or find alternative servers."

/datum/config_entry/string/extreme_popcap_message
	config_entry_value = "The server is currently serving a high number of users, find alternative servers."
