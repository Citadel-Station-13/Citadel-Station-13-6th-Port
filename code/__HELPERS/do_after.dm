/**
  * Higher overhead "advanced" version of do_after.
  * @params
  * - atom/user is the atom doing the action or the "physical" user
  * - delay is time in deciseconds
  * - atom/target is the atom the action is being done to, defaults to user
  * - do_after_flags see __DEFINES/flags/do_after.dm for details.
  * - datum/callback/extra_checks - Every time this ticks, extra_checks() is invoked with (user, delay, target, time_left, do_after_flags, required_mobility_flags, required_combat_flags, mob_redirect, stage, initially_held_item, tool).
  * 	Stage can be DO_AFTER_STARTING, DO_AFTER_PROGRESSING, DO_AFTER_FINISHING
  * 	If it returns DO_AFTER_STOP, this breaks.
  * 	If it returns nothing, all other checks are done.
  * 	If it returns DO_AFTER_PROCEED, all other checks are ignored.
  * - required_mobility_flags is checked with CHECK_ALL_MOBILITY. Will immediately fail if the user isn't a mob.
  * - requried_combat_flags is checked with CHECK_MULTIPLE_BITFIELDS. Will immediately fail if the user isn't a mob.
  * - mob/living/mob_redirect - advanced option: If this is specified, movement and mobility/combat flag checks will use this instead of user. Progressbars will also go to this.
  * - obj/item/tool - The tool we're using. See do_after flags for details.
  */
