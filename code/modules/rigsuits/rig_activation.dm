// Note - user vs wearer.
// When being remote controlled, they won't be the same. Wearer should always be a loc check.

/**
 * Immediately activates the rig.
 */
/obj/item/rig/proc/activate(mob/user, silent, bypass_seal_delay, deploy_all)
	ASSERT(isliving(loc))
	wearer = loc
	rig_message(user, "[src] clicks into place around you.", "RIG system initializations complete.")
	if(!deploy_all)
		INVOKE_ASYNC(src, .proc/try_seal_all, bypass_delay = bypass_seal_delay)
	else
		INVOKE_ASYNC(src, .proc/deploy_all, bypass_delay = bypass_seal_delay))
	#warn self nodrop trait that prevents user from removing it themselves

/**
 * Immediately deactivates the rig.
 */
/obj/item/rig/proc/deactivate(mob/user, silent, retract_all)
	rig_message(user, "[src]'s locks click open, detaching itself from you.", "RIG shutdown complete.")
	unseal_all(bypass_delay = TRUE)
	if(retract_all)
		retract_all()
	#warn self nodrop trait that prevents user from removing it themselves
	wearer = null

/**
 * Tries to activate the rig.
 */
/obj/item/rig/proc/try_activate(mob/user, silent, ignore_permissions = FALSE, bypass_delay = FALSE, bypass_seal_delay = FALSE, deploy_all = FALSE)
	if(wearer)
		to_chat(user, "<span class='danger'>BUG: A wearer already exists for this rigsuit. Contact coders and/or admins immediately.</span>>")
		CRASH("Rig with existing wearer is trying to activate again.")
	// temporarily set wearer
	wearer = loc
	if(activated)
		if(!silent)
			rig_message(user, "<span class='warning'>[src] is already activated!</span>")
		wearer = null
		return
	if(!activation_slot_check(user))
		if(!silent)
			rig_message(user, "<span class='warning'>[src] must be on [ismob(loc)? ((loc == user)? "your" : "[loc]'s") : "someone's"] back!</span>", target_only = TRUE)
		wearer = null
		return
	if(!ignore_permissions && !check_control_flags(user, RIG_CONTROL_ACTIVATION))
		if(!silent)
			rig_message(user, "<span class='warning'>[src] blinks red as you try to manipulate the activation. You seem to be locked out!</span>", target_only = TRUE)
		wearer = null
		return
	var/delay = bypass_delay? 0 : cycle_delay
	if(delay)
		if(!silent)
			rig_message(user, "[src] clicks as it begins to seal...", "Initiating RIG_OS activation and attaching to user...")
		if(!do_mob(wearer, wearer, delay, TRUE, TRUE))
			wearer = null
			return
	// clear again, because activate should handle wearer
	wearer = null
	/// Success.
	activate(user, silent, bypass_seal_delay, deploy_all)

/**
 * Tries to deactivate the rig.
 */
/obj/item/rig/proc/try_deactivate(mob/user, silent, ignore_permissions = FALSE, bypass_delay = FALSE, bypass_seal_delay = FALSE, retract_all = FALSE)
	if(!activated)
		if(!silent)
			rig_message(user, "<span class='warning'>[src] is not activated!</span>")
		return
	if(!ignore_permissions && !check_control_flags(user, RIG_CONTROL_ACTIVATION))
		if(!silent)
			rig_message(user, "<span class='warning'>[src] blinks red as you try to manipulate the activation. You seem to be locked out!</span>", target_only = TRUE)
		return
	var/delay = bypass_delay? 0 : cycle_delay
	if(delay)
		if(!silent)
			rig_message(user, "[src] clicks as it begins to unseal...", "Powering off suit systems...")
		if(retract_all)
			retract_all(silent = silent, bypass_delay = bypass_sela_delay)
		else
			try_unseal_all(silent = silent, bypass_delay = bypass_seal_delay)
		if(!do_mob(wearer, wearer, delay, TRUE, TRUE))
			return
	/// Success.
	deactivate(user, silent, retract_all)


/**
 * Checks that the rig is in the right slot.
 */
/obj/item/rig/proc/activation_slot_check(mob/user)
	// hardcoded to humans for now
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer))
		return FALSE
	// hardcoded for back for now
	return wearer.back == src
