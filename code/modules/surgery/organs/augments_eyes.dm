/obj/item/organ/cyberimp/eyes/hud
	name = "cybernetic hud"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = ORGAN_SLOT_EYES
	zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY

// HUD implants
/obj/item/organ/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = ORGAN_SLOT_HUD
	var/HUD_type = 0

/obj/item/organ/cyberimp/eyes/hud/Insert(var/mob/living/carbon/M, var/special = 0, drop_if_replaced = FALSE)
	..()
	if(HUD_type)
		var/datum/atom_hud/H = GLOB.huds[HUD_type]
		H.add_hud_to(M)

/obj/item/organ/cyberimp/eyes/hud/Remove(special = FALSE)
	if(!QDELETED(owner) && HUD_type)
		var/datum/atom_hud/H = GLOB.huds[HUD_type]
		H.remove_hud_from(owner)
	return ..()

/obj/item/organ/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	HUD_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/organ/cyberimp/eyes/hud/diagnostic
	name = "Diagnostics HUD implant"
	desc = "These cybernetic eye implants will display a diagnostics HUD over everything you see."
	HUD_type = DATA_HUD_DIAGNOSTIC_ADVANCED

/obj/item/organ/cyberimp/eyes/hud/science
	name = "Science HUD implant"
	desc = "These cybernetic eye implants will display a science HUD over everything you see."
	actions_types = list(/datum/action/item_action/toggle_research_scanner)

/obj/item/organ/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	HUD_type = DATA_HUD_SECURITY_ADVANCED

/obj/item/organ/cyberimp/eyes/hud/security/syndicate
	name = "Contraband Security HUD Implant"
	desc = "A Cybersun Industries brand Security HUD Implant. These illicit cybernetic eye implants will display a security HUD over everything you see."
	syndicate_implant = TRUE
