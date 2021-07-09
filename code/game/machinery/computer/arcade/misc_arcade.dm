// Memeorable yet too short arcade games ahead.

// ** AMPUTATION ** //

/obj/machinery/computer/arcade/amputation
	name = "Mediborg's Amputation Adventure"
	desc = "A picture of a blood-soaked medical cyborg flashes on the screen. The mediborg has a speech bubble that says, \"Put your hand in the machine if you aren't a <b>coward!</b>\""
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/amputation

/obj/machinery/computer/arcade/amputation/on_attack_hand(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/c_user = user
	if(!c_user.get_bodypart(BODY_ZONE_L_ARM) && !c_user.get_bodypart(BODY_ZONE_R_ARM))
		return
	to_chat(c_user, "<span class='warning'>You move your hand towards the machine, and begin to hesitate as a bloodied guillotine emerges from inside of it...</span>")
	if(do_after(c_user, 50, target = src))
		to_chat(c_user, "<span class='userdanger'>The guillotine drops on your arm, and the machine sucks it in!</span>")
		playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
		var/which_hand = BODY_ZONE_L_ARM
		if(!(c_user.active_hand_index % 2))
			which_hand = BODY_ZONE_R_ARM
		var/obj/item/bodypart/chopchop = c_user.get_bodypart(which_hand)
		chopchop.dismember()
		qdel(chopchop)
		// user.mind?.adjust_experience(/datum/skill/gaming, 100)
		playsound(loc, 'sound/arcade/win.ogg', 50, TRUE)
		prizevend(user, user.rand_good(3,5))
	else
		to_chat(c_user, "<span class='notice'>You (wisely) decide against putting your hand in the machine.</span>")

/obj/machinery/computer/arcade/amputation/festive //dispenses wrapped gifts instead of arcade prizes, also known as the ancap christmas tree
	name = "Mediborg's Festive Amputation Adventure"
	desc = "A picture of a blood-soaked medical cyborg wearing a Santa hat flashes on the screen. The mediborg has a speech bubble that says, \"Put your hand in the machine if you aren't a <b>coward!</b>\""
	prize_override = list(/obj/item/a_gift/anything = 1)
