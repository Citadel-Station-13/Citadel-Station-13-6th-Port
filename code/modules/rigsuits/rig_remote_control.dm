/**
 * RIGSUIT REMOTE CONTROL
 *
 * Remote control will generally involve one of the following:
 * - If the controller is something like a carded AI, which is physically in the rigsuit, their view will be directly jacked into it with necessary UI to function. It's like as if they're controlling the host.
 * - If the controller is not, like a malf AI hacking a RIG, their view will pop up on a TGUI screen. A toggle will be provided to redirect their movement/clicks. This is highly experimental.
 */

/**
 * Gets the control flags of a user.
 */
/obj/item/rig/proc/get_control_flags(mob/M)
	if(!fakeuser && (M == wearer))
		return wearer_control_flags
	if(M in remote_controllers)
		return remote_controllers[M]
	return NONE

/**
 * Checks if a user has a set of control flags
 */
/obj/item/rig/proc/check_control_flags(mob/M, flags)
	return (get_control_flags(M) & flags) == flags

/**
 * Send different messages based on if target is the actual wearer, or someone controlling the suit.
 * If no target, sends to wearer only
 * If target, sends wearer or controller message to target based on who they are, AND sends wearer message to wearer if target_only isn't TRUE
 *
 * Applies span class notice by default.
 */
/obj/item/rig/proc/rig_message(mob/target, wearer_message, controller_message, target_only = FALSE)
	if(!controller_message)
		controller_message = wearer_message
	if(!target)
		to_chat(wearer, "<span class='notice'>[wearer_message]</span>")
		return
	if(target == wearer)
		to_chat(wearer, "<span class='notice'>[wearer_message]</span>")
		return
	to_chat(target, "<span class='notice'>[controller_message]</span>")
	if(!target_only)
		to_chat(wearer, "<span class='notice'>[wearer_message]</span>")

/**
 * Checks if user has control flags.
 * If false, warns the user with a message.
 */
/obj/item/rig/proc/attempt_control_flags(mob/M, flags, msg = "<span class='warning'>You seem to be locked out of this function.</span>")
	. = check_control_flags(M, flags)
	if(!.)
		to_chat(M, msg)
