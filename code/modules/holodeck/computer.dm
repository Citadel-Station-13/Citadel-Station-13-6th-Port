/*
	Holodeck Update

	The on-station holodeck area is of type [holodeck_type].
	All subtypes of [program_type] are loaded into the program cache or emag programs list.
	If init_program is null, a random program will be loaded on startup.
	If you don't wish this, set it to the offline program or another of your choosing.

	You can use this to add holodecks with minimal code:
	1) Define new areas for the holodeck programs
	2) Map them
	3) Create a new control console that uses those areas

	Non-mapped areas should be skipped but you should probably comment them out anyway.
	The base of program_type will always be ignored; only subtypes will be loaded.
*/

#define HOLODECK_CD 25
#define HOLODECK_DMG_CD 500

/obj/machinery/computer/holodeck
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."
	icon_screen = "holocontrol"
	idle_power_usage = 10
	active_power_usage = 50
	var/area/holodeck/linked
	var/area/holodeck/program
	var/area/holodeck/last_program
	var/area/offline_program = /area/holodeck/rec_center/offline

	var/list/program_cache = list()
	var/list/emag_programs = list()

	// Splitting this up allows two holodecks of the same size
	// to use the same source patterns.  Y'know, if you want to.
	var/holodeck_type = /area/holodeck/rec_center	// locate(this) to get the target holodeck
	var/program_type = /area/holodeck/rec_center	// subtypes of this (but not this itself) are loadable programs

	// set this if you want it to start with some particular program.
	var/init_program = null
	// or this to get anything
	var/random_program = 0

	var/active = 0
	var/damaged = 0
	var/list/spawned = list()
	var/list/effects = list()
	var/last_change = 0



/obj/machinery/computer/holodeck/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/holodeck/LateInitialize()
  if(ispath(holodeck_type,/area))
    var/list/possible = get_areas(holodeck_type,subtypes = FALSE)
    linked = pop(possible)
  if(ispath(offline_program,/area))
    var/list/possible = get_areas(offline_program,subtypes = FALSE)
    offline_program = pop(possible)
  // the following is necessary for power reasons
  if(!linked || !offline_program)
    log_world("No matching holodeck area found")
    qdel(src)
    return
  var/area/AS = get_area(src)
  if(istype(AS,/area/holodeck))
    log_world("### MAPPING ERROR")
    log_world("Holodeck computer cannot be in a holodeck.")
    log_world("This would cause circular power dependency.")
    qdel(src)  // todo handle constructed computers
    return	//l-lewd...
  else
    linked.linked = src // todo detect multiple/constructed computers

  program_cache = list()
  emag_programs = list()
  for(var/typekey in subtypesof(program_type))
    var/area/holodeck/A = locate(typekey)
    if(!A || A == offline_program)
      continue
    if(A.contents.len == 0)
      continue // not loaded
    if(A.restricted)
      emag_programs += A
    else
      program_cache += A
    if(typekey == init_program)
      load_program(A,force=1)
  if(random_program && program_cache.len && init_program == null)
    load_program(pick(program_cache),force=1)
  else if(!program)
    load_program(offline_program)

/obj/machinery/computer/holodeck/power_change()
	..()
	toggle_power(!stat)

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = 0)
	if(active == toggleOn) return

	if(toggleOn)
		if(last_program && last_program != offline_program)
			load_program(last_program, delay = 1)
		active = 1
	else
		last_program = program
		load_program(offline_program,force=1)
		active = 0

/obj/machinery/computer/holodeck/proc/emergency_shutdown()
	last_program = program
	load_program(offline_program,1)
	active = 0

/obj/machinery/computer/holodeck/process()
	if(damaged)
		if(prob(10))
			for(var/turf/T in linked)
				if(prob(5))
					var/datum/effect_system/spark_spread/s = new
					s.set_up(2, 1, T)
					s.start()
					return

	if(!..() || !active)
		return

	if(!floorcheck())
		emergency_shutdown()
		damaged = 1
		for(var/mob/M in urange(10,src))
			M.show_message("The holodeck overloads!")

		for(var/turf/T in linked)
			if(prob(30))
				var/datum/effect_system/spark_spread/s = new
				s.set_up(2, 1, T)
				s.start()
			T.ex_act(3)
			T.hotspot_expose(1000,500,1)

	if(!emagged)
		for(var/item in spawned)
			if(!(get_turf(item) in linked))
				derez(item, 0)
	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.tick()

	active_power_usage = 50 + spawned.len * 3 + effects.len * 5

