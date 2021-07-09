/**********************Jaunter**********************/
/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least.\nThanks to modifications provided by the Free Golems, this jaunter can be worn on the belt to provide protection from chasms."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	slot_flags = ITEM_SLOT_BELT

/obj/item/wormhole_jaunter/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
	SSblackbox.record_feedback("tally", "jaunter", 1, "User") // user activated
	activate(user, TRUE)

/obj/item/wormhole_jaunter/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_BELT)
		RegisterSignal(user, COMSIG_MOVABLE_CHASM_DROP, .proc/chasm_react)

/obj/item/wormhole_jaunter/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_CHASM_DROP)

/obj/item/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf || is_centcom_level(device_turf.z) || is_reserved_level(device_turf.z))
		to_chat(user, "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/wormhole_jaunter/proc/get_destinations(mob/user)
	var/list/destinations = list()

	for(var/obj/item/beacon/B in GLOB.teleportbeacons)
		var/turf/T = get_turf(B)
		if(is_station_level(T.z))
			destinations += B

	return destinations

/obj/item/wormhole_jaunter/proc/activate(mob/user, adjacent, force_entry = FALSE)
	if(!turf_check(user))
		return

	var/list/L = get_destinations(user)
	if(!L.len)
		to_chat(user, "<span class='notice'>The [name] found no beacons in the world to anchor a wormhole to.</span>")
		return
	var/chosen_beacon = pick(L)
	var/obj/effect/portal/jaunt_tunnel/J = new (get_turf(src), 100, null, FALSE, get_turf(chosen_beacon))
	if(adjacent)
		try_move_adjacent(J)
	if(force_entry)
		J.teleport(user, force = TRUE)
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	qdel(src)

/obj/item/wormhole_jaunter/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	var/mob/M = loc
	if(istype(M))
		if(M.get_item_by_slot(SLOT_BELT) == src)
			if(M.prob_bad(severity))
				M.visible_message("<span class='warning'>[src] overloads and activates!</span>")
				SSblackbox.record_feedback("tally", "jaunter", 1, "EMP") // EMP accidental activation
				activate(M)

/obj/item/wormhole_jaunter/proc/chasm_react(mob/source, datum/component/chasm/C)
	to_chat(source, "Your [name] activates, saving you from the chasm!</span>")
	SSblackbox.record_feedback("tally", "jaunter", 1, "Chasm") // chasm automatic activation
	activate(source, FALSE, TRUE)
	if(C)
		var/atom/A = C.parent
		A.visible_message("<span class='boldwarning'>[source] falls into [A]!</span>")
	return TRUE

//jaunter tunnel
/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."
	mech_sized = TRUE //save your ripley
	teleport_channel = TELEPORT_CHANNEL_WORMHOLE
	innate_accuracy_penalty = 6

/obj/effect/portal/jaunt_tunnel/teleport(atom/movable/M, force = FALSE)
	. = ..()
	if(.)
		// KERPLUNK
		playsound(M,'sound/weapons/resonator_blast.ogg',50,1)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			L.DefaultCombatKnockdown(60)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				addtimer(CALLBACK(L, /mob/living/carbon.proc/vomit), 20)
