/turf/open/pool
	icon = 'icons/turf/pool.dmi'
	name = "poolwater"
	desc = "You're safer here than in the deep."
	icon_state = "pool_tile"
	heat_capacity = INFINITY
	var/filled = TRUE
	var/next_splash = 0
	var/obj/machinery/pool/controller/controller
	var/obj/effect/overlay/water/watereffect
	var/obj/effect/overlay/water/top/watertop

/turf/open/pool/Initialize(mapload)
	. = ..()
	update_icon()

/turf/open/pool/Destroy()
	if(controller)
		controller.linked_turfs -= src
		controller = null
	QDEL_NULL(watereffect)
	QDEL_NULL(watertop)
	return ..()

/turf/open/pool/update_icon()
	. = ..()
	if(!filled)
		name = "drained pool"
		desc = "No diving!"
		QDEL_NULL(watereffect)
		QDEL_NULL(watertop)
	else
		name = "poolwater"
		desc = "You're safer here than in the deep."
		watereffect = new /obj/effect/overlay/water(src)
		watertop = new /obj/effect/overlay/water/top(src)

/obj/effect/overlay/water
	name = "water"
	icon = 'icons/turf/pool.dmi'
	icon_state = "bottom"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/effect/overlay/water/top
	icon_state = "top"
	layer = BELOW_MOB_LAYER

// Mousedrop hook to normal turfs to get out of pools.
/turf/open/MouseDrop_T(atom/from, mob/living/user)
	if(!istype(user))
		return ..()
	// I could make this /open/floor and not have the !istype but ehh - kev
	if(HAS_TRAIT(from, TRAIT_SWIMMING) && isliving(user) && ((user == from) || user.CanReach(from)) && !CHECK_MOBILITY(user, MOBILITY_USE) && !istype(src, /turf/open/pool))
		var/mob/living/L = from
		//The element only exists if you're on water and a living mob, so let's skip those checks.
		var/pre_msg
		var/post_msg
		if(user == from)
			pre_msg = "<span class='notice'>[L] is getting out of the pool.</span>"
			post_msg = "<span class='notice'>[L] gets out of the pool.</span>"
		else
			pre_msg = "<span class='notice'>[L] is being pulled out of the pool by [user].</span>"
			post_msg = "<span class='notice'>[user] pulls [L] out of the pool.</span>"
		L.visible_message(pre_msg)
		if(do_mob(user, L, 20))
			L.visible_message(post_msg)
			L.forceMove(src)
	else
		return ..()

// Exit check
/turf/open/pool/Exit(atom/movable/AM, atom/newloc)
	if(!AM.has_gravity(src))
		return ..()
	if(isliving(AM) || isstructure(AM))
		if(AM.throwing)
			return ..()			//WHEEEEEEEEEEE
		if(istype(AM, /obj/structure) && isliving(AM.pulledby))
			return ..()			//people pulling stuff out of pool
		if(!ishuman(AM))
			return ..()			//human weak, monkey (and anyone else) ook ook eek eek strong
		if(isliving(AM) && (locate(/obj/structure/pool/ladder) in src))
			return ..()			//climbing out
		return istype(newloc, /turf/open/pool)
	return ..()

// Exited logic
/turf/open/pool/Exited(atom/A, atom/newLoc)
	. = ..()
	if(isliving(A))
		var/turf/open/pool/P = newLoc
		if(!istype(P) || (P.controller != controller))
			controller?.mobs_in_pool -= A

