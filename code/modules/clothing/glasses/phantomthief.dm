/obj/item/clothing/glasses/phantomthief
	name = "suspicious paper mask"
	desc = "A cheap, Syndicate-branded paper face mask. They'll never see it coming."
	mob_overlay_icon = 'icons/mob/clothing/mask.dmi'
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "ninjaOLD"
	item_state = "ninjaOLD"

/obj/item/clothing/glasses/phantomthief/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/phantomthief)

/obj/item/clothing/glasses/phantomthief/syndicate
	name = "suspicious plastic mask"
	desc = "A cheap, bulky, Syndicate-branded plastic face mask. You have to break in to break out."
	var/nextadrenalinepop

/obj/item/clothing/glasses/phantomthief/syndicate/examine(mob/user)
	. = ..()
	if(user.get_item_by_slot(SLOT_GLASSES) == src)
		if(world.time >= nextadrenalinepop)
			. += "<span class='notice'>The built-in adrenaline injector is ready for use.</span>"
		else
			. += "<span class='notice'>[DisplayTimeText(nextadrenalinepop - world.time)] left before the adrenaline injector can be used again."

/obj/item/clothing/glasses/phantomthief/syndicate/proc/injectadrenaline(mob/living/user, was_forced = FALSE)
	if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_TOGGLED) && world.time >= nextadrenalinepop)
		nextadrenalinepop = world.time + 5 MINUTES
		user.reagents.add_reagent(/datum/reagent/syndicateadrenals, 5)
		user.playsound_local(user, 'sound/misc/adrenalinject.ogg', 100, 0, pressure_affected = FALSE)

/obj/item/clothing/glasses/phantomthief/syndicate/equipped(mob/user, slot)
	. = ..()
	if(!istype(user))
		return
	if(slot != SLOT_GLASSES)
		return
	RegisterSignal(user, COMSIG_LIVING_COMBAT_ENABLED, .proc/injectadrenaline)

/obj/item/clothing/glasses/phantomthief/syndicate/dropped(mob/user)
	. = ..()
	if(!istype(user))
		return
	UnregisterSignal(user, COMSIG_LIVING_COMBAT_ENABLED)
