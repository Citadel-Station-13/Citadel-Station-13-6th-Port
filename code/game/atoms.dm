/**
 * The base type for nearly all physical objects in SS13

 * Lots and lots of functionality lives here, although in general we are striving to move
 * as much as possible to the components/elements system
 */
/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND

	var/level = 2
	///If non-null, overrides a/an/some in all cases
	var/article

	///First atom flags var
	var/flags_1 = NONE
	///Intearaction flags
	var/interaction_flags_atom = NONE

	var/flags_ricochet = NONE

	///When a projectile tries to ricochet off this atom, the projectile ricochet chance is multiplied by this
	var/ricochet_chance_mod = 1
	///When a projectile ricochets off this atom, it deals the normal damage * this modifier to this atom
	var/ricochet_damage_mod = 0.33

	///Reagents holder
	var/datum/reagents/reagents = null

	///This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list = null
	///HUD images that this atom can provide.
	var/list/hud_possible

	///Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	/// Flags for explosions
	var/explosion_flags = NONE
	/// Amount to decrease wave explosions by
	var/wave_explosion_block = 0
	/// Amount to multiply wave explosions by
	var/wave_explosion_multiply = 1

							//its inherent color, the colored paint applied on it, special color effect etc...
	/**
	  * used to store the different colors on an atom
	  *
	  * its inherent color, the colored paint applied on it, special color effect etc...
	  */
	var/list/atom_colours

	/// a very temporary list of overlays to remove
	var/list/remove_overlays
	/// a very temporary list of overlays to add
	var/list/add_overlays

	///vis overlays managed by SSvis_overlays to automaticaly turn them like other overlays
	var/list/managed_vis_overlays
	///overlays managed by [update_overlays][/atom/proc/update_overlays] to prevent removing overlays that weren't added by the same proc
	var/list/managed_overlays

	///Proximity monitor associated with this atom
	var/datum/proximity_monitor/proximity_monitor
	///Last fingerprints to touch this atom
	var/fingerprintslast

	var/list/filter_data //For handling persistent filters

	///Price of an item in a vending machine, overriding the base vending machine price. Define in terms of paycheck defines as opposed to raw numbers.
	var/custom_price
	///Price of an item in a vending machine, overriding the premium vending machine price. Define in terms of paycheck defines as opposed to raw numbers.
	var/custom_premium_price

	//List of datums orbiting this atom
	var/datum/component/orbiter/orbiters

	var/rad_flags = NONE // Will move to flags_1 when i can be arsed to
	/// Radiation insulation types
	var/rad_insulation = RAD_NO_INSULATION

	///The custom materials this atom is made of, used by a lot of things like furniture, walls, and floors (if I finish the functionality, that is.)
	///The list referenced by this var can be shared by multiple objects and should not be directly modified. Instead, use [set_custom_materials][/atom/proc/set_custom_materials].
	var/list/custom_materials
	///Bitfield for how the atom handles materials.
	var/material_flags = NONE
	///Modifier that raises/lowers the effect of the amount of a material, prevents small and easy to get items from being death machines.
	var/material_modifier = 1

	var/datum/wires/wires = null

	var/icon/blood_splatter_icon
	var/list/fingerprints
	var/list/fingerprintshidden
	var/list/blood_DNA
	var/list/suit_fibers

	/// Last name used to calculate a color for the chatmessage overlays
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays
	var/chat_color
	/// A luminescence-shifted value of the last color calculated for chatmessage overlays
	var/chat_color_darkened

	///Mobs that are currently do_after'ing this atom, to be cleared from on Destroy()
	var/list/targeted_by

	///Reference to atom being orbited
	var/atom/orbit_target

/**
 * Called when an atom is created in byond (built in engine proc)
 *
 * Not a lot happens here in SS13 code, as we offload most of the work to the
 * [Intialization][/atom/proc/Initialize] proc, mostly we run the preloader
 * if the preloader is being used and then call [InitAtom][/datum/controller/subsystem/atoms/proc/InitAtom] of which the ultimate
 * result is that the Intialize proc is called.
 *
 * We also generate a tag here if the DF_USE_TAG flag is set on the atom
 */
/atom/New(loc, ...)
	//atom creation method that preloads variables at creation
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		world.preloader_load(src)

	if(datum_flags & DF_USE_TAG)
		GenerateTag()

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			//we were deleted
			return

/**
 * The primary method that objects are setup in SS13 with
 *
 * we don't use New as we have better control over when this is called and we can choose
 * to delay calls or hook other logic in and so forth
 *
 * During roundstart map parsing, atoms are queued for intialization in the base atom/New(),
 * After the map has loaded, then Initalize is called on all atoms one by one. NB: this
 * is also true for loading map templates as well, so they don't Initalize until all objects
 * in the map file are parsed and present in the world
 *
 * If you're creating an object at any point after SSInit has run then this proc will be
 * immediately be called from New.
 *
 * mapload: This parameter is true if the atom being loaded is either being intialized during
 * the Atom subsystem intialization, or if the atom is being loaded from the map template.
 * If the item is being created at runtime any time after the Atom subsystem is intialized then
 * it's false.
 *
 * You must always call the parent of this proc, otherwise failures will occur as the item
 * will not be seen as initalized (this can lead to all sorts of strange behaviour, like
 * the item being completely unclickable)
 *
 * You must not sleep in this proc, or any subprocs
 *
 * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
 * there are no other arguments
 *
 * Must return an [initialization hint][INITIALIZE_HINT_NORMAL] or a runtime will occur.
 *
 * Note: the following functions don't call the base for optimization and must copypasta handling:
 * * [/turf/proc/Initialize]
 * * [/turf/open/space/proc/Initialize]
 */