// Entered logic
/turf/open/pool/Entered(atom/movable/AM, atom/oldloc)
	if(istype(AM, /obj/effect/decal/cleanable))
		var/obj/effect/decal/cleanable/C = AM
		if(prob(C.bloodiness))
			controller.set_bloody(TRUE)
		QDEL_IN(AM, 25)
		animate(AM, alpha = 10, time = 20)
		return ..()
	if(!AM.has_gravity(src))
		return ..()
	if(isliving(AM))
		var/mob/living/victim = AM
		if(!HAS_TRAIT(victim, TRAIT_SWIMMING))		//poor guy not swimming time to dunk them!
			victim.AddElement(/datum/element/swimming)
			controller.mobs_in_pool += victim
			if(locate(/obj/structure/pool/ladder) in src)		//safe climbing
				return
			if(iscarbon(AM))		//FUN TIME!
				var/mob/living/carbon/H = victim
				if(filled)
					if (H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSMOUTH)
						H.visible_message("<span class='danger'>[H] falls in the water!</span>",
											"<span class='userdanger'>You fall in the water!</span>")
						playsound(src, 'sound/effects/splash.ogg', 60, TRUE, 1)
						H.DefaultCombatKnockdown(20)
						return
					else
						H.DefaultCombatKnockdown(60)
						H.adjustOxyLoss(5)
						H.emote("cough")
						H.visible_message("<span class='danger'>[H] falls in and takes a drink!</span>",
											"<span class='userdanger'>You fall in and swallow some water!</span>")
						playsound(src, 'sound/effects/splash.ogg', 60, TRUE, 1)
				else if(!H.head || !(H.head.armor.getRating("melee") > 20))
					if(H.prob_good(75))
						H.visible_message("<span class='danger'>[H] falls in the drained pool!</span>",
													"<span class='userdanger'>You fall in the drained pool!</span>")
						H.adjustBruteLoss(7)
						H.DefaultCombatKnockdown(80)
						playsound(src, 'sound/effects/woodhit.ogg', 60, TRUE, 1)
					else
						H.visible_message("<span class='danger'>[H] falls in the drained pool, and cracks his skull!</span>",
													"<span class='userdanger'>You fall in the drained pool, and crack your skull!</span>")
						H.apply_damage(15, BRUTE, "head")
						H.DefaultCombatKnockdown(200) // This should hurt. And it does.
						playsound(src, 'sound/effects/woodhit.ogg', 60, TRUE, 1)
						playsound(src, 'sound/misc/crack.ogg', 100, TRUE)
				else
					H.visible_message("<span class='danger'>[H] falls in the drained pool, but had an helmet!</span>",
										"<span class='userdanger'>You fall in the drained pool, but you had an helmet!</span>")
					H.DefaultCombatKnockdown(40)
					playsound(src, 'sound/effects/woodhit.ogg', 60, TRUE, 1)
		else if(filled)
			if(iscarbon(victim))
				victim.adjustStaminaLoss(1)
			playsound(src, "water_wade", 20, TRUE)
	return ..()

/turf/open/pool/MouseDrop_T(atom/from, mob/user)
	. = ..()
	if(!isliving(from))
		return
	var/mob/living/victim = from
	if(user.stat || user.lying || !Adjacent(user) || !from.Adjacent(user) || !iscarbon(user) || !victim.has_gravity(src) || HAS_TRAIT(victim, TRAIT_SWIMMING))
		return
	var/victimname = victim == user? "themselves" : "[victim]"
	var/starttext = victim == user? "[user] is descending into [src]." : "[user] is lowering [victim] into [src]."
	user.visible_message("<span class='notice'>[starttext]</span>")
	if(do_mob(user, victim, 20))
		user.visible_message("<span class='notice'>[user] lowers [victimname] into [src].</span>")
		victim.AddElement(/datum/element/swimming)		//make sure they have it so they don't fall/whatever
		victim.forceMove(src)

/turf/open/pool/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/mop) && filled)
		W.reagents.add_reagent("water", 5)
		to_chat(user, "<span class='notice'>You wet [W] in [src].</span>")
		playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
	else
		return ..()

/turf/open/pool/on_attack_hand(mob/living/user, act_intent = user.a_intent, unarmed_attack_flags)
	. = ..()
	if(.)
		return
	if((user.loc != src) && !user.IsStun() && !user.IsKnockdown() && !user.incapacitated() && Adjacent(user) && HAS_TRAIT(user, TRAIT_SWIMMING) && filled && (next_splash < world.time))
		playsound(src, 'sound/effects/watersplash.ogg', 8, TRUE, 1)
		next_splash = world.time + 25
		var/obj/effect/splash/S = new(src)
		animate(S, alpha = 0, time = 8)
		QDEL_IN(S, 10)
		for(var/mob/living/carbon/human/H in src)
			if(!H.wear_mask && (H.stat == CONSCIOUS))
				H.emote("cough")
			H.adjustStaminaLoss(4)
