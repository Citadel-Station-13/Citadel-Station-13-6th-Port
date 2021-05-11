
/*

	All telecommunications interactions:

*/

/obj/machinery/telecomms
	var/temp = "" // output message

/obj/machinery/telecomms/attackby(obj/item/P, mob/user, params)
	var/icon_closed = initial(icon_state)
	var/icon_open = "[initial(icon_state)]_o"

	if(!on)
		icon_closed = "[initial(icon_state)]_off"
		icon_open = "[initial(icon_state)]_o_off"

	if(default_deconstruction_screwdriver(user, icon_open, icon_closed, P))
		return
	// Using a multitool lets you access the receiver's interface
	else if(P.tool_behaviour == TOOL_MULTITOOL)
		attack_hand(user)

	else if(default_deconstruction_crowbar(P))
		return
	else
		return ..()

/obj/machinery/telecomms/ui_interact(mob/user, datum/tgui/ui)
	if(!canInteract(user))
		if(ui)
			ui.close() //haha no.
		return
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "TelecommsInteraction", "[name] Access")
		ui.open()

/obj/machinery/telecomms/ui_data(mob/user)
	. = list() //cpypaste from the vending bus
	.["notice"] = temp
	.["multitool"] = FALSE
	var/obj/item/P = get_multitool(user)
	if(P)
		.["multitool"] = TRUE
		.["multitool_buf"] = null //to clean the list!
		var/obj/machinery/telecomms/T = P.buffer
		if(istype(T))
			.["multitool_buf"] = list(
				name = T.name,
				id = T.id
			)

	.["machine"] = list()
	.["machine"]["power"] = toggled
	.["machine"]["id"] = id
	.["machine"]["network"] = network
	.["machine"]["prefab"] = LAZYLEN(autolinkers) ? TRUE : FALSE
	.["machine"]["hidden"] = hide

	.["links"] = list()
	for(var/obj/machinery/telecomms/T in links)
		if(T.hide && !hide)
			continue
		var/list/data = list(
			name = T.name,
			id = T.id,
			ref = REF(T)
		)
		.["links"] += list(data)

	.["freq_listening"] = freq_listening

/obj/machinery/telecomms/relay/ui_data(mob/user)
	. = ..()
	.["machine"]["isrelay"] = TRUE
	.["machine"]["broadcast"] = broadcasting
	.["machine"]["receiving"] = receiving

/obj/machinery/telecomms/bus/ui_data(mob/user)
	. = ..()
	.["machine"]["isbus"] = TRUE
	.["machine"]["chang_frequency"] = change_frequency
	.["machine"]["chang_freq_value"] = change_freq_value

