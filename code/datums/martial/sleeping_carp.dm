#define STRONG_PUNCH_COMBO "HH"
#define LAUNCH_KICK_COMBO "HD"
#define DROP_KICK_COMBO "HG"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/sleeping_carp_help
	block_parry_data = /datum/block_parry_data/sleeping_carp
	pugilist = TRUE

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,STRONG_PUNCH_COMBO))
		streak = ""
		strongPunch(A,D)
		return TRUE
	if(findtext(streak,LAUNCH_KICK_COMBO))
		streak = ""
		launchKick(A,D)
		return TRUE
	if(findtext(streak,DROP_KICK_COMBO))
		streak = ""
		dropKick(A,D)
		return TRUE
	return FALSE

///Gnashing Teeth: Harm Harm, high force punch on every second harm punch, which can both wound and dismember
/datum/martial_art/the_sleeping_carp/proc/strongPunch(mob/living/carbon/human/A, mob/living/carbon/human/D)
	///this var is so that the strong punch is always aiming for the body part the user is targeting and not trying to apply to the chest before deviating
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/atk_verb = pick("precisely kick", "brutally chop", "cleanly hit", "viciously slam")
	var/damage = (damage_roll(A,D) + 15)
	var/wound_unarmed_bonus = A.dna.species.punchstunthreshold
	D.visible_message("<span class='danger'>[A] [atk_verb]s [D]!</span>", \
					"<span class='userdanger'>[A] [atk_verb]s you!</span>", null, null, A)
	to_chat(A, "<span class='danger'>You [atk_verb] [D]!</span>")

	if(atk_verb == "precisely kick" || atk_verb == "viciously slam")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 75, TRUE, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
		playsound(get_turf(D), 'sound/weapons/rapierhit.ogg', 75, TRUE, -1)
	log_combat(A, D, "strong punched (Sleeping Carp)")
	D.apply_damage(damage, BRUTE, affecting, wound_bonus = wound_unarmed_bonus * 0.5, bare_wound_bonus = wound_unarmed_bonus, sharpness = SHARP_EDGED)
	D.apply_damage(damage, STAMINA, affecting, wound_bonus = CANT_WOUND)
	return TRUE

