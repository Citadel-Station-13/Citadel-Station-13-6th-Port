/mob/living/simple_animal/hostile/asteroid/ice_whelp/lavaland
	name = "ash whelp"
	desc = "A small ash drake, much weaker than it's mother but still dangerous."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "ash_whelp"
	icon_living = "ash_whelp"
	icon_dead = "ash_whelp_dead"
	speed = 2
	move_to_delay = 15
	ranged = TRUE
	ranged_cooldown_time = 40
	maxHealth = 750 //Very tough enemy
	health = 750
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	deathmessage = "collapses on it's side."

	var/swooping = FALSE

/mob/living/simple_animal/hostile/asteroid/ice_whelp/lavaland/OpenFire()
	if(swooping)
		return
	var/swoop_chance = clamp(((maxHealth - health)/25), 0, 20)

	if(prob(swoop_chance) && (target in range(4, src)))
		density = FALSE
		icon_state = "ash_whelp_shadow"
		visible_message("<span class='boldwarning'>[src] swoops up high!</span>")
		alpha = 255
		var/oldtransform = transform
		animate(src, alpha = 204, transform = matrix()*0.9, time = 3, easing = BOUNCE_EASING)
		for(var/i in 1 to 3)
			sleep(1)
			if(QDELETED(src) || stat == DEAD) //somehow we got hit
				if(stat == DEAD)
					animate(src, alpha = 255, transform = oldtransform, time = 0, flags = ANIMATION_END_NOW) //reset immediately
				return
		animate(src, alpha = 100, transform = matrix()*0.7, time = 7)
		swooping = TRUE
		var/swoop_duration = 30
		while(swoop_duration > 0)
			if(!target && !FindTarget())
				break //we lost our target while chasing it down and couldn't get a new one
			if(loc == get_turf(target))
				break

			forceMove(get_step(src, get_dir(src, target)))
			swoop_duration -= 1
			sleep(1)

		sleep(5)

		for(var/mob/M in range(2, src))
			shake_camera(M, 15, 1)

		for(var/mob/living/L in get_turf(src))
			if(!L.stat) //not attacking downed losers
				L.adjustBruteLoss(45)
				if(L && !QDELETED(L)) // Some mobs are deleted on death
					var/throw_dir = pick(GLOB.alldirs)
					var/throwtarget = get_edge_target_turf(src, throw_dir)
					L.throw_at(throwtarget, 3)
					visible_message("<span class='warning'>[L] is thrown clear of [src]!</span>")

		icon_state = "ash_whelp"
		animate(src, alpha = 255, transform = oldtransform, time = 5)
		playsound(loc, 'sound/effects/meteorimpact.ogg', 200, 1)
		swooping = FALSE
		density = TRUE
		return

	var/turf/T = get_ranged_target_turf_direct(src, target, fire_range)
	var/list/burn_turfs = getline(src, T) - get_turf(src)
	dragon_fire_line(src, burn_turfs)

/mob/living/simple_animal/hostile/asteroid/ice_whelp/lavaland/ex_act(severity, target)
	if(swooping)
		return
	..()

/mob/living/simple_animal/hostile/asteroid/ice_whelp/lavaland/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && swooping)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/asteroid/ice_whelp/lavaland/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, mob/target, target_message, omni = FALSE)
	if(swooping)
		return
	return ..()

/mob/living/simple_animal/hostile/asteroid/ice_whelp/lavaland/AttackingTarget()
	if(!swooping)
		return ..()

/mob/living/simple_animal/hostile/asteroid/ice_whelp/lavaland/Move()
	if(!swooping)
		return ..()

/mob/living/simple_animal/hostile/asteroid/ice_whelp/lavaland/Goto(target, delay, minimum_distance)
	if(!swooping)
		return ..()
