/datum/surgery/prosthetic_replacement
	name = "limb replacement"
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/add_prosthetic
	)
	species = list(
	/mob/living/carbon/human,
	/mob/living/carbon/monkey,
	!/mob/living/carbon/human/species/golem
	)
	possible_locs = list("r_arm", "l_arm", "l_leg", "r_leg", "head")
	requires_bodypart = FALSE //need a missing limb
	requires_bodypart_type = 0


/datum/surgery/prosthetic_replacement/can_start(mob/user, mob/living/carbon/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/C = target
	if(!C.get_bodypart(user.zone_selected)) //can only start if limb is missing
		return TRUE

/datum/surgery/prosthetic_replacement/golem
	name = "material limb replacement"
	steps = list(
	/datum/surgery_step/saw_material,
	/datum/surgery_step/retract_material,
	/datum/surgery_step/add_prosthetic
	)
	species = list(
	/mob/living/carbon/human/species/golem
	)


/datum/surgery_step/add_prosthetic
	name = "add limb"
	implements = list(/obj/item/bodypart = 100, /obj/item/organ_storage = 100, /obj/item/twohanded/required/chainsaw = 100, /obj/item/melee/synthetic_arm_blade = 100)
	time = 32
	var/organ_rejection_dam = 0

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='notice'>There is nothing inside [tool]!</span>")
			return FALSE
		var/obj/item/I = tool.contents[1]
		if(!isbodypart(I))
			to_chat(user, "<span class='notice'>[I] cannot be attached!</span>")
			return FALSE
		tool = I
	if(istype(tool, /obj/item/bodypart))
		var/obj/item/bodypart/BP = tool
		if(ismonkey(target))// monkey patient only accept organic monkey limbs
			if(BP.status == BODYPART_ROBOTIC || BP.animal_origin != MONKEY_BODYPART)
				to_chat(user, "<span class='warning'>[BP] doesn't match the patient's morphology.</span>")
				return FALSE
		if(BP.status != BODYPART_ROBOTIC)
			organ_rejection_dam = 10
			if(ishuman(target))
				if(BP.animal_origin)
					to_chat(user, "<span class='warning'>[BP] doesn't match the patient's morphology.</span>")
					return FALSE
				var/mob/living/carbon/human/H = target
				if(H.dna.species.id != BP.species_id)
					organ_rejection_dam = 30

		if(target_zone == BP.body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
			user.visible_message("[user] begins to replace [target]'s [parse_zone(target_zone)].", "<span class ='notice'>You begin to replace [target]'s [parse_zone(target_zone)]...</span>")
		else
			to_chat(user, "<span class='warning'>[tool] isn't the right type for [parse_zone(target_zone)].</span>")
			return -1
	else if(target_zone == "l_arm" || target_zone == "r_arm")
		user.visible_message("[user] begins to attach [tool] onto [target].", "<span class='notice'>You begin to attach [tool] onto [target]...</span>")
	else
		to_chat(user, "<span class='warning'>[tool] must be installed onto an arm.</span>")
		return FALSE

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage))
		tool.icon_state = "evidenceobj"
		tool.desc = "A container for holding body parts."
		tool.cut_overlays()
		tool = tool.contents[1]
	if(istype(tool, /obj/item/bodypart) && user.temporarilyRemoveItemFromInventory(tool))
		var/obj/item/bodypart/L = tool
		L.attach_limb(target)
		if(organ_rejection_dam)
			target.adjustToxLoss(organ_rejection_dam)
		user.visible_message("[user] successfully replaces [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You succeed in replacing [target]'s [parse_zone(target_zone)].</span>")
		return TRUE
	else
		var/obj/item/bodypart/L = target.newBodyPart(target_zone, FALSE, FALSE)
		L.is_pseudopart = TRUE
		L.attach_limb(target)
		user.visible_message("[user] finishes attaching [tool]!", "<span class='notice'>You attach [tool].</span>")
		qdel(tool)
		if(istype(tool, /obj/item/twohanded/required/chainsaw))
			var/obj/item/mounted_chainsaw/new_arm = new(target)
			target_zone == "r_arm" ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			return TRUE
		else if(istype(tool, /obj/item/melee/synthetic_arm_blade))
			var/obj/item/melee/arm_blade/new_arm = new(target,TRUE,TRUE)
			target_zone == "r_arm" ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			return TRUE

