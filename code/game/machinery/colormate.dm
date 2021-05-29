/obj/machinery/gear_painter
	name = "\improper Color Mate"
	desc = "A machine to give your apparel a fresh new color! Recommended to use with white items for best results."
	icon = 'icons/obj/vending.dmi'
	icon_state = "colormate"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/colormate
	var/atom/movable/inserted
	var/activecolor = "#FFFFFF"
	var/list/color_matrix_last
	var/matrix_mode = FALSE
	/// Allow holder'd mobs
	var/allow_mobs = TRUE
	/// Minimum lightness for normal mode
	var/minimum_normal_lightness = 50
	/// Minimum lightness for matrix mode, tested using 4 test colors of full red, green, blue, white.
	var/minimum_matrix_lightness = 75
	/// Minimum matrix tests that must pass for something to be considered a valid color (see above)
	var/minimum_matrix_tests = 2
	var/list/allowed_types = list(
			/obj/item/clothing,
			/obj/item/storage/backpack,
			/obj/item/storage/belt
			)

/obj/machinery/gear_painter/Initialize(mapload)
	. = ..()
	color_matrix_last = list(
		1, 0, 0,
		0, 1, 0,
		0, 0, 1,
		0, 0, 0
	)

/obj/machinery/gear_painter/update_icon_state()
	if(panel_open)
		icon_state = "colormate_open"
	else if(!is_operational)
		icon_state = "colormate_off"
	else if(inserted)
		icon_state = "colormate_active"
	else
		icon_state = "colormate"

/obj/machinery/gear_painter/Destroy()
	if(inserted) //please i beg you do not drop nulls
		inserted.forceMove(drop_location())
	return ..()

