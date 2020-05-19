/obj/machinery/computer/cargo
	name = "supply console"
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon_screen = "supply"
	circuit = /obj/item/circuitboard/computer/cargo
	req_access = list(ACCESS_CARGO)
	ui_x = 780
	ui_y = 750

	var/requestonly = FALSE
	var/contraband = FALSE
	var/self_paid = FALSE
	var/safety_warning = "For safety reasons, the automated supply shuttle \
		cannot transport live organisms, human remains, classified nuclear weaponry, \
		homing beacons or machinery housing any form of artificial intelligence."
	var/blockade_warning = "Bluespace instability detected. Shuttle movement impossible."
	/// radio used by the console to send messages on supply channel
	var/obj/item/radio/headset/radio
	/// var that tracks message cooldown
	var/message_cooldown

	light_color = "#E2853D"//orange

	//Each cargo console and request console will need  a trade rout uploaded into them to unlock this
	//Emags
	var/permits = 0

/obj/machinery/computer/cargo/request
	name = "supply request console"
	desc = "Used to request supplies from cargo."
	icon_screen = "request"
	circuit = /obj/item/circuitboard/computer/cargo/request
	req_access = list()
	requestonly = TRUE

/obj/machinery/computer/cargo/Initialize()
	. = ..()
	radio = new /obj/item/radio/headset/headset_cargo(src)
	var/obj/item/circuitboard/computer/cargo/board = circuit
	contraband = board.contraband
	if (board.obj_flags & EMAGGED)
		obj_flags |= EMAGGED
	else
		obj_flags &= ~EMAGGED

/obj/machinery/computer/cargo/Destroy()
	QDEL_NULL(radio)
	..()

/obj/machinery/computer/cargo/proc/get_export_categories()
	. = EXPORT_CARGO
	if(contraband)
		. |= EXPORT_CONTRABAND
	if(obj_flags & EMAGGED)
		. |= EXPORT_EMAG

/obj/machinery/computer/cargo/emag_act(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	if(user)
		user.visible_message("<span class='warning'>[user] swipes a suspicious card through [src]!</span>",
		"<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

	obj_flags |= EMAGGED
	contraband = TRUE

	permits |= PREMIT_SPACE
	permits |= PREMIT_WEAPONS
	permits |= PERMIT_MEDCO
	permits |= PERMIT_BLACKMARKET
	permits |= PERMIT_ANIMALS
	permits |= PERMIT_ADVSCI

	// This also permamently sets this on the circuit board
	var/obj/item/circuitboard/computer/cargo/board = circuit

	board.contraband = TRUE

	board.permits |= PREMIT_SPACE
	board.permits |= PREMIT_WEAPONS
	board.permits |= PERMIT_MEDCO
	board.permits |= PERMIT_BLACKMARKET
	board.permits |= PERMIT_ANIMALS
	board.permits |= PERMIT_ADVSCI

	board.obj_flags |= EMAGGED
	req_access = list()
	update_static_data(user)
	return ..()

/obj/machinery/computer/cargo/attackby(obj/item/W, mob/living/user, params)
	var/obj/item/circuitboard/computer/cargo/board = circuit
	if((istype(W, /obj/item/folder/permit/space_gear)) && allowed(user) && !CHECK_BITFIELD(permits,PREMIT_SPACE))
		permits |= PREMIT_SPACE
		board.permits |= PREMIT_SPACE
		SSshuttle.supply.callTime += 15
		to_chat(user, "<span class='notice'>You upload the [W] into the console unlocking more options.</span>")
		qdel(W) //Yes we are one time use.
		return
	if((istype(W, /obj/item/folder/permit/heavy_firearms)) && allowed(user) && !CHECK_BITFIELD(permits,PREMIT_WEAPONS))
		permits |= PREMIT_WEAPONS
		board.permits |= PREMIT_WEAPONS
		SSshuttle.supply.callTime += 60
		to_chat(user, "<span class='notice'>You upload the [W] into the console unlocking more options.</span>")
		qdel(W) //Yes we are one time use.
		return
	if((istype(W, /obj/item/folder/permit/medco_trade)) && allowed(user) && !CHECK_BITFIELD(permits,PERMIT_MEDCO))
		permits |= PERMIT_MEDCO
		board.permits |= PERMIT_MEDCO
		SSshuttle.supply.callTime += 20
		to_chat(user, "<span class='notice'>You upload the [W] into the console unlocking more options.</span>")
		qdel(W) //Yes we are one time use.
		return
	if((istype(W, /obj/item/folder/permit/blackmarket)) && allowed(user) && !CHECK_BITFIELD(permits,PERMIT_BLACKMARKET))
		permits |= PERMIT_BLACKMARKET
		board.permits |= PERMIT_BLACKMARKET
		SSshuttle.supply.callTime += 120 //Backwater hidden route
		to_chat(user, "<span class='notice'>You upload the hidden trade route with [W] into the console unlocking more options.</span>")
		//qdel(W) //Shhhhhh Were not one time
		return
	if((istype(W, /obj/item/folder/permit/animal_handing)) && allowed(user) && !CHECK_BITFIELD(permits,PERMIT_ANIMALS))
		permits |= PERMIT_ANIMALS
		board.permits |= PERMIT_ANIMALS
		SSshuttle.supply.callTime += 5 //Local
		to_chat(user, "<span class='notice'>You upload the [W] into the console unlocking more options.</span>")
		qdel(W) //Yes we are one time use.
		return
	if((istype(W, /obj/item/folder/permit/adv_sci)) && allowed(user) && !CHECK_BITFIELD(permits,PERMIT_ADVSCI))
		permits |= PERMIT_ADVSCI
		board.permits |= PERMIT_ADVSCI
		SSshuttle.supply.callTime += 600 //Your connecting with a massive amout of routes and networking, its going to double your time
		to_chat(user, "<span class='notice'>You upload the [W] into the console unlocking more options.</span>")
		//qdel(W) //Were not one time use...
		return
	..()

/obj/machinery/computer/cargo/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cargo", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/cargo/ui_data()
	var/list/data = list()
	data["location"] = SSshuttle.supply.getStatusText()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		data["points"] = D.account_balance
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["self_paid"] = self_paid
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	var/message = "Remember to stamp and send back the supply manifests."
	if(SSshuttle.centcom_message)
		message = SSshuttle.centcom_message
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message
	data["cart"] = list()
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		data["cart"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"id" = SO.id,
			"orderer" = SO.orderer,
			"paid" = !isnull(SO.paying_account) //paid by requester
		))

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSshuttle.requestlist)
		data["requests"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id
		))

	return data

