/obj/machinery/atmospherics/component/binary
	icon = 'icons/obj/atmospherics/component/binary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	use_power = IDLE_POWER_USE
	device_type = BINARY
	layer = GAS_PUMP_LAYER

/obj/machinery/atmospherics/component/binary/SetInitDirections()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/component/binary/hide(intact)
	update_icon()
	..()

/obj/machinery/atmospherics/component/binary/getNodeConnects()
	return list(turn(dir, 180), dir)
