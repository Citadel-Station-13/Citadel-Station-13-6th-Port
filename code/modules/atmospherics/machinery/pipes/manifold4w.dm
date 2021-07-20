/**
 * 4 way manifolds.
 */

/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-2"

	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes."

	initialize_directions = NORTH|SOUTH|EAST|WEST

	device_type = QUATERNARY

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"

	var/mutable_appearance/center

/obj/machinery/atmospherics/pipe/manifold4w/Initialize()
	icon_state = ""
	center = mutable_appearance(icon, "manifold4w_center")
	return ..()

/obj/machinery/atmospherics/pipe/manifold4w/SetInitDirections()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/manifold4w/update_overlays()
	. = ..()
	PIPE_LAYER_DOUBLE_SHIFT(center, pipe_layer)
	. += center
	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(connected[i])
			. += getpipeimage(icon, "pipe-[pipe_layer]", get_dir(src, connected[i]))