/obj/machinery/gear_painter/attackby(obj/item/I, mob/living/user)
	if(inserted)
		to_chat(user, "<span class='warning'>The machine is already loaded.</span>")
		return
	if(default_deconstruction_screwdriver(user, "colormate_open", "colormate", I))
		return
	if(default_deconstruction_crowbar(I))
		return
	if(default_unfasten_wrench(user, I, 40))
		return
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(allow_mobs && istype(I, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/H = I
		var/mob/victim = H.held_mob
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return
		if(!QDELETED(H))
			H.release()
		insert_mob(victim, user)

	if(is_type_in_list(I, allowed_types) && is_operational)
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
			return
		if(QDELETED(I))
			return
		user.visible_message("<span class='notice'>[user] inserts [I] into [src]'s receptable.</span>")

		inserted = I
		update_icon()
	else
		return ..()

/obj/machinery/gear_painter/proc/insert_mob(mob/victim, mob/user)
	if(inserted)
		return
	if(user)
		visible_message("<span class='warning'>[user] stuffs [victim] into [src]!</span>")
	inserted = victim
	inserted.forceMove(src)

/obj/machinery/gear_painter/AllowDrop()
	return FALSE

/obj/machinery/gear_painter/handle_atom_del(atom/movable/AM)
	if(AM == inserted)
		inserted = null
	return ..()

/obj/machinery/gear_painter/AltClick(mob/user)
	. = ..()
	if(!user.CanReach(src))
		return
	if(!inserted)
		return
	to_chat(user, "<span class='notice'>You remove [inserted] from [src]")
	inserted.forceMove(drop_location())
	inserted = null
	update_icon()
	updateUsrDialog()

/obj/machinery/gear_painter/ui_interact(mob/user)
	if(!is_operational)
		return
	user.set_machine(src)
	var/list/dat = list("<TITLE>Color Mate Control Panel</TITLE><BR>")
	if(!inserted)
		dat += "No item inserted."
	else
		dat += "Item inserted: [inserted]<HR>"
		dat += "<a href='?src=[REF(src)];toggle_matrix_mode=1'>Matrix mode: [matrix_mode? "On" : "Off"]</a>"
		if(!matrix_mode)
			dat += "<A href='?src=\ref[src];select=1'>Select new color.</A><BR>"
			dat += "Color: <font color='[activecolor]'>&#9899;</font>"
			dat += "<A href='?src=\ref[src];paint=1'>Apply new color.</A><BR><BR>"
		else
			// POGGERS
#define MATRIX_FIELD(field, default) "<b><label for='[##field]'>[##field]</label></b> <input type='number' step='0.001' name='[field]' value='[default]'>"
			dat += "<br><form name='matrix paint' action='?src=[REF(src)]'>"
			dat += "<input type='hidden' name='src' value='[REF(src)]'>"
			dat += "<input type='hidden' name='matrix_paint' value='1'"
			dat += "<br><br>"
			dat += MATRIX_FIELD("rr", color_matrix_last[1])
			dat += MATRIX_FIELD("gr", color_matrix_last[4])
			dat += MATRIX_FIELD("br", color_matrix_last[7])
			dat += "<br><br>"
			dat += MATRIX_FIELD("rg", color_matrix_last[2])
			dat += MATRIX_FIELD("gg", color_matrix_last[5])
			dat += MATRIX_FIELD("bg", color_matrix_last[8])
			dat += "<br><br>"
			dat += MATRIX_FIELD("rb", color_matrix_last[3])
			dat += MATRIX_FIELD("gb", color_matrix_last[6])
			dat += MATRIX_FIELD("bb", color_matrix_last[9])
			dat += "<br><br>"
			dat += MATRIX_FIELD("cr", color_matrix_last[10])
			dat += MATRIX_FIELD("cg", color_matrix_last[11])
			dat += MATRIX_FIELD("cb", color_matrix_last[12])
			dat += "<br><br>"
			dat += "<input type='submit' value='Matrix Paint'>"
			dat += "</form><br>"
#undef MATRIX_FIELD
		dat += "<A href='?src=\ref[src];clear=1'>Remove paintjob.</A><BR><BR>"
		dat += "<A href='?src=\ref[src];eject=1'>Eject item.</A><BR><BR>"

	var/datum/browser/menu = new(user, "colormate","Color Mate Control Panel", 800, 600, src)
	menu.set_content(dat.Join(""))
	menu.open()

/obj/machinery/gear_painter/Topic(href, href_list)
	if((. = ..()))
		return

	add_fingerprint(usr)

	if(href_list["close"])
		usr << browse(null, "window=colormate")
		return

	if(href_list["select"])
		var/newcolor = input(usr, "Choose a color.", "", activecolor) as color|null
		if(newcolor)
			activecolor = newcolor
		updateUsrDialog()

	if(href_list["paint"])
		if(!inserted)
			return
		if(!check_valid_color(activecolor, usr))
			return
		inserted.add_atom_colour(activecolor, FIXED_COLOUR_PRIORITY)
		playsound(src, 'sound/effects/spray3.ogg', 50, 1)
		updateUsrDialog()

	if(href_list["toggle_matrix_mode"])
		matrix_mode = !matrix_mode
		updateUsrDialog()

	if(href_list["matrix_paint"])
		if(!inserted)
			return
		// assemble matrix
		var/list/cm = rgb_construct_color_matrix(
			text2num(href_list["rr"]),
			text2num(href_list["rg"]),
			text2num(href_list["rb"]),
			text2num(href_list["gr"]),
			text2num(href_list["gg"]),
			text2num(href_list["gb"]),
			text2num(href_list["br"]),
			text2num(href_list["bg"]),
			text2num(href_list["bb"]),
			text2num(href_list["cr"]),
			text2num(href_list["cg"]),
			text2num(href_list["cb"])
		)
		color_matrix_last = cm.Copy()
		if(!check_valid_color(cm, usr))
			return
		inserted.add_atom_colour(cm, FIXED_COLOUR_PRIORITY)
		playsound(src, 'sound/effects/spray3.ogg', 50, 1)
		updateUsrDialog()

	if(href_list["clear"])
		if(!inserted)
			return
		inserted.remove_atom_colour(FIXED_COLOUR_PRIORITY)
		playsound(src, 'sound/effects/spray3.ogg', 50, 1)
		updateUsrDialog()

	if(href_list["eject"])
		if(!inserted)
			return
		inserted.forceMove(drop_location())
		inserted = null
		update_icon()
		updateUsrDialog()

/obj/machinery/gear_painter/proc/check_valid_color(list/cm, mob/user)
	if(!islist(cm))		// normal
		var/list/HSV = ReadHSV(RGBtoHSV(cm))
		if(HSV[3] < minimum_normal_lightness)
			to_chat(user, "<span class='warning'>[cm] is far too dark (min lightness [minimum_normal_lightness]!</span>")
			return FALSE
		return TRUE
	else	// matrix
		// We test using full red, green, blue, and white
		// A predefined number of them must pass to be considered valid
		var/passed = 0
#define COLORTEST(thestring, thematrix) passed += (ReadHSV(RGBtoHSV(RGBMatrixTransform(thestring, thematrix)))[3] >= minimum_matrix_lightness)
		COLORTEST("FF0000", cm)
		COLORTEST("00FF00", cm)
		COLORTEST("0000FF", cm)
		COLORTEST("FFFFFF", cm)
#undef COLORTEST
		if(passed < minimum_matrix_tests)
			to_chat(user, "<span class='warning'>[english_list(color)] is not allowed (pased [passed] out of 4, minimum [minimum_matrix_tests], minimum lightness [minimum_matrix_lightness]).</span>")
			return FALSE
		return TRUE
