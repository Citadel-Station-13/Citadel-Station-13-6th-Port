/**
 * Gets the armor datum applied to wearers
 */
/obj/item/rig/proc/get_user_armor()
	return installed_armor? installed_armor.user_protection : getArmor()

/**
 * Gets the armor datum applied to rig damage
 */
/obj/item/rig/proc/get_suit_armor()
	return installed_armor? installed_armor.rig_protection : getArmor()

/**
 * Gets heat protection temp
 */
/obj/item/rig/proc/get_heat_shielding()
	return installed_thermal_shielding?.max_heat_protection_temperature

/**
 * Gets cold protection temp
 */
/obj/item/rig/proc/get_cold_shielding()
	return installed_thermal_shielding?.min_cold_protection_temperature

/**
 * Gets if we're pressure shielded
 */
/obj/item/rig/proc/is_pressure_shielded()
	return installed_pressure_shielding?.pressure_immune

/**
 * Gets if we're thickmaterial
 */
/obj/item/rig/proc/is_thick_material()
	return installed_pressure_shielding?.thick_material

/**
 * Gets if we should block gas smoke effects
 */
/obj/item/rig/proc/is_gas_smoke_shielded()
	return installed_pressure_shielding?.block_gas_smoke_effect

/**
 * Gets if we allow internals usage without mask
 */
/obj/item/rig/proc/is_internals_allowed()
	return installed_pressure_shielding?.allow_internals
