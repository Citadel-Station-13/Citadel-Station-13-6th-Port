//Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
//Movement impairing would indicate drugs and the like.

/datum/action/item_action/ninjaboost
	check_flags = NONE
	name = "Adrenaline Boost"
	desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	button_icon_state = "adrenal"
	icon_icon = 'icons/obj/implants.dmi'
	required_mobility_flags = NONE

/**
 * Proc called to activate space ninja's adrenaline.
 *
 * Proc called to use space ninja's adrenaline.  Gets the ninja out of almost any stun.
 * Also makes them shout MGS references when used.  After a bit, it injects the user with
 * radium by calling a different proc.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost()
	if(ninjacost(0,N_ADRENALINE))
		return
	var/mob/living/carbon/human/ninja = affecting
	ninja.do_adrenaline(150, TRUE, 0, 0, TRUE, list(/datum/reagent/medicine/epinephrine = 3, /datum/reagent/medicine/regen_jelly = 10, /datum/reagent/medicine/stimulants = 2), "<span class='boldnotice'>You feel a sudden surge of energy!</span>")
	ninja.say(pick("A CORNERED FOX IS MORE DANGEROUS THAN A JACKAL!","HURT ME MOOORRREEE!","IMPRESSIVE!"), forced = "ninjaboost")
	a_boost = FALSE
	to_chat(ninja, "<span class='notice'>You have used the adrenaline boost.</span>")
	addtimer(CALLBACK(src, .proc/ninjaboost_after), 70)

/**
 * Proc called to inject the ninja with radium.
 *
 * Used after 7 seconds of using the ninja's adrenaline.
 * Injects the user with how much radium the suit needs to refill an adrenaline boost.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost_after()
	var/mob/living/carbon/human/ninja = affecting
	ninja.reagents.add_reagent(/datum/reagent/radium, a_transfer * 0.25)
	to_chat(ninja, "<span class='danger'>You are beginning to feel the after-effect of the injection.</span>")
