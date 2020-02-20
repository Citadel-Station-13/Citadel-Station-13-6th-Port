/turf
	//used for temperature calculations
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1
	var/temperature_archived

	//list of open turfs adjacent to us
	var/list/atmos_adjacent_turfs
	//bitfield of dirs in which we are superconducitng
	var/atmos_superconductivity = NONE

	//used to determine whether we should archive
	var/archived_cycle = 0
	var/current_cycle = 0

	//used for mapping and for breathing while in walls (because that's a thing that needs to be accounted for...)
	//string parsed by /datum/gas/proc/copy_from_turf
	var/initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	//approximation of MOLES_O2STANDARD and MOLES_N2STANDARD pending byond allowing constant expressions to be embedded in constant strings
	// If someone will place 0 of some gas there, SHIT WILL BREAK. Do not do that.

/turf/open
	//used for spacewind
	var/pressure_difference = 0
	var/pressure_direction = 0

	var/datum/excited_group/excited_group
	var/excited = FALSE
	var/datum/gas_mixture/turf/air

	//used to artificially slow down equalization
	var/last_equalize = 0
	var/obj/effect/hotspot/active_hotspot
	var/planetary_atmos = FALSE //air will revert to initial_gas_mix over time

	var/list/atmos_overlay_types //gas IDs of current active gas overlays

/turf/open/Initialize()
	if(!blocks_air)
		air = new
		air.copy_from_turf(src)
	. = ..()

/turf/open/Destroy()
	if(active_hotspot)
		QDEL_NULL(active_hotspot)
	// Adds the adjacent turfs to the current atmos processing
	for(var/T in atmos_adjacent_turfs)
		SSair.add_to_active(T)
	return ..()

/////////////////GAS MIXTURE PROCS///////////////////

/turf/open/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	if(!giver)
		return FALSE
	air.merge(giver)
	update_visuals()
	return TRUE

/turf/open/remove_air(amount)
	var/datum/gas_mixture/ours = return_air()
	var/datum/gas_mixture/removed = ours.remove(amount)
	update_visuals()
	return removed

/turf/open/proc/copy_air_with_tile(turf/open/T)
	if(istype(T))
		var/datum/gas_mixture/T_air = T.air
		COPY_GAS_FROM_TO(air,T_air)

/turf/open/proc/copy_air(datum/gas_mixture/copy)
	if(copy)
		COPY_GAS_FROM_TO(air,copy)

/turf/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	var/datum/gas_mixture/GM = new
	GM.copy_from_turf(src)
	return GM

/turf/open/return_air()
	RETURN_TYPE(/datum/gas_mixture)
	return air

/turf/temperature_expose()
	if(temperature > heat_capacity)
		to_be_destroyed = TRUE

/turf/proc/archive()
	temperature_archived = temperature

/turf/open/archive()
	ARCHIVE_TEMPERATURE(air)
	archived_cycle = SSair.times_fired
	temperature_archived = temperature

/////////////////////////GAS OVERLAYS//////////////////////////////

/turf/open/proc/update_visuals()
	var/list/new_overlay_types = tile_graphic()
	var/list/atmos_overlay_types = src.atmos_overlay_types // Cache for free performance

	if (atmos_overlay_types)
		for(var/overlay in atmos_overlay_types-new_overlay_types) //doesn't remove overlays that would only be added
			vis_contents -= overlay

	if (length(new_overlay_types))
		if (atmos_overlay_types)
			vis_contents += new_overlay_types - atmos_overlay_types //don't add overlays that already exist
		else
			vis_contents += new_overlay_types

	UNSETEMPTY(new_overlay_types)
	src.atmos_overlay_types = new_overlay_types

/turf/open/proc/tile_graphic()
	var/static/list/nonoverlaying_gases = typecache_of_gases_with_no_overlays()
	if(!air)
		return
	. = new /list
	var/list/gases = air.gases
	for(var/id in gases)
		if (nonoverlaying_gases[id])
			continue
		var/gas = gases[id]
		var/gas_overlay = GLOB.meta_gas_overlays[id]
		if(gas_overlay && gas > GLOB.meta_gas_visibility[id])
			. += gas_overlay[min(FACTOR_GAS_VISIBLE_MAX, CEILING(gas / MOLES_GAS_VISIBLE_STEP, 1))]

/proc/typecache_of_gases_with_no_overlays()
	. = list()
	for (var/gastype in subtypesof(/datum/gas))
		var/datum/gas/gasvar = gastype
		if (!initial(gasvar.gas_overlay))
			.[gastype] = TRUE

/////////////////////////////SIMULATION///////////////////////////////////

