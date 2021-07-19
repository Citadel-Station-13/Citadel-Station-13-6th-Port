/**
 * Pressure shielding, thickmaterial, etc.
 * Most of the time, rigs won't have this be able to be swapped out.
 */
/obj/item/rig_component/pressure_shielding
	name = "unnamed pressure module"
	desc = "Suspicious"
	rig_zone = RIG_ZONE_ALL
	/// Stops pressure damage
	var/pressure_immune = TRUE
	/// Allows internal usage
	var/allow_internals = TRUE
	/// Thickmaterial - blocks syringe guns and similar
	var/thick_material = TRUE
	/// Blocks gas smoke effect even if user isn't on internals
	var/block_gas_smoke_effect = TRUE

/obj/item/rig_component/pressure_shielding/on_attach(obj/item/rig/rig, rig_creation = fALSE)
	rig.update_pressure_module()
