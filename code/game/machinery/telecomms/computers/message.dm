/*
	The monitoring computer for the messaging server.
	Lets you read PDA and request console messages.
*/

// The monitor itself.
/obj/machinery/computer/message_monitor
	name = "message monitor console"
	desc = "Used to monitor the crew's PDA messages, as well as request console messages."
	icon_screen = "comm_logs"
	circuit = /obj/item/circuitboard/computer/message_monitor

	//Servers, and server linked to.
	var/network = "tcommsat"		// the network to probe
	var/list/machinelist = list()	// the servers located by the computer
	var/obj/machinery/telecomms/message_server/linkedServer = null

	//Sparks effect - For emag
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread

	//Messages - Saves me time if I want to change something.
	var/noserver = "ALERT: No server detected. Server may be nonresponsive."
	var/incorrectkey = "ALERT: Incorrect decryption key!"
	var/rebootmsg = "%$�(�:SYS&EM INTRN@L ACfES VIOL�TIa█ DEtE₡TED! Ree3ARcinG A█ BAaKUP RdST�RE PbINT \[0xcff32ca/ - PLfASE aAIT"

	//Computer properties
	var/hacking = FALSE		// Is it being hacked into by the AI/Cyborg
	var/message = ""		// The message that shows on the main menu.
	var/auth = FALSE 		// Are they authenticated?

	// Custom Message Properties
	var/obj/item/pda/customrecepient = null
	var/customsender = "System Administrator"
	var/customjob		= "Admin"
	var/custommessage 	= "This is a test, please ignore."

	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/message_monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "TelecommsPDALog", name)
		ui.open()

/obj/machinery/computer/message_monitor/ui_static_data(mob/user)
	var/list/data_out = list()

	if(!linkedServer || !auth) // no need building this if the usr isn't authenticated
		return data_out

	data_out["recon_logs"] = list()
	var/i1 = 0
	for(var/datum/data_rc_msg/rc in linkedServer.rc_msgs)
		i1++
		if(i1 > 3000)
			break
		var/list/data = list(
			sender = rc.send_dpt,
			recipient = rc.rec_dpt,
			message = rc.message,
			stamp = rc.stamp,
			auth = rc.id_auth,
			priority = rc.priority,
			ref = REF(rc)
		)
		data_out["recon_logs"] += list(data)

	data_out["message_logs"] = list()
	var/i2 = 0
	for(var/datum/data_pda_msg/pda in linkedServer.pda_msgs)
		i2++
		if(i2 > 3000)
			break
		var/list/data = list(
			sender = pda.sender,
			recipient = pda.recipient,
			message = pda.message,
			picture = pda.picture ? TRUE : FALSE,
			ref = REF(pda)
		)
		data_out["message_logs"] += list(data)

	return data_out

/obj/machinery/computer/message_monitor/ui_data(mob/user)
	var/list/data_out = list()

	data_out["notice"] = message
	data_out["authenticated"] = auth
	data_out["network"] = network

	var/mob/living/silicon/S = user
	if(istype(S) && S.hack_software)
		data_out["canhack"] = TRUE

	data_out["hacking"] = (hacking || CHECK_BITFIELD(obj_flags, EMAGGED))
	if(hacking)
		data_out["borg"] = ((isAI(user) || iscyborg(user)) && !CHECK_BITFIELD(obj_flags, EMAGGED)) //even borgs can't read emag
		return data_out

	data_out["servers"] = list()
	for(var/obj/machinery/telecomms/message_server/T in machinelist)
		var/list/data = list(
			name = T.name,
			id = T.id,
			ref = REF(T)
		)
		data_out["servers"] += list(data)	// This /might/ cause an oom. Too bad!
	data_out["servers"] = sortList(data_out["servers"]) //a-z sort

	data_out["fake_message"] = list(
		sender = customsender,
		job = customjob,
		message = custommessage,
		recepient = (customrecepient ? "[customrecepient.owner] ([customrecepient.ownjob])" : null)
	)

	if(!linkedServer)
		data_out["selected"] = null
		return data_out

	data_out["selected"] = list(
		name = linkedServer.name,
		id = linkedServer.id,
		ref = REF(linkedServer),
		status = (linkedServer.on && (linkedServer.toggled != FALSE)) // returns true if server is running
	)
	return data_out

