/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list -= src
	GLOB.all_clockwork_mobs -= src
	GLOB.mob_directory -= tag
	focus = null
	LAssailant = null
	movespeed_modification = null
	for (var/alert in alerts)
		clear_alert(alert, TRUE)
	if(observers && observers.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			observe.reset_perspective(null)
	qdel(hud_used)
	for(var/cc in client_colours)
		qdel(cc)
	client_colours = null
	ghostize()
	..()
	return QDEL_HINT_HARDDEL

/mob/Initialize()
	GLOB.mob_list += src
	GLOB.mob_directory[tag] = src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	else
		GLOB.alive_mob_list += src
	set_focus(src)
	prepare_huds()
	for(var/v in GLOB.active_alternate_appearances)
		if(!v)
			continue
		var/datum/atom_hud/alternate_appearance/AA = v
		AA.onNewMob(src)
	set_nutrition(rand(NUTRITION_LEVEL_START_MIN, NUTRITION_LEVEL_START_MAX))
	. = ..()
	update_config_movespeed()
	update_movespeed(TRUE)
	initialize_actionspeed()
	hook_vr("mob_new",list(src))

/mob/GenerateTag()
	tag = "mob_[next_mob_id++]"

/atom/proc/prepare_huds()
	hud_list = list()
	for(var/hud in hud_possible)
		var/hint = hud_possible[hud]
		switch(hint)
			if(HUD_LIST_LIST)
				hud_list[hud] = list()
			else
				var/image/I = image('icons/mob/hud.dmi', src, "")
				I.appearance_flags = RESET_COLOR|RESET_TRANSFORM
				hud_list[hud] = I

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t =	"<span class='notice'>Coordinates: [x],[y] \n</span>"
	t +=	"<span class='danger'>Temperature: [environment.return_temperature()] \n</span>"
	for(var/id in environment.get_gases())
		if(environment.get_moles(id))
			t+="<span class='notice'>[GLOB.gas_data.names[id]]: [environment.get_moles(id)] \n</span>"

	to_chat(usr, t)

/mob/proc/get_photo_description(obj/item/camera/camera)
	return "a ... thing?"

/mob/proc/show_message(msg, type, alt_msg, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	if(audiovisual_redirect)
		audiovisual_redirect.show_message(msg ? "<avredirspan class='small'>[msg]</avredirspan>" : null, type, alt_msg ? "<avredirspan class='small'>[alt_msg]</avredirspan>" : null, alt_type)

	if(!client)
		return

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)

	if(type)
		if(type & MSG_VISUAL && eye_blind )//Vision related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type

		if(type & MSG_AUDIBLE && !can_hear())//Hearing related
			if(!alt_msg)
				return
			else
				msg = alt_msg
				type = alt_type
				if(type & MSG_VISUAL && eye_blind)
					return
	// voice muffling
	if(stat == UNCONSCIOUS)
		if(type & MSG_AUDIBLE) //audio
			to_chat(src, "<I>... You can almost hear something ...</I>")
		return
	to_chat(src, msg)

/**
  * Generate a visible message from this atom
  *
  * Show a message to all player mobs who sees this atom
  *
  * Show a message to the src mob (if the src is a mob)
  *
  * Use for atoms performing visible actions
  *
  * message is output to anyone who can see, e.g. "The [src] does something!"
  *
  * Vars:
  * * self_message (optional) is what the src mob sees e.g. "You do something!"
  * * blind_message (optional) is what blind people will hear e.g. "You hear something!"
  * * vision_distance (optional) define how many tiles away the message can be seen.
  * * ignored_mobs (optional) doesn't show any message to any given mob in the list.
  * * target (optional) is the other mob involved with the visible message. For example, the attacker in many combat messages.
  * * target_message (optional) is what the target mob will see e.g. "[src] does something to you!"
  * * omni (optional) if TRUE, will show to users no matter what.
  */
/atom/proc/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, ignored_mobs, mob/target, target_message, omni = FALSE)
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/list/hearers = get_hearers_in_view(vision_distance, src) //caches the hearers and then removes ignored mobs.
	if(!length(hearers))
		return
	hearers -= ignored_mobs

	if(target_message && target && istype(target) && target.client)
		hearers -= target
		if(omni)
			target.show_message(target_message)
		else
			//This entire if/else chain could be in two lines but isn't for readibilties sake.
			var/msg = target_message
			if(target.see_invisible<invisibility) //if src is invisible to us,
				msg = blind_message
			//the light object is dark and not invisible to us, darkness does not matter if you're directly next to the target
			else if(T.lighting_object && T.lighting_object.invisibility <= target.see_invisible && T.is_softly_lit() && !in_range(T,target))
				msg = blind_message
			if(msg)
				target.show_message(msg, MSG_VISUAL,blind_message, MSG_AUDIBLE)
	if(self_message)
		hearers -= src
	for(var/mob/M in hearers)
		if(!M.client)
			continue
		if(omni)
			M.show_message(message)
			continue
		//This entire if/else chain could be in two lines but isn't for readibilties sake.
		var/msg = message
		//CITADEL EDIT, required for vore code to remove (T != loc && T != src)) as a check
		if(M.see_invisible<invisibility) //if src is invisible to us,
			msg = blind_message
		else if(T.lighting_object && T.lighting_object.invisibility <= M.see_invisible && T.is_softly_lit() && !in_range(T,M)) //the light object is dark and not invisible to us, darkness does not matter if you're directly next to the target
			msg = blind_message
		else if(SEND_SIGNAL(M, COMSIG_MOB_GET_VISIBLE_MESSAGE, src, message, vision_distance, ignored_mobs) & COMPONENT_NO_VISIBLE_MESSAGE)
			msg = blind_message
		if(!msg)
			continue
		M.show_message(msg, MSG_VISUAL,blind_message, MSG_AUDIBLE)

