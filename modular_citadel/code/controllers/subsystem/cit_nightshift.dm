/obj/machinery/light
	var/obeysnightshift = FALSE
	var/nightshift = FALSE

/obj/machinery/light/Initialize()
	. = ..()
	var/area/a = get_area(src)
	if(a.type in GLOB.the_station_areas)
		obeysnightshift = TRUE
		SSnightshift.nightlights += src

/obj/machinery/light/Destroy()
	if(obeysnightshift && src in SSnightshift.nightlights)
		SSnightshift.nightlights -= src
	. = ..()

SUBSYSTEM_DEF(nightshift)
	name = "Night shift"
	wait = 3000
	flags = SS_BACKGROUND

	var/nightshift = FALSE
	var/nightshift_light_power = 0.4
	var/nightshift_light_color = "#FFCCBB"

	var/list/nightlights = list()

/datum/controller/subsystem/nightshift/Initialize()
	if(CONFIG_GET(flag/nightshift_enabled))
		var/nighttime = text2num(time2text(world.timeofday,"hh"))
		if((nighttime >= CONFIG_GET(number/nightshift_start)) || (nighttime <= CONFIG_GET(number/nightshift_finish) && !nightshift))
			nightshift = TRUE
	. = ..()

/datum/controller/subsystem/nightshift/fire(resumed = 0)
	if(CONFIG_GET(flag/nightshift_enabled))
		var/nighttime = text2num(time2text(world.timeofday,"hh"))
		if((nighttime >= CONFIG_GET(number/nightshift_start)) || (nighttime <= CONFIG_GET(number/nightshift_finish) && !nightshift))
			nightshift = TRUE
			for(var/obj/machinery/light/nightlight in nightlights)
				if(nightlight)
					nightlight.update(FALSE)
		else if(nightshift)
			nightshift = FALSE
			for(var/obj/machinery/light/nightlight in nightlights)
				if(nightlight)
					nightlight.update(FALSE)