/atom/proc/Initialize(mapload, ...)
	// SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_CREATED, src) /// Sends a signal that the new atom `src`, has been created at `loc`

	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_power && light_range)
		update_light()

	if (opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	if (canSmoothWith)
		canSmoothWith = typelist("canSmoothWith", canSmoothWith)

	// apply materials properly from the default custom_materials value
	set_custom_materials(custom_materials)

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL

/**
 * Late Intialization, for code that should run after all atoms have run Intialization
 *
 * To have your LateIntialize proc be called, your atoms [Initalization][/atom/proc/Initialize]
 *  proc must return the hint
 * [INITIALIZE_HINT_LATELOAD] otherwise you will never be called.
 *
 * useful for doing things like finding other machines on GLOB.machines because you can guarantee
 * that all atoms will actually exist in the "WORLD" at this time and that all their Intialization
 * code has been run
 */
/atom/proc/LateInitialize()
	set waitfor = FALSE

/// Put your [AddComponent] calls here
/atom/proc/ComponentInitialize()
	return

/**
 * Top level of the destroy chain for most atoms
 *
 * Cleans up the following:
 * * Removes alternate apperances from huds that see them
 * * qdels the reagent holder from atoms if it exists
 * * clears the orbiters list
 * * clears overlays and priority overlays
 * * clears the light object
 */
/atom/Destroy()
	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			AA.remove_from_hud(src)

	if(reagents)
		qdel(reagents)

	orbiters = null // The component is attached to us normaly and will be deleted elsewhere

	LAZYCLEARLIST(overlays)

	for(var/i in targeted_by)
		var/mob/M = i
		LAZYREMOVE(M.do_afters, src)
	targeted_by = null

	QDEL_NULL(light)

	return ..()

/**
  * Checks if a projectile should ricochet off of us. Projectiles get final say.
  * [__DEFINES/projectiles.dm] for return values.
  */
/atom/proc/check_projectile_ricochet(obj/item/projectile/P)
	return (flags_1 & DEFAULT_RICOCHET_1)? PROJECTILE_RICOCHET_YES : PROJECTILE_RICOCHET_NO

/atom/proc/handle_ricochet(obj/item/projectile/P)
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	var/a_incidence_s = abs(incidence_s)
	if(a_incidence_s > 90 && a_incidence_s < 270)
		return FALSE
	if((P.flag in list("bullet", "bomb")) && P.ricochet_incidence_leeway)
		if((a_incidence_s < 90 && a_incidence_s < 90 - P.ricochet_incidence_leeway) || (a_incidence_s > 270 && a_incidence_s -270 > P.ricochet_incidence_leeway))
			return
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	return TRUE

/atom/proc/CanPass(atom/movable/mover, turf/target)
	return !density

/**
 * Is this atom currently located on centcom
 *
 * Specifically, is it on the z level and within the centcom areas
 *
 * You can also be in a shuttleshuttle during endgame transit
 *
 * Used in gamemode to identify mobs who have escaped and for some other areas of the code
 * who don't want atoms where they shouldn't be
 */
/atom/proc/onCentCom()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(is_reserved_level(T.z))
		for(var/A in SSshuttle.mobile)
			var/obj/docking_port/mobile/M = A
			if(M.launch_status == ENDGAME_TRANSIT)
				for(var/place in M.shuttle_areas)
					var/area/shuttle/shuttle_area = place
					if(T in shuttle_area)
						return TRUE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	//Check for centcom itself
	if(istype(T.loc, /area/centcom))
		return TRUE

	//Check for centcom shuttles
	for(var/A in SSshuttle.mobile)
		var/obj/docking_port/mobile/M = A
		if(M.launch_status == ENDGAME_LAUNCHED)
			for(var/place in M.shuttle_areas)
				var/area/shuttle/shuttle_area = place
				if(T in shuttle_area)
					return TRUE

/**
 * Is the atom in any of the centcom syndicate areas
 *
 * Either in the syndie base on centcom, or any of their shuttles
 *
 * Also used in gamemode code for win conditions
 */
/atom/proc/onSyndieBase()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(!is_centcom_level(T.z))//if not, don't bother
		return FALSE

	if(istype(T.loc, /area/shuttle/syndicate) || istype(T.loc, /area/syndicate_mothership) || istype(T.loc, /area/shuttle/assault_pod))
		return TRUE

	return FALSE

/**
 * Is the atom in an away mission
 *
 * Must be in the away mission z-level to return TRUE
 *
 * Also used in gamemode code for win conditions
 */
/atom/proc/onAwayMission()
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE

	if(is_away_level(T.z))
		return TRUE

	return FALSE

/atom/proc/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)
	if(does_attack_animation)
		user.DelayNextAction(CLICK_CD_MELEE)
		log_combat(user, src, "punched", "hulk powers")
		user.do_attack_animation(src, ATTACK_EFFECT_SMASH)