///Adds the functionality to self_message.
/mob/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, mob/target, target_message, omni = FALSE)
	. = ..()
	if(self_message && target != src)
		if(!omni)
			show_message(self_message, MSG_VISUAL, blind_message, MSG_AUDIBLE)
		else
			show_message(self_message)

/**
  * Show a message to all mobs in earshot of this atom
  *
  * Use for objects performing audible actions
  *
  * vars:
  * * message is the message output to anyone who can hear.
  * * deaf_message (optional) is what deaf people will see.
  * * hearing_distance (optional) is the range, how many tiles away the message can be heard.
  * * ignored_mobs (optional) doesn't show any message to any given mob in the list.
  */
/atom/proc/audible_message(message, deaf_message, hearing_distance = DEFAULT_MESSAGE_RANGE, self_message, ignored_mobs)
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/list/hearers = get_hearers_in_view(hearing_distance, src)
	if(!length(hearers))
		return
	hearers -= ignored_mobs
	if(self_message)
		hearers -= src
	for(var/mob/M in hearers)
		M.show_message(message, MSG_AUDIBLE, deaf_message, MSG_VISUAL)

/**
  * Show a message to all mobs in earshot of this one
  *
  * This would be for audible actions by the src mob
  *
  * vars:
  * * message is the message output to anyone who can hear.
  * * self_message (optional) is what the src mob hears.
  * * deaf_message (optional) is what deaf people will see.
  * * hearing_distance (optional) is the range, how many tiles away the message can be heard.
  * * ignored_mobs (optional) doesn't show any message to any given mob in the list.
  */
/mob/audible_message(message, deaf_message, hearing_distance = DEFAULT_MESSAGE_RANGE, self_message, list/ignored_mobs)
	. = ..()
	if(self_message)
		show_message(self_message, MSG_AUDIBLE, deaf_message, MSG_VISUAL)

/mob/proc/get_item_by_slot(slot_id)
	return null

/mob/proc/restrained(ignore_grab)
	return

/mob/proc/incapacitated(ignore_restraints, ignore_grab)
	return

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_held_item()

	if(istype(W))
		if(equip_to_slot_if_possible(W, slot, FALSE, FALSE, FALSE, FALSE, TRUE))
			return TRUE

	if(!W)
		// Activate the item
		var/obj/item/I = get_item_by_slot(slot)
		if(istype(I))
			if(slot in check_obscured_slots())
				to_chat(src, "<span class='warning'>You are unable to unequip that while wearing other garments over it!</span>")
				return FALSE
			I.attack_hand(src)

	return FALSE

/// Checks for slots that are currently obscured by other garments.
/mob/proc/check_obscured_slots()
	return

// reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
// reset_perspective() set eye to common default : mob on turf, loc otherwise
/mob/proc/reset_perspective(atom/A)
	if(!client)
		return
	if(A)
		if(ismovable(A))
			//Set the the thing unless it's us
			if(A != src)
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
			else
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
		else if(isturf(A))
			//Set to the turf unless it's our current turf
			if(A != loc)
				client.perspective = EYE_PERSPECTIVE
				client.eye = A
			else
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
		else
			//Do nothing
	else
		//Reset to common defaults: mob if on turf, otherwise current loc
		if(isturf(loc))
			client.eye = client.mob
			client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.eye = loc
	SEND_SIGNAL(src, COMSIG_MOB_RESET_PERSPECTIVE, A)
	return TRUE

/mob/proc/show_inv(mob/user)
	return

//view() but with a signal, to allow blacklisting some of the otherwise visible atoms.
/mob/proc/fov_view(dist = world.view)
	. = view(dist, src)
	SEND_SIGNAL(src, COMSIG_MOB_FOV_VIEW, .)

/**
  * Examine a mob
  *
  * mob verbs are faster than object verbs. See
  * [this byond forum post](https://secure.byond.com/forum/?post=1326139&page=2#comment8198716)
  * for why this isn't atom/verb/examine()
  */
/mob/verb/examinate(atom/A as mob|obj|turf in view()) //It used to be oview(12), but I can't really say why
	set name = "Examine"
	set category = "IC"

	if(isturf(A) && !(sight & SEE_TURFS) && !(A in view(client ? client.view : world.view, src)))
		// shift-click catcher may issue examinate() calls for out-of-sight turfs
		return

	if(is_blind())
		to_chat(src, "<span class='warning'>Something is there but you can't see it!</span>")
		return

	face_atom(A)
	var/list/result
	if(client)
		LAZYINITLIST(client.recent_examines)
		if(isnull(client.recent_examines[A]) || client.recent_examines[A] < world.time)
			result = A.examine(src)
			client.recent_examines[A] = world.time + EXAMINE_MORE_TIME // set the value to when the examine cooldown ends
			RegisterSignal(A, COMSIG_PARENT_QDELETING, .proc/clear_from_recent_examines, override=TRUE) // to flush the value if deleted early
			addtimer(CALLBACK(src, .proc/clear_from_recent_examines, A), EXAMINE_MORE_TIME)
			handle_eye_contact(A)
		else
			result = A.examine_more(src)
	else
		result = A.examine(src) // if a tree is examined but no client is there to see it, did the tree ever really exist?

	to_chat(src, result.Join("\n"))
	SEND_SIGNAL(src, COMSIG_MOB_EXAMINATE, A)

/mob/proc/clear_from_recent_examines(atom/A)
	if(!client)
		return
	UnregisterSignal(A, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(client.recent_examines, A)

/**
  * handle_eye_contact() is called when we examine() something. If we examine an alive mob with a mind who has examined us in the last second within 5 tiles, we make eye contact!
  *
  * Note that if either party has their face obscured, the other won't get the notice about the eye contact
  * Also note that examine_more() doesn't proc this or extend the timer, just because it's simpler this way and doesn't lose much.
  *	The nice part about relying on examining is that we don't bother checking visibility, because we already know they were both visible to each other within the last second, and the one who triggers it is currently seeing them
  */
/mob/proc/handle_eye_contact(mob/living/examined_mob)
	return

/mob/living/handle_eye_contact(mob/living/examined_mob)
	if(!istype(examined_mob) || src == examined_mob || examined_mob.stat >= UNCONSCIOUS || !client || !examined_mob.client?.recent_examines || !(src in examined_mob.client.recent_examines))
		return

	if(get_dist(src, examined_mob) > EYE_CONTACT_RANGE)
		return

	var/mob/living/carbon/examined_carbon = examined_mob
	// check to see if their face is blocked (or if they're not a carbon, in which case they can't block their face anyway)
	if(!istype(examined_carbon) || (!(examined_carbon.wear_mask && examined_carbon.wear_mask.flags_inv & HIDEFACE) && !(examined_carbon.head && examined_carbon.head.flags_inv & HIDEFACE)))
		if(SEND_SIGNAL(src, COMSIG_MOB_EYECONTACT, examined_mob, TRUE) != COMSIG_BLOCK_EYECONTACT)
			var/msg = "<span class='smallnotice'>You make eye contact with [examined_mob].</span>"
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, src, msg), 3) // so the examine signal has time to fire and this will print after

	var/mob/living/carbon/us_as_carbon = src // i know >casting as subtype, but this isn't really an inheritable check
	if(!istype(us_as_carbon) || (!(us_as_carbon.wear_mask && us_as_carbon.wear_mask.flags_inv & HIDEFACE) && !(us_as_carbon.head && us_as_carbon.head.flags_inv & HIDEFACE)))
		if(SEND_SIGNAL(examined_mob, COMSIG_MOB_EYECONTACT, src, FALSE) != COMSIG_BLOCK_EYECONTACT)
			var/msg = "<span class='smallnotice'>[src] makes eye contact with you.</span>"
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, examined_mob, msg), 3)

