/// Basic machine used to paint PDAs and re-trim ID cards.
/obj/machinery/pdapainter
	name = "\improper PDA Painter"
	desc = "A painting machine that can be used to paint PDAs. To use, simply insert the item and choose the desired preset."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	// base_icon_state = "pdapainter"
	density = TRUE
	max_integrity = 200
	/// Current PDA inserted into the machine.
	var/obj/item/pda/stored_pda = null
	/// A blacklist of PDA types that we should not be able to paint.
	var/static/list/pda_type_blacklist = list(
		/obj/item/pda/ai/pai,
		/obj/item/pda/ai,
		/obj/item/pda/heads,
		/obj/item/pda/clear,
		/obj/item/pda/syndicate,
		/obj/item/pda/chameleon,
		/obj/item/pda/chameleon/broken,
		/obj/item/pda/lieutenant)
	/// A list of the PDA types that this machine can currently paint.
	var/list/pda_types = list()
	/// Set to a region define (REGION_SECURITY for example) to create a departmental variant, limited to departmental options. If null, this is unrestricted.
	var/target_dept

/obj/machinery/pdapainter/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "pdapainter-broken"
		return ..()
	icon_state = "pdapainter[powered() ? null : "-off"]"
	return ..()

/obj/machinery/pdapainter/update_overlays()
	. = ..()

	if(machine_stat & BROKEN)
		return

	if(stored_pda)
		. += "[initial(icon_state)]-closed"

/obj/machinery/pdapainter/Initialize()
	. = ..()
	// use old logic because i cannot be bothered

	for(var/A in typesof(/obj/item/pda) - pda_type_blacklist)
		var/obj/item/pda/P = A
		var/PDA_name = initial(P.name)
		pda_types[PDA_name] = P

	// if(!target_dept)
	// 	pda_types = SSid_access.station_pda_templates.Copy()
	// 	return

	// Cache the manager list, then check through each manager.
	// If we get a region match, add their trim templates and PDA paths to our lists.
	// var/list/manager_cache = SSid_access.sub_department_managers_tgui
	// for(var/access_txt in manager_cache)
	// 	var/list/manager_info = manager_cache[access_txt]
	// 	var/list/manager_regions = manager_info["regions"]
	// 	if(target_dept in manager_regions)
	// 		var/list/pda_list = manager_info["pdas"]
	// 		var/list/trim_list = manager_info["templates"]
	// 		pda_types |= pda_list
	// 		card_trims |= trim_list

/obj/machinery/pdapainter/Destroy()
	QDEL_NULL(stored_pda)
	return ..()

/obj/machinery/pdapainter/on_deconstruction()
	// Don't use ejection procs as we're gonna be destroyed anyway, so no need to update icons or anything.
	if(stored_pda)
		stored_pda.forceMove(loc)
		stored_pda = null

/obj/machinery/pdapainter/contents_explosion(severity, target)
	if(stored_pda)
		stored_pda.ex_act(severity, target)

/obj/machinery/pdapainter/handle_atom_del(atom/A)
	if(A == stored_pda)
		stored_pda = null
		update_appearance(UPDATE_ICON)

