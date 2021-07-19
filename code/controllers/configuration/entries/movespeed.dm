/datum/config_entry/keyed_list/multiplicative_movespeed
	key_mode = KEY_MODE_TYPE
	value_mode = VALUE_MODE_NUM
	abstract_type = /datum/config_entry/keyed_list/multiplicative_movespeed

/datum/config_entry/keyed_list/multiplicative_movespeed/ValidateAndSet()
	. = ..()
	if(.)
		update_config_movespeed_type_lookup(TRUE)

/datum/config_entry/keyed_list/multiplicative_movespeed/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_config_movespeed_type_lookup(TRUE)

/datum/config_entry/keyed_list/multiplicative_movespeed/normal
	name = "multiplicative_movespeed"
	config_entry_value = list(			//DEFAULTS
	/mob/living/simple_animal = 1,
	/mob/living/silicon/pai = 1,
	/mob/living/carbon/alien/humanoid/sentinel = 0.25,
	/mob/living/carbon/alien/humanoid/drone = 0.5,
	/mob/living/carbon/alien/humanoid/royal/praetorian = 1,
	/mob/living/carbon/alien/humanoid/royal/queen = 3
	)

/datum/config_entry/keyed_list/multiplicative_movespeed/floating
	name = "multiplicative_movespeed_floating"
	config_entry_value = list(
		/mob/living = 0,
		/mob/living/carbon/alien/humanoid = 0,
		/mob/living/carbon/alien/humanoid/royal/praetorian = 0,
		/mob/living/carbon/alien/humanoid/royal/queen = 2
	)

/datum/config_entry/number/movedelay	//Used for modifying movement speed for mobs.
	abstract_type = /datum/config_entry/number/movedelay
	integer = FALSE

/datum/config_entry/number/movedelay/ValidateAndSet()
	. = ..()
	if(.)
		update_mob_config_movespeeds()

/datum/config_entry/number/movedelay/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && (var_name == NAMEOF(src, config_entry_value)))
		update_mob_config_movespeeds()

/datum/config_entry/number/movedelay/run_delay

/datum/config_entry/number/movedelay/run_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/run)
	M.sync()

/datum/config_entry/number/movedelay/walk_delay

/datum/config_entry/number/movedelay/walk_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/walk)
	M.sync()

/datum/config_entry/flag/sprint_enabled
	config_entry_value = TRUE

/datum/config_entry/flag/sprint_enabled/ValidateAndSet(str_val)
	. = ..()
	for(var/datum/hud/human/H)
		H.assert_move_intent_ui()
	if(!config_entry_value)		// disabled
		for(var/mob/living/L in world)
			L.disable_intentional_sprint_mode()

/datum/config_entry/number/sprintless_stagger_slowdown
	config_entry_value = 0

/datum/config_entry/number/sprintless_off_balance_slowdown
	config_entry_value = 0.85

/datum/config_entry/number/melee_stagger_factor
	config_entry_value = 1

/datum/config_entry/number/movedelay/sprint_speed_increase
	config_entry_value = 1

/datum/config_entry/number/movedelay/sprint_max_tiles_increase
	config_entry_value = 5

/datum/config_entry/number/movedelay/sprint_absolute_max_tiles
	config_entry_value = 13

/datum/config_entry/number/movedelay/sprint_buffer_max
	config_entry_value = 24

/datum/config_entry/number/movedelay/sprint_stamina_cost
	config_entry_value = 1.4

/datum/config_entry/number/movedelay/sprint_buffer_regen_per_ds
	config_entry_value = 0.4

/////////////////////////////////////////////////Outdated move delay
/datum/config_entry/number/outdated_movedelay
	deprecated_by = /datum/config_entry/keyed_list/multiplicative_movespeed/normal
	abstract_type = /datum/config_entry/number/outdated_movedelay

	var/movedelay_type

/datum/config_entry/number/outdated_movedelay/DeprecationUpdate(value)
	return "[movedelay_type] [value]"

/datum/config_entry/number/outdated_movedelay/human_delay
	movedelay_type = /mob/living/carbon/human
/datum/config_entry/number/outdated_movedelay/robot_delay
	movedelay_type = /mob/living/silicon/robot
/datum/config_entry/number/outdated_movedelay/monkey_delay
	movedelay_type = /mob/living/carbon/monkey
/datum/config_entry/number/outdated_movedelay/alien_delay
	movedelay_type = /mob/living/carbon/alien
/datum/config_entry/number/outdated_movedelay/slime_delay
	movedelay_type = /mob/living/simple_animal/slime
/datum/config_entry/number/outdated_movedelay/animal_delay
	movedelay_type = /mob/living/simple_animal
/////////////////////////////////////////////////