//same as above
//note: ghosts can point, this is intended
//visible_message will handle invisibility properly
//overridden here and in /mob/dead/observer for different point span classes and sanity checks
/mob/verb/pointed(atom/A as mob|obj|turf in fov_view())
	set name = "Point To"
	set category = "Object"

	if(!src || !isturf(src.loc) || !(A in view(src.loc)))
		return FALSE
	if(istype(A, /obj/effect/temp_visual/point))
		return FALSE

	var/tile = get_turf(A)
	if (!tile)
		return FALSE

	new /obj/effect/temp_visual/point(A,invisibility)
	SEND_SIGNAL(src, COMSIG_MOB_POINTED, A)
	return TRUE

/mob/proc/can_resist()
	return FALSE		//overridden in living.dm

/mob/proc/spin(spintime, speed)
	set waitfor = 0
	var/D = dir
	if((spintime < 1)||(speed < 1)||!spintime||!speed)
		return
	while(spintime >= speed)
		sleep(speed)
		switch(D)
			if(NORTH)
				D = EAST
			if(SOUTH)
				D = WEST
			if(EAST)
				D = SOUTH
			if(WEST)
				D = NORTH
		setDir(D)
		spintime -= speed

/mob/proc/update_pull_hud_icon()
	hud_used?.pull_icon?.update_icon()

/mob/proc/update_rest_hud_icon()
	hud_used?.rest_icon?.update_icon()

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(ismecha(loc))
		return

	if(incapacitated())
		return

	var/obj/item/I = get_active_held_item()
	if(I)
		I.attack_self(src)
		update_inv_hands()

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	set desc = "View your character's notes memory."
	if(mind)
//ambition start
		var/datum/browser/popup = new(src, "memory", "Memory and Notes")
		popup.set_content(mind.show_memory())
		popup.open()
//ambition end
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't look at your notes, if you had any.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext_char(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "You don't have a mind datum for some reason, so you can't add a note to it.")

/mob/proc/transfer_ckey(mob/new_mob, send_signal = TRUE)
	if(!new_mob || (!ckey && new_mob.ckey))
		CRASH("transfer_ckey() called [new_mob ? "on ckey-less mob with a player mob as target" : "without a valid mob target"]!")
	if(!ckey)
		return
	SEND_SIGNAL(new_mob, COMSIG_MOB_PRE_PLAYER_CHANGE, new_mob, src)
	if (client)
		if(client.prefs?.auto_ooc)
			if (client.prefs.chat_toggles & CHAT_OOC && isliving(new_mob))
				client.prefs.chat_toggles ^= CHAT_OOC
			if (!(client.prefs.chat_toggles & CHAT_OOC) && isdead(new_mob))
				client.prefs.chat_toggles ^= CHAT_OOC
	new_mob.ckey = ckey
	if(send_signal)
		SEND_SIGNAL(src, COMSIG_MOB_KEY_CHANGE, new_mob, src)
	return TRUE

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_perspective(null)
	unset_machine()

GLOBAL_VAR_INIT(exploit_warn_spam_prevention, 0)

//suppress the .click/dblclick macros so people can't use them to identify the location of items or aimbot
/mob/verb/DisClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".click"
	set hidden = TRUE
	set category = null
	if(GLOB.exploit_warn_spam_prevention < world.time)
		var/msg = "[key_name_admin(src)]([ADMIN_KICK(src)]) attempted to use the .click macro!"
		log_admin(msg)
		message_admins(msg)
		GLOB.exploit_warn_spam_prevention = world.time + 10