/obj/machinery/pdapainter/attackby(obj/item/O, mob/living/user, params)
	if(machine_stat & BROKEN)
		if(O.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
			if(!O.tool_start_check(user, amount=0))
				return
			user.visible_message("<span class='notice'>[user] is repairing [src].</span>", \
							"<span class='notice'>You begin repairing [src]...</span>", \
							"<span class='hear'>You hear welding.</span>")
			if(O.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, "<span class='notice'>You repair [src].</span>")
				set_machine_stat(machine_stat & ~BROKEN)
				obj_integrity = max_integrity
				update_appearance(UPDATE_ICON)
			return
		return ..()

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	if(istype(O, /obj/item/pda))
		insert_pda(O, user)
		return

	return ..()

/obj/machinery/pdapainter/deconstruct(disassembled = TRUE)
	obj_break()

/**
 * Insert a PDA into the machine.
 *
 * Will swap PDAs if one is already inside. Attempts to put the PDA into the user's hands if possible.
 * Returns TRUE on success, FALSE otherwise.
 * Arguments:
 * * new_pda - The PDA to insert.
 * * user - The user to try and eject the PDA into the hands of.
 */
/obj/machinery/pdapainter/proc/insert_pda(obj/item/pda/new_pda, mob/living/user)
	if(!istype(new_pda))
		return FALSE

	if(user && !user.transferItemToLoc(new_pda, src))
		return FALSE
	else
		new_pda.forceMove(src)

	if(stored_pda)
		eject_pda(user)

	stored_pda = new_pda
	new_pda.add_fingerprint(user)
	update_icon()
	return TRUE

/**
 * Eject the stored PDA into the user's hands if possible, otherwise on the floor.
 *
 * Arguments:
 * * user - The user to try and eject the PDA into the hands of.
 */
/obj/machinery/pdapainter/proc/eject_pda(mob/living/user)
	if(stored_pda)
		if(user && !issilicon(user) && in_range(src, user))
			user.put_in_hands(stored_pda)
		else
			stored_pda.forceMove(drop_location())

		stored_pda = null
		update_icon()

/obj/machinery/pdapainter/on_attack_hand(mob/user)
	if((machine_stat & BROKEN) || !stored_pda)
		return

	var/selection = input(user, "Select the new skin!", "PDA Painting") as null|anything in pda_types
	if(!selection || (machine_stat & BROKEN) || !stored_pda || !in_range(src, user))
		return

	if(!(pda_types[selection]))
		return

	var/obj/item/pda/pda_path = pda_types[selection]
	stored_pda.icon_state = initial(pda_path.icon_state)
	stored_pda.desc = initial(pda_path.desc)
	stored_pda.overlays_offsets = initial(pda_path.overlays_offsets)
	stored_pda.overlays_icons = initial(pda_path.overlays_icons)
	stored_pda.set_new_overlays()
	stored_pda.update_icon()

	eject_pda()

// /obj/machinery/pdapainter/ui_interact(mob/user, datum/tgui/ui)
// 	ui = SStgui.try_update_ui(user, src, ui)
// 	if(!ui)
// 		ui = new(user, src, "PaintingMachine", name)
// 		ui.open()

// /obj/machinery/pdapainter/ui_data(mob/user)
// 	var/data = list()

// 	if(stored_pda)
// 		data["hasPDA"] = TRUE
// 		data["pdaName"] = stored_pda.name
// 	else
// 		data["hasPDA"] = FALSE
// 		data["pdaName"] = null

// 	data["hasID"] = FALSE
// 	data["idName"] = null

// 	return data

// /obj/machinery/pdapainter/ui_static_data(mob/user)
// 	var/data = list()

// 	data["pdaTypes"] = pda_types

// 	return data

// /obj/machinery/pdapainter/ui_act(action, params)
// 	. = ..()
// 	if(.)
// 		return

// 	switch(action)
// 		if("eject_pda")
// 			if((machine_stat & BROKEN))
// 				return TRUE

// 			var/obj/item/held_item = usr.get_active_held_item()
// 			if(istype(held_item, /obj/item/pda))
// 				// If we successfully inserted, we've ejected the old item. Return early.
// 				if(insert_pda(held_item, usr))
// 					return TRUE
// 			// If we did not successfully insert, try to eject.
// 			if(stored_pda)
// 				eject_pda(usr)
// 				return TRUE

// 			return TRUE
// 		if("trim_pda")
// 			if((machine_stat & BROKEN) || !stored_pda)
// 				return TRUE

// 			var/selection = params["selection"]
// 			for(var/path in pda_types)
// 				if(!(pda_types[path] == selection))
// 					continue

// 				var/obj/item/pda/pda_path = path
// 				stored_pda.icon_state = initial(pda_path.icon_state)
// 				stored_pda.desc = initial(pda_path.desc)
// 			return TRUE

/// Security departmental variant. Limited to PDAs defined in the SSid_access.sub_department_managers_tgui data structure.
// /obj/machinery/pdapainter/security
// 	name = "\improper Security PDA & ID Painter"
// 	target_dept = REGION_SECURITY

/// Medical departmental variant. Limited to PDAs defined in the SSid_access.sub_department_managers_tgui data structure.
// /obj/machinery/pdapainter/medbay
// 	name = "\improper Medbay PDA & ID Painter"
// 	target_dept = REGION_MEDBAY

/// Science departmental variant. Limited to PDAs defined in the SSid_access.sub_department_managers_tgui data structure.
// /obj/machinery/pdapainter/research
// 	name = "\improper Research PDA & ID Painter"
// 	target_dept = REGION_RESEARCH

/// Engineering departmental variant. Limited to PDAs defined in the SSid_access.sub_department_managers_tgui data structure.
// /obj/machinery/pdapainter/engineering
// 	name = "\improper Engineering PDA & ID Painter"
// 	target_dept = REGION_ENGINEERING
