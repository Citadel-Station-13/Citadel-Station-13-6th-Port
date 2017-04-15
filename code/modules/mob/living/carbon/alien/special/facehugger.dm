

//TODO: Make these simple_animals

#define MIN_IMPREGNATION_TIME 100 //time it takes to impregnate someone
#define MAX_IMPREGNATION_TIME 150

#define MIN_ACTIVE_TIME 200 //time between being dropped and going idle
#define MAX_ACTIVE_TIME 400

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = WEIGHT_CLASS_TINY //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = MASKINTERNALS
	throw_range = 5
	tint = 3
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	layer = MOB_LAYER

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case

	var/sterile = FALSE
	var/real = TRUE //0 for the toy, 1 for real. Sure I could istype, but fuck that.
	var/strength = 5

	var/attached = 0

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	sterile = 1

/obj/item/clothing/mask/facehugger/dead
	icon_state = "facehugger_dead"
	item_state = "facehugger_inactive"
	stat = DEAD

/obj/item/clothing/mask/facehugger/impregnated
	icon_state = "facehugger_impregnated"
	item_state = "facehugger_impregnated"
	stat = DEAD

/obj/item/clothing/mask/facehugger/attack_alien(mob/user) //can be picked up by aliens
	attack_hand(user)
	return

/obj/item/clothing/mask/facehugger/attack_hand(mob/user)
	if((stat == CONSCIOUS && !sterile) && !isalien(user))
		if(Attach(user))
			return
	..()

/obj/item/clothing/mask/facehugger/attack(mob/living/M, mob/user)
	..()
	if(user.temporarilyRemoveItemFromInventory(src))
		Attach(M)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	..()
	if(!real)//So that giant red text about probisci doesn't show up.
		return
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			to_chat(user, "<span class='boldannounce'>[src] is not moving.</span>")
		if(CONSCIOUS)
			to_chat(user, "<span class='boldannounce'>[src] seems to be active!</span>")
	if (sterile)
		to_chat(user, "<span class='boldannounce'>It looks like the proboscis has been removed.</span>")

/obj/item/clothing/mask/facehugger/attackby(obj/item/O,mob/m, params)
	if(O.force)
		Die()
	return

/obj/item/clothing/mask/facehugger/bullet_act(obj/item/projectile/P)
	if(P.damage)
		Die()

/obj/item/clothing/mask/facehugger/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	Attach(M)

/obj/item/clothing/mask/facehugger/Crossed(atom/target)
	HasProximity(target)
	return

/obj/item/clothing/mask/facehugger/on_found(mob/finder)
	if(stat == CONSCIOUS)
		return HasProximity(finder)
	return 0

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM as mob|obj)
	if(CanHug(AM) && Adjacent(AM))
		return Attach(AM)
	return 0

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	if(!..())
		return
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		spawn(15)
			if(icon_state == "[initial(icon_state)]_thrown")
				icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		Attach(hit_atom)

/obj/item/clothing/mask/facehugger/proc/valid_to_attach(mob/living/M)
	// valid targets: corgis, carbons except aliens and devils
	// facehugger state early exit checks
	if(stat != CONSCIOUS)
		return FALSE
	if(attached)
		return FALSE
	if(!iscorgi(M) && !iscarbon(M))
		return FALSE
	if(iscarbon(M))
		// disallowed carbons
		if(isalien(M) || isdevil(M))
			return FALSE
		var/mob/living/carbon/target = M
		// gotta have a head to be implanted (no changelings or sentient plants)
		if(!target.get_bodypart("head"))
			return FALSE

		if(target.getorgan(/obj/item/organ/alien/hivenode) || target.getorgan(/obj/item/organ/body_egg/alien_embryo))
			return FALSE
		// carbon, has head, not alien or devil, has no hivenode or embryo: valid
		return TRUE
	else if(iscorgi(M))
		// corgi: valid
		return TRUE

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/M)
	if(!valid_to_attach(M))
		return FALSE
	// passed initial checks - time to leap!
	M.visible_message("<span class='danger'>[src] leaps at [M]'s face!</span>", \
							"<span class='userdanger'>[src] leaps at [M]'s face!</span>")

	// probiscis-blocker handling
	if(iscarbon(M))
		var/mob/living/carbon/target = M

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.is_mouth_covered(head_only = 1))
				H.visible_message("<span class='danger'>[src] smashes against [H]'s [H.head]!</span>", \
									"<span class='userdanger'>[src] smashes against [H]'s [H.head]!</span>")
				Die()
				return FALSE

		if(target.wear_mask)
			var/obj/item/clothing/W = target.wear_mask
			if(!istype(W,/obj/item/clothing/mask/facehugger) && target.dropItemToGround(W))
				target.visible_message("<span class='danger'>[src] tears [W] off of [target]'s face!</span>", \
									"<span class='userdanger'>[src] tears [W] off of [target]'s face!</span>")
		forceMove(target)
		target.equip_to_slot_if_possible(src, slot_wear_mask, 0, 1, 1)
	// early returns and validity checks done: attach.
	attached++
	//ensure we detach once we no longer need to be attached
	spawn(MAX_IMPREGNATION_TIME)
		attached = 0

	if (iscorgi(M))
		var/mob/living/simple_animal/pet/dog/corgi/C = M
		loc = C
		C.facehugger = src
		C.regenerate_icons()

	if(!sterile)
		M.take_bodypart_damage(strength,0) //done here so that humans in helmets take damage
		M.Paralyse(MAX_IMPREGNATION_TIME/6) //something like 25 ticks = 20 seconds with the default settings

	GoIdle() //so it doesn't jump the people that tear it off

	spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
		Impregnate(M)

	return TRUE // time for a smoke

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target)
	if(!target || target.stat == DEAD) //was taken off or something
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.wear_mask != src)
			return

	if(!sterile)
		//target.contract_disease(new /datum/disease/alien_embryo(0)) //so infection chance is same as virus infection chance
		target.visible_message("<span class='danger'>[src] falls limp after violating [target]'s face!</span>", \
								"<span class='userdanger'>[src] falls limp after violating [target]'s face!</span>")

		Die()
		icon_state = "[initial(icon_state)]_impregnated"

		var/obj/item/bodypart/chest/LC = target.get_bodypart("chest")
		if((!LC || LC.status != BODYPART_ROBOTIC) && !target.getorgan(/obj/item/organ/body_egg/alien_embryo))
			new /obj/item/organ/body_egg/alien_embryo(target)

		if(iscorgi(target))
			var/mob/living/simple_animal/pet/dog/corgi/C = target
			src.loc = get_turf(C)
			C.facehugger = null
	else
		target.visible_message("<span class='danger'>[src] violates [target]'s face!</span>", \
								"<span class='userdanger'>[src] violates [target]'s face!</span>")

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/proc/GoIdle()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	spawn(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
		GoActive()
	return

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	item_state = "facehugger_inactive"
	stat = DEAD

	visible_message("<span class='danger'>[src] curls up into a ball!</span>")

/proc/CanHug(mob/living/M)
	if(!istype(M))
		return 0
	if(M.stat == DEAD)
		return 0
	if(M.getorgan(/obj/item/organ/alien/hivenode))
		return 0

	if(iscorgi(M) || ismonkey(M))
		return 1

	var/mob/living/carbon/C = M
	if(ishuman(C) && !(slot_wear_mask in C.dna.species.no_equip))
		var/mob/living/carbon/human/H = C
		if(H.is_mouth_covered(head_only = 1))
			return 0
		return 1
	return 0