/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(ismovable(A))
			var/atom/movable/M = A
			if(isliving(M.loc))
				var/mob/living/L = M.loc
				L.transferItemToLoc(M, src)
			else
				M.forceMove(src)

//common name
/atom/proc/update_multiz(prune_on_fail = FALSE)
	return FALSE

/atom/proc/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/atom/proc/check_eye(mob/user)
	return

/atom/proc/Bumped(atom/movable/AM)
	set waitfor = FALSE

// Convenience procs to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/atom/proc/is_injectable(allowmobs = TRUE)
	return reagents && (reagents.reagents_holder_flags & (INJECTABLE | REFILLABLE))

/atom/proc/is_drawable(allowmobs = TRUE)
	return reagents && (reagents.reagents_holder_flags & (DRAWABLE | DRAINABLE))

/atom/proc/is_refillable()
	return reagents && (reagents.reagents_holder_flags & REFILLABLE)

/atom/proc/is_drainable()
	return reagents && (reagents.reagents_holder_flags & DRAINABLE)


/atom/proc/AllowDrop()
	return FALSE

/atom/proc/CheckExit()
	return TRUE

/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/proc/emp_act(severity)
	var/protection = SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)
	if(!(protection & EMP_PROTECT_WIRES) && istype(wires))
		wires.emp_pulse(severity)
	return protection // Pass the protection value collected here upwards

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	. = P.on_hit(src, 0, def_zone)

//used on altdisarm() for special interactions between the shoved victim (target) and the src, with user being the one shoving the target on it.
// IMPORTANT: if you wish to add a new own shove_act() to a certain object, remember to add SHOVABLE_ONTO to its obj_flags bitfied var first.
/atom/proc/shove_act(mob/living/target, mob/living/user)
	return FALSE

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/atom/proc/get_examine_name(mob/user)
	. = "\a [src]"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] [src]"
		override[EXAMINE_POSITION_ARTICLE] = article

	var/should_override = FALSE

	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		should_override = TRUE


	if(blood_DNA && !istype(src, /obj/effect/decal))
		override[EXAMINE_POSITION_BEFORE] = " blood-stained "
		should_override = TRUE

	if(should_override)
		. = override.Join("")

///Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(src, user)] [thats? "That's ":""][get_examine_name(user)]"

/atom/proc/examine(mob/user)
	. = list("[get_examine_string(user, TRUE)].")

	if(desc)
		. += desc

	if(custom_materials)
		var/list/materials_list = list()
		for(var/i in custom_materials)
			var/datum/material/M = i
			materials_list += "[M.name]"
		. += "<u>It is made out of [english_list(materials_list)]</u>."
	if(reagents)
		if(reagents.reagents_holder_flags & TRANSPARENT)
			. += "It contains:"
			if(length(reagents.reagent_list))
				if(user.can_see_reagents()) //Show each individual reagent
					for(var/datum/reagent/R in reagents.reagent_list)
						. += "[R.volume] units of [R.name]"
				else //Otherwise, just show the total volume
					var/total_volume = 0
					for(var/datum/reagent/R in reagents.reagent_list)
						total_volume += R.volume
					. += "[total_volume] units of various reagents"
			else
				. += "Nothing."
		else if(reagents.reagents_holder_flags & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				. += "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>"
			else
				. += "<span class='danger'>It's empty.</span>"

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)

/**
  * Called when a mob examines (shift click or verb) this atom twice (or more) within EXAMINE_MORE_TIME (default 1.5 seconds)
  *
  * This is where you can put extra information on something that may be superfluous or not important in critical gameplay
  * moments, while allowing people to manually double-examine to take a closer look
  *
  * Produces a signal [COMSIG_PARENT_EXAMINE_MORE]
  */
/atom/proc/examine_more(mob/user)
	. = list()
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE_MORE, user, .)
	if(!LAZYLEN(.)) // lol ..length
		return list("<span class='notice'><i>You examine [src] closer, but find nothing of interest...</i></span>")

/**
 * Updates the appearence of the icon
 *
 * Mostly delegates to update_name, update_desc, and update_icon
 *
 * Arguments:
 * - updates: A set of bitflags dictating what should be updated. Defaults to [ALL]
 */
/atom/proc/update_appearance(updates=ALL)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_APPEARANCE, updates)
	if(updates & UPDATE_NAME)
		. |= update_name(updates)
	if(updates & UPDATE_DESC)
		. |= update_desc(updates)
	if(updates & UPDATE_ICON)
		. |= update_icon(updates)

/// Updates the name of the atom
/atom/proc/update_name(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME, updates)

/// Updates the description of the atom
/atom/proc/update_desc(updates=ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_DESC, updates)