#define INVOKE_CALLBACK cb_return = extra_checks?.Invoke(user, delay, target, world.time - starttime, do_after_flags, required_mobility_flags, required_combat_flags, mob_redirect, stage, initially_held_item, tool)
#define CHECK_FLAG_FAILURE ((required_mobility_flags || required_combat_flags) && (!living_user || (required_mobility_flags && !CHECK_ALL_MOBILITY(living_user, required_mobility_flags)) || (required_combat_flags && !CHECK_MULTIPLE_BITFIELDS(living_user.combat_flags, required_combat_flags))))
#define TIMELEFT (world.time - starttime)
/proc/do_after_advanced(atom/user, delay, atom/target, do_after_flags, datum/callback/extra_checks, required_mobility_flags, required_combat_flags, mob/living/mob_redirect, obj/item/tool)
	// CHECK AND SET VARIABLES
	if(!user)
		return FALSE
	if(!target)
		target = user
	if((user.loc == null) || (target.loc == null))
		return FALSE
	var/mob/living/living_user = mob_redirect
	if(!living_user && isliving(user))
		living_user = user
	var/stage = DO_AFTER_STARTING
	var/startlocuser = user.loc
	var/startloctarget = target.loc
	var/turf/userturf = get_turf(user)
	var/turf/targetturf = get_turf(target)
	if(!userturf || !targetturf)
		return FALSE
	if((do_after_flags & DO_AFTER_REQUIRES_USER_ON_TURF) && !isturf(user.loc))
		return FALSE
	if(!(do_after_flags & DO_AFTER_NO_COEFFICIENT) && living_user)
		delay *= living_user.cached_multiplicative_actions_slowdown
	var/starttime = world.time
	var/endtime = world.time + delay
	var/obj/item/initially_held_item = mob_redirect?.get_active_held_item()
	var/atom/movable/AM_user = ismovable(user) && user
	var/drifting = AM_user?.Process_Spacemove(NONE) && AM_user.inertia_dir
	var/initial_dx = targetturf.x - userturf.x
	var/initial_dy = targetturf.y - userturf.y
	var/dx = initial_dx
	var/dy = initial_dy
	// DO OUR STARTING CHECKS
	var/cb_return
	INVOKE_CALLBACK
	if(cb_return == DO_AFTER_STOP)
		return FALSE
	else if(cb_return != DO_AFTER_PROCEED)
		if(CHECK_FLAG_FAILURE)
			return FALSE
	// SETUP LOOP
	var/datum/progressbar/progbar
	if(living_user)
		if(!(do_after_flags & DO_AFTER_NO_PROGRESSBAR))
			progbar = new(living_user, delay, target)
	// MAIN LOOP
	. = TRUE
	if(!delay)
		return
	var/obj/item/held
	var/locchanged
	var/ctu
	var/ctt
	while(world.time < endtime)
		stoplag(1)
		progbar?.update(TIMELEFT)
		if(QDELETED(user) || QDELETED(target) || (user.loc == null) || (target.loc == null))
			. = FALSE
			break
		INVOKE_CALLBACK
		if(cb_return == DO_AFTER_STOP)
			. = FALSE
			break
		else if(cb_return == DO_AFTER_PROCEED)
			continue
		// otherwise, go through our normal checks.
		if(((do_after_flags & DO_AFTER_DISALLOW_MOVING_ABSOLUTE_USER) && (user.loc != startlocuser)) || ((do_after_flags & DO_AFTER_DISALLOW_MOVING_ABSOLUTE_TARGET) && (target.loc != startloctarget)))
			. = FALSE
			break
		else if(do_after_flags & DO_AFTER_DISALLOW_MOVING_RELATIVE)
			ctu = get_turf(user)
			ctt = get_turf(target)
			locchanged = (userturf != ctu) || (targetturf != ctt)
			userturf = ctu
			targetturf = ctt
			dx = targetturf.x - userturf.x
			dy = targetturf.y - userturf.y
			if((dx != initial_dx) || (dy != initial_dy))
				. = FALSE
				break
			if(locchanged && !drifting && !(do_after_flags & DO_AFTER_ALLOW_NONSPACEDRIFT_RELATIVITY))
				. = FALSE
				break
		if(!AM_user.inertia_dir)
			drifting = FALSE
		if((do_after_flags & DO_AFTER_REQUIRES_USER_ON_TURF) && !isturf(user.loc))
			return FALSE
		if(CHECK_FLAG_FAILURE)
			. = FALSE
			break
		held = living_user?.get_active_held_item()
		if((do_after_flags & DO_AFTER_DISALLOW_ACTIVE_ITEM_CHANGE) && (held != (tool || initially_held_item)))
			. = FALSE
			break
		if((do_after_flags & DO_AFTER_REQUIRE_FREE_HAND_OR_TOOL) && (!living_user?.is_holding(tool) && !length(living_user?.get_empty_held_indexes())))
			. = FALSE
			break

	// CLEANUP
	qdel(progbar)
	// If we failed, just return.
	if(!.)
		return FALSE
	// DO FINISHING CHECKS
	if(QDELETED(user) || QDELETED(target))
		return FALSE
	INVOKE_CALLBACK
	if(cb_return == DO_AFTER_STOP)
		return FALSE
	else if(cb_return == DO_AFTER_PROCEED)
		return TRUE
	if(CHECK_FLAG_FAILURE)
		return FALSE
	if(((do_after_flags & DO_AFTER_DISALLOW_MOVING_ABSOLUTE_USER) && (user.loc != startlocuser)) || ((do_after_flags & DO_AFTER_DISALLOW_MOVING_ABSOLUTE_TARGET) && (target.loc != startloctarget)))
		return FALSE
	else if(do_after_flags & DO_AFTER_DISALLOW_MOVING_RELATIVE)
		ctu = get_turf(user)
		ctt = get_turf(target)
		locchanged = (userturf != ctu) || (targetturf != ctt)
		userturf = ctu
		targetturf = ctt
		dx = targetturf.x - userturf.x
		dy = targetturf.y - userturf.y
		if((dx != initial_dx) || (dy != initial_dy))
			return FALSE
		if(locchanged && !drifting && !(do_after_flags & DO_AFTER_ALLOW_NONSPACEDRIFT_RELATIVITY))
			return FALSE
	if((do_after_flags & DO_AFTER_REQUIRES_USER_ON_TURF) && !isturf(user.loc))
		return FALSE
	held = living_user?.get_active_held_item()
	if((do_after_flags & DO_AFTER_DISALLOW_ACTIVE_ITEM_CHANGE) && (held != (tool || initially_held_item)))
		return FALSE
	if((do_after_flags & DO_AFTER_REQUIRE_FREE_HAND_OR_TOOL) && (!living_user?.is_holding(tool) && !length(living_user?.get_empty_held_indexes())))
		return FALSE

