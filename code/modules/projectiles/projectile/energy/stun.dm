/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = TRUE
	knockdown = 60
	knockdown_stamoverride = 36
	knockdown_stam_max = 50
	stutter = 10
	jitter = 20
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 14
	pixels_per_second = TILES_TO_PIXELS(16.667)
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = /obj/effect/projectile/muzzle/stun
	impact_type = /obj/effect/projectile/impact/stun
	var/tase_duration = 50
	var/strong_tase = TRUE

/obj/item/projectile/energy/electrode/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, TRUE, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "tased", /datum/mood_event/tased)
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)
		C.IgniteMob()
		if(C.dna && C.dna.check_mutation(HULK))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")
		else if(tase_duration && (C.status_flags & CANKNOCKDOWN) && !HAS_TRAIT(C, TRAIT_STUNIMMUNE) && !HAS_TRAIT(C, TRAIT_TASED_RESISTANCE))
			C.apply_status_effect(strong_tase? STATUS_EFFECT_TASED : STATUS_EFFECT_TASED_WEAK, tase_duration)
			addtimer(CALLBACK(C, /mob/living/carbon.proc/do_jitter_animation, jitter), 5)
	else if(iscyborg(target))
		target.visible_message(span_danger("A shower of sparks emit from [target] on impact from [src]!"))
		do_sparks(1, TRUE, target)
		var/mob/living/silicon/robot/R = target
		R.vtec_disable(10 SECONDS)

/obj/item/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, TRUE, src)
	..()

/obj/item/projectile/energy/electrode/security
	tase_duration = 40
	knockdown = 0
	stamina = 0
	knockdown_stamoverride = 0
	knockdown_stam_max = 0
	strong_tase = FALSE

/obj/item/projectile/energy/electrode/security/hos
	tase_duration = 40
	knockdown = 0
	stamina = 0
	knockdown_stamoverride = 0
	knockdown_stam_max = 0
	strong_tase = FALSE
