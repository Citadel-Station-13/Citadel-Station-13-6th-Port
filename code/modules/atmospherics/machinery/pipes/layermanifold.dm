/**
 * Layer manifolds
 * Connects every layer together.
 */

/obj/machinery/atmospherics/pipe/layer_manifold
	name = "layer adaptor"
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifoldlayer"
	desc = "A special pipe to bridge pipe layers with."
	dir = SOUTH
	initialize_directions = NORTH|SOUTH
	pipe_flags = PIPE_ALL_LAYER | PIPE_DEFAULT_LAYER_ONLY | PIPE_CARDINAL_AUTONORMALIZE
	pipe_layer = PIPE_LAYER_DEFAULT
	device_type = 0
	volume = 260
	construction_type = /obj/item/pipe/binary
	pipe_state = "manifoldlayer"

/obj/machinery/atmospherics/pipe/layer_manifold/Initialize()
	icon_state = "manifoldlayer_center"
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/update_overlays()
	. = ..()
	for(var/i in 1 to connected.len)
		if(!connected[i])
			continue
		. += add_attached_images(connected[i])

/obj/machinery/atmospherics/pipe/layer_manifold/update_layer()
	layer = initial(layer) + (PIPE_LAYER_MAX * PIPE_LAYER_LCHANGE)	//This is above everything else.

/obj/machinery/atmospherics/pipe/layer_manifold/proc/add_attached_images(obj/machinery/atmospherics/A)
	. = list()
	if(!A)
		return
	if(istype(A, /obj/machinery/atmospherics/pipe/layer_manifold))
		for(var/i in PIPE_LAYER_MIN to PIPE_LAYER_MAX)
			. += add_attached_image(get_dir(src, A), i)
			return
	. += add_attached_image(get_dir(src, A), A.pipe_layer, A.pipe_color)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/add_attached_image(p_dir, p_layer, p_color = null)
	var/image/I

	if(p_color)
		I = getpipeimage(icon, "pipe", p_dir, p_color, pipe_layer = pipe_layer)
	else
		I = getpipeimage(icon, "pipe", p_dir, pipe_layer = pipe_layer)

	I.layer = layer - 0.01
	PIPE_LAYER_SHIFT(I, p_layer)
	. = I

/obj/machinery/atmospherics/pipe/layer_manifold/SetInitDirections()
	switch(dir)
		if(NORTH || SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, dir)
	if(initialize_directions & dir)
		return ..()
	if((NORTH|EAST) & dir)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer + 1, PIPE_LAYER_MIN, PIPE_LAYER_MAX)
	if((SOUTH|WEST) & dir)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer - 1, PIPE_LAYER_MIN, PIPE_LAYER_MAX)
	to_chat(user, "You align yourself with the [user.ventcrawl_layer]\th output.")
