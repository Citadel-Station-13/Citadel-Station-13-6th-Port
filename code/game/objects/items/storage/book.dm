/obj/item/storage/book
	name = "hollowed book"
	desc = "I guess someone didn't like it."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	var/title = "book"

/obj/item/storage/book/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1

/obj/item/storage/book/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")

GLOBAL_LIST_INIT(biblenames, list("Bible", "Quran", "Scrapbook", "Burning Bible", "Clown Bible", "Banana Bible", "Creeper Bible", "White Bible", "Holy Light",  "The God Delusion", "Tome",        "The King in Yellow", "Ithaqua", "Scientology", "Melted Bible", "Necronomicon"))
GLOBAL_LIST_INIT(biblestates, list("bible", "koran", "scrapbook", "burning",       "honk1",       "honk2",        "creeper",       "white",       "holylight",   "atheist",          "tome",        "kingyellow",         "ithaqua", "scientology", "melted",       "necronomicon"))
GLOBAL_LIST_INIT(bibleitemstates, list("bible", "koran", "scrapbook", "bible",         "bible",       "bible",        "syringe_kit",   "syringe_kit", "syringe_kit", "syringe_kit",      "syringe_kit", "kingyellow",         "ithaqua", "scientology", "melted",       "necronomicon"))

/mob/proc/bible_check() //The bible, if held, might protect against certain things
	var/obj/item/storage/book/bible/B = locate() in src
	if(is_holding(B))
		return B
	return 0

/obj/item/storage/book/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon = 'icons/obj/storage.dmi'
	icon_state = "bible"
	item_state = "bible"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	var/mob/affecting = null
	var/deity_name = "Christ"
	force_string = "holy"

/obj/item/storage/book/bible/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, FALSE, TRUE)

/obj/item/storage/book/bible/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is offering [user.p_them()]self to [deity_name]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/storage/book/bible/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(GLOB.bible_icon_state) // if there is already a bible icon return FALSE
		return FALSE
	if(user.job != "Chaplain") // if the user is not the chaplain, return FALSE
		return FALSE

	var/list/skins = list()
	for(var/i in 1 to GLOB.biblestates.len)
		var/image/bible_image = image(icon = 'icons/obj/storage.dmi', icon_state = GLOB.biblestates[i])
		skins += list("[GLOB.biblenames[i]]" = bible_image)

	var/choice = show_radial_menu(user, src, skins, custom_check = CALLBACK(src, .proc/check_menu, user), radius = 40, require_near = TRUE)
	if(!choice)
		return FALSE
	var/bible_index = GLOB.biblenames.Find(choice)
	if(!bible_index)
		return FALSE
	icon_state = GLOB.biblestates[bible_index]
	item_state = GLOB.bibleitemstates[bible_index]

	if(icon_state == "honk1" || icon_state == "honk2")
		var/mob/living/carbon/human/H = usr
		H.dna.add_mutation(CLOWNMUT)
		H.dna.add_mutation(SMILE)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_WEAR_MASK)

	GLOB.bible_icon_state = icon_state
	GLOB.bibleitemstates = item_state
	SSblackbox.record_feedback("text", "religion_book", 1, "[choice]")

/**
  * Checks if we are allowed to interact with the radial
  *
  * Arguements: user The mob interacting with the menu
  */

/obj/item/storage/book/bible/proc/check_menu(mob/living/carbon/human/user)
	if(GLOB.bible_icon_state)
		return FALSE
	if(!istype(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(!user.can_read(src))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(user.job != "Chaplain")
		return FALSE
	return TRUE

/obj/item/storage/book/bible/proc/bless(mob/living/carbon/human/H, mob/living/user)
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.is_robotic_limb())
			to_chat(user, "<span class='warning'>[src.deity_name] refuses to heal this metallic taint!</span>")
			return 0

	var/heal_amt = 5
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt))
				H.update_damage_overlays()
		H.visible_message("<span class='notice'>[user] heals [H] with the power of [deity_name]!</span>")
		to_chat(H, "<span class='boldnotice'>May the power of [deity_name] compel you to be healed!</span>")
		playsound(src.loc, "punch", 25, 1, -1)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return 1

/obj/item/storage/book/bible/attack(mob/living/M, mob/living/user, attackchain_flags = NONE, damage_multiplier = 1, heal_mode = TRUE)

	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if (HAS_TRAIT(user, TRAIT_CLUMSY) && user.prob_bad(50))
		to_chat(user, "<span class='danger'>[src] slips out of your hand and hits your head.</span>")
		user.take_bodypart_damage(10)
		user.Unconscious(400)
		return

	var/chaplain = 0
	if(user.mind && (user.mind.isholy))
		chaplain = 1

	if(!chaplain)
		to_chat(user, "<span class='danger'>The book sizzles in your hands.</span>")
		user.take_bodypart_damage(0,10)
		return

	if (!heal_mode)
		return ..()

	var/smack = 1

	if (M.stat != DEAD)
		if(chaplain && user == M)
			to_chat(user, "<span class='warning'>You can't heal yourself!</span>")
			return

		if(ishuman(M) && (user.prob_good(37.5) || M.prob_good(36)) && bless(M, user))
			smack = 0
		else if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!istype(C.head, /obj/item/clothing/head))
				C.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 80)
				to_chat(C, "<span class='danger'>You feel dumber.</span>")

		if(smack)
			M.visible_message("<span class='danger'>[user] beats [M] over the head with [src]!</span>", \
					"<span class='userdanger'>[user] beats [M] over the head with [src]!</span>")
			playsound(src.loc, "punch", 25, 1, -1)
			log_combat(user, M, "attacked", src)

	else
		M.visible_message("<span class='danger'>[user] smacks [M]'s lifeless corpse with [src].</span>")
		playsound(src.loc, "punch", 25, 1, -1)

