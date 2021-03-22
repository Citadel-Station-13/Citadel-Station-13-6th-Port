
/datum/component/exposable
	var/item_name = "exposable"
	var/mob/living/carbon/owner
	var/exposure_flags = 0

/datum/component/exposable/Initialize(mob/living/carbon/_owner, _name, new_zone, _exposure_flags = EXPOSABLE_UNDIES_HIDDEN, _flavor_name = null, _save_key = null)
	. = ..()
	if(. & COMPONENT_INCOMPATIBLE)
		return
	owner = _owner
	exposure_flags = _exposure_flags

/datum/component/exposable/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_GET_EXPOSED, .proc/is_exposed)
	RegisterSignal(owner, COMSIG_EXPOSABLE_GET, .proc/add_to_list)
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, .proc/show_exposed)

/datum/component/exposable/proc/show_exposed(datum/source, mob/user, list/returnlist)
	returnlist += "You see [item_list]"

/datum/component/exposable/proc/add_to_list(datum/source, list/exposable_list)
	exposable_list += src

/datum/component/exposable/proc/is_exposed()
	if(!owner || exposure_flags & (EXPOSABLE_HIDDEN))
		return FALSE
	if(exposure_flags & EXPOSABLE_UNDIES_HIDDEN && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(!(NO_UNDERWEAR in H.dna.species.species_traits))
			var/datum/sprite_accessory/underwear/top/T = H.hidden_undershirt ? null : GLOB.undershirt_list[H.undershirt]
			var/datum/sprite_accessory/underwear/bottom/B = H.hidden_underwear ? null : GLOB.underwear_list[H.underwear]
			if(zone == BODY_ZONE_CHEST ? (T?.covers_chest || B?.covers_chest) : (T?.covers_groin || B?.covers_groin))
				return FALSE
	if(exposure_flags & EXPOSABLE_THROUGH_CLOTHES)
		return TRUE

	switch(zone) //update as more genitals are added
		if(BODY_ZONE_CHEST)
			return owner.is_chest_exposed()
		if(BODY_ZONE_PRECISE_GROIN)
			return owner.is_groin_exposed()

/datum/component/exposable/proc/toggle_visibility(visibility, update = TRUE)
	exposure_flags &= ~(EXPOSABLE_THROUGH_CLOTHES|EXPOSABLE_HIDDEN|EXPOSABLE_UNDIES_HIDDEN)
	if(owner)
		owner.exposed_genitals -= src
	switch(visibility)
		if(GEN_VISIBLE_ALWAYS)
			exposure_flags |= EXPOSABLE_THROUGH_CLOTHES
			if(owner)
				owner.log_message("Exposed their [item_name]",LOG_EMOTE)
				owner.exposed_genitals += src
		if(GEN_VISIBLE_NO_CLOTHES)
			if(owner)
				owner.log_message("Hid their [item_name] under clothes only",LOG_EMOTE)
		if(GEN_VISIBLE_NO_UNDIES)
			exposure_flags |= EXPOSABLE_UNDIES_HIDDEN
			if(owner)
				owner.log_message("Hid their [item_name] under underwear",LOG_EMOTE)
		if(GEN_VISIBLE_NEVER)
			exposure_flags |= EXPOSABLE_HIDDEN
			if(owner)
				owner.log_message("Hid their [item_name] completely",LOG_EMOTE)

	if(update && owner) //recast to use update genitals proc
		SEND_SIGNAL(owner, COMSIG_UPDATE_EXPOSABLES)