/mob/verb/DisDblClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".dblclick"
	set hidden = TRUE
	set category = null
	if(GLOB.exploit_warn_spam_prevention < world.time)
		var/msg = "[key_name_admin(src)]([ADMIN_KICK(src)]) attempted to use the .dblclick macro!"
		log_admin(msg)
		message_admins(msg)
		GLOB.exploit_warn_spam_prevention = world.time + 10

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	if(href_list["refresh"])
		if(machine && in_range(src, usr))
			show_inv(machine)

	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			var/hand_index = text2num(href_list["hand_index"])
			var/obj/item/what
			if(hand_index)
				what = get_item_for_held_index(hand_index)
				slot = list(slot,hand_index)
			else
				what = get_item_by_slot(slot)
			if(what)
				if(!(what.item_flags & ABSTRACT))
					usr.stripPanelUnequip(what,src,slot)
			else
				usr.stripPanelEquip(what,src,slot)

	if(usr.machine == src)
		if(Adjacent(usr))
			show_inv(usr)
		else
			usr << browse(null,"window=mob[REF(src)]")

// The src mob is trying to strip an item from someone
// Defined in living.dm
/mob/proc/stripPanelUnequip(obj/item/what, mob/who)
	return

// The src mob is trying to place an item on someone
// Defined in living.dm
/mob/proc/stripPanelEquip(obj/item/what, mob/who)
	return

/mob/MouseDrop(mob/M)
	. = ..()
	if(M != usr)
		return
	if(usr == src)
		return
	if(!Adjacent(usr))
		return
	if(isAI(M))
		return

/mob/MouseDrop_T(atom/dropping, atom/user)
	. = ..()
	if(ismob(dropping) && dropping != user)
		var/mob/M = dropping
		M.show_inv(user)

/mob/proc/is_muzzled()
	return FALSE

/// Adds this list to the output to the stat browser
/mob/proc/get_status_tab_items()
	. = list()

/// Gets all relevant proc holders for the browser statpenl
/mob/proc/get_proc_holders()
	. = list()
	if(mind)
		. += get_spells_for_statpanel(mind.spell_list)
	. += get_spells_for_statpanel(mob_spell_list)

/**
  * Convert a list of spells into a displyable list for the statpanel
  *
  * Shows charge and other important info
  */
/mob/proc/get_spells_for_statpanel(list/spells)
	var/list/L = list()
	for(var/obj/effect/proc_holder/spell/S in spells)
		if((!S.mobs_blacklist || !S.mobs_blacklist[src]) && (!S.mobs_whitelist || S.mobs_whitelist[src]))
			switch(S.charge_type)
				if("recharge")
					L[++L.len] = list("[S.panel]", "[S.charge_counter/10.0]/[S.charge_max/10]", S.name, REF(S))
				if("charges")
					L[++L.len] = list("[S.panel]", "[S.charge_counter]/[S.charge_max]", S.name, REF(S))
				if("holdervar")
					L[++L.len] = list("[S.panel]", "[S.holder_var_type] [S.holder_var_amount]", S.name, REF(S))
	return L

/mob/proc/add_stings_to_statpanel(list/stings)
	for(var/obj/effect/proc_holder/changeling/S in stings)
		if(S.chemical_cost >=0 && S.can_be_used_by(src))
			statpanel("[S.panel]",((S.chemical_cost > 0) ? "[S.chemical_cost]" : ""),S)

#define MOB_FACE_DIRECTION_DELAY 1

// facing verbs
/mob/proc/canface()
	if(world.time < client.last_turn)
		return FALSE
	if(stat == DEAD || stat == UNCONSCIOUS)
		return FALSE
	if(anchored)
		return FALSE
	if(mob_transforming)
		return FALSE
	if(restrained())
		return FALSE
	return TRUE

/mob/proc/fall(forced)
	drop_all_held_items()

/mob/verb/eastface()
	set hidden = TRUE
	if(!canface())
		return FALSE
	setDir(EAST)
	client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY
	return TRUE

/mob/verb/westface()
	set hidden = TRUE
	if(!canface())
		return FALSE
	setDir(WEST)
	client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY
	return TRUE

/mob/verb/northface()
	set hidden = TRUE
	if(!canface())
		return FALSE
	setDir(NORTH)
	client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY
	return TRUE

/mob/verb/southface()
	set hidden = TRUE
	if(!canface())
		return FALSE
	setDir(SOUTH)
	client.last_turn = world.time + MOB_FACE_DIRECTION_DELAY
	return TRUE

