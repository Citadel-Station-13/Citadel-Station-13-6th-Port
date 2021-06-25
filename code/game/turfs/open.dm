/turf/open
	plane = FLOOR_PLANE
	var/slowdown = 0 //negative for faster, positive for slower

	var/postdig_icon_change = FALSE
	var/postdig_icon
	var/wet

	var/footstep = null
	var/barefootstep = null
	var/clawfootstep = null
	var/heavyfootstep = null

	/// Dirtyness system, cit specific.

	/// Does dirt buildup happen on us?
	var/dirt_buildup_allowed = FALSE
	/// Dirt level.
	var/dirtyness = 0
	/// Dirt level to spawn dirt. Null to use config.
	var/dirt_spawn_threshold

/turf/open/ComponentInitialize()
	. = ..()
	if(wet)
		AddComponent(/datum/component/wet_floor, wet, INFINITY, 0, INFINITY, TRUE)

//direction is direction of travel of A
/turf/open/zPassIn(atom/movable/A, direction, turf/source)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	return FALSE

//direction is direction of travel of A
/turf/open/zPassOut(atom/movable/A, direction, turf/destination)
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

//direction is direction of travel of air
/turf/open/zAirIn(direction, turf/source)
	return (direction == DOWN)

//direction is direction of travel of air
/turf/open/zAirOut(direction, turf/source)
	return (direction == UP)

/turf/open/MouseDrop_T(atom/dropping, mob/user)
	. = ..()
	if(dropping == user && isliving(user))
		var/mob/living/L = user
		if(L.resting && do_after(L, max(10, L.getStaminaLoss()*0.5), 0, src))
			if(Adjacent(L, src))
				step(L, get_dir(L, src))
				playsound(L, "rustle", 25, 1)

/turf/open/indestructible
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = TRUE

/turf/open/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/indestructible/singularity_act()
	return

/turf/open/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/open/indestructible/sound
	name = "squeaky floor"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	var/sound

/turf/open/indestructible/sound/Entered(var/mob/AM)
	..()
	if(istype(AM))
		playsound(src,sound,50,1)

/turf/open/indestructible/cobble/side
	icon_state = "cobble_side"

/turf/open/indestructible/cobble/corner
	icon_state = "cobble_corner"

/turf/open/indestructible/cobble
	name = "cobblestone path"
	desc = "A simple but beautiful path made of various sized stones."
	icon = 'icons/turf/floors.dmi'
	icon_state = "cobble"
	baseturfs = /turf/open/indestructible/cobble
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturfs = /turf/open/indestructible/necropolis
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	tiled_dirt = FALSE

/turf/open/indestructible/necropolis/Initialize()
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/open/indestructible/necropolis/ice
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/indestructible/necropolis/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/boss //you put stone tiles on this and use it as a base
	name = "necropolis floor"
	icon = 'icons/turf/boss_floors.dmi'
	icon_state = "boss"
	baseturfs = /turf/open/indestructible/boss
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/indestructible/boss/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/hierophant
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	baseturfs = /turf/open/indestructible/hierophant
	smooth = SMOOTH_TRUE
	tiled_dirt = FALSE

/turf/open/indestructible/hierophant/two

/turf/open/indestructible/hierophant/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/open/indestructible/paper
	name = "notebook floor"
	desc = "A floor made of invulnerable notebook paper."
	icon_state = "paperfloor"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	tiled_dirt = FALSE

/turf/open/indestructible/binary
	name = "tear in the fabric of reality"
	CanAtmosPass = ATMOS_PASS_NO
	baseturfs = /turf/open/indestructible/binary
	icon_state = "binary"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null

/turf/open/indestructible/airblock
	icon_state = "bluespace"
	CanAtmosPass = ATMOS_PASS_NO
	baseturfs = /turf/open/indestructible/airblock

/turf/open/indestructible/clock_spawn_room
	name = "cogmetal floor"
	desc = "Brass plating that gently radiates heat. For some reason, it reminds you of blood."
	icon_state = "reebe"
	baseturfs = /turf/open/indestructible/clock_spawn_room
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/indestructible/clock_spawn_room/Entered()
	..()
	START_PROCESSING(SSfastprocess, src)

/turf/open/indestructible/clock_spawn_room/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/turf/open/indestructible/clock_spawn_room/process()
	if(!port_servants())
		STOP_PROCESSING(SSfastprocess, src)

/turf/open/indestructible/clock_spawn_room/proc/port_servants()
	. = FALSE
	for(var/mob/living/L in src)
		if(is_servant_of_ratvar(L) && L.stat != DEAD)
			. = TRUE
			L.forceMove(get_turf(pick(GLOB.servant_spawns)))
			visible_message("<span class='warning'>[L] vanishes in a flash of red!</span>")
			L.visible_message("<span class='warning'>[L] appears in a flash of red!</span>", \
			"<span class='bold cult'>sas'so c'arta forbici</span><br><span class='danger'>You're yanked away from [src]!</span>")
			playsound(src, 'sound/magic/enter_blood.ogg', 50, TRUE)
			playsound(L, 'sound/magic/exit_blood.ogg', 50, TRUE)
			flash_color(L, flash_color = "#C80000", flash_time = 10)

