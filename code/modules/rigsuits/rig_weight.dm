/**
 * Updates the rigsuit's weight.
 */
/obj/item/rig/proc/update_weight()
	var/old = weight
	weight = innate_weight

	for(var/i in modules)
		var/obj/item/rig_component/C = i
		weight += C.weight
	weight += installed_armor?.weight
	weight += installed_pressure_shielding?.weight
	weight += installed_thermal_shielding?.weight
	if(old != weight)
		update_slowdown()
