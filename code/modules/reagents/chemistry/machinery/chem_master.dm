
/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_master

	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/bottle = null
	var/mode = 1
	var/condi = FALSE
	var/chosenPillStyle = 1
	var/screen = "home"
	var/analyzeVars[0]
	var/useramount = 30 // Last used amount
	var/list/pillStyles
	var/fermianalyze //Give more detail on fermireactions on analysis

/obj/machinery/chem_master/Initialize()
	create_reagents(100)

	//Calculate the span tags and ids fo all the available pill icons
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	pillStyles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		var/list/SL = list()
		SL["id"] = x
		SL["className"] = assets.icon_class_name("pill[x]")
		pillStyles += list(SL)

	. = ..()

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(bottle)
	return ..()

/obj/machinery/chem_master/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_master/contents_explosion(severity, target)
	..()
	if(beaker)
		beaker.ex_act(severity, target)
	if(bottle)
		bottle.ex_act(severity, target)

/obj/machinery/chem_master/Exited(atom/movable/A, atom/newloc)
	. = ..()
	if(A == beaker)
		beaker = null
		update_appearance()
	if(A == bottle)
		bottle = null
		update_appearance()

/obj/machinery/chem_master/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		update_appearance()
	else if(A == bottle)
		bottle = null

/obj/machinery/chem_master/update_icon_state()
	icon_state = "mixer[beaker ? 1 : 0]"
	return ..()

/obj/machinery/chem_master/update_overlays()
	. = ..()
	if(machine_stat & BROKEN)
		. += "waitlight"

/obj/machinery/chem_master/blob_act(obj/structure/blob/B)
	if (prob(50))
		qdel(src)

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
		return

	else if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE // no afterattack
		if(panel_open)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		var/obj/item/reagent_containers/B = I
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
	else if(!condi && istype(I, /obj/item/storage/pill_bottle))
		. = TRUE // no afterattack
		if(panel_open)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		replace_pillbottle(user, I)
		to_chat(user, "<span class='notice'>You add [I] into the dispenser slot.</span>")
		updateUsrDialog()
	else
		return ..()

/obj/machinery/chem_master/AltClick(mob/living/user)
	. = ..()
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(beaker)
		replace_beaker(user)
	else if(bottle)
		replace_pillbottle(user)
	return TRUE

/obj/machinery/chem_master/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		var/obj/item/reagent_containers/B = beaker
		B.forceMove(drop_location())
		if(user && Adjacent(user) && user.can_hold_items())
			user.put_in_hands(B)
	if(new_beaker)
		beaker = new_beaker
	update_icon()

/obj/machinery/chem_master/proc/replace_pillbottle(mob/living/user, obj/item/storage/pill_bottle/new_bottle)
	if(bottle)
		var/obj/item/storage/pill_bottle/B = bottle
		B.forceMove(drop_location())
		if(user && Adjacent(user) && user.can_hold_items())
			user.put_in_hands(B)
		else
			adjust_item_drop_location(B)
	if(new_bottle)
		bottle = new_bottle

/obj/machinery/chem_master/on_deconstruction()
	var/atom/A = drop_location()
	beaker?.forceMove(A)
	bottle?.forceMove(A)
	return ..()

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/pills),
	)

/obj/machinery/chem_master/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.open()

/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["mode"] = mode
	data["condi"] = condi
	data["screen"] = screen
	data["analyzeVars"] = analyzeVars
	data["fermianalyze"] = fermianalyze
	data["chosenPillStyle"] = chosenPillStyle
	data["isPillBottleLoaded"] = bottle ? 1 : 0
	if(bottle)
		var/datum/component/storage/STRB = bottle.GetComponent(/datum/component/storage)
		data["pillBottleCurrentAmount"] = bottle.contents.len
		data["pillBottleMaxAmount"] = STRB.max_items

	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = R.type, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	var/bufferContents[0]
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			bufferContents.Add(list(list("name" = N.name, "id" = N.type, "volume" = N.volume))) // ^
	data["bufferContents"] = bufferContents

	//Calculated at init time as it never changes
	data["pillStyles"] = pillStyles
	return data