/// Updates the icon of the atom
/atom/proc/update_icon(updates=ALL)
	SIGNAL_HANDLER
	// SHOULD_CALL_PARENT(TRUE)

	. = NONE
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON, updates)
	if(updates & UPDATE_ICON_STATE)
		update_icon_state()
		. |= UPDATE_ICON_STATE

	if(updates & UPDATE_GREYSCALE)
		update_greyscale()
		// var/list/colors = update_greyscale()
		// Updating the greyscale config in update_greyscale() is fine or we would check this earlier
		// if(greyscale_config)
		// 	icon = SSgreyscale.GetColoredIconByType(greyscale_config, colors)
		. |= UPDATE_GREYSCALE

	if(updates & UPDATE_OVERLAYS)
		if(LAZYLEN(managed_vis_overlays))
			SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

		var/list/new_overlays = update_overlays()
		if(managed_overlays)
			cut_overlay(managed_overlays)
			managed_overlays = null
		if(length(new_overlays))
			managed_overlays = new_overlays
			add_overlay(new_overlays)
		. |= UPDATE_OVERLAYS

	. |= SEND_SIGNAL(src, COMSIG_ATOM_UPDATED_ICON, updates, .)

/// Updates the icon state of the atom
/atom/proc/update_icon_state()
	// SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

/atom/proc/update_greyscale()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	// var/list/raw_rgb = splittext(greyscale_colors, "#")
	// for(var/i in 2 to length(raw_rgb))
	// 	. += "#[raw_rgb[i]]"
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_GREYSCALE, .)

/// Updates the overlays of the atom
/atom/proc/update_overlays()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)

/**
 * An atom we are buckled or is contained within us has tried to move
 *
 * Default behaviour is to send a warning that the user can't move while buckled as long
 * as the [buckle_message_cooldown][/atom/var/buckle_message_cooldown] has expired (50 ticks)
 */
/atom/proc/relaymove(mob/living/user, direction)
	if(user.buckle_message_cooldown <= world.time)
		user.buckle_message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>You can't move while buckled to [src]!</span>")
	return

/// Handle what happens when your contents are exploded by a bomb
/atom/proc/contents_explosion(severity, target)
	return //For handling the effects of explosions on contents that would not normally be effected

/**
 * React to being hit by an explosion
 *
 * Default behaviour is to call [contents_explosion][/atom/proc/contents_explosion] and send the [COMSIG_ATOM_EX_ACT] signal
 */
/atom/proc/ex_act(severity, target)
	set waitfor = FALSE
	contents_explosion(severity, target)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)

/**
  * Called when a wave explosion hits this atom. Do not override this.
  *
  * Returns explosion power to "allow through".
  */
/atom/proc/wave_explode(power, datum/wave_explosion/explosion, dir)
	set waitfor = FALSE
	// SHOULD_NOT_SLEEP(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_WAVE_EX_ACT, args)
	. = wave_ex_act(power, explosion, dir)		// this must happen first for stuff like destruction/damage to tick.
	if(isnull(.))
		stack_trace("wave_ex_act on [type] failed to return a number. defaulting to no blocking.")
		return power
	if((explosion_flags & EXPLOSION_FLAG_DENSITY_DEPENDENT) && !density)
		return power	// no block
	else if((explosion_flags & EXPLOSION_FLAG_HARD_OBSTACLE) && !QDELETED(src))
		return 0		// fully blocked

/**
  * Called when a wave explosion hits this atom.
  *
  * Returns explosion power to "allow through". Standard handling and flag overrides in [wave_explode()].
  */
/atom/proc/wave_ex_act(power, datum/wave_explosion/explosion, dir)
	// SHOULD_NOT_SLEEP(TRUE)
	return power * wave_explosion_multiply - wave_explosion_block

/**
 * React to a hit by a blob objecd
 *
 * default behaviour is to send the [COMSIG_ATOM_BLOB_ACT] signal
 */
/atom/proc/blob_act(obj/structure/blob/B)
	// var/blob_act_result = SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B)
	// if (blob_act_result & COMPONENT_CANCEL_BLOB_ACT)
	// 	return FALSE
	SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B)
	return TRUE

/atom/proc/fire_act(exposed_temperature, exposed_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	return

/**
 * React to being hit by a thrown object
 *
 * Default behaviour is to call [hitby_react][/atom/proc/hitby_react] on ourselves after 2 seconds if we are dense
 * and under normal gravity.
 *
 * Im not sure why this the case, maybe to prevent lots of hitby's if the thrown object is
 * deleted shortly after hitting something (during explosions or other massive events that
 * throw lots of items around - singularity being a notable example)
 */
/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	// SEND_SIGNAL(src, COMSIG_ATOM_HITBY, AM, skipcatch, hitpush, blocked, throwingdatum)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, .proc/hitby_react, AM), 2)

/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))

/atom/proc/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube)
	return

//returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	var/blood_id = get_blood_id()
	if(!(blood_id in GLOB.blood_reagent_types))
		return
	return list("color" = BLOOD_COLOR_HUMAN, "ANIMAL DNA" = "Y-")

/mob/living/carbon/get_blood_dna_list()
	var/blood_id = get_blood_id()
	if(!(blood_id in GLOB.blood_reagent_types))
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna["color"] = dna.species.exotic_blood_color //so when combined, the list grows with the number of colors
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["color"] = BLOOD_COLOR_HUMAN
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("color" = BLOOD_COLOR_XENO, "UNKNOWN DNA" = "X*")

