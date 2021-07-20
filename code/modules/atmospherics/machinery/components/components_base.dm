// So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
// On top of that, now people can add component-speciic procs/vars if they want!

/obj/machinery/atmospherics/component
	/// Welded vents/scrubbers
	var/welded = FALSE
	// Air movement calculations
	// Not all components will use these, but they're pretty much standard.
	/// Maximum power rating - maximum power it can draw for operations in watts.
	var/power_rating = ATMOSMECH_POWER_RATING
	/// Current power rating - defaults to max
	var/power_setting = ATMOSMECH_POWER_RATING
	/// Max operating pressure - cannot pressurize above this, but can accept above this
	var/max_pressure = ATMOSMECH_PUMP_PRESSURE
	/// Current pressure setting - defaults to max
	var/pressure_setting = ATMOSMECH_PUMP_PRESSURE
	/// Max operating rate - cannot pump faster than this (L/s)
	var/max_rate = ATMOSMECH_PUMP_RATE
	/// Current rate setting - defaults to max
	var/rate_setting = ATMOSMECH_PUMP_RATE
	/// Efficiency multiplier
	var/power_efficiency = 1
	/// Minimum volume to move per second before it gives up
	var/futile_rate = ATMOSMECH_FUTILE_PUMP_RATE
	/// Below this in moles, anything left is instantly moved. This ensures you can't require infinite power to drain something.
	var/moles_to_instant_pump = ATMOSMECH_INSTANT_PUMP_MOLES
	/// Below this in pressure, anything left is instantly moved. This ensures you can't require infinite power to drain something.
	var/pressure_to_instant_pump = ATMOSMECH_INSTANT_PUMP_PRESSURE
	/// Last flow rate, set by gas transfer procs [code/modules/atmospherics/gasmixtures/transfer_helpers.dm]. Has different contexts based on what proc you used.
	var/last_transfer_rate
	/// Last power usage, set by gas transfer procs [code/modules/atmospherics/gasmixtures/transfer_helpers.dm].
	/// Pipelines this belongs to. This should have the same indices as [connected]
	var/list/datum/pipeline/pipelines
	/// Gas mixtures we contain. This should have the same indices as [connected]
	var/list/datum/gas_mixture/airs
	/// Volume of each of our airs
	var/volume = 200

	var/showpipe = FALSE
	var/shift_underlay_only = TRUE //Layering only shifts underlay?

/obj/machinery/atmospherics/component/InitAtmos()
	pipelines = new /list(device_type)
	airs = new /list(device_type)
	for(var/i in 1 to device_type)
		airs[i] = new /datum/gas_mixture(volume)
	return ..()

// Iconnery

/obj/machinery/atmospherics/component/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/component/update_icon()
	update_icon_nopipes()

	underlays.Cut()

	var/turf/T = loc
	if(level == 2 || (istype(T) && !T.intact))
		showpipe = TRUE
		plane = ABOVE_WALL_PLANE
	else
		showpipe = FALSE
		plane = FLOOR_PLANE

	if(!showpipe)
		return //no need to update the pipes if they aren't showing

	var/connected = 0 //Direction bitset

	for(var/i in 1 to device_type) //adds intact pieces
		if(connected[i])
			var/obj/machinery/atmospherics/node = connected[i]
			var/image/img = get_pipe_underlay("pipe_intact", get_dir(src, node), node.pipe_color)
			underlays += img
			connected |= img.dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			underlays += get_pipe_underlay("pipe_exposed", direction)

	if(!shift_underlay_only)
		PIPE_LAYER_SHIFT(src, pipe_layer)

/obj/machinery/atmospherics/component/proc/get_pipe_underlay(state, dir, color = null)
	if(color)
		. = getpipeimage('icons/obj/atmospherics/component/binary_devices.dmi', state, dir, color, pipe_layer = shift_underlay_only ? pipe_layer : 2)
	else
		. = getpipeimage('icons/obj/atmospherics/component/binary_devices.dmi', state, dir, pipe_layer = shift_underlay_only ? pipe_layer : 2)

/obj/machinery/atmospherics/component/Teardown()
	for(var/i in 1 to pipelines.len)
		if(pipelines[i])
			QDEL_NULL(pipelines[i])