/obj/machinery/computer/cargo/ui_static_data(mob/user)
	var/list/data = list()
	data["requestonly"] = requestonly
	data["supplies"] = list()
	data["emagged"] = obj_flags & EMAGGED
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && !(obj_flags & EMAGGED)) || (P.contraband && !contraband) || (P.special && !P.special_enabled) || P.DropPodOnly)
			continue
		if((P.permits & permits) != P.permits)
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost,
			"id" = pack,
			"desc" = P.desc || P.name, // If there is a description, use it. Otherwise use the pack's name.
			"access" = P.access,
			"can_private_buy" = P.can_private_buy
		))
	return data

/obj/machinery/computer/cargo/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='notice'>Access denied.</span>")
		return
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				say(safety_warning)
				return
			if(SSshuttle.supplyBlocked)
				say(blockade_warning)
				return
			if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.supply.export_categories = get_export_categories()
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				say("The supply shuttle is departing.")
				investigate_log("[key_name(usr)] sent the supply shuttle away.", INVESTIGATE_CARGO)
			else
				investigate_log("[key_name(usr)] called the supply shuttle.", INVESTIGATE_CARGO)
				say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			if(SSshuttle.supplyBlocked)
				say(blockade_warning)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != "supply_away")
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				say("The supply shuttle has been loaned to CentCom.")
				. = TRUE
		if("add")
			var/id = text2path(params["id"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
			if((pack.hidden && !(obj_flags & EMAGGED)) || (pack.contraband && !contraband) || pack.DropPodOnly)
				return

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"

			var/datum/bank_account/account
			if(self_paid)
				if(!pack.can_private_buy && !(obj_flags & EMAGGED))
					return
				var/obj/item/card/id/id_card = usr.get_idcard(TRUE)
				if(!istype(id_card))
					say("No ID card detected.")
					return
				account = id_card.registered_account
				if(!istype(account))
					say("Invalid bank account.")
					return

			var/reason = ""
			if(requestonly && !self_paid)
				reason = stripped_input("Reason:", name, "")
				if(isnull(reason) || ..())
					return

			var/turf/T = get_turf(src)
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason, account)
			SO.generateRequisition(T)
			if(requestonly && !self_paid)
				SSshuttle.requestlist += SO
			else
				SSshuttle.shoppinglist += SO
				if(self_paid)
					say("Order processed. The price will be charged to [account.account_holder]'s bank account on delivery.")
			. = TRUE
		if("remove")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
				if(SO.id == id)
					SSshuttle.shoppinglist -= SO
					. = TRUE
					break
		if("clear")
			SSshuttle.shoppinglist.Cut()
			. = TRUE
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					SSshuttle.shoppinglist += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.requestlist.Cut()
			. = TRUE
		if("toggleprivate")
			self_paid = !self_paid
			. = TRUE
	if(.)
		post_signal("supply")

/obj/machinery/computer/cargo/proc/post_signal(command)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = command))
	frequency.post_signal(src, status_signal)