/obj/machinery/computer/message_monitor/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("mainmenu") //deselect
			linkedServer = null
			auth = FALSE
			message = ""
			return
		if("release") //release server listing
			machinelist = list()
			message = ""
			return
		if("network") //network change, flush the selected machine and buffer, and de-auth them, if blank, return default
			var/newnet = sanitize(sanitize_text(params["value"], network))
			if(length(newnet) > 15)	//i'm looking at you, you href fuckers
				message = "FAILED: Network tag string too lengthy"
				return
			network = newnet
			linkedServer = null
			machinelist = list()
			auth = FALSE
			message  = "NOTICE: Network change detected. Server disconnected, please re-authenticate."
			return
		if("probe") //probe network for the pda serbs
			if(LAZYLEN(machinelist) > 0)
				message = "FAILED: Cannot probe when buffer full"
				return

			for(var/obj/machinery/telecomms/message_server/T in GLOB.telecomms_list)
				if(T.network == network)
					LAZYADD(machinelist, T)

			if(!LAZYLEN(machinelist))
				message = "FAILED: Unable to locate network entities in \[[network]\]"
				return
		if("viewmachine")	//selected but not authorized
			for(var/obj/machinery/telecomms/message_server/T in machinelist)
				if(T.id == params["value"])
					linkedServer = T
					break

		if("auth")
			if(!(linkedServer.on && (linkedServer.toggled != FALSE)))
				message = noserver
				return
			if(auth)
				auth = FALSE
				update_static_data(usr) //make sure it's cleared!
				return
			var/dkey = stripped_input(usr, "Please enter the decryption key.")
			if(dkey && dkey == "")
				return
			if(linkedServer.decryptkey == dkey)
				auth = TRUE
			else
				message = incorrectkey
			update_static_data(usr)
		if("change_auth")
			if(!auth)
				message = "WARNING: Auth failed! Please log in to change the password!"
				return
			else if(!(linkedServer.on && (linkedServer.toggled != FALSE)))
				message = noserver
				return

			var/dkey = stripped_input(usr, "Please enter the old decryption key.")
			if(dkey && dkey != "")
				if(linkedServer.decryptkey == dkey)
					var/newkey = stripped_input(usr, "Please enter the new key (3 - 20 characters max):")
					if(!ISINRANGE(length(newkey), 3, 20))
						message = "NOTICE: Decryption key length too long/short!"
						return
					if(newkey && newkey != "")
						linkedServer.decryptkey = newkey
						message = "NOTICE: Decryption key set."
					return
			message = incorrectkey

		if("hack")
			if(!(linkedServer.on && (linkedServer.toggled != FALSE)))
				message = noserver
				return

			var/mob/living/silicon/S = usr
			if(istype(S) && S.hack_software)
				hacking = TRUE
				//Time it takes to bruteforce is dependant on the password length.
				addtimer(CALLBACK(src, .proc/BruteForce, usr), (10 SECONDS) * length(linkedServer.decryptkey))

		if("del_log")
			if(!auth)
				message = "WARNING: Auth failed! Delete aborted!"
				return
			else if(!(linkedServer.on && (linkedServer.toggled != FALSE)))
				message = noserver
				return

			var/datum/data_ref = locate(params["ref"])
			if(istype(data_ref, /datum/data_rc_msg))
				LAZYREMOVE(linkedServer.rc_msgs, data_ref)
				message = "NOTICE: Log Deleted!"
			else if(istype(data_ref, /datum/data_pda_msg))
				LAZYREMOVE(linkedServer.pda_msgs, data_ref)
				message = "NOTICE: Log Deleted!"
			else
				message = "NOTICE: Log not found! It may have already been deleted"
			update_static_data(usr)

		if("clear_log")
			if(!auth)
				message = "WARNING: Auth failed! Delete aborted!"
				return
			else if(!(linkedServer.on && (linkedServer.toggled != FALSE)))
				message = noserver
				return

			var/what = params["value"]
			if(what == "pda_logs")
				linkedServer.pda_msgs = list()
			if(what == "rc_msgs")
				linkedServer.rc_msgs = list()
			update_static_data(usr)
		if("fake")
			if(!auth)
				message = "WARNING: Auth failed!"
				return
			else if(!(linkedServer.on && (linkedServer.toggled != FALSE)))
				message = noserver
				return

			if("reset" in params)
				ResetMessage()
				return
			if("send" in params)
				if(isnull(customrecepient))
					message = "NOTICE: No recepient selected!"
					return
				if(length(custommessage) <= 0 || custommessage == "")
					message = "NOTICE: No message entered!"
					return
				if(length(customjob) <= 0 || customjob == "")
					customjob = "Admin"
					return
				if(length(customsender) <= 0 || customsender == "")
					customsender = "UNKNOWN"
				//sanitize text!!!
				var/datum/signal/subspace/messaging/pda/signal = new(src, list(
					"name" = sanitize_name(customsender),
					"job" = sanitize(customjob),
					"message" = sanitize(custommessage),
					"emojis" = TRUE,
					"targets" = list("[customrecepient.owner] ([customrecepient.ownjob])")
				))
				// this will log the signal and transmit it to the target
				linkedServer.receive_information(signal, null)
				usr.log_message("(PDA: [name] | [usr.real_name]) sent \"[sanitize(custommessage)]\" to [signal.format_target()]", LOG_PDA)
				message = ""
				return
			// Do not check if it's blank yet
			// But do check if it's above our set limit (for people who manualy send hrefs at us!)
			if("sender" in params)
				var/S = params["sender"]
				if(length(S) > MAX_NAME_LEN)
					message = "FAILED: Job string too lengthy"
					return
				customsender = S
				return
			if("job" in params)
				var/J = params["job"]
				if(length(J) > 100)
					message = "FAILED: Job string too lengthy"
					return

				customjob = J
				return
			if("message" in params)
				var/M = params["message"]
				if(length(M) > MAX_MESSAGE_LEN)
					message = "FAILED: Message string too lengthy"
					return
				custommessage = M
				return

			if("recepient" in params)
				// Get out list of viable PDAs
				var/list/obj/item/pda/sendPDAs = get_viewable_pdas()
				if(GLOB.PDAs && LAZYLEN(GLOB.PDAs) > 0)
					customrecepient = input(usr, "Select a PDA from the list.") as null|anything in sortNames(sendPDAs)
				else
					customrecepient = null
				return
		if("refresh")
			update_static_data(usr)

