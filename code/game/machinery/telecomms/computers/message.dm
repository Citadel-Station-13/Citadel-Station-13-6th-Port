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
	var/defaultmsg = "Welcome. Please select an option."
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

/obj/machinery/computer/message_monitor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE,\
														datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "telepdalog", name, 727, 510, master_ui, state)
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

	if(hacking)
		data_out["hacking"] = TRUE
		data_out["borg"] = (isAI(user) || iscyborg(user))
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
		status = linkedServer.on // returns true if server is running
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
		if("network") //network change, flush the selected machine and buffer, and de-auth them
			var/newnet = trim(html_encode(params["value"]), 15)
			if(length(newnet) > 15)	//i'm looking at you, you href fuckers
				message = "FAILED: NETWORK TAG STRING TOO LENGHTLY"
				return
			network = newnet
			linkedServer = null
			machinelist = list()
			auth = FALSE
			message  = "NOTICE: Network change detected. Server disconnected, please re-authenticate."
			return
		if("probe") //probe network for the pda serbs
			if(LAZYLEN(machinelist) > 0)
				message = "FAILED: CANNOT PROBE WHEN BUFFER FULL"
				return
			
			for(var/obj/machinery/telecomms/message_server/T in GLOB.telecomms_list)
				if(T.network == network)
					LAZYADD(machinelist, T)

			if(!LAZYLEN(machinelist))
				message = "FAILED: UNABLE TO LOCATE NETWORK ENTITIES IN \[[network]\]"
				return
		if("viewmachine")	//selected but not authorized
			for(var/obj/machinery/telecomms/message_server/T in machinelist)
				if(T.id == params["value"])
					linkedServer = T
					break

		if("auth")
			if(!linkedServer.on)
				message = noserver
				return
			if(auth)
				auth = FALSE
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
			else if(linkedServer.on)
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
			if(!linkedServer.on)
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
			else if(!linkedServer.on)
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
			else if(!linkedServer.on)
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
				message = "WARNING: Auth failed! Operation aborted!"
				return
			if("reset" in params)
				ResetMessage()
				return
			if("send" in params)
				if(isnull(customrecepient))
					message = "NOTICE: No recepient selected!"
					return
				if(isnull(custommessage) || custommessage == "")
					message = "NOTICE: No message entered!"
					return

				if(isnull(customsender) || customsender == "")
					customsender = "UNKNOWN"

				var/datum/signal/subspace/pda/signal = new(src, list(
					"name" = customsender,
					"job" = customjob,
					"message" = custommessage,
					"emojis" = TRUE,
					"targets" = list("[customrecepient.owner] ([customrecepient.ownjob])")
				))
				// this will log the signal and transmit it to the target
				linkedServer.receive_information(signal, null)
				usr.log_message("(PDA: [name] | [usr.real_name]) sent \"[custommessage]\" to [signal.format_target()]", LOG_PDA)
				return
			// Do not check if it's blank yet
			if("sender" in params)
				customsender = params["sender"]
				return
			if("job" in params)
				customjob = params["job"]
				return
			if("message" in params)
				custommessage = params["message"]
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
	if(istype(O, /obj/item/screwdriver) && CHECK_BITFIELD(obj_flags, EMAGGED))
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
	message = rebootmsg
	return TRUE

/obj/machinery/computer/message_monitor/New()
	. = ..()
	GLOB.telecomms_list += src

/obj/machinery/computer/message_monitor/Destroy()
	GLOB.telecomms_list -= src
	. = ..()