/obj/machinery/chem_master/ui_act(action, params)
	if(..())
		return

	if(action == "eject")
		replace_beaker(usr)
		return TRUE

	if(action == "ejectPillBottle")
		if(!bottle)
			return FALSE
		bottle.forceMove(drop_location())
		adjust_item_drop_location(bottle)
		bottle = null
		return TRUE

	if(action == "transfer")
		if(!beaker)
			return FALSE
		var/reagent = text2path(params["id"])
		var/amount = text2num(params["amount"])
		var/to_container = params["to"]
		// Custom amount
		if (amount == -1)
			amount = text2num(input(
				"Enter the amount you want to transfer:",
				name, ""))
		if (amount == null || amount <= 0)
			return FALSE
		if (to_container == "buffer")
			end_fermi_reaction()
			beaker.reagents.trans_id_to(src, reagent, amount)
			return TRUE
		if (to_container == "beaker" && mode)
			end_fermi_reaction()
			reagents.trans_id_to(beaker, reagent, amount)
			return TRUE
		if (to_container == "beaker" && !mode)
			end_fermi_reaction()
			reagents.remove_reagent(reagent, amount)
			return TRUE
		return FALSE

	if(action == "toggleMode")
		mode = !mode
		return TRUE

	if(action == "pillStyle")
		var/id = text2num(params["id"])
		chosenPillStyle = id
		return TRUE

	if(action == "create")
		if(reagents.total_volume == 0)
			return FALSE
		var/item_type = params["type"]
		// Get amount of items
		var/amount = text2num(params["amount"])
		if(amount == null)
			amount = text2num(input(usr,
				"Max 20. Buffer content will be split evenly.",
				"How many to make?", 1))
		amount = clamp(round(amount), 0, 20)
		if (amount <= 0)
			return FALSE
		// Get units per item
		var/vol_each = text2num(params["volume"])
		var/vol_each_text = params["volume"]
		var/vol_each_max = reagents.total_volume / amount
		if (item_type == "pill")
			vol_each_max = min(50, vol_each_max)
		else if (item_type == "patch")
			vol_each_max = min(40, vol_each_max)
		else if (item_type == "bottle")
			vol_each_max = min(30, vol_each_max)
		else if (item_type == "condimentPack")
			vol_each_max = min(10, vol_each_max)
		else if (item_type == "condimentBottle")
			vol_each_max = min(50, vol_each_max)
		else if (item_type == "hypoVial")
			vol_each_max = min(60, vol_each_max)
		else if (item_type == "smartDart")
			vol_each_max = min(20, vol_each_max)
		else
			return FALSE
		if(vol_each_text == "auto")
			vol_each = vol_each_max
		if(vol_each == null)
			vol_each = text2num(input(usr,
				"Maximum [vol_each_max] units per item.",
				"How many units to fill?",
				vol_each_max))
		vol_each = clamp(vol_each, 0, vol_each_max)
		if(vol_each <= 0)
			return FALSE
		// Get item name
		var/name = params["name"]
		var/name_has_units = item_type == "pill" || item_type == "patch"
		if(!name)
			var/name_default = reagents.get_master_reagent_name()
			if (name_has_units)
				name_default += " ([vol_each]u)"
			name = stripped_input(usr,
				"Name:",
				"Give it a name!",
				name_default,
				MAX_NAME_LEN)
		if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
			return FALSE
		// Start filling
		if(item_type == "pill")
			var/obj/item/reagent_containers/pill/P
			var/target_loc = drop_location()
			var/drop_threshold = INFINITY
			if(bottle)
				var/datum/component/storage/STRB = bottle.GetComponent(
					/datum/component/storage)
				if(STRB)
					drop_threshold = STRB.max_items - bottle.contents.len
			for(var/i = 0; i < amount; i++)
				if(i < drop_threshold)
					P = new/obj/item/reagent_containers/pill(target_loc)
				else
					P = new/obj/item/reagent_containers/pill(drop_location())
				P.name = trim("[name] pill")
				if(chosenPillStyle == RANDOM_PILL_STYLE)
					P.icon_state ="pill[rand(1,21)]"
				else
					P.icon_state = "pill[chosenPillStyle]"
				if(P.icon_state == "pill4")
					P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each)//, transfered_by = usr)
			return TRUE
		if(item_type == "patch")
			var/obj/item/reagent_containers/pill/patch/P
			for(var/i = 0; i < amount; i++)
				P = new/obj/item/reagent_containers/pill/patch(drop_location())
				P.name = trim("[name] patch")
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each)//, transfered_by = usr)
			return TRUE
		if(item_type == "bottle")
			var/obj/item/reagent_containers/glass/bottle/P
			for(var/i = 0; i < amount; i++)
				P = new/obj/item/reagent_containers/glass/bottle(drop_location())
				P.name = trim("[name] bottle")
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each)//, transfered_by = usr)
			return TRUE
		if(item_type == "condimentPack")
			var/obj/item/reagent_containers/food/condiment/pack/P
			for(var/i = 0; i < amount; i++)
				P = new/obj/item/reagent_containers/food/condiment/pack(drop_location())
				P.originalname = name
				P.name = trim("[name] pack")
				P.desc = "A small condiment pack. The label says it contains [name]."
				reagents.trans_to(P, vol_each)//, transfered_by = usr)
			return TRUE
		if(item_type == "condimentBottle")
			var/obj/item/reagent_containers/food/condiment/P
			for(var/i = 0; i < amount; i++)
				P = new/obj/item/reagent_containers/food/condiment(drop_location())
				P.originalname = name
				P.name = trim("[name] bottle")
				reagents.trans_to(P, vol_each)//, transfered_by = usr)
			return TRUE
		if(item_type == "hypoVial")
			var/obj/item/reagent_containers/glass/bottle/vial/small/P
			for(var/i = 0; i < amount; i++)
				P = new/obj/item/reagent_containers/glass/bottle/vial/small(drop_location())
				P.name = trim("[name] hypovial")
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each)//, transfered_by = usr)
			return TRUE
		if(item_type == "smartDart")
			var/obj/item/reagent_containers/syringe/dart/P
			for(var/i = 0; i < amount; i++)
				P = new /obj/item/reagent_containers/syringe/dart(drop_location())
				P.name = trim("[name] SmartDart")
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each)//, transfered_by = usr)
				P.mode=!mode
				P.update_icon()
			return TRUE
		return FALSE

	if(action == "analyze")
		// var/datum/reagent/R = GLOB.name2reagent[params["id"]]
		var/reagent = text2path(params["id"])
		var/datum/reagent/R = GLOB.chemical_reagents_list[reagent]
		if(R)
			var/state = "Unknown"
			if(initial(R.reagent_state) == 1)
				state = "Solid"
			else if(initial(R.reagent_state) == 2)
				state = "Liquid"
			else if(initial(R.reagent_state) == 3)
				state = "Gas"
			var/const/P = 3 //The number of seconds between life ticks
			var/T = initial(R.metabolization_rate) * (60 / P)
			if(istype(R, /datum/reagent/fermi))
				fermianalyze = TRUE
				var/datum/chemical_reaction/Rcr = get_chemical_reaction(reagent)
				var/pHpeakCache = (Rcr.OptimalpHMin + Rcr.OptimalpHMax)/2
				analyzeVars = list("name" = initial(R.name), "state" = state, "color" = initial(R.color), "description" = initial(R.description), "metaRate" = T, "overD" = initial(R.overdose_threshold), "addicD" = initial(R.addiction_threshold), "purityF" = R.purity, "inverseRatioF" = initial(R.inverse_chem_val), "purityE" = initial(Rcr.PurityMin), "minTemp" = initial(Rcr.OptimalTempMin), "maxTemp" = initial(Rcr.OptimalTempMax), "eTemp" = initial(Rcr.ExplodeTemp), "pHpeak" = pHpeakCache)
			else
				fermianalyze = FALSE
				analyzeVars = list("name" = initial(R.name), "state" = state, "color" = initial(R.color), "description" = initial(R.description), "metaRate" = T, "overD" = initial(R.overdose_threshold), "addicD" = initial(R.addiction_threshold), "purityF" = R.purity)
			screen = "analyze"
			return TRUE

	if(action == "goScreen")
		screen = params["screen"]
		return TRUE

	return FALSE



/obj/machinery/chem_master/proc/end_fermi_reaction()//Ends any reactions upon moving.
	if(beaker && beaker.reagents.fermiIsReacting)
		beaker.reagents.fermiEnd()

/obj/machinery/chem_master/proc/isgoodnumber(num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 0
		else
			num = round(num)
		return num
	else
		return 0


/obj/machinery/chem_master/adjust_item_drop_location(atom/movable/AM) // Special version for chemmasters and condimasters
	if (AM == beaker)
		AM.pixel_x = -8
		AM.pixel_y = 8
		return null
	else if (AM == bottle)
		if (length(bottle.contents))
			AM.pixel_x = -13
		else
			AM.pixel_x = -7
		AM.pixel_y = -8
		return null
	else
		var/md5 = md5(AM.name)
		for (var/i in 1 to 32)
			. += hex2num(md5[i])
		. = . % 9
		AM.pixel_x = ((.%3)*6)
		AM.pixel_y = -8 + (round( . / 3)*8)

/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."
	condi = TRUE

#undef PILL_STYLE_COUNT
#undef RANDOM_PILL_STYLE