///Crashing Wave Kick: Harm Disarm combo, throws people seven tiles backwards
/datum/martial_art/the_sleeping_carp/proc/launchKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/damage = (damage_roll(A,D) + 15)
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	D.visible_message("<span class='warning'>[A] kicks [D] square in the chest, sending them flying!</span>", \
					"<span class='userdanger'>You are kicked square in the chest by [A], sending you flying!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	var/atom/throw_target = get_edge_target_turf(D, A.dir)
	D.throw_at(throw_target, 7, 14, A)
	D.apply_damage(damage, BRUTE, BODY_ZONE_CHEST, wound_bonus = CANT_WOUND)
	log_combat(A, D, "launchkicked (Sleeping Carp)")
	return TRUE

///Keelhaul: Harm Grab combo, knocks people down, deals stamina damage while they're on the floor
/datum/martial_art/the_sleeping_carp/proc/dropKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/damage = damage_roll(A,D)
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	if((D.mobility_flags & MOBILITY_STAND))
		D.apply_damage(damage, BRUTE, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND)
		D.DefaultCombatKnockdown(50, override_hardstun = 0.01, override_stamdmg = 0)
		D.apply_damage(damage + 35, STAMINA, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND) //A cit specific change form the tg port to really punish anyone who tries to stand up
		D.visible_message("<span class='warning'>[A] kicks [D] in the head, sending them face first into the floor!</span>", \
					"<span class='userdanger'>You are kicked in the head by [A], sending you crashing to the floor!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	else
		D.apply_damage(damage*0.5, BRUTE, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND)
		D.apply_damage(damage + 35, STAMINA, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND)
		D.drop_all_held_items()
		D.visible_message("<span class='warning'>[A] kicks [D] in the head!</span>", \
					"<span class='userdanger'>You are kicked in the head by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	log_combat(A, D, "dropkicked (Sleeping Carp)")
	return TRUE

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "grabbed (Sleeping Carp)")
	return ..()

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	var/damage = (damage_roll(A,D) + 5)
	var/stunthreshold = A.dna.species.punchstunthreshold
	if(check_streak(A,D))
		return TRUE
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/atk_verb = pick("kick", "chop", "hit", "slam")
	D.visible_message("<span class='danger'>[A] [atk_verb]s [D]!</span>", \
					"<span class='userdanger'>[A] [atk_verb]s you!</span>", null, null, A)
	to_chat(A, "<span class='danger'>You [atk_verb] [D]!</span>")
	D.apply_damage(damage, BRUTE, affecting, wound_bonus = CANT_WOUND)
	D.apply_damage(damage*1.5, STAMINA, affecting, wound_bonus = CANT_WOUND)
	if(atk_verb == "kick" || atk_verb == "slam")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	if(CHECK_MOBILITY(D, MOBILITY_STAND) && damage >= stunthreshold)
		to_chat(D, "<span class='danger'>You stumble and fall!</span>")
		D.DefaultCombatKnockdown(10, override_hardstun = 0.01, override_stamdmg = damage)
	log_combat(A, D, "punched (Sleeping Carp)")
	return TRUE


/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "disarmed (Sleeping Carp)")
	return ..()

/datum/martial_art/the_sleeping_carp/on_projectile_hit(mob/living/carbon/human/A, obj/item/projectile/P, def_zone)
	. = ..()
	if(A.incapacitated(FALSE, TRUE)) //NO STUN
		return BULLET_ACT_HIT
	if(!CHECK_ALL_MOBILITY(A, MOBILITY_USE|MOBILITY_STAND)) //NO UNABLE TO USE, NO DEFLECTION ON THE FLOOR
		return BULLET_ACT_HIT
	if(A.dna && A.dna.check_mutation(HULK)) //NO HULK
		return BULLET_ACT_HIT
	if(!isturf(A.loc)) //NO MOTHERFLIPPIN MECHS!
		return BULLET_ACT_HIT
	if(A.in_throw_mode)
		A.visible_message("<span class='danger'>[A] effortlessly swats the projectile aside! They can deflect projectile with their bare hands!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
		playsound(get_turf(A), pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
		P.firer = A
		P.setAngle(rand(0, 360))//SHING
		A.adjustStaminaLoss(3)
		return BULLET_ACT_FORCE_PIERCE
	return BULLET_ACT_HIT

/datum/block_parry_data/sleeping_carp
	parry_time_windup = 0
	parry_time_active = 25
	parry_time_spindown = 0
	// we want to signal to players the most dangerous phase, the time when automatic counterattack is a thing.
	parry_time_windup_visual_override = 1
	parry_time_active_visual_override = 3
	parry_time_spindown_visual_override = 12
	parry_flags = PARRY_DEFAULT_HANDLE_FEEDBACK		//can attack while
	parry_time_perfect = 2.5		// first ds isn't perfect
	parry_time_perfect_leeway = 1.5
	parry_imperfect_falloff_percent = 5
	parry_efficiency_to_counterattack = 100
	parry_efficiency_considered_successful = 65		// VERY generous
	parry_efficiency_perfect = 100
	parry_failed_stagger_duration = 4 SECONDS
	parry_cooldown = 0.5 SECONDS

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(H, TRAIT_NOGUNS, SLEEPING_CARP_TRAIT)
	ADD_TRAIT(H, TRAIT_HARDLY_WOUNDED, SLEEPING_CARP_TRAIT)
	ADD_TRAIT(H, TRAIT_NODISMEMBER, SLEEPING_CARP_TRAIT)
	H.faction |= "carp" //:D

/datum/martial_art/the_sleeping_carp/on_remove(mob/living/carbon/human/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_NOGUNS, SLEEPING_CARP_TRAIT)
	REMOVE_TRAIT(H, TRAIT_HARDLY_WOUNDED, SLEEPING_CARP_TRAIT)
	REMOVE_TRAIT(H, TRAIT_NODISMEMBER, SLEEPING_CARP_TRAIT)
	H.faction -= "carp" //:(

/mob/living/carbon/human/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>\n\
	<span class='notice'>Gnashing Teeth</span>: Harm Harm. Deal additional damage every second (consecutive) punch!\n\
	<span class='notice'>Crashing Wave Kick</span>: Harm Disarm. Launch your opponent away from you with incredible force!\n\
	<span class='notice'>Keelhaul</span>: Harm Grab. Kick an opponent to the floor, knocking them down! If your opponent is already prone, this move will disarm them and deal additional stamina damage to them.\n\
	<span class='notice'>While in throw mode (and not stunned, not a hulk, and not in a mech), you can reflect all projectiles that come your way, sending them back at the people who fired them!\n\
	<span class='notice'>Also, you are more resilient against suffering wounds in combat, and your limbs cannot be dismembered. This grants you extra staying power during extended combat, especially against slashing and other bleeding weapons.\n\
	<span class='notice'>You are not invincible, however- while you may not suffer debilitating wounds often, you must still watch your health and appropriate medical supplies when possible for use during downtime.\n\
	<span class='notice'>In addition, your training has imbued you with a loathing of guns, and you can no longer use them.</span>")

/obj/item/staff/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_chance = 50
	var/wielded = FALSE // track wielded status on item

/obj/item/staff/bostaff/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/staff/bostaff/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=24, icon_wielded="bostaff1")

/// triggered on wield of two handed item
/obj/item/staff/bostaff/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/staff/bostaff/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE

/obj/item/staff/bostaff/update_icon_state()
	icon_state = "bostaff0"

/obj/item/staff/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='warning'>You club yourself over the head with [src].</span>")
		user.DefaultCombatKnockdown(60)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, "<span class='warning'>It would be dishonorable to attack a foe while they cannot retaliate.</span>")
		return
	if(user.a_intent == INTENT_DISARM)
		if(!wielded)
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("[user] clubs [H] with [src]!", \
									  "[user] smacks [H] with the butt of [src]!", \
									  "[user] broadsides [H] with [src]!", \
									  "[user] smashes [H]'s head with [src]!", \
									  "[user] beats [H] with front of [src]!", \
									  "[user] twirls and slams [H] with [src]!")
		H.visible_message("<span class='warning'>[pick(fluffmessages)]</span>", \
							   "<span class='userdanger'>[pick(fluffmessages)]</span>")
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
		H.adjustStaminaLoss(rand(13,20))
		if(prob(10))
			H.visible_message("<span class='warning'>[H] collapses!</span>", \
								   "<span class='userdanger'>Your legs give out!</span>")
			H.DefaultCombatKnockdown(80)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message("<span class='warning'>[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!</span>", \
									   "<span class='userdanger'>[user] knocks you unconscious!</span>")
				H.SetSleeping(600)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/staff/bostaff/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	if(!wielded)
		return BLOCK_NONE
	return ..()
