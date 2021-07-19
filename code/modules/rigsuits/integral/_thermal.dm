/**
 * Thermal shielding modules
 * Holds maximum shielding for clothing items in regards to cold and heat.
 */
/obj/item/rig_component/thermal_shielding
	name = "unnamed thermal module"
	desc = "Suspicious"
	rig_zone = RIG_ZONE_ALL
	/// Minimum cold protection temperature.
	cold_protection = SPACE_HELM_MIN_TEMP_PROTECT
	/// Maximum heat protection temperature
	heat_protection = SPACE_HELM_MAX_TEMP_PROTECT

/obj/item/rig_component/thermal_shielding/on_attach(obj/item/rig/rig, rig_creation = fALSE)
	rig.update_thermal_module()