/mob/verb/eastshift()
	set hidden = TRUE
	if(!canface())
		return FALSE
	if(pixel_x <= 16)
		pixel_x++
		is_shifted = TRUE

/mob/verb/westshift()
	set hidden = TRUE
	if(!canface())
		return FALSE
	if(pixel_x >= -16)
		pixel_x--
		is_shifted = TRUE

/mob/verb/northshift()
	set hidden = TRUE
	if(!canface())
		return FALSE
	if(pixel_y <= 16)
		pixel_y++
		is_shifted = TRUE

/mob/verb/southshift()
	set hidden = TRUE
	if(!canface())
		return FALSE
	if(pixel_y >= -16)
		pixel_y--
		is_shifted = TRUE

/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return FALSE

/mob/proc/swap_hand()
	var/obj/item/held_item = get_active_held_item()
	if(SEND_SIGNAL(src, COMSIG_MOB_SWAP_HANDS, held_item) & COMPONENT_BLOCK_SWAP)
		to_chat(src, "<span class='warning'>Your other hand is too busy holding [held_item].</span>")
		return FALSE
	return TRUE

/mob/proc/activate_hand(selhand)
	return

/mob/proc/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) //For sec bot threat assessment
	return 0

/mob/proc/get_ghost(even_if_they_cant_reenter = 0)
	if(mind)
		return mind.get_ghost(even_if_they_cant_reenter)

/mob/proc/grab_ghost(force)
	if(mind)
		return mind.grab_ghost(force = force)

