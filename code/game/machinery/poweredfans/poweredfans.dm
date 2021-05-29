/obj/machinery/poweredfans
	icon = 'icons/obj/poweredfans.dmi'
	icon_state = "mfan_powered"
	name = "micro powered fan"
	desc = "A handmade fan, releasing a thin gust of air."
	use_power = ACTIVE_POWER_USE
	power_channel = AREA_USAGE_ENVIRON
	idle_power_usage = 5
	active_power_usage = 10
	max_integrity = 150
	layer = ABOVE_NORMAL_TURF_LAYER
	anchored = TRUE
	density = FALSE
	CanAtmosPass = ATMOS_PASS_NO
	var/obj/machinery/fan_assembly/assembly

/obj/machinery/poweredfans/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!assembly)
			assembly = new()
		assembly.forceMove(drop_location())
		assembly.construction_stat = FAN_CONSTRUCTION_WELDED
		assembly.set_anchored(TRUE)
		assembly = null
		new /obj/item/stack/cable_coil(loc, 2)
	qdel(src)

/obj/machinery/poweredfans/wirecutter_act(mob/living/user, obj/item/I)
	user.visible_message("<span class='warning'>[user] removes the wires from the [src].</span>",
		"<span class='notice'>You start to remove the wires from the [src]...</span>", "You hear clanking and banging noises.")
	if(I.use_tool(src, user, 30, volume=50))
		deconstruct()
	return TRUE

/obj/machinery/poweredfans/Initialize(mapload, obj/machinery/fan_assembly/FA)
	. = ..()
	if(FA)
		assembly = FA
	else
		assembly = new(src)
		assembly.construction_stat = FAN_CONSTRUCTION_WIRED
	air_update_turf(1)

/obj/machinery/poweredfans/power_change()
	..()
	if(powered())
		icon_state = "mfan_powered"
		CanAtmosPass = ATMOS_PASS_NO
		air_update_turf(TRUE)
	else
		icon_state = "mfan_unpowered"
		CanAtmosPass = ATMOS_PASS_YES
		air_update_turf(TRUE)
	update_icon_state()

