/datum/config_entry/keyed_list/breasts_cups_prefs
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG
	config_entry_value = list("a", "b", "c", "d", "e") //keep these lowercase

/datum/config_entry/number/penis_min_inches_prefs
	config_entry_value = 1
	min_val = 0

/datum/config_entry/number/penis_max_inches_prefs
	config_entry_value = 20
	min_val = 0

/datum/config_entry/keyed_list/safe_visibility_toggles
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG
	config_entry_value = list(GEN_VISIBLE_NO_CLOTHES, GEN_VISIBLE_NO_UNDIES, GEN_VISIBLE_NEVER) //refer to cit_helpers for all toggles.

//Body size configs, the feature will be disabled if both min and max have the same value.
/datum/config_entry/number/body_size_min
	config_entry_value = 0.9
	min_val = 0.1 //to avoid issues with zeros and negative values.
	max_val = RESIZE_DEFAULT_SIZE
	integer = FALSE

/datum/config_entry/number/body_size_max
	config_entry_value = 1.25
	min_val = RESIZE_DEFAULT_SIZE
	integer = FALSE

//Penalties given to characters with a body size smaller than this value,
//to compensate for their smaller hitbox.
//To disable, just make sure the value is lower than 'body_size_min'
/datum/config_entry/number/threshold_body_size_penalty
	config_entry_value = RESIZE_DEFAULT_SIZE
	min_val = 0
	max_val = RESIZE_DEFAULT_SIZE
	integer = FALSE

//multiplicative slowdown multiplier. See 'dna.update_body_size' for the operation.
//doesn't apply to floating or crawling mobs
/datum/config_entry/number/body_size_slowdown_multiplier
	config_entry_value = 0
	min_val = 0
	integer = FALSE
