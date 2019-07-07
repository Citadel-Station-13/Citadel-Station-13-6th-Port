#define EGG_INCUBATION_TIME 120

/mob/living/simple_animal/hostile/headcrab
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	gender = NEUTER
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("squeaks")
	ventcrawler = VENTCRAWLER_ALWAYS
	var/datum/mind/origin
	var/egg_lain = 0
	gold_core_spawnable = NO_SPAWN //are you sure about this?? // CITADEL CHANGE, Yes.

/mob/living/simple_animal/hostile/headcrab/proc/Infect(mob/living/carbon/victim)
	var/obj/item/organ/body_egg/changeling_egg/egg = new(victim)
	egg.Insert(victim)
	if(origin)
		egg.origin = origin
	else if(mind) // Let's make this a feature
		egg.origin = mind
	for(var/obj/item/organ/I in src)
		I.forceMove(egg)
	visible_message("<span class='warning'>[src] plants something in [victim]'s flesh!</span>", \
					"<span class='danger'>We inject our egg into [victim]'s body!</span>")
	egg_lain = 1

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	. = ..()
	if(. && !egg_lain && iscarbon(target) && !ismonkey(target))
		// Changeling egg can survive in aliens!
		var/mob/living/carbon/C = target
		if(C.stat == DEAD)
			if(HAS_TRAIT(C, TRAIT_XENO_HOST))
				to_chat(src, "<span class='userdanger'>A foreign presence repels us from this body. Perhaps we should try to infest another?</span>")
				return
			Infect(target)
			to_chat(src, "<span class='userdanger'>With our egg laid, our death approaches rapidly...</span>")
			addtimer(CALLBACK(src, .proc/death), 100)

/mob/living/simple_animal/hostile/headcrab/attack_hand(mob/user)
	(..())
	if(stat == DEAD)
		if (user.a_intent == INTENT_HELP)
			var/obj/item/headcrab/H = new(get_turf(user))
			src.forceMove(H)
			user.put_in_hands(H)
			H.slug = src

/obj/item/headcrab //Edible headslug obj so lings who last resort can still be absorbed
	name = "dead headslug"
	desc = "The deceased remains of a changeling headslug. Looks strangely edible, like it might be nutritious. But only one of its own kind could possibly enjoy such a meal... "
	icon = 'icons/mob/animal.dmi'
	icon_state = "headcrab_dead"
	item_flags = DROPDEL
	var/mob/living/slug = null

/obj/item/headcrab/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !target)
		return
	if(target == user)
		feed(user)
	else
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/victim = target
			user.visible_message("<span class='warning'>[user] is trying to force [victim] to eat [src]!</span>")
			if(do_mob(user, victim, 40))
				feed(target)

/obj/item/headcrab/proc/feed(var/mob/living/carbon/M)
	M.visible_message("<span class='warning'>[M] devours the [src]!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 20, 1)
	M.reagents.add_reagent("changelingmeth", 15)
	var/datum/antagonist/changeling/changeling = M.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		if(slug.mind)
			var/datum/antagonist/changeling/target_ling = slug.mind.has_antag_datum(/datum/antagonist/changeling)
			if(target_ling)
				changeling.absorb_mind(slug)
		else
			to_chat(M, "<span class='warning'>We sense the mind inhabiting this vessel has vacated</span>")

	else
		M.visible_message("<span class='warning'>[M] starts heaving uncontrollably!</span>")
		M.vomit()
	qdel(slug) //You ate it
	qdel(src)


/obj/item/headcrab/Destroy()
	for(var/mob/M in src)
		M.forceMove(drop_location())
	return ..()


/obj/item/organ/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	var/datum/mind/origin
	var/time

/obj/item/organ/body_egg/changeling_egg/egg_process()
	// Changeling eggs grow in dead people
	time++
	if(time >= EGG_INCUBATION_TIME)
		Pop()
		Remove(owner)
		qdel(src)

/obj/item/organ/body_egg/changeling_egg/proc/Pop()
	var/mob/living/carbon/monkey/M = new(owner)
	owner.stomach_contents += M

	for(var/obj/item/organ/I in src)
		I.Insert(M, 1)

	if(origin && (origin.current ? (origin.current.stat == DEAD) : origin.get_ghost()))
		origin.transfer_to(M)
		var/datum/antagonist/changeling/C = origin.has_antag_datum(/datum/antagonist/changeling)
		if(!C)
			C = origin.add_antag_datum(/datum/antagonist/changeling/xenobio)
		if(C.can_absorb_dna(owner))
			C.add_new_profile(owner)

		C.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
		M.key = origin.key
	owner.gib()



#undef EGG_INCUBATION_TIME