//to add a mob's dna info into an object's blood_DNA list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	// Returns 0 if we have that blood already
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	LAZYINITLIST(blood_DNA)	//if our list of DNA doesn't exist yet, initialise it.
	var/old_length = blood_DNA.len
	blood_DNA |= new_blood_dna
	var/changed = FALSE
	if(!blood_DNA["color"])
		blood_DNA["color"] = new_blood_dna["color"]
		changed = TRUE
	else
		var/old = blood_DNA["color"]
		blood_DNA["color"] = BlendRGB(blood_DNA["color"], new_blood_dna["color"])
		changed = old != blood_DNA["color"]
	if(blood_DNA.len == old_length)
		return FALSE
	return changed

//to add blood dna info to the object's blood_DNA list
/atom/proc/transfer_blood_dna(list/blood_dna, list/datum/disease/diseases)
	LAZYINITLIST(blood_DNA)

	var/old_length = blood_DNA.len
	blood_DNA |= blood_dna
	if(blood_DNA.len > old_length)
		. = TRUE
		//some new blood DNA was added
		if(!blood_dna["color"])
			return
		if(!blood_DNA["color"])
			blood_DNA["color"] = blood_dna["color"]
		else
			blood_DNA["color"] = BlendRGB(blood_DNA["color"], blood_dna["color"])

//to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return FALSE
	return add_blood_DNA(blood_dna, M.diseases)

//to add blood onto something, with blood dna info to include.
/atom/proc/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	return FALSE

/obj/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	return transfer_blood_dna(blood_dna, diseases)

/obj/item/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	if(!.)
		return
	add_blood_overlay()

/obj/item/proc/add_blood_overlay()
	if(!blood_DNA.len)
		return
	if(initial(icon) && initial(icon_state))
		blood_splatter_icon = icon(initial(icon), initial(icon_state), , 1)		//we only want to apply blood-splatters to the initial icon_state for each object
		blood_splatter_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
		blood_splatter_icon.Blend(icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		blood_splatter_icon.Blend(blood_DNA_to_color(), ICON_MULTIPLY)
		add_overlay(blood_splatter_icon)

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src, diseases)
	B.transfer_blood_dna(blood_dna, diseases) //give blood info to the blood decal.
	return TRUE //we bloodied the floor

/mob/living/carbon/human/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	if(head)
		head.add_blood_DNA(blood_dna, diseases)
		update_inv_head()
	else if(wear_mask)
		wear_mask.add_blood_DNA(blood_dna, diseases)
		update_inv_wear_mask()
	if(wear_neck)
		wear_neck.add_blood_DNA(blood_dna, diseases)
		update_inv_neck()
	if(wear_suit)
		wear_suit.add_blood_DNA(blood_dna, diseases)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood_DNA(blood_dna, diseases)
		update_inv_w_uniform()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood_DNA(blood_dna, diseases)
	else
		transfer_blood_dna(blood_dna, diseases)
		bloody_hands = rand(2, 4)
	update_inv_gloves()	//handles bloody hands overlays and updating
	return TRUE

/atom/proc/blood_DNA_to_color()
	return (blood_DNA && blood_DNA["color"]) || BLOOD_COLOR_HUMAN

/atom/proc/clean_blood()
	. = blood_DNA? TRUE : FALSE
	blood_DNA = null

/atom/proc/wash_cream()
	return TRUE

/atom/proc/isinspace()
	if(isspaceturf(get_turf(src)))
		return TRUE
	else
		return FALSE

/atom/proc/handle_fall()
	return

/atom/proc/singularity_act()
	return

/atom/proc/singularity_pull(obj/singularity/S, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, S, current_size)

/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)

/atom/proc/emag_act()
	return SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT)

/atom/proc/rad_act(strength)
	SEND_SIGNAL(src, COMSIG_ATOM_RAD_ACT, strength)

/atom/proc/narsie_act()
	SEND_SIGNAL(src, COMSIG_ATOM_NARSIE_ACT)

/atom/proc/ratvar_act()
	SEND_SIGNAL(src, COMSIG_ATOM_RATVAR_ACT)

/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	SEND_SIGNAL(src, COMSIG_ATOM_RCD_ACT, user, the_rcd, passed_mode)
	return FALSE

/**
  * Respond to a electric bolt action on our item
  *
  * Default behaviour is to return, we define here to allow for cleaner code later on
  */
/atom/proc/zap_act(power, zap_flags, shocked_targets)
	return

/atom/proc/storage_contents_dump_act(obj/item/storage/src_object, mob/user)
	if(GetComponent(/datum/component/storage))
		return component_storage_contents_dump_act(src_object, user)
	return FALSE

/atom/proc/component_storage_contents_dump_act(datum/component/storage/src_object, mob/user)
	var/list/things = src_object.contents()
	var/datum/progressbar/progress = new(user, things.len, src)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	while (do_after(user, 10, TRUE, src, FALSE, CALLBACK(STR, /datum/component/storage.proc/handle_mass_item_insertion, things, src_object, user, progress)))
		stoplag(1)
	qdel(progress)
	to_chat(user, "<span class='notice'>You dump as much of [src_object.parent]'s contents into [STR.insert_preposition]to [src] as you can.</span>")
	if(user.active_storage) //refresh the HUD to show the transfered contents
		user.active_storage.ui_show(user)
	return TRUE

