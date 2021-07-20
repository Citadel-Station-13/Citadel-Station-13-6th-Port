/* Automatically places pipes on init based on any pipes connecting to it and adjacent helpers. Only supports cardinals.
 * Conflicts with ANY PIPE ON ITS LAYER, as well as atmos network build helpers on the same layer, as well as any pipe on all layers. Do those manually.
*/
/obj/effect/mapping_helpers/network_builder/atmos_pipe
	name = "atmos pipe autobuilder"
	icon_state = "atmospipebuilder"

	/// Layer to put our pipes on
	var/pipe_layer = PIPE_LAYER_DEFAULT

	/// Color to set our pipes to
	var/pipe_color

	/// Whether or not pipes we make are visible
	var/visible_pipes = FALSE

	color = null

/obj/effect/mapping_helpers/network_builder/atmos_pipe/check_duplicates()
	for(var/obj/effect/mapping_helpers/network_builder/atmos_pipe/other in loc)
		if(other == src)
			continue
		if(other.pipe_layer == pipe_layer)
			return other
	for(var/obj/machinery/atmospherics/A in loc)
		if(A.pipe_flags & PIPE_ALL_LAYER)
			return A
		if(A.pipe_layer == pipe_layer)
			return A
	return FALSE

/// Scans directions, sets network_directions to have every direction that we can link to. If there's another power cable builder detected, make sure they know we're here by adding us to their cable directions list before we're deleted.
/obj/effect/mapping_helpers/network_builder/atmos_pipe/scan_directions()
	var/turf/T
	for(var/i in GLOB.cardinals)
		if(i in network_directions)
			continue				//we're already set, that means another builder set us.
		T = get_step(loc, i)
		if(!T)
			continue
		var/found = FALSE
		for(var/obj/effect/mapping_helpers/network_builder/atmos_pipe/other in T)
			if(other.pipe_layer == pipe_layer)
				network_directions += i
				other.network_directions += turn(i, 180)
				found = TRUE
				break
		if(found)
			continue
		for(var/obj/machinery/atmospherics/A in T)
			if((A.pipe_layer == pipe_layer) && (A.initialize_directions & turn(i, 180)))
				network_directions += i
				break
	return network_directions

/// Directions should only ever have cardinals.
/obj/effect/mapping_helpers/network_builder/atmos_pipe/build_network()
	if(length(network_directions) <= 1)
		return
	var/obj/machinery/atmospherics/pipe/built
	switch(length(network_directions))
		if(2)		//straight pipe
			built = new /obj/machinery/atmospherics/pipe/simple(loc)
			var/d1 = network_directions[1]
			var/d2 = network_directions[2]
			var/combined = d1 | d2
			if(combined in GLOB.diagonals)
				built.setDir(combined)
			else
				built.setDir(d1)
		if(3)		//manifold
			var/list/missing = network_directions ^ GLOB.cardinals
			missing = missing[1]
			built = new /obj/machinery/atmospherics/pipe/manifold(loc)
			built.setDir(missing)
		if(4)		//4 way manifold
			built = new /obj/machinery/atmospherics/pipe/manifold4w(loc)
	built.SetInitDirections()
	built.on_construction(pipe_color, pipe_layer)
	built.hide(!visible_pipes)

/obj/effect/mapping_helpers/network_builder/atmos_pipe/distro
	name = "distro line autobuilder"
	pipe_layer = PIPE_LAYER_MIN
	pixel_x = -PIPE_LAYER_P_X
	pixel_y = -PIPE_LAYER_P_Y
	pipe_color = rgb(130,43,255)
	color = rgb(130,43,255)

/obj/effect/mapping_helpers/network_builder/atmos_pipe/scrubbers
	name = "scrubbers line autobuilder"
	pipe_layer = PIPE_LAYER_MAX
	pixel_x = PIPE_LAYER_P_X
	pixel_y = PIPE_LAYER_P_Y
	pipe_color = rgb(255,0,0)
	color = rgb(255,0,0)
