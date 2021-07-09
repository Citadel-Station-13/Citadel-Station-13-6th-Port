/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING
	pacifism_check = FALSE //Let's pretend pacifists can boxe the heck out of other people, it only deals stamina damage right now.
	pugilist = TRUE

/datum/martial_art/boxing/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>Can't disarm while boxing!</span>")
	return 1

/datum/martial_art/boxing/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>Can't grab while boxing!</span>")
	return 1

/datum/martial_art/boxing/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")
	var/extra_damage = damage_roll(A,D)
	if(extra_damage == A.dna.species.punchdamagelow)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to [atk_verb] [D]!</span>", \
			"<span class='userdanger'>[A] has attempted to [atk_verb] [D]!</span>", null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to hit", atk_verb)
		return TRUE

	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)

	D.visible_message("<span class='danger'>[A] has [atk_verb]ed [D]!</span>", \
			"<span class='userdanger'>[A] has [atk_verb]ed [D]!</span>", null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(A.rand_good(10,13,D) + extra_damage, STAMINA, affecting, armor_block)
	log_combat(A, D, "punched (boxing) ")
	if(D.getStaminaLoss() > 100 && istype(D.mind?.martial_art, /datum/martial_art/boxing))
		var/knockout_prob = (D.getStaminaLoss() + A.rand_good(-15,15,D))*0.75
		if((D.stat != DEAD) && A.prob_good(knockout_prob,D))
			D.visible_message("<span class='danger'>[A] has knocked [D] out with a haymaker!</span>", \
								"<span class='userdanger'>[A] has knocked [D] out with a haymaker!</span>")
			D.apply_effect(200,EFFECT_KNOCKDOWN,armor_block)
			D.SetSleeping(100)
			D.forcesay(GLOB.hit_appends)
			log_combat(A, D, "knocked out (boxing) ")
		else if(D.lying)
			D.forcesay(GLOB.hit_appends)
	return 1

/datum/martial_art/boxing/teach(mob/living/carbon/human/H, make_temporary = TRUE)
	. = ..()
	if(.)
		if(H.pulling && ismob(H.pulling))
			H.stop_pulling()

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user) && slot == SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H,TRUE)

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_GLOVES) == src)
		style.remove(H)