/turf/open/Initalize_Atmos(times_fired)
	set_excited(FALSE)
	update_visuals()

	current_cycle = times_fired
	ImmediateCalculateAdjacentTurfs()
	for(var/i in atmos_adjacent_turfs)
		var/turf/open/enemy_tile = i
		var/datum/gas_mixture/enemy_air = enemy_tile.return_air()
		if(!get_excited() && air.compare(enemy_air))
			//testing("Active turf found. Return value of compare(): [is_active]")
			set_excited(TRUE)
			SSair.add_to_active_extools(src)

/turf/open/proc/GetHeatCapacity()
	. = air.heat_capacity()

/turf/open/proc/GetTemperature()
	. = air.return_temperature()

/turf/open/proc/TakeTemperature(temp)
	air.set_temperature(air.return_temperature() + temp)
	air_update_turf()

/turf/open/proc/freon_gas_act()
	for(var/obj/I in contents)
		if(I.resistance_flags & FREEZE_PROOF)
			return
		if(!(I.obj_flags & FROZEN))
			I.make_frozen_visual()
	for(var/mob/living/L in contents)
		if(L.bodytemperature <= 50)
			L.apply_status_effect(/datum/status_effect/freon)
	MakeSlippery(TURF_WET_PERMAFROST, 50)
	return 1

/turf/open/proc/water_vapor_gas_act(gas_temp)
	var/already_wet = MakeWet(MOLES_GAS_VISIBLE, gas_temp, forced = FALSE)
	for(var/mob/living/simple_animal/slime/M in src)
		M.apply_water()

	if(!already_wet)
		SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
		clean_blood()
		for(var/obj/effect/O in src)
			if(is_cleanable(O))
				qdel(O)
	return !already_wet

/turf/open/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube)
	if(!(lube & FLYING_DOESNT_HELP) && (C.movement_type & FLYING || !has_gravity(src)))
		return FALSE
	var/obj/buckled_obj
	if(C.buckled)
		buckled_obj = C.buckled
		if(!(lube&GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
			return FALSE
	else
		if(!(lube&SLIP_WHEN_CRAWLING) && (C.lying || !(C.status_flags & CANKNOCKDOWN))) // can't slip unbuckled mob if they're lying or can't fall.
			return FALSE
		if(lube & NO_SLIP_WHEN_WALKING)
			if(C.m_intent == MOVE_INTENT_WALK)
				return FALSE
			if(ishuman(C) && !(lube & SLIP_WHEN_JOGGING) && CONFIG_GET(flag/sprint_enabled))
				var/mob/living/carbon/human/H = C
				if(!(H.combat_flags & COMBAT_FLAG_SPRINT_ACTIVE) && H.getStaminaLoss() <= 20)
					return FALSE
	if(!(lube&SLIDE_ICE))
		to_chat(C, "<span class='notice'>You slipped[ O ? " on the [O.name]" : ""]!</span>")
		playsound(C.loc, 'sound/misc/slip.ogg', 50, 1, -3)

	SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "slipped", /datum/mood_event/slipped)
	for(var/obj/item/I in C.held_items)
		C.accident(I)

	var/olddir = C.dir
	if(!(lube & SLIDE_ICE))
		C.DefaultCombatKnockdown(knockdown_amount)
		C.stop_pulling()
	else
		C.Stun(20)

	if(buckled_obj)
		buckled_obj.unbuckle_mob(C)
		lube |= SLIDE_ICE

	if(lube&SLIDE)
		new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 4), 1, FALSE, CALLBACK(C, /mob/living/carbon/.proc/spin, 1, 1))
	else if(lube&SLIDE_ICE)
		new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 1), 1, FALSE)	//spinning would be bad for ice, fucks up the next dir
	return TRUE

/turf/open/proc/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent)
	AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)

/turf/open/proc/MakeWet(amt = 0.0, new_temp = T20C, forced = TRUE)
	. = GetComponent(/datum/component/wetness)
	if(forced || !.)
		AddComponent(/datum/component/wetness, amt, new_temp)

/turf/open/proc/MakeDry(wet_setting = TURF_WET_WATER, immediate = FALSE, amount = INFINITY)
	SEND_SIGNAL(src, COMSIG_TURF_MAKE_DRY, wet_setting, immediate, amount)

/turf/open/get_dumping_location()
	return src

/turf/open/proc/ClearWet()//Nuclear option of immediately removing slipperyness from the tile instead of the natural drying over time
	qdel(GetComponent(/datum/component/wet_floor))

/turf/open/rad_act(pulse_strength)
	. = ..()
	if (air.get_moles(/datum/gas/carbon_dioxide) && air.get_moles(/datum/gas/oxygen))
		pulse_strength = min(pulse_strength,air.get_moles(/datum/gas/carbon_dioxide)*1000,air.get_moles(/datum/gas/oxygen)*2000) //Ensures matter is conserved properly
		air.set_moles(/datum/gas/carbon_dioxide, max(air.get_moles(/datum/gas/carbon_dioxide)-(pulse_strength/1000),0))
		air.set_moles(/datum/gas/oxygen, max(air.get_moles(/datum/gas/oxygen)-(pulse_strength/2000),0))
		air.adjust_moles(/datum/gas/pluoxium, pulse_strength/4000)