/mob/proc/notify_ghost_cloning(var/message = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!", var/sound = 'sound/effects/genetics.ogg', var/atom/source = null, flashwindow)
	var/mob/dead/observer/ghost = get_ghost()
	if(ghost)
		ghost.notify_cloning(message, sound, source, flashwindow)
		return ghost

/mob/proc/AddSpell(obj/effect/proc_holder/spell/S)
	mob_spell_list += S
	S.action.Grant(src)

/mob/proc/RemoveSpell(obj/effect/proc_holder/spell/spell)
	if(!spell)
		return
	for(var/X in mob_spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(istype(S, spell))
			mob_spell_list -= S
			qdel(S)
	if(client)
		client << output(null, "statbrowser:check_spells")

/mob/proc/anti_magic_check(magic = TRUE, holy = FALSE, tinfoil = FALSE, chargecost = 1, self = FALSE)
	if(!magic && !holy && !tinfoil)
		return
	var/list/protection_sources = list()
	if(SEND_SIGNAL(src, COMSIG_MOB_RECEIVE_MAGIC, src, magic, holy, tinfoil, chargecost, self, protection_sources) & COMPONENT_BLOCK_MAGIC)
		if(protection_sources.len)
			return pick(protection_sources)
		else
			return src
	if((magic && HAS_TRAIT(src, TRAIT_ANTIMAGIC)) || (holy && HAS_TRAIT(src, TRAIT_HOLY)))
		return src

//You can buckle on mobs if you're next to them since most are dense
/mob/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(M.buckled)
		return FALSE
	var/turf/T = get_turf(src)
	if(M.loc != T)
		var/old_density = density
		density = FALSE
		var/can_step = step_towards(M, T)
		density = old_density
		if(!can_step)
			return FALSE
	return ..()

//Default buckling shift visual for mobs
/mob/post_buckle_mob(mob/living/M)
	var/height = M.get_mob_buckling_height(src)
	M.pixel_y = initial(M.pixel_y) + height
	if(M.layer < layer)
		M.layer = layer + 0.1

/mob/post_unbuckle_mob(mob/living/M)
	M.layer = initial(M.layer)
	M.pixel_y = initial(M.pixel_y)

//returns the height in pixel the mob should have when buckled to another mob.
/mob/proc/get_mob_buckling_height(mob/seat)
	if(isliving(seat))
		var/mob/living/L = seat
		if(L.mob_size <= MOB_SIZE_SMALL) //being on top of a small mob doesn't put you very high.
			return 0
	return 9

//can the mob be buckled to something by default?
/mob/proc/can_buckle()
	return TRUE

//can the mob be unbuckled from something by default?
/mob/proc/can_unbuckle()
	return TRUE

/mob/proc/can_buckle_others(mob/living/target, atom/buckle_to)
	return TRUE

//Can the mob interact() with an atom?
/mob/proc/can_interact_with(atom/A)
	return IsAdminGhost(src) || Adjacent(A) || A.hasSiliconAccessInArea(src)

//Can the mob use Topic to interact with machines
/mob/proc/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	return

/mob/proc/canUseStorage()
	return FALSE

/mob/proc/faction_check_mob(mob/target, exact_match)
	if(exact_match) //if we need an exact match, we need to do some bullfuckery.
		var/list/faction_src = faction.Copy()
		var/list/faction_target = target.faction.Copy()
		if(!("[REF(src)]" in faction_target)) //if they don't have our ref faction, remove it from our factions list.
			faction_src -= "[REF(src)]" //if we don't do this, we'll never have an exact match.
		if(!("[REF(target)]" in faction_src))
			faction_target -= "[REF(target)]" //same thing here.
		return faction_check(faction_src, faction_target, TRUE)
	return faction_check(faction, target.faction, FALSE)

/proc/faction_check(list/faction_A, list/faction_B, exact_match)
	var/list/match_list
	if(exact_match)
		match_list = faction_A&faction_B //only items in both lists
		var/length = LAZYLEN(match_list)
		if(length)
			return (length == LAZYLEN(faction_A)) //if they're not the same len(gth) or we don't have a len, then this isn't an exact match.
	else
		match_list = faction_A&faction_B
		return LAZYLEN(match_list)
	return FALSE


//This will update a mob's name, real_name, mind.name, GLOB.data_core records, pda, id and traitor text
//Calling this proc without an oldname will only update the mob and skip updating the pda, id and records ~Carn
/mob/proc/fully_replace_character_name(oldname,newname)
	log_message("[src] name changed from [oldname] to [newname]", LOG_OWNERSHIP)
	if(!newname)
		return 0
	real_name = newname
	name = newname
	if(mind)
		mind.name = newname

	if(oldname)
		//update the datacore records! This is goig to be a bit costly.
		replace_records_name(oldname,newname)

		//update our pda and id if we have them on our person
		replace_identification_name(oldname,newname)

		for(var/datum/mind/T in SSticker.minds)
			for(var/datum/objective/obj in T.get_all_objectives())
				// Only update if this player is a target
				if(obj.target && obj.target.current && obj.target.current.real_name == name)
					obj.update_explanation_text()
	return 1

//Updates GLOB.data_core records with new name , see mob/living/carbon/human
/mob/proc/replace_records_name(oldname,newname)
	return

/mob/proc/replace_identification_name(oldname,newname)
	var/list/searching = GetAllContents()
	var/search_id = 1
	var/search_pda = 1

	for(var/A in searching)
		if( search_id && istype(A, /obj/item/card/id) )
			var/obj/item/card/id/ID = A
			if(ID.registered_name == oldname)
				ID.registered_name = newname
				ID.update_label()
				if(!search_pda)
					break
				search_id = 0

		else if( search_pda && istype(A, /obj/item/pda) )
			var/obj/item/pda/PDA = A
			if(PDA.owner == oldname)
				PDA.owner = newname
				PDA.update_label()
				if(!search_id)
					break
				search_pda = 0

/mob/proc/update_stat()
	return

/mob/proc/update_health_hud()
	return

/mob/proc/update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)

	sync_lighting_plane_alpha()

/mob/proc/sync_lighting_plane_alpha()
	if(hud_used)
		var/obj/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
		if (L)
			L.alpha = lighting_alpha

/mob/proc/update_mouse_pointer()
	if (!client)
		return
	client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
	if (ismecha(loc))
		var/obj/mecha/M = loc
		if(M.mouse_pointer)
			client.mouse_pointer_icon = M.mouse_pointer

/mob/proc/is_literate()
	return 0

/mob/proc/can_hold_items()
	return FALSE

/mob/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_GIB, "Gib")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_SPELL, "Give Spell")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_SPELL, "Remove Spell")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_DISEASE, "Give Disease")
	VV_DROPDOWN_OPTION(VV_HK_GODMODE, "Toggle Godmode")
	VV_DROPDOWN_OPTION(VV_HK_DROP_ALL, "Drop Everything")
	VV_DROPDOWN_OPTION(VV_HK_REGEN_ICONS, "Regenerate Icons")
	VV_DROPDOWN_OPTION(VV_HK_PLAYER_PANEL, "Show player panel")
	VV_DROPDOWN_OPTION(VV_HK_BUILDMODE, "Toggle Buildmode")
	VV_DROPDOWN_OPTION(VV_HK_DIRECT_CONTROL, "Assume Direct Control")
	VV_DROPDOWN_OPTION(VV_HK_OFFER_GHOSTS, "Offer Control to Ghosts")