/obj/machinery/computer/holodeck/emag_act(mob/user)
	if(emagged)
		return
	if(!LAZYLEN(emag_programs))
		to_chat(user, "[src] does not seem to have a card swipe port. It must be an inferior model.")
		return
	playsound(src, 'sound/effects/sparks4.ogg', 75, 1)
	emagged = TRUE
	to_chat(user, "<span class='warning'>You vastly increase projector power and override the safety and security protocols.</span>")
	to_chat(user, "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call Nanotrasen maintenance and do not use the simulator.")
	log_game("[key_name(user)] emagged the Holodeck Control Console")
	nerf(!emagged)

/obj/machinery/computer/holodeck/emp_act(severity)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/ex_act(severity, target)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/blob_act(obj/structure/blob/B)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/proc/generate_program_list()
	for(var/typekey in subtypesof(program_type))
		var/area/holodeck/A = locate(typekey) in GLOB.sortedAreas
		if(!A || A == offline_program || !A.contents.len)
			continue
		var/list/info_this = list()
		info_this["name"] = A.name
		info_this["type"] = A.type
		if(A.restricted)
			LAZYADD(emag_programs, list(info_this))
		else
			LAZYADD(program_cache, list(info_this))

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = FALSE)
	if(active == toggleOn)
		return

	if(toggleOn)
		if(last_program && last_program != offline_program)
			addtimer(CALLBACK(src, .proc/load_program, last_program, TRUE), 25)
		active = TRUE
	else
		last_program = program
		load_program(offline_program, TRUE)
		active = FALSE

/obj/machinery/computer/holodeck/proc/emergency_shutdown()
	last_program = program
	load_program(offline_program, TRUE)
	active = FALSE

/obj/machinery/computer/holodeck/proc/floorcheck()
	for(var/turf/T in linked)
		if(!T.intact || isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/computer/holodeck/proc/nerf(active)
	for(var/obj/item/I in spawned)
		I.damtype = active ? STAMINA : initial(I.damtype)
	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.safety(active)

/obj/machinery/computer/holodeck/proc/load_program(area/A, force = FALSE, add_delay = TRUE)
	if(!is_operational())
		A = offline_program
		force = TRUE

	if(program == A)
		return
	if(current_cd > world.time && !force)
		say("ERROR. Recalibrating projection apparatus.")
		return
	if(add_delay)
		current_cd = world.time + HOLODECK_CD
		if(damaged)
			current_cd += HOLODECK_DMG_CD
	active = (A != offline_program)
	use_power = active + IDLE_POWER_USE

	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.deactivate(src)

	for(var/item in spawned)
		derez(item, force)

	program = A
	// note nerfing does not yet work on guns, should
	// should also remove/limit/filter reagents?
	// this is an exercise left to others I'm afraid.  -Sayu
	spawned = A.copy_contents_to(linked, 1, nerf_weapons = !emagged)
	for(var/obj/machinery/M in spawned)
		M.flags |= NODECONSTRUCT
	for(var/obj/structure/S in spawned)
		S.flags |= NODECONSTRUCT
	effects = list()

	addtimer(CALLBACK(src, .proc/finish_spawn), 30)

/obj/machinery/computer/holodeck/proc/finish_spawn()
	var/list/added = list()
	for(var/obj/effect/holodeck_effect/HE in spawned)
		effects += HE
		spawned -= HE
		var/atom/x = HE.activate(src)
		if(istype(x) || islist(x))
			spawned += x // holocarp are not forever
			added += x
	for(var/obj/machinery/M in added)
		M.flags |= NODECONSTRUCT
	for(var/obj/structure/S in added)
		S.flags |= NODECONSTRUCT

/obj/machinery/computer/holodeck/proc/derez(obj/O, silent = TRUE, forced = FALSE)
	// Emagging a machine creates an anomaly in the derez systems.
	if(O && emagged && !stat && !forced)
		if((ismob(O) || ismob(O.loc)) && prob(50))
			addtimer(CALLBACK(src, .proc/derez, O, silent), 50) // may last a disturbingly long time
			return

	spawned -= O
	if(!O)
		return
	var/turf/T = get_turf(O)
	for(var/atom/movable/AM in O) // these should be derezed if they were generated
		AM.forceMove(T)
		if(ismob(AM))
			silent = FALSE					// otherwise make sure they are dropped

	if(!silent)
		visible_message("[O] fades away!")
	qdel(O)

#undef HOLODECK_CD
#undef HOLODECK_DMG_CD