/obj/machinery/computer/message_monitor/attackby(obj/item/O, mob/living/user, params)
	if(O.tool_behaviour == TOOL_SCREWDRIVER && CHECK_BITFIELD(obj_flags, EMAGGED))
		//Stops people from just unscrewing the monitor and putting it back to get the console working again.
		//Why this though, you should make it emag to a board level. (i wont do it)
		to_chat(user, "<span class='warning'>It is too hot to mess with!</span>")
	else
		return ..()

/obj/machinery/computer/message_monitor/emag_act(mob/user)
	. = ..()
	if(CHECK_BITFIELD(obj_flags, EMAGGED))
		return
	if(isnull(linkedServer))
		to_chat(user, "<span class='notice'>A no server error appears on the screen.</span>")
		return
	ENABLE_BITFIELD(obj_flags, EMAGGED)
	spark_system.set_up(5, 0, src)
	spark_system.start()
	var/obj/item/paper/monitorkey/MK = new(loc, linkedServer)
	// Will help make emagging the console not so easy to get away with.
	MK.info += "<br><br><font color='red'>�%@%(*$%&(�&?*(%&�/{}</font>"
	addtimer(CALLBACK(src, .proc/UnmagConsole), (10 SECONDS) * length(linkedServer.decryptkey))
	//message = rebootmsg
	return TRUE

/obj/machinery/computer/message_monitor/New()
	. = ..()
	GLOB.telecomms_list += src

/obj/machinery/computer/message_monitor/Destroy()
	GLOB.telecomms_list -= src
	. = ..()

/obj/machinery/computer/message_monitor/proc/BruteForce(mob/user)
	if(isnull(linkedServer))
		to_chat(user, "<span class='warning'>Could not complete brute-force: Linked Server Disconnected!</span>")
	else
		var/currentKey = linkedServer.decryptkey
		to_chat(user, "<span class='warning'>Brute-force completed! The key is '[currentKey]'.</span>")
	hacking = FALSE
	message = ""

/obj/machinery/computer/message_monitor/proc/UnmagConsole()
	DISABLE_BITFIELD(obj_flags, EMAGGED)
	message = ""

/obj/machinery/computer/message_monitor/proc/ResetMessage()
	customsender 	= "System Administrator"
	customrecepient = null
	custommessage 	= "This is a test, please ignore."
	customjob 		= "Admin"

/obj/item/paper/monitorkey
	name = "monitor decryption key"

/obj/item/paper/monitorkey/Initialize(mapload, obj/machinery/telecomms/message_server/server)
	..()
	if(server)
		print(server)
		return INITIALIZE_HINT_NORMAL
	else
		return INITIALIZE_HINT_LATELOAD

/obj/item/paper/monitorkey/proc/print(obj/machinery/telecomms/message_server/server)
	info = "<center><h2>Daily Key Reset</h2></center><br>The new message monitor key is '[server.decryptkey]'.<br>Please keep this a secret and away from the clown.<br>If necessary, change the password to a more secure one."
	add_overlay("paper_words")

/obj/item/paper/monitorkey/LateInitialize()
	for(var/obj/machinery/telecomms/message_server/server in GLOB.telecomms_list)
		if(server.decryptkey)
			print(server)
			break