/turf/proc/process_cell(fire_count)
	SSair.remove_from_active(src)

/turf/open/process_cell(fire_count,forced = FALSE)
	var/atmos_mix_tick_delay = SSair.atmos_mix_tick_delay
	var/atmos_mixed_tick_delay = (atmos_mix_tick_delay-SSair.atmos_mixed_tick_delay)
	if(!forced && ((fire_count - last_equalize) < atmos_mix_tick_delay))
		return
	if(archived_cycle < fire_count) //archive self if not already done
		archive()

	current_cycle = fire_count

	//cache for sanic speed
	var/list/adjacent_turfs = atmos_adjacent_turfs
	var/datum/excited_group/our_excited_group = excited_group
	var/adjacent_turfs_length = LAZYLEN(adjacent_turfs)

	var/planet_atmos = planetary_atmos
	var/datum/gas_mixture/our_air = air
	if (planet_atmos)
		air.copy_from_turf(src)
		SSair.remove_from_active(src)
		return

	var/should_share_air = FALSE
	for(var/t in adjacent_turfs)
		var/turf/open/enemy_tile = t

		if(fire_count <= enemy_tile.current_cycle)
			continue

	/******************* GROUP HANDLING START *****************************************************************/

		var/datum/gas_mixture/enemy_air = enemy_tile.air

		//cache for sanic speed
		var/datum/excited_group/enemy_excited_group = enemy_tile.excited_group

		if(our_excited_group && enemy_excited_group)
			if(our_excited_group != enemy_excited_group)
				//combine groups (this also handles updating the excited_group var of all involved turfs)
				our_excited_group.merge_groups(enemy_excited_group)
				our_excited_group = excited_group //update our cache
			should_share_air = TRUE

		else if(our_air.compare(enemy_air))
			if(!enemy_tile.excited)
				SSair.add_to_active(enemy_tile)
			var/datum/excited_group/EG = our_excited_group || enemy_excited_group || new
			if(!our_excited_group)
				EG.add_turf(src)
			if(!enemy_excited_group)
				EG.add_turf(enemy_tile)
			our_excited_group = excited_group
			should_share_air = TRUE

	if(should_share_air)
		var/datum/gas_mixture/final_air = new()
		var/lowest_pressure = -1
		var/highest_moles = -1
		var/lowest_moles = 2**64
		var/turf/open/lowest_pressure_tile
		var/datum/gas_mixture/our_copy = our_air.copy()
		MERGE_GASES(final_air,our_copy)
		var/are_we_spaced = FALSE
		for(var/t in adjacent_turfs)
			var/turf/open/enemy_tile = t
			var/datum/gas_mixture/enemy_air = enemy_tile.air
			if(istype(enemy_air, /datum/gas_mixture/immutable/space))
				are_we_spaced = enemy_air
				lowest_pressure_tile = enemy_tile
				break
			else
				var/pressure
				PRESSURE(enemy_air,pressure)
				var/molage
				TOTAL_MOLES(enemy_air,molage)
				if(pressure < lowest_pressure || lowest_pressure == -1)
					lowest_pressure = pressure
					lowest_pressure_tile = enemy_tile
				highest_moles = max(molage,highest_moles)
				lowest_moles = min(molage,lowest_moles)
				var/datum/gas_mixture/enemy_copy = enemy_air.copy()
				MERGE_GASES(final_air,enemy_copy)
		var/datum/gas_mixture/new_air
		if(are_we_spaced)
			var/datum/gas_mixture/space_air = are_we_spaced
			COPY_GAS_FROM_TO(space_air,new_air)
			new_air.temperature = final_air.temperature
		else
			new_air = (final_air.remove_ratio(1 / (adjacent_turfs_length + 1)))
		if(!istype(new_air)) // this can happen if this runs in space
			return
		GAS_GARBAGE_COLLECT(new_air)
		var/last_share = highest_moles-lowest_moles
		if(last_share > MINIMUM_AIR_TO_SUSPEND)
			our_excited_group.reset_cooldowns()
		else if(last_share > MINIMUM_MOLES_DELTA_TO_MOVE)
			our_excited_group.dismantle_cooldown = 0
		consider_pressure_difference(lowest_pressure_tile,air.return_pressure()-lowest_pressure)
		COPY_GAS_FROM_TO(our_air,new_air)
		update_visuals()
		for(var/t in adjacent_turfs)
			var/turf/open/enemy_tile = t
			var/enemy_pressure
			var/datum/gas_mixture/enemy_air = enemy_tile.air
			PRESSURE(enemy_air,enemy_pressure)
			var/difference = enemy_pressure - lowest_pressure
			COPY_GAS_FROM_TO(enemy_air,new_air)
			enemy_tile.last_equalize = max(enemy_tile.last_equalize,fire_count-atmos_mixed_tick_delay)
			enemy_tile.update_visuals()
			enemy_tile.consider_pressure_difference(lowest_pressure_tile, -difference)
			SSair.add_to_react_queue(enemy_tile)
		last_equalize = fire_count


	/******************* GROUP HANDLING FINISH *********************************************************************/


	SSair.add_to_react_queue(src)

	if((!our_excited_group && !(our_air.temperature > MINIMUM_TEMPERATURE_START_SUPERCONDUCTION && consider_superconductivity(starting = TRUE))))
		SSair.remove_from_active(src)