/atom/proc/get_dumping_location(obj/item/storage/source,mob/user)
	return null

//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, A)

//called when the turf the atom resides on is ChangeTurfed
/atom/proc/HandleTurfChange(turf/T)
	for(var/a in src)
		var/atom/A = a
		A.HandleTurfChange(T)

//the vision impairment to give to the mob whose perspective is set to that atom (e.g. an unfocused camera giving you an impaired vision when looking through it)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
	return


//Hook for running code when a dir change occurs
/atom/proc/setDir(newdir, ismousemovement=FALSE)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir

/atom/proc/mech_melee_attack(obj/mecha/M)
	return

//If a mob logouts/logins in side of an object you can use this proc
/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)


/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/


/*
	Adds an instance of colour_type to the atom's atom_colours list
*/
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()


/*
	Removes an instance of colour_type from the atom's atom_colours list
*/
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()


/*
	Resets the atom's color to null, and then sets it to the highest priority
	colour available
*/
/atom/proc/update_atom_colour()
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return

/atom/vv_edit_var(var_name, var_value)
	if(!GLOB.Debug2)
		flags_1 |= ADMIN_SPAWNED_1
	. = ..()
	switch(var_name)
		if(NAMEOF(src, color))
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)

/atom/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	if(!ismovable(src))
		var/turf/curturf = get_turf(src)
		if(curturf)
			. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]'>Jump To</option>"
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_TRANSFORM, "Modify Transform")
	VV_DROPDOWN_OPTION(VV_HK_ADD_REAGENT, "Add Reagent")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EMP, "EMP Pulse")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EXPLOSION, "Explosion")
	// VV_DROPDOWN_OPTION(VV_HK_RADIATE, "Radiate")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_FILTERS, "Edit Filters")
	// VV_DROPDOWN_OPTION(VV_HK_ADD_AI, "Add AI controller")

/atom/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_ADD_REAGENT] && check_rights(R_VAREDIT))
		if(!reagents)
			var/amount = input(usr, "Specify the reagent size of [src]", "Set Reagent Size", 50) as num
			if(amount)
				create_reagents(amount)

		if(reagents)
			var/chosen_id = choose_reagent_id(usr)
			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", reagents.maximum_volume) as num
				if(amount)
					reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to [src]")
					message_admins("<span class='notice'>[key_name(usr)] has added [amount] units of [chosen_id] to [src]</span>")
	if(href_list[VV_HK_TRIGGER_EXPLOSION] && check_rights(R_FUN))
		usr.client.cmd_admin_explosion(src)
	if(href_list[VV_HK_TRIGGER_EMP] && check_rights(R_FUN))
		usr.client.cmd_admin_emp(src)
	if(href_list[VV_HK_MODIFY_TRANSFORM] && check_rights(R_VAREDIT))
		var/result = input(usr, "Choose the transformation to apply","Transform Mod") as null|anything in list("Scale","Translate","Rotate")
		var/matrix/M = transform
		switch(result)
			if("Scale")
				var/x = input(usr, "Choose x mod","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod","Transform Mod") as null|num
				if(!isnull(x) && !isnull(y))
					transform = M.Scale(x,y)
			if("Translate")
				var/x = input(usr, "Choose x mod","Transform Mod") as null|num
				var/y = input(usr, "Choose y mod","Transform Mod") as null|num
				if(!isnull(x) && !isnull(y))
					transform = M.Translate(x,y)
			if("Rotate")
				var/angle = input(usr, "Choose angle to rotate","Transform Mod") as null|num
				if(!isnull(angle))
					transform = M.Turn(angle)
	if(href_list[VV_HK_AUTO_RENAME] && check_rights(R_VAREDIT))
		var/newname = input(usr, "What do you want to rename this to?", "Automatic Rename") as null|text
		if(newname)
			vv_auto_rename(newname)
	if(href_list[VV_HK_EDIT_FILTERS] && check_rights(R_VAREDIT))
		var/client/C = usr.client
		C?.open_filter_editor(src)

/atom/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += "[VV_HREF_TARGETREF(refid, VV_HK_AUTO_RENAME, "<b id='name'>[src]</b>")]"
	. += "<br><font size='1'><a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(dir) || dir]</a> <a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"

/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : L.drop_location()

/atom/proc/vv_auto_rename(newname)
	name = newname

/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/atom/Exit(atom/movable/AM, atom/newLoc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, AM, newLoc) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

/atom/Exited(atom/movable/AM, atom/newLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newLoc)

/atom/proc/return_temperature()
	return

// Tool behavior procedure. Redirects to tool-specific procs by default.
// You can override it to catch all tool interactions, for use in complex deconstruction procs.
// Just don't forget to return ..() in the end.
/atom/proc/tool_act(mob/living/user, obj/item/I, tool_type)
	switch(tool_type)
		if(TOOL_CROWBAR)
			return crowbar_act(user, I)
		if(TOOL_MULTITOOL)
			return multitool_act(user, I)
		if(TOOL_SCREWDRIVER)
			return screwdriver_act(user, I)
		if(TOOL_WRENCH)
			return wrench_act(user, I)
		if(TOOL_WIRECUTTER)
			return wirecutter_act(user, I)
		if(TOOL_WELDER)
			return welder_act(user, I)
		if(TOOL_ANALYZER)
			return analyzer_act(user, I)