/mob/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_REGEN_ICONS])
		if(!check_rights(NONE))
			return
		regenerate_icons()
	if(href_list[VV_HK_PLAYER_PANEL])
		if(!check_rights(NONE))
			return
		usr.client.holder.show_player_panel(src)
	if(href_list[VV_HK_GODMODE])
		if(!check_rights(R_ADMIN))
			return
		usr.client.cmd_admin_godmode(src)
	if(href_list[VV_HK_GIVE_SPELL])
		if(!check_rights(NONE))
			return
		usr.client.give_spell(src)
	if(href_list[VV_HK_REMOVE_SPELL])
		if(!check_rights(NONE))
			return
		usr.client.remove_spell(src)
	if(href_list[VV_HK_GIVE_DISEASE])
		if(!check_rights(NONE))
			return
		usr.client.give_disease(src)
	if(href_list[VV_HK_GIB])
		if(!check_rights(R_FUN))
			return
		usr.client.cmd_admin_gib(src)
	if(href_list[VV_HK_BUILDMODE])
		if(!check_rights(R_BUILDMODE))
			return
		togglebuildmode(src)
	if(href_list[VV_HK_DROP_ALL])
		if(!check_rights(NONE))
			return
		usr.client.cmd_admin_drop_everything(src)
	if(href_list[VV_HK_DIRECT_CONTROL])
		if(!check_rights(NONE))
			return
		usr.client.cmd_assume_direct_control(src)
	if(href_list[VV_HK_OFFER_GHOSTS])
		if(!check_rights(NONE))
			return
		offer_control(src)

/mob/vv_get_var(var_name)
	switch(var_name)
		if("logging")
			return debug_variable(var_name, logging, 0, src, FALSE)
		if(NAMEOF(src, lastKnownIP))
			if(!check_rights(R_SENSITIVE, FALSE))
				return "SENSITIVE"
		if(NAMEOF(src, computer_id))
			if(!check_rights(R_SENSITIVE, FALSE))
				return "SENSITIVE"
	. = ..()

/mob/vv_auto_rename(new_name)
	//Do not do parent's actions, as we *usually* do this differently.
	fully_replace_character_name(real_name, new_name)

/mob/verb/open_language_menu()
	set name = "Open Language Menu"
	set category = "IC"

	var/datum/language_holder/H = get_language_holder()
	H.open_language_menu(usr)

///Adjust the nutrition of a mob
/mob/proc/adjust_nutrition(change, max = INFINITY) //Honestly FUCK the oldcoders for putting nutrition on /mob someone else can move it up because holy hell I'd have to fix SO many typechecks
	nutrition = clamp(nutrition + change, 0, max)

///Force set the mob nutrition
/mob/proc/set_nutrition(var/change) //Seriously fuck you oldcoders.
	nutrition = max(0, change)

/mob/setMovetype(newval)
	. = ..()
	update_movespeed(FALSE)

/mob/proc/getLAssailant()
	return LAssailant?.resolve()

/// Updates the grab state of the mob and updates movespeed
/mob/setGrabState(newstate)
	. = ..()
	switch(grab_state)
		if(GRAB_PASSIVE)
			remove_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE)
		if(GRAB_AGGRESSIVE)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/aggressive)
		if(GRAB_NECK)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/neck)
		if(GRAB_KILL)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/kill)

/mob/proc/update_equipment_speed_mods()
	var/speedies = equipped_speed_mods()
	if(!speedies)
		remove_movespeed_modifier(/datum/movespeed_modifier/equipment_speedmod, update=TRUE)
	else
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/equipment_speedmod, multiplicative_slowdown = speedies)

/// Gets the combined speed modification of all worn items
/// Except base mob type doesnt really wear items
/mob/proc/equipped_speed_mods()
	for(var/obj/item/I in held_items)
		if(I.item_flags & SLOWS_WHILE_IN_HAND)
			. += I.slowdown

/**
  * Mostly called by doUnEquip()
  * Like item dropped() on mob side.
  */
/mob/proc/on_item_dropped(obj/item/I)
	return