/obj/item/storage/book/bible/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isfloorturf(A))
		to_chat(user, "<span class='notice'>You hit the floor with the bible.</span>")
		if(user.mind && (user.mind.isholy))
			for(var/obj/effect/rune/R in orange(2,user))
				R.invisibility = 0
	if(user.mind && (user.mind.isholy))
		if(A.reagents && A.reagents.has_reagent(/datum/reagent/water)) // blesses all the water in the holder
			to_chat(user, "<span class='notice'>You bless [A].</span>")
			var/water2holy = A.reagents.get_reagent_amount(/datum/reagent/water)
			A.reagents.del_reagent(/datum/reagent/water)
			A.reagents.add_reagent(/datum/reagent/water/holywater,water2holy)
		if(A.reagents && A.reagents.has_reagent(/datum/reagent/fuel/unholywater)) // yeah yeah, copy pasted code - sue me
			to_chat(user, "<span class='notice'>You purify [A].</span>")
			var/unholy2clean = A.reagents.get_reagent_amount(/datum/reagent/fuel/unholywater)
			A.reagents.del_reagent(/datum/reagent/fuel/unholywater)
			A.reagents.add_reagent(/datum/reagent/water/holywater,unholy2clean)
	if(istype(A, /obj/item/cult_bastard) || istype(A, /obj/item/melee/cultblade) && !iscultist(user))
		to_chat(user, "<span class='notice'>You begin to exorcise [A].</span>")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,1)
		if(do_after(user, 40, target = A))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,1)
			if(istype(A, /obj/item/cult_bastard))
				for(var/obj/item/soulstone/SS in A.contents)
					SS.usability = TRUE
					for(var/mob/living/simple_animal/hostile/construct/shade/EX in SS)
						SSticker.mode.remove_cultist(EX.mind, 1, 0)
						EX.icon_state = "ghost1"
						EX.name = "Purified [EX.name]"
					SS.release_shades(user)
					qdel(SS)
				new /obj/item/nullrod/claymore(get_turf(A))
			else
				new /obj/item/claymore/purified(get_turf(A))
			user.visible_message("<span class='notice'>[user] has purified [A]!</span>")
			qdel(A)

	else if(istype(A, /obj/item/soulstone) && !iscultist(user))
		var/obj/item/soulstone/SS = A
		to_chat(user, "<span class='notice'>You begin to exorcise [SS].</span>")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,1)
		if(do_after(user, 40, target = SS))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,1)
			SS.usability = TRUE
			for(var/mob/living/simple_animal/hostile/construct/shade/EX in SS)
				SSticker.mode.remove_cultist(EX.mind, 1, 0)
				EX.icon_state = "ghost1"
				EX.name = "Purified [EX.name]"
				SS.release_shades(user)
			user.visible_message("<span class='notice'>[user] has purified the [SS]!</span>")
			qdel(SS)

/obj/item/storage/book/bible/booze
	desc = "To be applied to the head repeatedly."

/obj/item/storage/book/bible/booze/PopulateContents()
	new /obj/item/reagent_containers/food/drinks/bottle/whiskey(src)

/obj/item/storage/book/bible/syndicate
	icon_state ="ebook"
	deity_name = "The Syndicate"
	throw_speed = 2
	throwforce = 18
	throw_range = 7
	force = 18
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	name = "Syndicate Tome"
	attack_verb = list("attacked", "burned", "blessed", "damned", "scorched")
	var/uses = 1

/obj/item/storage/book/bible/syndicate/attack_self(mob/living/carbon/human/H)
	if (uses)
		H.mind.isholy = TRUE
		uses -= 1
		to_chat(H, "<span class='userdanger'>You try to open the book AND IT BITES YOU!</span>")
		playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
		H.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		to_chat(H, "<span class='notice'>Your name appears on the inside cover, in blood.</span>")
		var/ownername = H.real_name
		desc += "<span class='warning'>The name [ownername] is written in blood inside the cover.</span>"

/obj/item/storage/book/bible/syndicate/attack(mob/living/M, mob/living/user, attackchain_flags = NONE, damage_multiplier = 1, heal_mode = TRUE)
	if(user.a_intent != INTENT_HELP)
		heal_mode = FALSE		//args pass over
	return ..()		// to ..()

/obj/item/storage/book/bible/syndicate/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/storage/book/bible/syndicate/empty
	uses = 0
