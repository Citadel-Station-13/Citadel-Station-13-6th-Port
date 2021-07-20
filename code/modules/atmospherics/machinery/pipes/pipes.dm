/obj/machinery/atmospherics/pipe
	/// Temporarily stores air while rebuilding pipeline
	var/datum/gas_mixture/air_temporary
	/// Our volume. Null for default.
	var/volume
	/// The pipeline we belong to, if any
	var/datum/pipeline/pipeline

	level = 1

	use_power = NO_POWER_USE
	can_unwrench = 1

	//Buckling
	can_buckle = 1
	buckle_requires_restraints = 1
	buckle_lying = -1

/obj/machinery/atmospherics/pipe/InitAtmos()
	if(isnull(volume))
		volume = 35 * device_type
	. = ..()
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	var/turf/T = loc
	hide(T.intact)

/obj/machinery/atmospherics/pipe/Teardown()
	if(pipeline)
		QDEL_NULL(pipeline)

/obj/machinery/atmospherics/pipe/Build()
	if(!pipeline)
		pipeline = new
		pipeline.build_pipeline(src)

/obj/machinery/atmospherics/pipe/DirectConnection(datum/pipeline/querying, obj/machinery/atmospherics/source)
	. = list()
	for(var/i in 1 to connected.len)
		if(connected[i])
			. += connected[i]

/obj/machinery/atmospherics/pipe/hide(i)
	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/machinery/atmospherics/pipe/ReleaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)
		air_update_turf()

/obj/machinery/atmospherics/pipe/return_air()
	return pipeline.air

/obj/machinery/atmospherics/pipe/remove_air(amount)
	return pipeline.air.remove(amount)

/obj/machinery/atmospherics/pipe/remove_air_ratio(ratio)
	return pipeline.air.remove_ratio(ratio)

/obj/machinery/atmospherics/pipe/ReplacePipeline(datum/pipeline/old, datum/pipeline/replacing)
	if(pipeline != old)
		stack_trace("Tried to replace pipeline on [src] ([COORD(src)]) but old didn't match. Real: [pipeline]. Old: [old]")
	pipeline = replacing

/obj/machinery/atmospherics/pipe/SetPipeline(datum/pipeline/setting, obj/machinery/atmospherics/source)
	pipeline = setting

/obj/machinery/atmospherics/pipe/NullifyPipeline(datum/pipeline/removing)
	if(removing != pipeline)
		stack_trace("Tried to nullify pipelinie on [src] ([COORD(src)]) but old didn't match. Real: [pipeline]. Old: [removing]")
	pipeline = null

/obj/machinery/atmospherics/pipe/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = W
		user.dropItemToGround(meter)
		meter.setAttachLayer(pipe_layer)
	else
		return ..()

/obj/machinery/atmospherics/pipe/analyzer_act(mob/living/user, obj/item/I)
	atmosanalyzer_scan(pipeline.air, user, src)
	return TRUE

/obj/machinery/atmospherics/pipe/Destroy()
	ReleaseAirToTurf()
	if(air_temporary)
		QDEL_NULL(air_temporary)
	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)
	return ..()

/obj/machinery/atmospherics/pipe/update_alpha()
	alpha = invisibility ? 64 : 255

/obj/machinery/atmospherics/pipe/ReturnPipelines()
	. = ..()
	if(pipeline)
		. += pipeline

/obj/machinery/atmospherics/pipe/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 12)
		return 0
	. = ..()

/obj/machinery/atmospherics/pipe/proc/paint(paint_color)
	add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
	pipe_color = paint_color
	UpdateConnectedIcons()
	return TRUE

/obj/machinery/atmospherics/pipe/attack_ghost(mob/dead/observer/O)
	. = ..()
	if(pipeline)
		atmosanalyzer_scan(pipeline.air, O, src, FALSE)
	else
		to_chat(O, "<span class='warning'>[src] doesn't have a pipenet, which is probably a bug.</span>")
