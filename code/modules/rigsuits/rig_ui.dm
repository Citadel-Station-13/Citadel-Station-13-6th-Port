/**
 * RIG UI:
 *
 * RIGs will have a lot of data. This means we need a queuing system to not resend data unless necessary.
 */

/**
 * Queues a rig component to update.
 */
/obj/item/rig/proc/ui_queue_component(obj/item/rig_component/C)
	ASSERT(istype(C))
	LAZYOR(ui_pieces_queued, C)
	ui_queue()

/**
 * Queues a rig piece to update its ui data.
 */
/obj/item/rig/proc/ui_queue_piece(datum/component/rig_piece/R)
	R = resolve_piece_component(R)
	ASSERT(istype(R))
	LAZYOR(ui_components_queued, R)
	ui_queue()

/**
 * Queues updating reflists. Use when something is added/removed, ontop of the actual component/piece update.
 */
/obj/item/rig/proc/ui_queue_reflists()
	ui_refs_changed = TRUE
	ui_queue()

/**
 * Queues an UI resend
 */
/obj/item/rig/proc/ui_queue()
	ui_update_queued = addtimer(CALLBACK(src, .proc/flush_ui_queue), 0, TIMER_STOPPABLE | TIMER_UNIQUE)

/**
 * Flushes UI data
 */
/obj/item/rig/proc/flush_ui_queue()
	SStgui.update_uis(src)
	ui_pieces_queued = null
	ui_components_queued = null
	ui_refs_changed = FALSE
	ui_udate_queued = null

/**
 * RIG UI static data
 */
/obj/item/rig/ui_static_data(mob/user)
	. = ..()
	// Integrals
	if(installed_armor)
		.[REF(installed_armor)] = installed_armor?.rig_ui_data(user)
		.[REF(installed_thermal_shielding)] = installed_thermal_shielding?.rig_ui_data(user)
		.[REF(installed_pressure_shielding)] = installed_pressure_shielding?.rig_ui_data(user)
	// modules
	for(var/obj/item/rig_component/module/M in modules)
		var/ref = REF(M)
		.[ref] = M.rig_ui_data(user)
	// pieces
	for(var/datum/component/rig_piece/P in piece_components)
		var/ref = REF(P)
		.[ref] = P.rig_ui_data(user)
	// reflists
	. += ui_refs_generate()
	// standard data
	. += ui_volatile_data()

/**
 * Generate list associations for installed components and pieces
 */
/obj/item/rig/proc/ui_refs_generate()
	.["modules"] = generate_module_refs()
	.["pieces"] = generate_piece_refs()
	.["integral_armor"] = installed_armor? REF(installed_armor) : null
	.["integral_thermal"] = installed_thermal_shielding? REF(installed_thermal_shielding) : null
	.["integral_pressure"] = installed_pressure_shielding? REF(installed_pressure_shielding) : null

/obj/item/rig/proc/generate_module_refs()
	. = list()
	for(var/obj/item/rig_component/module/M in modules)
		. |= REF(M)

/obj/item/rig/proc/generate_piece_refs()
	. = list()
	for(var/datum/component/rig_piece/P in piece_components)
		. |= REF(P)


/**
 * Standard ui data that changes a lot
 */
/obj/item/rig/proc/ui_volatile_data(mob/user)

/**
 * RIG UI data
 */
/obj/item/rig/ui_data(mob/user)
	. = ..()
	if(ui_refs_changed)
		. += ui_refs_generate()
	if(ui_components_queued)
		for(var/obj/item/rig_component/C in ui_components_queued)
			.[REF(C)] = C.rig_ui_data(user)
	if(ui_pieces_queued)
		for(var/datum/component/rig_piece/P in ui_pieces_queued)
			.[REF(P)] = P.rig_ui_date(user)
	. += ui_volatile_data(user)

/**
 * RIG UI status
 */
/obj/item/rig/ui_status(mob/user)
	var/control_flags = get_control_flags(user)
	if(!(control_flags & RIG_CONTROL_UI_VIEW))
		return UI_CLOSE
	return UI_INTERACTIVE


/**
 * RIG UI act
 */
/obj/item/rig/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	if(params["module"])
		if(!attempt_control_flags(user, RIG_CONTROL_UI_MODULES))
			return TRUE
		var/obj/item/rig_component/module/M = locate(params["module"]) in modules
		if(!M)
			return TRUE
		M.rig_ui_act(action, params))
		return TRUE
	if(params["deploy"])
		if(!attempt_control_flags(user, RIG_CONTROL_DEPLOY))
			return TRUE
		try_deploy(params["deploy"], user)
	if(params["undeploy"])
		if(!attempt_control_flags(user, RIG_CONTROL_DEPLOY))
			return TRUE
		try_retract(params["undeploy"], user)