// Tool-specific behavior procs. To be overridden in subtypes.
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return

/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return

/atom/proc/multitool_check_buffer(user, obj/item/I, silent = FALSE)
	if(!I.tool_behaviour == TOOL_MULTITOOL)
		if(user && !silent)
			to_chat(user, "<span class='warning'>[I] has no data buffer!</span>")
		return FALSE
	return TRUE

/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	SEND_SIGNAL(src, COMSIG_ATOM_SCREWDRIVER_ACT, user, I)

/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return

/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return

/atom/proc/welder_act(mob/living/user, obj/item/I)
	return

/atom/proc/analyzer_act(mob/living/user, obj/item/I)
	return

/atom/proc/GenerateTag()
	return

/**
  * Called after a shuttle is loaded **from map template initially**.
  *
  * @params
  * * port - Mobile port/shuttle
  * * dock - Stationary dock the shuttle's at
  * * idnum - ID number of the shuttle
  */
/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	return

// Generic logging helper
/atom/proc/log_message(message, message_type, color=null, log_globally=TRUE)
	if(!log_globally)
		return

	var/log_text = "[key_name(src)] [message] [loc_name(src)]"
	switch(message_type)
		if(LOG_ATTACK)
			log_attack(log_text)
		if(LOG_SAY)
			log_say(log_text)
		if(LOG_WHISPER)
			log_whisper(log_text)
		if(LOG_EMOTE)
			log_emote(log_text)
		if(LOG_SUBTLER)
			log_subtler(log_text)
		if(LOG_DSAY)
			log_dsay(log_text)
		if(LOG_PDA)
			log_pda(log_text)
		if(LOG_CHAT)
			log_chat(log_text)
		if(LOG_COMMENT)
			log_comment(log_text)
		if(LOG_TELECOMMS)
			log_telecomms(log_text)
		if(LOG_OOC)
			log_ooc(log_text)
		if(LOG_ADMIN)
			log_admin(log_text)
		if(LOG_ADMIN_PRIVATE)
			log_admin_private(log_text)
		if(LOG_ASAY)
			log_adminsay(log_text)
		if(LOG_OWNERSHIP)
			log_game(log_text)
		if(LOG_GAME)
			log_game(log_text)
		if(LOG_SHUTTLE)
			log_shuttle(log_text)
		else
			stack_trace("Invalid individual logging type: [message_type]. Defaulting to [LOG_GAME] (LOG_GAME).")
			log_game(log_text)

// Helper for logging chat messages or other logs with arbitrary inputs (e.g. announcements)
/atom/proc/log_talk(message, message_type, tag=null, log_globally=TRUE, forced_by=null)
	var/prefix = tag ? "([tag]) " : ""
	var/suffix = forced_by ? " FORCED by [forced_by]" : ""
	log_message("[prefix]\"[message]\"[suffix]", message_type, log_globally=log_globally)

// Helper for logging of messages with only one sender and receiver
/proc/log_directed_talk(atom/source, atom/target, message, message_type, tag)
	if(!tag)
		stack_trace("Unspecified tag for private message")
		tag = "UNKNOWN"

	source.log_talk(message, message_type, tag="[tag] to [key_name(target)]")
	if(source != target)
		target.log_talk(message, message_type, tag="[tag] from [key_name(source)]", log_globally=FALSE)

/**
  * Log a combat message in the attack log
  *
  * Arguments:
  * * atom/user - argument is the actor performing the action
  * * atom/target - argument is the target of the action
  * * what_done - is a verb describing the action (e.g. punched, throwed, kicked, etc.)
  * * atom/object - is a tool with which the action was made (usually an item)
  * * addition - is any additional text, which will be appended to the rest of the log line
  */
/proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	var/ssource = key_name(user)
	var/starget = key_name(target)

	var/mob/living/living_target = target
	var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""

	var/sobject = ""
	if(object)
		sobject = " with [key_name(object)]"
	var/saddition = ""
	if(addition)
		saddition = " [addition]"

	var/postfix = "[sobject][saddition][hp]"

	var/message = "has [what_done] [starget][postfix]"
	user.log_message(message, LOG_ATTACK, color="red")

	if(user != target)
		var/reverse_message = "has been [what_done] by [ssource][postfix]"
		target.log_message(reverse_message, LOG_ATTACK, color="orange", log_globally=FALSE)