/obj/machinery/atmospherics/component/Build()
	for(var/i in 1 to pipelines.len)
		if(!pipelines[i])
			var/datum/pipeline/PL = new
			pipelines[i] = PL
			PL.build_pipeline(src)

/obj/machinery/atmospherics/component/NullifyPipeline(datum/pipeline/removing)
	var/index = pipelines.Find(removing)
	if(!index)
		CRASH("FATAL: NullifyPipeline could not find [removing] in [src] ([COORD(src)])")
	pipelines[index] = null

/obj/machinery/atmospherics/component/SetPipeline(datum/pipeline/setting, obj/machinery/atmospherics/source)
	// We want to set the pipeline index that corrosponds to the node order
	var/index = connected.Find(source)
	if(!index)
		CRASH("FATAL: SetPipeline could not find [source] in [src] ([COORD(src)])")
	pipelines[index] = setting

/obj/machinery/atmospherics/component/ReplacePipeline(datum/pipeline/old, datum/pipeline/replacing)
	var/index = pipelines.Find(old)
	if(!index)
		CRASH("FATAL: ReplacePipeline() could not find [old] in [src] ([COORD(src)])")
	pipelines[index] = replacing

/obj/machinery/atmospherics/component/DirectConnection(datum/pipeline/querying, obj/machinery/atmospherics/source)
	var/index = pipelines.Find(querying)
	if(!index)
		CRASH("FATAL: DirectConnection() could not find [querying] in [src] ([COORD(src)]). Source was [source]")
	. = list()
	if(connected[index])
		. += connected[index]

/**
 * Gets the air that corrosponds to a pipeline
 */
/obj/machinery/atmospherics/component/proc/ReturnPipenetAir(datum/pipeline/querying)
	var/index = pipelines.Find(querying)
	if(!index)
		CRASH("FATAL: ReturnPipenetAir() could not find [querying] in [src] ([COORD(src)])")
	return airs[index]

/obj/machinery/atmospherics/component/unsafe_pressure_release(var/mob/user, var/pressures)
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from airs and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = null
		var/times_lost = 0
		for(var/i in 1 to device_type)
			var/datum/gas_mixture/air = airs[i]
			lost += pressures*environment.return_volume()/(air.return_temperature() * R_IDEAL_GAS_EQUATION)
			times_lost++
		var/shared_loss = lost/times_lost

		for(var/i in 1 to device_type)
			var/datum/gas_mixture/air = airs[i]
			T.assume_air_moles(air, shared_loss)
		air_update_turf(1)

/obj/machinery/atmospherics/component/proc/safe_input(var/title, var/text, var/default_set)
	var/new_value = input(usr,text,title,default_set) as num
	if(usr.canUseTopic(src))
		return new_value
	return default_set

/obj/machinery/atmospherics/component/ReturnPipelines()
	. = list()
	for(var/datum/pipeline/PL in pipelines)
		. += PL

// Helpers

/**
 * Marks all pipelines as needing to update
 */
/obj/machinery/atmospherics/component/proc/MarkDirty()
	for(var/i in 1 to pipelines.len)
		var/datum/pipeline/PL = pipelines[i]
		if(!PL)
			stack_trace("[src] is missing a pipenet. Rebuilding.")
			QueueRebuild()
			return
		PL.update = TRUE

// UI Stuff

/obj/machinery/atmospherics/component/ui_status(mob/user)
	if(allowed(user))
		return ..()
	to_chat(user, "<span class='danger'>Access denied.</span>")
	return UI_CLOSE

/obj/machinery/atmospherics/component/attack_ghost(mob/dead/observer/O)
	. = ..()
	atmosanalyzer_scan(airs, O, src, FALSE)

// Standard ui_data
/obj/machinery/atmospherics/component/ui_static_data(mob/user)
	. = ..()
	.["power_max"] = power_rating
	.["pressure_max"] = max_pressure
	.["rate_max"] = max_rate

// Standard ui_data
/obj/machinery/atmospherics/component/ui_data(mob/user)
	. = ..()
	.["power_setting"] = power_setting
	.["pressure_setting"] = pressure_setting
	.["rate_setting"] = rate_setting
	.["power_current"] = last_power_draw
	.["rate_current"] = last_transfer_rate

// Tool acts

/obj/machinery/atmospherics/component/analyzer_act(mob/living/user, obj/item/I)
	atmosanalyzer_scan(airs, user, src)
	return TRUE
