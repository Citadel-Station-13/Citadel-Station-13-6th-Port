#define ICE_SPECIFIC_HEAT 40 // joules/mole-kelvin
#define WATER_SPECIFIC_HEAT 75
#define WATER_ENTHALPY_OF_VAPORIZATION		0
#define WATER_ENTHALPY_OF_FUSION			6000

/datum/component/wetness
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	can_transfer = TRUE
	var/ice = 0
	var/water = 0
	var/ice_temp = T0C
	var/water_temp = T0C
	var/last_process = 0

/datum/component/wetness/Initialize(amt, new_temp)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	add_wet(amt,new_temp)
	START_PROCESSING(SSwet_floors, src)
	addtimer(CALLBACK(src, .proc/gc, TRUE), 1)
	last_process = world.time

/datum/component/wetness/Destroy()
	STOP_PROCESSING(SSwet_floors, src)
	..()

/datum/component/wetness/InheritComponent(datum/newcomp, orig, amt, new_temp)
	if(!newcomp)
		add_wet(amt,new_temp)
	else
		var/datum/component/wetness/WF = newcomp
		if(WF.gc())						//See if it's even valid, still. Also does LAZYLEN and stuff for us.
			CRASH("Wetness component tried to inherit another, but the other was able to garbage collect while being inherited! What a waste of time!")
		if(WF.ice)
			add_wet(WF.ice,WF.ice_temp)
		if(WF.water)
			add_wet(WF.water,WF.water_temp)

/datum/component/wetness/process()
	var/diff = (world.time - last_process) / SSwet_floors.time_ratio
	var/delta_temperature = water_temp - ice_temp
	var/water_cap = water * WATER_SPECIFIC_HEAT
	var/ice_cap = ice * ICE_SPECIFIC_HEAT
	var/heat_transfer = 0.1 * delta_temperature * diff * ((ice_cap * water_cap) / (ice_cap + water_cap))
	if(water_cap)
		water_temp -= heat_transfer / water_cap
	if(ice_cap)
		ice_temp += heat_transfer / ice_cap
	var/atom/A = parent
	var/datum/gas_mixture/air = A.return_air()
	if(istype(air))
		if(water_cap)
			water_temp = air.temperature_share(null, min(0.05 * diff, 0.4), water_temp, water_cap)
		if(ice_cap)
			ice_temp = air.temperature_share(null, min(0.05 * diff, 0.4), ice_temp, ice_cap)
	if(water_temp < T0C)
		var/amount_frozen = clamp(((T0C - water_temp) * water_cap) / WATER_ENTHALPY_OF_FUSION, 0, water)
		water_temp = T0C
		water -= amount_frozen
		ice += amount_frozen
	if(ice_temp > T0C)
		var/amount_melted = clamp(((ice_temp - T0C) * ice_cap) / WATER_ENTHALPY_OF_FUSION, 0, ice)
		ice_temp = T0C
		water += amount_melted
		ice -= amount_melted
	if(istype(air))
		var/T = water_temp - T0C
		var/saturation_pressure = 0
		// approximation of the arden buck equation https://en.wikipedia.org/wiki/Arden_Buck_equation
		switch(T)
			if(-INFINITY to 0)
				saturation_pressure = 0
			if(0 to 25)
				saturation_pressure = T * 0.1 + 0.6
			if(25 to 50)
				saturation_pressure = T * 0.4 - 6.9
			if(50 to 75)
				saturation_pressure = T - 36.9
			if(75 to INFINITY)
				saturation_pressure = T * 2.55 - 153.15

		// the pressure of water vapor in the air; not relative humidity, but relative humidity makes less sense in space
		var/vapor_pp = air.return_pressure() * (air.get_moles(/datum/gas/water_vapor) / air.total_moles())
		// divided arbitrarily by 64 so it looks nice, clamped by the amount of vapor in the air and water in the atom
		var/evaporated_amt = clamp((saturation_pressure - vapor_pp)*air.return_volume()/(air.return_temperature() * R_IDEAL_GAS_EQUATION),-air.get_moles(/datum/gas/water_vapor), water)
		// evaporation/condensation absorb/release heat respectively, so this does that
		air.set_moles(/datum/gas/water_vapor, air.get_moles(/datum/gas/water_vapor) + evaporated_amt)
		water -= evaporated_amt
	if(isopenturf(parent))
		var/turf/open/T = parent
		if(water > MOLES_GAS_VISIBLE)
			T.MakeSlippery(TURF_WET_WATER, 5 SECONDS, 2 SECONDS, permanent = TRUE)
		else
			T.MakeDry(TURF_WET_WATER, TRUE, 10 SECONDS)
		if(ice > MOLES_GAS_VISIBLE)
			T.MakeSlippery(TURF_WET_ICE, 5 SECONDS, 2 SECONDS, permanent = TRUE)
		else
			T.MakeDry(TURF_WET_ICE, TRUE, 10 SECONDS)
	gc()

/datum/component/wetness/proc/add_wet(amt, new_temp)
	if(new_temp <= T0C)
		var/heat = ice * ICE_SPECIFIC_HEAT * ice_temp
		var/new_heat = amt * ICE_SPECIFIC_HEAT * new_temp
		ice += amt
		ice_temp = (heat + new_heat) / (ICE_SPECIFIC_HEAT * ice)
	else
		var/heat = water * WATER_SPECIFIC_HEAT * water_temp
		var/new_heat = amt * WATER_SPECIFIC_HEAT * new_temp
		water += amt
		water_temp = (heat + new_heat) / (WATER_SPECIFIC_HEAT * water)

/datum/component/wetness/proc/gc()
	if(ice < 0.001 && water < 0.001)
		qdel(src)
		return TRUE
	return FALSE