/obj/machinery/telecomms/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(!canInteract(usr))
		if(ui)
			ui.close() //haha no.
		return
	temp = ""

	switch(action)
		if("toggle")
			toggled = !toggled
			temp = "-% [src.name] has been [toggled ? "activated" : "deactivated"]. %-"
			update_power()
			return
		if("machine")
			if("id" in params)
				if(!canAccess(usr))
					return
				//if the text is blank, return the id it was using
				var/newid = sanitize_text(reject_bad_text(params["id"]), id) // reject_bad_text can return null!
				if(length(newid) > 255)
					temp = "-% Too many characters in new id tag. %-"
					return
				temp = "-% New ID assigned: \"[newid]\". %-"
				id = newid
				return
			if("network" in params)
				if(!canAccess(usr))
					return
				var/newnet = sanitize(sanitize_text(params["network"], network))
				if(length(newnet) > 15)
					temp = "-% Too many characters in new network tag. %-"
					return
				network = newnet
				links = list()
				temp = "-% New network tag assigned: \"[network]\" %-"
				return
		if("multitool")
			var/obj/item/P = get_multitool(usr)
			if("Link" in params)
				if(!canAccess(usr))
					return
				if(!P.tool_behaviour == TOOL_MULTITOOL)
					temp = "-% Unable to acquire buffer %-"
					return

				var/obj/machinery/telecomms/T = P.buffer
				if(!istype(T) || T == src)
					temp = "-% Unable to acquire buffer %-"
					return

				if(!(src in T.links))
					LAZYADD(T.links, src)

				if(!(T in links))
					LAZYADD(links, T)
				temp = "-% Successfully linked with [REF(T)] [T.name] %-"

			if("Flush" in params)
				if(!istype(P))
					temp = "-% Unable to acquire multitool %-"
					return

				temp = "-% Buffer successfully flushed. %-"
				P.buffer = null

			if("Add" in params)
				if(!canAccess(usr))
					return
				if(!istype(P))
					temp = "-% Unable to acquire multitool %-"
					return

				P.buffer = src
				temp = "% Successfully stored [REF(P.buffer)] [P.buffer] in buffer %-"

		if("unlink")
			var/obj/machinery/telecomms/T = locate(params["value"])
			if(!canAccess(usr))
				return
			if(!istype(T))
				temp = "-% Unable to locate machine to unlink from, try again. %-"
				return

			temp = "-% Removed [REF(T)] [T.name] from linked entities. %-"
			if(T.links) //lazyrem makes blank list null, which is good but some might cause runtime ee's
				T.links.Remove(src)
			links.Remove(T)
		if("freq")
			if("add" in params)
				var/newfreq = input("Specify a new frequency to filter (GHz). Decimals assigned automatically.", src.name, null) as null|num
				if(!canAccess(usr) || !newfreq || isnull(newfreq))
					return

				if(findtext(num2text(newfreq), ".")) // did they not read the text?
					newfreq *= 10 // shift the decimal one place

				newfreq = sanitize_frequency(newfreq, TRUE) //sanitize
				if(newfreq == FREQ_SYNDICATE)
					temp = "-% Error: Interference preventing filtering frequency: \"[newfreq] GHz\" %-"
					return
				if(newfreq in freq_listening)
					temp = "-% Error: Frequency already filtered %-"
					return

				LAZYADD(freq_listening, newfreq)
				temp = "-% New frequency filter assigned: \"[newfreq] GHz\" %-"

			if("remove" in params)
				if(!canAccess(usr))
					return
				var/x = text2num(params["remove"])
				temp = "-% Removed frequency filter [x] %-"
				freq_listening.Remove(x)

/obj/machinery/telecomms/relay/ui_act(action, params)
	..()
	switch(action)
		if("relay")
			if("broadcast" in params)
				if(!canAccess(usr))
					return
				broadcasting = !broadcasting
				temp = "-% Broadcasting mode changed. %-"
				return
			if("receiving" in params)
				if(!canAccess(usr))
					return
				receiving = !receiving
				temp = "-% Receiving mode changed. %-"

/obj/machinery/telecomms/bus/ui_act(action, params)
	..()
	switch(action)
		if("frequency")
			if("toggle" in params)
				if(!canAccess(usr))
					return
				change_frequency = !change_frequency
				return
			if("adjust" in params)
				var/newfreq = text2num(params["adjust"])
				if(!canAccess(usr) || !newfreq)
					return
				// this should return true, unless the href is handcrafted
				if(findtext(num2text(newfreq), "."))
					newfreq *= 10 // shift the decimal one place

				newfreq = sanitize_frequency(newfreq, TRUE)
				if(newfreq == FREQ_SYNDICATE)
					temp = "-% Error: Interference preventing filtering frequency: \"[newfreq] GHz\" %-"
					return

				change_freq_value = newfreq
				temp = "-% New frequency to change to assigned: \"[newfreq] GHz\" %-"
				return

// Check if the user can use it.
/obj/machinery/telecomms/proc/canInteract(mob/user)
	var/obj/item/I = user.get_active_held_item()
	if(!issilicon(user) && I)
		if(I.tool_behaviour == TOOL_MULTITOOL)
			return TRUE
	if(hasSiliconAccessInArea(user))
		return TRUE
	return FALSE

// Check if the user is nearby and has a multitool.
/obj/machinery/telecomms/proc/canAccess(mob/user)
	if((canInteract(user) && in_range(user, src)) || hasSiliconAccessInArea(user))
		return TRUE
	return FALSE

// Returns a multitool from a user depending on their mobtype.
/obj/machinery/telecomms/proc/get_multitool(mob/user)
	if(!canInteract(user))
		return null
	var/obj/item/P = user.get_active_held_item()
	// Is the ref not a null? and is it the actual type?
	if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(iscyborg(user) && !in_range(user, src))
		return null
	if(!P)
		return null
	else if(P.tool_behaviour == TOOL_MULTITOOL)
		return P
	return P