/turf/open/space/process_cell(fire_count) //dumb hack to prevent space pollution
	. = ..()
	var/datum/gas_mixture/immutable/I = space_gas
	I.after_process_cell()

/turf/proc/process_cell_reaction()
	SSair.remove_from_react_queue(src)

/turf/open/process_cell_reaction()
	air.react(src)
	update_visuals()
	SSair.remove_from_react_queue(src)
	return

//////////////////////////SPACEWIND/////////////////////////////

/turf/open/proc/consider_pressure_difference(turf/T, difference)
	SSair.high_pressure_delta |= src
	if(difference > pressure_difference)
		pressure_direction = get_dir(src, T)
		pressure_difference = difference

/turf/open/proc/high_pressure_movements()
	var/atom/movable/M
	for(var/thing in src)
		M = thing
		if (!M.anchored && !M.pulledby && M.last_high_pressure_movement_air_cycle < SSair.times_fired)
			M.experience_pressure_difference(pressure_difference, pressure_direction)

/atom/movable/var/pressure_resistance = 10
/atom/movable/var/last_high_pressure_movement_air_cycle = 0

/atom/movable/proc/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	var/const/PROBABILITY_OFFSET = 25
	var/const/PROBABILITY_BASE_PRECENT = 75
	var/max_force = sqrt(pressure_difference)*(MOVE_FORCE_DEFAULT / 5)
	set waitfor = 0
	var/move_prob = 100
	if (pressure_resistance > 0)
		move_prob = (pressure_difference/pressure_resistance*PROBABILITY_BASE_PRECENT)-PROBABILITY_OFFSET
	move_prob += pressure_resistance_prob_delta
	if (move_prob > PROBABILITY_OFFSET && prob(move_prob) && (move_resist != INFINITY) && (!anchored && (max_force >= (move_resist * MOVE_FORCE_PUSH_RATIO))) || (anchored && (max_force >= (move_resist * MOVE_FORCE_FORCEPUSH_RATIO))))
		step(src, direction)
		last_high_pressure_movement_air_cycle = SSair.times_fired

///////////////////////////EXCITED GROUPS/////////////////////////////

/datum/excited_group
	var/list/turf_list = list()
	var/breakdown_cooldown = 0
	var/dismantle_cooldown = 0

/datum/excited_group/New()
	SSair.excited_groups += src

/datum/excited_group/proc/add_turf(turf/open/T)
	turf_list += T
	T.excited_group = src
	reset_cooldowns()

/datum/excited_group/proc/merge_groups(datum/excited_group/E)
	if(turf_list.len > E.turf_list.len)
		SSair.excited_groups -= E
		for(var/t in E.turf_list)
			var/turf/open/T = t
			T.excited_group = src
			turf_list += T
		reset_cooldowns()
	else
		SSair.excited_groups -= src
		for(var/t in turf_list)
			var/turf/open/T = t
			T.excited_group = E
			E.turf_list += T
		E.reset_cooldowns()

/datum/excited_group/proc/reset_cooldowns()
	breakdown_cooldown = 0
	dismantle_cooldown = 0

//argument is so world start can clear out any turf differences quickly.
/datum/excited_group/proc/self_breakdown(space_is_all_consuming = FALSE)
	var/datum/gas_mixture/A = new

	//make local for sanic speed
	var/list/A_gases = A.gases
	var/list/turf_list = src.turf_list
	var/turflen = turf_list.len
	var/space_in_group = FALSE

	for(var/t in turf_list)
		var/turf/open/T = t
		if (space_is_all_consuming && !space_in_group && istype(T.air, /datum/gas_mixture/immutable/space))
			space_in_group = TRUE
			qdel(A)
			A = new /datum/gas_mixture/immutable/space()
			A_gases = A.gases //update the cache
			break
		A.merge(T.air)

	for(var/id in A_gases)
		A_gases[id] /= turflen

	for(var/t in turf_list)
		var/turf/open/T = t
		var/datum/gas_mixture/T_air = T.air
		COPY_GAS_FROM_TO(T_air,A)
		T.update_visuals()

	breakdown_cooldown = 0

