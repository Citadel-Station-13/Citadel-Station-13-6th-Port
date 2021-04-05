/obj/item/implant/epitaph
	name = "epitaph implant"
	desc = "Sing a song of sorrow in a world where time has vanished."
	activated = FALSE

/obj/item/implant/epitaph/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Epitaph Personality Beacon<BR>
<b>Life:</b> until complete and utter eradication of the body<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Implants the target with a second, drug-fueled killer personality that envoys the user with the ability to temporarily skip time in a local timezone. Might or might not have other consequences.<BR>
<b>Special Features:</b><BR>
<i>Timeskip</i>- Ability to see through time and space to avoid attacks.<BR>
<HR>
No Implant Specifics"}
	return dat

/obj/item/implant/epitaph/implant(mob/living/target, mob/user, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/C = target
	C.gain_trauma(/datum/brain_trauma/severe/split_personality/epitaph, TRAUMA_RESILIENCE_ABSOLUTE)
	return TRUE

/obj/item/implanter/epitaph
	name = "implanter (epitaph)"
	imp_type = /obj/item/implant/epitaph


