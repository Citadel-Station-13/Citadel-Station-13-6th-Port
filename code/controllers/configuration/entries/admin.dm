/datum/config_entry/flag/admin_legacy_system	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/protect_legacy_admins	//Stops any admins loaded by the legacy system from having their rank edited by the permissions panel
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/protect_legacy_ranks	//Stops any ranks loaded by the legacy system from having their flags edited by the permissions panel
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/enable_localhost_rank	//Gives the !localhost! rank to any client connecting from 127.0.0.1 or ::1
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/load_legacy_ranks_only	//Loads admin ranks only from legacy admin_ranks.txt, while enabled ranks are mirrored to the database
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/mentors_mobname_only

/datum/config_entry/flag/mentor_legacy_system	//Defines whether the server uses the legacy mentor system with mentors.txt or the SQL system
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/forbid_singulo_possession

/datum/config_entry/flag/see_own_notes	//Can players see their own admin notes

/datum/config_entry/number/note_fresh_days
	config_entry_value = null
	min_val = 0
	integer = FALSE

/datum/config_entry/number/note_stale_days
	config_entry_value = null
	min_val = 0
	integer = FALSE

/datum/config_entry/flag/autoconvert_notes	//if all connecting player's notes should attempt to be converted to the database
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/announce_admin_logout

/datum/config_entry/flag/announce_admin_login

/datum/config_entry/string/centcom_ban_db	// URL for the CentCom Galactic Ban DB API

/datum/config_entry/flag/autoadmin  // if autoadmin is enabled
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/autoadmin_rank	// the rank for autoadmins
	config_entry_value = "Game Master"
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/allow_admin_ooccolor	// Allows admins with relevant permissions to have their own ooc colour

/datum/config_entry/flag/popup_admin_pm	// adminPMs to non-admins show in a pop-up 'reply' window when set

/datum/config_entry/flag/guest_jobban

/datum/config_entry/flag/ban_legacy_system	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system.
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/guest_ban

/datum/config_entry/flag/automute_on	//enables automuting/spam prevention

/datum/config_entry/flag/debug_admin_hrefs
