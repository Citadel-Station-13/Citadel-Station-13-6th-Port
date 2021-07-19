/// Seconds for CMD on defib-with-memory-loss policy config to display instead of defib-intact config
/datum/config_entry/number/defib_cmd_time_limit
	config_entry_value = 300
	integer = TRUE

/datum/config_entry/keyed_list/policy
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_TEXT

/datum/config_entry/keyed_list/policy/preprocess_key(key)
	return uppertext(..())