/*
/obj/machinery/computer/message_monitor/ui_interact(mob/living/user)
	. = ..()
	//If the computer is being hacked or is emagged, display the reboot message.
	if(hacking || (obj_flags & EMAGGED))
		message = rebootmsg
	var/dat = "<center><font color='blue'[message]</font></center>"

	if(auth)
		dat += "<h4><dd><A href='?src=[REF(src)];auth=1'>&#09;<font color='green'>\[Authenticated\]</font></a>&#09;/"
		dat += " Server Power: <A href='?src=[REF(src)];active=1'>[linkedServer && linkedServer.toggled ? "<font color='green'>\[On\]</font>":"<font color='red'>\[Off\]</font>"]</a></h4>"
	else
		dat += "<h4><dd><A href='?src=[REF(src)];auth=1'>&#09;<font color='red'>\[Unauthenticated\]</font></a>&#09;/"
		dat += " Server Power: <u>[linkedServer && linkedServer.toggled ? "<font color='green'>\[On\]</font>":"<font color='red'>\[Off\]</font>"]</u></h4>"

	if(hacking || (obj_flags & EMAGGED))
		screen = 2
	else if(!auth || linkedServer.on)
		if(linkedServer.on)
			message = noserver
		screen = 0

	switch(screen)
		//Main menu
		if(0)
			//&#09; = TAB
			var/i = 0
			dat += "<dd><A href='?src=[REF(src)];find=1'>&#09;[++i]. Link To A Server</a></dd>"
			if(auth)
				if(linkedServer.on)
					dat += "<dd><A>&#09;ERROR: Server not found!</A><br></dd>"
				else
					dat += "<dd><A href='?src=[REF(src)];view_logs=1'>&#09;[++i]. View Message Logs </a><br></dd>"
					dat += "<dd><A href='?src=[REF(src)];view_requests=1'>&#09;[++i]. View Request Console Logs </a></br></dd>"
					dat += "<dd><A href='?src=[REF(src)];clear_logs=1'>&#09;[++i]. Clear Message Logs</a><br></dd>"
					dat += "<dd><A href='?src=[REF(src)];clear_requests=1'>&#09;[++i]. Clear Request Console Logs</a><br></dd>"
					dat += "<dd><A href='?src=[REF(src)];pass=1'>&#09;[++i]. Set Custom Key</a><br></dd>"
					dat += "<dd><A href='?src=[REF(src)];msg=1'>&#09;[++i]. Send Admin Message</a><br></dd>"
			else
				for(var/n = ++i; n <= optioncount; n++)
					dat += "<dd><font color='blue'>&#09;[n]. ---------------</font><br></dd>"
			var/mob/living/silicon/S = usr
			if(istype(S) && S.hack_software)
				//Malf/Traitor AIs can bruteforce into the system to gain the Key.
				dat += "<dd><A href='?src=[REF(src)];hack=1'><i><font color='Red'>*&@#. Bruteforce Key</font></i></font></a><br></dd>"
			else
				dat += "<br>"

			//Bottom message
			if(!auth)
				dat += "<br><hr><dd><span class='notice'>Please authenticate with the server in order to show additional options.</span>"
			else
				dat += "<br><hr><dd><span class='warning'>Reg, #514 forbids sending messages to a Head of Staff containing Erotic Rendering Properties.</span>"

		//Message Logs
		if(1)
			var/index = 0
			dat += "<center><A href='?src=[REF(src)];back=1'>Back</a> - <A href='?src=[REF(src)];refresh=1'>Refresh</a></center><hr>"
			dat += "<table border='1' width='100%'><tr><th width = '5%'>X</th><th width='15%'>Sender</th><th width='15%'>Recipient</th><th width='300px' word-wrap: break-word>Message</th></tr>"
			for(var/datum/data_pda_msg/pda in linkedServer.pda_msgs)
				index++
				if(index > 3000)
					break
				// Del - Sender   - Recepient - Message
				// X   - Al Green - Your Mom  - WHAT UP!?
				dat += "<tr><td width = '5%'><center><A href='?src=[REF(src)];delete_logs=[REF(pda)]' style='color: rgb(255,0,0)'>X</a></center></td><td width='15%'>[pda.sender]</td><td width='15%'>[pda.recipient]</td><td width='300px'>[pda.message][pda.picture ? " <a href='byond://?src=[REF(pda)];photo=1'>(Photo)</a>":""]</td></tr>"
			dat += "</table>"
		//Hacking screen.
		if(2)
			if(isAI(user) || iscyborg(user))
				dat += "Brute-forcing for server key.<br> It will take 20 seconds for every character that the password has."
				dat += "In the meantime, this console can reveal your true intentions if you let someone access it. Make sure no humans enter the room during that time."
			else
				//It's the same message as the one above but in binary. Because robots understand binary and humans don't... well I thought it was clever.
				dat += {"01000010011100100111010101110100011001010010110<br>
				10110011001101111011100100110001101101001011011100110011<br>
				10010000001100110011011110111001000100000011100110110010<br>
				10111001001110110011001010111001000100000011010110110010<br>
				10111100100101110001000000100100101110100001000000111011<br>
				10110100101101100011011000010000001110100011000010110101<br>
				10110010100100000001100100011000000100000011100110110010<br>
				10110001101101111011011100110010001110011001000000110011<br>
				00110111101110010001000000110010101110110011001010111001<br>
				00111100100100000011000110110100001100001011100100110000<br>
				10110001101110100011001010111001000100000011101000110100<br>
				00110000101110100001000000111010001101000011001010010000<br>
				00111000001100001011100110111001101110111011011110111001<br>
				00110010000100000011010000110000101110011001011100010000<br>
				00100100101101110001000000111010001101000011001010010000<br>
				00110110101100101011000010110111001110100011010010110110<br>
				10110010100101100001000000111010001101000011010010111001<br>
				10010000001100011011011110110111001110011011011110110110<br>
				00110010100100000011000110110000101101110001000000111001<br>
				00110010101110110011001010110000101101100001000000111100<br>
				10110111101110101011100100010000001110100011100100111010<br>
				10110010100100000011010010110111001110100011001010110111<br>
				00111010001101001011011110110111001110011001000000110100<br>
				10110011000100000011110010110111101110101001000000110110<br>
				00110010101110100001000000111001101101111011011010110010<br>
				10110111101101110011001010010000001100001011000110110001<br>
				10110010101110011011100110010000001101001011101000010111<br>
				00010000001001101011000010110101101100101001000000111001<br>
				10111010101110010011001010010000001101110011011110010000<br>
				00110100001110101011011010110000101101110011100110010000<br>
				00110010101101110011101000110010101110010001000000111010<br>
				00110100001100101001000000111001001101111011011110110110<br>
				10010000001100100011101010111001001101001011011100110011<br>
				10010000001110100011010000110000101110100001000000111010<br>
				001101001011011010110010100101110"}

		//Fake messages
		if(3)
			dat += "<center><A href='?src=[REF(src)];back=1'>Back</a> - <A href='?src=[REF(src)];Reset=1'>Reset</a></center><hr>"

			dat += {"<table border='1' width='100%'>
					<tr><td width='20%'><A href='?src=[REF(src)];select=Sender'>Sender</a></td>
					<td width='20%'><A href='?src=[REF(src)];select=RecJob'>Sender's Job</a></td>
					<td width='20%'><A href='?src=[REF(src)];select=Recepient'>Recipient</a></td>
					<td width='300px' word-wrap: break-word><A href='?src=[REF(src)];select=Message'>Message</a></td></tr>"}
				//Sender  - Sender's Job  - Recepient - Message
				//Al Green- Your Dad	  - Your Mom  - WHAT UP!?

			dat += {"<tr><td width='20%'>[customsender]</td>
			<td width='20%'>[customjob]</td>
			<td width='20%'>[customrecepient ? customrecepient.owner : "NONE"]</td>
			<td width='300px'>[custommessage]</td></tr>"}
			dat += "</table><br><center><A href='?src=[REF(src)];select=Send'>Send</a>"

		//Request Console Logs
		if(4)

			var/index = 0
			/* 	data_rc_msg
				X												 - 5%
				var/rec_dpt = "Unspecified" //name of the person - 15%
				var/send_dpt = "Unspecified" //name of the sender- 15%
				var/message = "Blank" //transferred message		 - 300px
				var/stamp = "Unstamped"							 - 15%
				var/id_auth = "Unauthenticated"					 - 15%
				var/priority = "Normal"							 - 10%
			*/
			dat += "<center><A href='?src=[REF(src)];back=1'>Back</a> - <A href='?src=[REF(src)];refresh=1'>Refresh</a></center><hr>"
			dat += {"<table border='1' width='100%'><tr><th width = '5%'>X</th><th width='15%'>Sending Dep.</th><th width='15%'>Receiving Dep.</th>
			<th width='300px' word-wrap: break-word>Message</th><th width='15%'>Stamp</th><th width='15%'>ID Auth.</th><th width='15%'>Priority.</th></tr>"}
			for(var/datum/data_rc_msg/rc in linkedServer.rc_msgs)
				index++
				if(index > 3000)
					break
				// Del - Sender   - Recepient - Message
				// X   - Al Green - Your Mom  - WHAT UP!?
				dat += {"<tr><td width = '5%'><center><A href='?src=[REF(src)];delete_requests=[REF(rc)]' style='color: rgb(255,0,0)'>X</a></center></td><td width='15%'>[rc.send_dpt]</td>
				<td width='15%'>[rc.rec_dpt]</td><td width='300px'>[rc.message]</td><td width='15%'>[rc.stamp]</td><td width='15%'>[rc.id_auth]</td><td width='15%'>[rc.priority]</td></tr>"}
			dat += "</table>"

	message = defaultmsg
	var/datum/browser/popup = new(user, "hologram_console", name, 700, 700)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()
*/
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

/*
/obj/machinery/computer/message_monitor/Topic(href, href_list)
	if(..())
		return

	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || hasSiliconAccessInArea(usr))
		//Authenticate
		if (href_list["auth"])
			if(linkedServer.on)
				message = noserver
			else if(auth)
				auth = FALSE
				screen = 0
			else
				var/dkey = trim(input(usr, "Please enter the decryption key.") as text|null)
				if(dkey && dkey != "")
					if(linkedServer.decryptkey == dkey)
						auth = TRUE
					else
						message = incorrectkey

		//Turn the server on/off.
		if (href_list["active"])
			if(linkedServer.on)
				message = noserver
			else if(auth)
				linkedServer.toggled = !linkedServer.toggled
		//Find a server
		if (href_list["find"])
			var/list/message_servers = list()
			for (var/obj/machinery/telecomms/message_server/M in GLOB.telecomms_list)
				message_servers += M

			if(message_servers.len > 1)
				linkedServer = input(usr, "Please select a server.", "Select a server.", null) as null|anything in message_servers
				message = "<span class='alert'>NOTICE: Server selected.</span>"
			else if(message_servers.len > 0)
				linkedServer = message_servers[1]
				message =  "<span class='notice'>NOTICE: Only Single Server Detected - Server selected.</span>"
			else
				message = noserver

		//View the logs - KEY REQUIRED
		if (href_list["view_logs"])
			if(linkedServer.on)
				message = noserver
			else if(auth)
				screen = 1

		//Clears the logs - KEY REQUIRED
		if (href_list["clear_logs"])
			if(linkedServer.on)
				message = noserver
			else if(auth)
				linkedServer.pda_msgs = list()
				message = "<span class='notice'>NOTICE: Logs cleared.</span>"
		//Clears the request console logs - KEY REQUIRED
		if (href_list["clear_requests"])
			if(linkedServer.on)
				message = noserver
			else if(auth)
				linkedServer.rc_msgs = list()
				message = "<span class='notice'>NOTICE: Logs cleared.</span>"
		//Change the password - KEY REQUIRED
		if (href_list["pass"])
			if(linkedServer.on)
				message = noserver
			else if(auth)
				var/dkey = stripped_input(usr, "Please enter the decryption key.")
				if(dkey && dkey != "")
					if(linkedServer.decryptkey == dkey)
						var/newkey = trim(input(usr,"Please enter the new key (3 - 16 characters max):"))
						if(length(newkey) <= 3)
							message = "<span class='notice'>NOTICE: Decryption key too short!</span>"
						else if(length(newkey) > 16)
							message = "<span class='notice'>NOTICE: Decryption key too long!</span>"
						else if(newkey && newkey != "")
							linkedServer.decryptkey = newkey
						message = "<span class='notice'>NOTICE: Decryption key set.</span>"
					else
						message = incorrectkey

		//Hack the Console to get the password
		if (href_list["hack"])
			var/mob/living/silicon/S = usr
			if(istype(S) && S.hack_software)
				hacking = TRUE
				screen = 2
				//Time it takes to bruteforce is dependant on the password length.
				spawn(100*length(linkedServer.decryptkey))
					if(src && linkedServer && usr)
						BruteForce(usr)
		//Delete the log.
		if (href_list["delete_logs"])
			//Are they on the view logs screen?
			if(screen == 1)
				if(linkedServer.on)
					message = noserver
				else //if(istype(href_list["delete_logs"], /datum/data_pda_msg))
					linkedServer.pda_msgs -= locate(href_list["delete_logs"])
					message = "<span class='notice'>NOTICE: Log Deleted!</span>"
		//Delete the request console log.
		if (href_list["delete_requests"])
			//Are they on the view logs screen?
			if(screen == 4)
				if(linkedServer.on)
					message = noserver
				else //if(istype(href_list["delete_logs"], /datum/data_pda_msg))
					linkedServer.rc_msgs -= locate(href_list["delete_requests"])
					message = "<span class='notice'>NOTICE: Log Deleted!</span>"
		//Create a custom message
		if (href_list["msg"])
			if(linkedServer.on)
				message = noserver
			else if(auth)
				screen = 3
		//Fake messaging selection - KEY REQUIRED
		if (href_list["select"])
			if(linkedServer.on)
				message = noserver
				screen = 0
			else
				switch(href_list["select"])

					//Reset
					if("Reset")
						ResetMessage()

					//Select Your Name
					if("Sender")
						customsender = stripped_input(usr, "Please enter the sender's name.") || customsender

					//Select Receiver
					if("Recepient")
						//Get out list of viable PDAs
						var/list/obj/item/pda/sendPDAs = get_viewable_pdas()
						if(GLOB.PDAs && GLOB.PDAs.len > 0)
							customrecepient = input(usr, "Select a PDA from the list.") as null|anything in sortNames(sendPDAs)
						else
							customrecepient = null

					//Enter custom job
					if("RecJob")
						customjob = stripped_input(usr, "Please enter the sender's job.") || customjob

					//Enter message
					if("Message")
						custommessage = stripped_input(usr, "Please enter your message.") || custommessage

					//Send message
					if("Send")
						if(isnull(customsender) || customsender == "")
							customsender = "UNKNOWN"

						if(isnull(customrecepient))
							message = "<span class='notice'>NOTICE: No recepient selected!</span>"
							return attack_hand(usr)

						if(isnull(custommessage) || custommessage == "")
							message = "<span class='notice'>NOTICE: No message entered!</span>"
							return attack_hand(usr)

						var/datum/signal/subspace/pda/signal = new(src, list(
							"name" = "[customsender]",
							"job" = "[customjob]",
							"message" = custommessage,
							"emojis" = TRUE,
							"targets" = list("[customrecepient.owner] ([customrecepient.ownjob])")
						))
						// this will log the signal and transmit it to the target
						linkedServer.receive_information(signal, null)
						usr.log_message("(PDA: [name] | [usr.real_name]) sent \"[custommessage]\" to [signal.format_target()]", LOG_PDA)


		//Request Console Logs - KEY REQUIRED
		if(href_list["view_requests"])
			if(linkedServer.on)
				message = noserver
			else if(auth)
				screen = 4

		if (href_list["back"])
			screen = 0

	return attack_hand(usr)
*/

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
	info_links = info
	add_overlay("paper_words")

/obj/item/paper/monitorkey/LateInitialize()
	for(var/obj/machinery/telecomms/message_server/server in GLOB.telecomms_list)
		if(server.decryptkey)
			print(server)
			break