/datum/excited_group/proc/dismantle()
	for(var/t in turf_list)
		var/turf/open/T = t
		T.excited = FALSE
		T.excited_group = null
		SSair.active_turfs -= T
	garbage_collect()

/datum/excited_group/proc/garbage_collect()
	for(var/t in turf_list)
		var/turf/open/T = t
		T.excited_group = null
	turf_list.Cut()
	SSair.excited_groups -= src

////////////////////////SUPERCONDUCTIVITY/////////////////////////////
/turf/proc/conductivity_directions()
	if(archived_cycle < SSair.times_fired)
		archive()
	return NORTH|SOUTH|EAST|WEST

/turf/open/conductivity_directions()
	if(blocks_air)
		return ..()
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		if(!(T in atmos_adjacent_turfs) && !(atmos_superconductivity & direction))
			. |= direction

/turf/proc/neighbor_conduct_with_src(turf/open/other)
	if(!other.blocks_air) //Open but neighbor is solid
		other.temperature_share_open_to_solid(src)
	else //Both tiles are solid
		other.share_temperature_mutual_solid(src, thermal_conductivity)
	temperature_expose(null, temperature, null)

/turf/open/neighbor_conduct_with_src(turf/other)
	if(blocks_air)
		..()
		return
	if(!other.blocks_air) //Both tiles are open
		var/turf/open/T = other
		T.air.temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
	else //Solid but neighbor is open
		temperature_share_open_to_solid(other)
	SSair.add_to_active(src, 0)

/turf/proc/super_conduct()
	var/conductivity_directions = conductivity_directions()

	if(conductivity_directions)
		//Conduct with tiles around me
		for(var/direction in GLOB.cardinals)
			if(conductivity_directions & direction)
				var/turf/neighbor = get_step(src,direction)

				if(!neighbor.thermal_conductivity)
					continue
				if(neighbor.archived_cycle < SSair.times_fired)
					neighbor.archive()
				neighbor.neighbor_conduct_with_src(src)

				neighbor.consider_superconductivity()

	radiate_to_spess()

	finish_superconduction()

/turf/proc/finish_superconduction(temp = temperature)
	//Make sure still hot enough to continue conducting heat
	if(temp < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
		SSair.active_super_conductivity -= src
		return FALSE

/turf/open/finish_superconduction()
	//Conduct with air on my tile if I have it
	if(!blocks_air)
		temperature = air.temperature_share(null, thermal_conductivity, temperature, heat_capacity)
	..((blocks_air ? temperature : air.temperature))

/turf/proc/consider_superconductivity()
	if(!thermal_conductivity)
		return FALSE

	SSair.active_super_conductivity |= src
	return TRUE

/turf/open/consider_superconductivity(starting)
	if(air.temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
		return FALSE
	if(air.heat_capacity() < M_CELL_WITH_RATIO) // Was: MOLES_CELLSTANDARD*0.1*0.05 Since there are no variables here we can make this a constant.
		return FALSE
	return ..()

/turf/closed/consider_superconductivity(starting)
	if(temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
		return FALSE
	return ..()

/turf/proc/radiate_to_spess() //Radiate excess tile heat to space
	if(temperature > T0C) //Considering 0 degC as te break even point for radiation in and out
		var/delta_temperature = (temperature_archived - TCMB) //hardcoded space temperature
		if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

			var/heat = thermal_conductivity*delta_temperature* \
				(heat_capacity*HEAT_CAPACITY_VACUUM/(heat_capacity+HEAT_CAPACITY_VACUUM))
			temperature -= heat/heat_capacity

/turf/open/proc/temperature_share_open_to_solid(turf/sharer)
	sharer.temperature = air.temperature_share(null, sharer.thermal_conductivity, sharer.temperature, sharer.heat_capacity)

/turf/proc/share_temperature_mutual_solid(turf/sharer, conduction_coefficient) //to be understood
	var/delta_temperature = (temperature_archived - sharer.temperature_archived)
	if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER && heat_capacity && sharer.heat_capacity)

		var/heat = conduction_coefficient*delta_temperature* \
			(heat_capacity*sharer.heat_capacity/(heat_capacity+sharer.heat_capacity))

		temperature -= heat/heat_capacity
		sharer.temperature += heat/sharer.heat_capacity