/**
  * log_wound() is for when someone is *attacked* and suffers a wound. Note that this only captures wounds from damage, so smites/forced wounds aren't logged, as well as demotions like cuts scabbing over
  *
  * Note that this has no info on the attack that dealt the wound: information about where damage came from isn't passed to the bodypart's damaged proc. When in doubt, check the attack log for attacks at that same time
  * TODO later: Add logging for healed wounds, though that will require some rewriting of healing code to prevent admin heals from spamming the logs. Not high priority
  *
  * Arguments:
  * * victim- The guy who got wounded
  * * suffered_wound- The wound, already applied, that we're logging. It has to already be attached so we can get the limb from it
  * * dealt_damage- How much damage is associated with the attack that dealt with this wound.
  * * dealt_wound_bonus- The wound_bonus, if one was specified, of the wounding attack
  * * dealt_bare_wound_bonus- The bare_wound_bonus, if one was specified *and applied*, of the wounding attack. Not shown if armor was present
  * * base_roll- Base wounding ability of an attack is a random number from 1 to (dealt_damage ** WOUND_DAMAGE_EXPONENT). This is the number that was rolled in there, before mods
  */
/proc/log_wound(atom/victim, datum/wound/suffered_wound, dealt_damage, dealt_wound_bonus, dealt_bare_wound_bonus, base_roll)
	if(QDELETED(victim) || !suffered_wound)
		return
	var/message = "has suffered: [suffered_wound][suffered_wound.limb ? " to [suffered_wound.limb.name]" : null]"// maybe indicate if it's a promote/demote?

	if(dealt_damage)
		message += " | Damage: [dealt_damage]"
		// The base roll is useful since it can show how lucky someone got with the given attack. For example, dealing a cut
		if(base_roll)
			message += " (rolled [base_roll]/[dealt_damage ** WOUND_DAMAGE_EXPONENT])"

	if(dealt_wound_bonus)
		message += " | WB: [dealt_wound_bonus]"

	if(dealt_bare_wound_bonus)
		message += " | BWB: [dealt_bare_wound_bonus]"

	victim.log_message(message, LOG_ATTACK, color="blue")

/atom/proc/add_filter(name,priority,list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

/atom/proc/update_filters()
	filters = null
	filter_data = sortTim(filter_data, /proc/cmp_filter_data_priority, TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/atom/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/atom/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/obj/item/update_filters()
	. = ..()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/atom/proc/get_filter(name)
	if(filter_data && filter_data[name])
		return filters[filter_data.Find(name)]

/atom/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/atom/proc/clear_filters()
	filter_data = null
	filters = null

/atom/proc/intercept_zImpact(atom/movable/AM, levels = 1)
	. |= SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_Z_FALL, AM, levels)

///Sets the custom materials for an item.
/atom/proc/set_custom_materials(list/materials, multiplier = 1)
	if(custom_materials) //Only runs if custom materials existed at first. Should usually be the case but check anyways
		for(var/i in custom_materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(i)
			custom_material.on_removed(src, custom_materials[i], material_flags) //Remove the current materials

	if(!length(materials))
		custom_materials = null
		return

	if(material_flags)
		for(var/x in materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(x)
			custom_material.on_applied(src, materials[x] * multiplier * material_modifier, material_flags)

	custom_materials = SSmaterials.FindOrCreateMaterialCombo(materials, multiplier)

/**
  * Returns true if this atom has gravity for the passed in turf
  *
  * Sends signals COMSIG_ATOM_HAS_GRAVITY and COMSIG_TURF_HAS_GRAVITY, both can force gravity with
  * the forced gravity var
  *
  * Gravity situations:
  * * No gravity if you're not in a turf
  * * No gravity if this atom is in is a space turf
  * * Gravity if the area it's in always has gravity
  * * Gravity if there's a gravity generator on the z level
  * * Gravity if the Z level has an SSMappingTrait for ZTRAIT_GRAVITY
  * * otherwise no gravity
  */
/atom/proc/has_gravity(turf/T)
	if(!T || !isturf(T))
		T = get_turf(src)

	if(!T)
		return 0

	var/list/forced_gravity = list()
	SEND_SIGNAL(src, COMSIG_ATOM_HAS_GRAVITY, T, forced_gravity)
	if(!forced_gravity.len)
		SEND_SIGNAL(T, COMSIG_TURF_HAS_GRAVITY, src, forced_gravity)
	if(forced_gravity.len)
		var/max_grav
		for(var/i in forced_gravity)
			max_grav = max(max_grav, i)
		return max_grav

	if(isspaceturf(T)) // Turf never has gravity
		return 0

	var/area/A = get_area(T)
	if(A.has_gravity) // Areas which always has gravity
		return A.has_gravity
	else
		// There's a gravity generator on our z level
		if(GLOB.gravity_generators["[T.z]"])
			var/max_grav = 0
			for(var/obj/machinery/gravity_generator/main/G in GLOB.gravity_generators["[T.z]"])
				max_grav = max(G.setting,max_grav)
			return max_grav
	return SSmapping.level_trait(T.z, ZTRAIT_GRAVITY)

/**
  * Causes effects when the atom gets hit by a rust effect from heretics
  *
  * Override this if you want custom behaviour in whatever gets hit by the rust
  */
/atom/proc/rust_heretic_act()
	return

/**
  * Used to set something as 'open' if it's being used as a supplypod
  *
  * Override this if you want an atom to be usable as a supplypod.
  */
/atom/proc/setOpened()
		return

/**
  * Used to set something as 'closed' if it's being used as a supplypod
  *
  * Override this if you want an atom to be usable as a supplypod.
  */
/atom/proc/setClosed()
		return