#undef INVOKE_CALLBACK
#undef CHECK_FLAG_FAILURE

//some additional checks as a callback for for do_afters that want to break on losing health or on the mob taking action
/mob/proc/break_do_after_checks(list/checked_health, check_clicks)
	if(check_clicks && !CheckActionCooldown())
		return FALSE
	return TRUE

//pass a list in the format list("health" = mob's health var) to check health during this
/mob/living/break_do_after_checks(list/checked_health, check_clicks)
	if(islist(checked_health))
		if(health < checked_health["health"])
			return FALSE
		checked_health["health"] = health
	return ..()

/proc/do_after(mob/user, var/delay, needhand = 1, atom/target = null, progress = 1, datum/callback/extra_checks = null, required_mobility_flags = (MOBILITY_USE|MOBILITY_MOVE), resume_time = 0 SECONDS)
	if(!user)
		return 0
	var/atom/Tloc = null
	if(target && !isturf(target))
		Tloc = target.loc

	if(target)
		LAZYADD(user.do_afters, target)
		LAZYADD(target.targeted_by, user)

	var/atom/Uloc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/holding = user.get_active_held_item()

	var/holdingnull = 1 //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = 0 //Users hand started holding something, check to see if it's still holding that

	delay *= user.cached_multiplicative_actions_slowdown

	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, delay, target)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = 1
	var/mob/living/L = isliving(user) && user			//evals to last thing eval'd
	while (world.time + resume_time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime + resume_time)

		if(drifting && !user.inertia_dir)
			drifting = 0
			Uloc = user.loc

		if(L && !CHECK_ALL_MOBILITY(L, required_mobility_flags))
			. = 0
			break

		if(QDELETED(user) || user.stat || (!drifting && user.loc != Uloc) || (extra_checks && !extra_checks.Invoke()))
			. = 0
			break

		if(!QDELETED(Tloc) && (QDELETED(target) || Tloc != target.loc))
			if((Uloc != Tloc || Tloc != user) && !drifting)
				. = 0
				break

		if(target && !(target in user.do_afters))
			. = FALSE
			break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					. = 0
					break
			if(user.get_active_held_item() != holding)
				. = 0
				break
	if(progress)
		qdel(progbar)
	if(!QDELETED(target))
		LAZYREMOVE(user.do_afters, target)

	if(!QDELETED(target))
		LAZYREMOVE(user.do_afters, target)
		LAZYREMOVE(target.targeted_by, user)

/proc/do_after_mob(mob/user, var/list/targets, time = 30, uninterruptible = 0, progress = 1, datum/callback/extra_checks)
	if(!user || !targets)
		return 0
	if(!islist(targets))
		targets = list(targets)
	var/user_loc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/list/originalloc = list()
	for(var/atom/target in targets)
		originalloc[target] = target.loc
		LAZYADD(user.do_afters, target)
		LAZYADD(target.targeted_by, user)

	var/holding = user.get_active_held_item()
	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, time, targets[1])

	time *= user.cached_multiplicative_actions_slowdown

	var/endtime = world.time + time
	var/starttime = world.time
	. = 1
	mainloop:
		while(world.time < endtime)
			stoplag(1)
			if(progress)
				progbar.update(world.time - starttime)
			if(QDELETED(user) || !targets)
				. = 0
				break
			if(uninterruptible)
				continue

			if(drifting && !user.inertia_dir)
				drifting = 0
				user_loc = user.loc

			for(var/atom/target in targets)
				if((!drifting && user_loc != user.loc) || QDELETED(target) || originalloc[target] != target.loc || user.get_active_held_item() != holding || user.incapacitated() || user.lying || (extra_checks && !extra_checks.Invoke()))
					. = 0
					break mainloop
	if(progbar)
		qdel(progbar)
	for(var/thing in targets)
		var/atom/target = thing
		if(!QDELETED(target))
			LAZYREMOVE(user.do_afters, target)
			LAZYREMOVE(target.targeted_by, user)
