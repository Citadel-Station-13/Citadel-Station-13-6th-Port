/obj/item/toy/plush
	name = "plush"
	desc = "This is the special coder plush, do not steal."
	icon = 'icons/obj/plushes.dmi'
	icon_state = "debug"
	attack_verb = list("thumped", "whomped", "bumped")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	var/list/squeak_override //Weighted list; If you want your plush to have different squeak sounds use this
	var/stuffed = TRUE //If the plushie has stuffing in it
	var/unstuffable = FALSE //for plushies that can't be stuffed
	var/obj/item/grenade/grenade //You can remove the stuffing from a plushie and add a grenade to it for *nefarious uses*
	//--love ~<3--
	gender = NEUTER
	var/obj/item/toy/plush/lover
	var/obj/item/toy/plush/partner
	var/obj/item/toy/plush/plush_child
	var/obj/item/toy/plush/paternal_parent	//who initiated creation
	var/obj/item/toy/plush/maternal_parent	//who owns, see love()
	var/static/list/breeding_blacklist = typecacheof(/obj/item/toy/plush/carpplushie/dehy_carp) // you cannot have sexual relations with this plush
	var/list/scorned	= list()	//who the plush hates
	var/list/scorned_by	= list()	//who hates the plush, to remove external references on Destroy()
	var/heartbroken = FALSE
	var/vowbroken = FALSE
	var/young = FALSE
	var/mood_message
	var/list/love_message
	var/list/partner_message
	var/list/heartbroken_message
	var/list/vowbroken_message
	var/list/parent_message
	var/normal_desc
	//--end of love :'(--

	var/snowflake_id					//if we set from a config snowflake plushie.
	/// wrapper, do not use, read only
	var/__ADMIN_SET_TO_ID
	var/can_random_spawn = TRUE			//if this is FALSE, don't spawn this for random plushies.

/obj/item/toy/plush/random_snowflake/Initialize(mapload, set_snowflake_id)
	. = ..()
	var/list/configlist = CONFIG_GET(keyed_list/snowflake_plushies)
	var/id = safepick(configlist)
	if(!id)
		return
	set_snowflake_from_config(id)

/obj/item/toy/plush/DoRevenantThrowEffects(atom/target)
	var/datum/component/squeak/squeaker = GetComponent(/datum/component/squeak)
	squeaker.do_play_squeak(TRUE)

/obj/item/toy/plush/Initialize(mapload, set_snowflake_id)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_override)
	AddElement(/datum/element/bed_tuckable, 6, -5, 90)

	//have we decided if Pinocchio goes in the blue or pink aisle yet?
	if(gender == NEUTER)
		if(prob(50))
			gender = FEMALE
		else
			gender = MALE

	love_message		= list("\n[src] is so happy, \he could rip a seam!")
	partner_message		= list("\n[src] has a ring on \his finger! It says bound to my dear [partner].")
	heartbroken_message	= list("\n[src] looks so sad.")
	vowbroken_message	= list("\n[src] lost \his ring...")
	parent_message		= list("\n[src] can't remember what sleep is.")

	normal_desc = desc

	if(set_snowflake_id)
		set_snowflake_from_config(set_snowflake_id)

/obj/item/toy/plush/Destroy()
	QDEL_NULL(grenade)

	//inform next of kin and... acquaintances
	if(partner)
		partner.bad_news(src)
		partner = null
		lover = null
	else if(lover)
		lover.bad_news(src)
		lover = null

	if(paternal_parent)
		paternal_parent.bad_news(src)
		paternal_parent = null

	if(maternal_parent)
		maternal_parent.bad_news(src)
		maternal_parent = null

	if(plush_child)
		plush_child.bad_news(src)
		plush_child = null

	var/i
	var/obj/item/toy/plush/P
	for(i=1, i<=scorned.len, i++)
		P = scorned[i]
		P.bad_news(src)
	scorned = null

	for(i=1, i<=scorned_by.len, i++)
		P = scorned_by[i]
		P.bad_news(src)
	scorned_by = null

	//null remaining lists
	squeak_override = null

	love_message = null
	partner_message = null
	heartbroken_message = null
	vowbroken_message = null
	parent_message = null

	return ..()

/obj/item/toy/plush/vv_get_var(var_name)
	if(var_name == NAMEOF(src, __ADMIN_SET_TO_ID))
		return debug_variable("__ADMIN: SET SNOWFLAKE ID", snowflake_id, 0, src)
	return ..()

/obj/item/toy/plush/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, __ADMIN_SET_TO_ID))
		return set_snowflake_from_config(var_value)
	return ..()

/obj/item/toy/plush/proc/set_snowflake_from_config(id)
	var/list/configlist = CONFIG_GET(keyed_list/snowflake_plushies)
	var/list/jsonlist = configlist[id]
	if(!jsonlist)
		return FALSE
	jsonlist = json_decode(jsonlist)
	if(jsonlist["inherit_from"])
		var/path = text2path(jsonlist["inherit_from"])
		if(!ispath(path, /obj/item/toy/plush))
			stack_trace("Invalid path for inheritance")
		else
			var/obj/item/toy/plush/P = new path		//can't initial() lists
			name = P.name
			desc = P.desc
			icon_state = P.icon_state
			item_state = P.item_state
			icon = P.icon
			squeak_override = P.squeak_override
			attack_verb = P.attack_verb
			gender = P.gender
			qdel(P)
	if(jsonlist["name"])
		name = jsonlist["name"]
	if(jsonlist["desc"])
		desc = jsonlist["desc"]
	if(jsonlist["gender"])
		gender = jsonlist["gender"]
	if(jsonlist["icon_state"])
		icon_state = jsonlist["icon_state"]
		item_state = jsonlist["item_state"]
		var/static/config_sprites = file("config/plushies/sprites.dmi")
		icon = config_sprites
	if(jsonlist["attack_verb"])
		attack_verb = jsonlist["attack_verb"]
	if(jsonlist["squeak_override"])
		squeak_override = jsonlist["squeak_override"]
	if(squeak_override)
		var/datum/component/squeak/S = GetComponent(/datum/component/squeak)
		S?.override_squeak_sounds = squeak_override
	snowflake_id = id
	return TRUE

/obj/item/toy/plush/handle_atom_del(atom/A)
	if(A == grenade)
		grenade = null
	..()

/obj/item/toy/plush/attack_self(mob/user)
	. = ..()
	if(stuffed || grenade)
		to_chat(user, "<span class='notice'>You pet [src]. D'awww.</span>")
		if(grenade && !grenade.active)
			if(istype(grenade, /obj/item/grenade/chem_grenade))
				var/obj/item/grenade/chem_grenade/G = grenade
				if(G.nadeassembly) //We're activated through different methods
					return
			log_game("[key_name(user)] activated a hidden grenade in [src].")
			grenade.preprime(user, msg = FALSE, volume = 10)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT,"plushpet", /datum/mood_event/plushpet)
	else
		to_chat(user, "<span class='notice'>You try to pet [src], but it has no stuffing. Aww...</span>")
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT,"plush_nostuffing", /datum/mood_event/plush_nostuffing)

/obj/item/toy/plush/attackby(obj/item/I, mob/living/user, params)
	if(I.get_sharpness())
		if(!grenade)
			if(unstuffable)
				to_chat(user, "<span class='notice'>Nothing to do here.</span>")
				return
			if(!stuffed)
				to_chat(user, "<span class='warning'>You already murdered it!</span>")
				return
			user.visible_message("<span class='notice'>[user] tears out the stuffing from [src]!</span>", "<span class='notice'>You rip a bunch of the stuffing from [src]. Murderer.</span>")
			I.play_tool_sound(src)
			stuffed = FALSE
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT,"plushjack", /datum/mood_event/plushjack)
		else
			to_chat(user, "<span class='notice'>You remove the grenade from [src].</span>")
			user.put_in_hands(grenade)
			grenade = null
		return
	if(istype(I, /obj/item/grenade))
		if(unstuffable)
			to_chat(user, "<span class='warning'>No... you should destroy it now!</span>")
			sleep(10)
			if(QDELETED(user) || QDELETED(src))
				return
			SEND_SOUND(user, 'sound/weapons/armbomb.ogg')
			return
		if(stuffed)
			to_chat(user, "<span class='warning'>You need to remove some stuffing first!</span>")
			return
		if(grenade)
			to_chat(user, "<span class='warning'>[src] already has a grenade!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		user.visible_message("<span class='warning'>[user] slides [grenade] into [src].</span>", \
		"<span class='danger'>You slide [I] into [src].</span>")
		grenade = I
		var/turf/grenade_turf = get_turf(src)
		log_game("[key_name(user)] added a grenade ([I.name]) to [src] at [AREACOORD(grenade_turf)].")
		return
	if(istype(I, /obj/item/toy/plush))
		love(I, user)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT,"plushplay", /datum/mood_event/plushplay)
		return
	return ..()

/obj/item/toy/plush/proc/love(obj/item/toy/plush/Kisser, mob/living/user)	//~<3
	var/chance = 100	//to steal a kiss, surely there's a 100% chance no-one would reject a plush such as I?
	var/concern = 20	//perhaps something might cloud true love with doubt
	var/loyalty = 30	//why should another get between us?
	var/duty = 50		//conquering another's is what I live for

	//we are not catholic
	if(young == TRUE || Kisser.young == TRUE)
		user.show_message("<span class='notice'>[src] plays tag with [Kisser].</span>", MSG_VISUAL,
			"<span class='notice'>They're happy.</span>", 0)
		Kisser.cheer_up()
		cheer_up()

	//never again
	else if(Kisser in scorned)
		//message, visible, alternate message, neither visible nor audible
		user.show_message("<span class='notice'>[src] rejects the advances of [Kisser]!</span>", MSG_VISUAL,
			"<span class='notice'>That didn't feel like it worked.</span>", 0)
	else if(src in Kisser.scorned)
		user.show_message("<span class='notice'>[Kisser] realises who [src] is and turns away.</span>", MSG_VISUAL,
			"<span class='notice'>That didn't feel like it worked.</span>", 0)

	//first comes love
	else if(Kisser.lover != src && Kisser.partner != src)	//cannot be lovers or married
		if(Kisser.lover)	//if the initiator has a lover
			Kisser.lover.heartbreak(Kisser)	//the old lover can get over the kiss-and-run whilst the kisser has some fun
			chance -= concern	//one heart already broken, what does another mean?
		if(lover)	//if the recipient has a lover
			chance -= loyalty	//mustn't... but those lips
		if(partner)	//if the recipient has a partner
			chance -= duty	//do we mate for life?

		if(prob(chance))	//did we bag a date?
			user.visible_message("<span class='notice'>[user] makes [Kisser] kiss [src]!</span>",
									"<span class='notice'>You make [Kisser] kiss [src]!</span>")
			if(lover)	//who cares for the past, we live in the present
				lover.heartbreak(src)
			new_lover(Kisser)
			Kisser.new_lover(src)
		else
			user.show_message("<span class='notice'>[src] rejects the advances of [Kisser], maybe next time?</span>", MSG_VISUAL,
								"<span class='notice'>That didn't feel like it worked, this time.</span>", 0)

	//then comes marriage
	else if(Kisser.lover == src && Kisser.partner != src)	//need to be lovers (assumes loving is a two way street) but not married (also assumes similar)
		user.visible_message("<span class='notice'>[user] pronounces [Kisser] and [src] married! D'aw.</span>",
									"<span class='notice'>You pronounce [Kisser] and [src] married!</span>")
		new_partner(Kisser)
		Kisser.new_partner(src)

	//then comes a baby in a baby's carriage, or an adoption in an adoption's orphanage
	else if(Kisser.partner == src && !plush_child)	//the one advancing does not take ownership of the child and we have a one child policy in the toyshop
		user.visible_message("<span class='notice'>[user] is going to break [Kisser] and [src] by bashing them like that.</span>",
									"<span class='notice'>[Kisser] passionately embraces [src] in your hands. Look away you perv!</span>")
		if(plop(Kisser))
			user.visible_message("<span class='notice'>Something drops at the feet of [user].</span>",
								"<span class='notice'>The miracle of oh god did that just come out of [src]?!</span>")

	//then comes protection, or abstinence if we are catholic
	else if(Kisser.partner == src && plush_child)
		user.visible_message("<span class='notice'>[user] makes [Kisser] nuzzle [src]!</span>",
									"<span class='notice'>You make [Kisser] nuzzle [src]!</span>")

	//then oh fuck something unexpected happened
	else
		user.show_message("<span class='warning'>[Kisser] and [src] don't know what to do with one another.</span>", 0)

/obj/item/toy/plush/proc/heartbreak(obj/item/toy/plush/Brutus)
	if(lover != Brutus)
		to_chat(world, "lover != Brutus")
		return	//why are we considering someone we don't love?

	scorned.Add(Brutus)
	Brutus.scorned_by(src)

	lover = null
	Brutus.lover = null	//feeling's mutual

	heartbroken = TRUE
	mood_message = pick(heartbroken_message)

	if(partner == Brutus)	//oh dear...
		partner = null
		Brutus.partner = null	//it'd be weird otherwise
		vowbroken = TRUE
		mood_message = pick(vowbroken_message)

	update_desc()

/obj/item/toy/plush/proc/scorned_by(obj/item/toy/plush/Outmoded)
	scorned_by.Add(Outmoded)

/obj/item/toy/plush/proc/new_lover(obj/item/toy/plush/Juliet)
	if(lover == Juliet)
		return	//nice try
	lover = Juliet

	cheer_up()
	lover.cheer_up()

	mood_message = pick(love_message)
	update_desc()

	if(partner)	//who?
		partner = null	//more like who cares

/obj/item/toy/plush/proc/new_partner(obj/item/toy/plush/Apple_of_my_eye)
	if(partner == Apple_of_my_eye)
		return	//double marriage is just insecurity
	if(lover != Apple_of_my_eye)
		return	//union not born out of love will falter

	partner = Apple_of_my_eye

	heal_memories()
	partner.heal_memories()

	mood_message = pick(partner_message)
	update_desc()

/obj/item/toy/plush/proc/plop(obj/item/toy/plush/Daddy)
	if(partner != Daddy)
		return	FALSE //we do not have bastards in our toyshop

	if(is_type_in_typecache(Daddy, breeding_blacklist))
		return FALSE // some love is forbidden

	if(prob(50))	//it has my eyes
		plush_child = new type(get_turf(loc))
	else	//it has your eyes
		plush_child = new Daddy.type(get_turf(loc))

	plush_child.make_young(src, Daddy)

/obj/item/toy/plush/proc/make_young(obj/item/toy/plush/Mama, obj/item/toy/plush/Dada)
	if(Mama == Dada)
		return	//cloning is reserved for plants and spacemen

	maternal_parent = Mama
	paternal_parent = Dada
	young = TRUE
	name = "[Mama] Jr"	//Icelandic naming convention pending
	normal_desc = "[src] is a little baby of [maternal_parent] and [paternal_parent]!"	//original desc won't be used so the child can have moods
	update_desc()

	Mama.mood_message = pick(Mama.parent_message)
	Mama.update_desc()
	Dada.mood_message = pick(Dada.parent_message)
	Dada.update_desc()

/obj/item/toy/plush/proc/bad_news(obj/item/toy/plush/Deceased)	//cotton to cotton, sawdust to sawdust
	var/is_that_letter_for_me = FALSE
	if(partner == Deceased)	//covers marriage
		is_that_letter_for_me = TRUE
		partner = null
		lover = null
	else if(lover == Deceased)	//covers lovers
		is_that_letter_for_me = TRUE
		lover = null

	//covers children
	if(maternal_parent == Deceased)
		is_that_letter_for_me = TRUE
		maternal_parent = null

	if(paternal_parent == Deceased)
		is_that_letter_for_me = TRUE
		paternal_parent = null

	//covers parents
	if(plush_child == Deceased)
		is_that_letter_for_me = TRUE
		plush_child = null

	//covers bad memories
	if(Deceased in scorned)
		scorned.Remove(Deceased)
		cheer_up()	//what cold button eyes you have

	if(Deceased in scorned_by)
		scorned_by.Remove(Deceased)

	//all references to the departed should be cleaned up by now

	if(is_that_letter_for_me)
		heartbroken = TRUE
		mood_message = pick(heartbroken_message)
		update_desc()

/obj/item/toy/plush/proc/cheer_up()	//it'll be all right
	if(!heartbroken)
		return	//you cannot make smile what is already
	if(vowbroken)
		return	//it's a pretty big deal

	heartbroken = !heartbroken

	if(mood_message in heartbroken_message)
		mood_message = null
	update_desc()

/obj/item/toy/plush/proc/heal_memories()	//time fixes all wounds
	if(!vowbroken)
		vowbroken = !vowbroken
		if(mood_message in vowbroken_message)
			mood_message = null
	cheer_up()

/obj/item/toy/plush/update_desc()
	desc = normal_desc
	if(mood_message)
		desc += mood_message
	. = ..()

GLOBAL_LIST_INIT(valid_plushie_paths, valid_plushie_paths())
/proc/valid_plushie_paths()
	. = list()
	for(var/i in subtypesof(/obj/item/toy/plush))
		var/obj/item/toy/plush/abstract = i
		if(!initial(abstract.can_random_spawn))
			continue
		. += i

/obj/item/toy/plush/random
	name = "Illegal plushie"
	desc = "Something fucked up"
	can_random_spawn = FALSE

/obj/item/toy/plush/random/Initialize()
	SHOULD_CALL_PARENT(FALSE)
	var/newtype
	var/list/snowflake_list = CONFIG_GET(keyed_list/snowflake_plushies)

	/// If there are no snowflake plushies we'll default to base plush, so we grab from the valid list
	if (snowflake_list.len)
		newtype = prob(CONFIG_GET(number/snowflake_plushie_prob)) ? /obj/item/toy/plush/random_snowflake : pick(GLOB.valid_plushie_paths)
	else
		newtype = pick(GLOB.valid_plushie_paths)

	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/toy/plush/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon_state = "carpplush"
	item_state = "carp_plushie"
	attack_verb = list("bitten", "eaten", "fin slapped")
	squeak_override = list('sound/weapons/bite.ogg'=1)

/obj/item/toy/plush/bubbleplush
	name = "bubblegum plushie"
	desc = "The friendly red demon that gives good miners gifts."
	icon_state = "bubbleplush"
	attack_verb = list("rends")
	squeak_override = list('sound/magic/demon_attack1.ogg'=1)

/obj/item/toy/plush/plushvar
	name = "ratvar plushie"
	desc = "An adorable plushie of the clockwork justiciar himself with new and improved spring arm action."
	icon_state = "plushvar"
	var/obj/item/toy/plush/narplush/clash_target
	gender = MALE	//he's a boy, right?

/obj/item/toy/plush/plushvar/Moved()
	. = ..()
	if(clash_target)
		return
	var/obj/item/toy/plush/narplush/P = locate() in range(1, src)
	if(P && istype(P.loc, /turf/open) && !P.clashing)
		clash_of_the_plushies(P)

/obj/item/toy/plush/plushvar/proc/clash_of_the_plushies(obj/item/toy/plush/narplush/P)
	clash_target = P
	P.clashing = TRUE
	say("YOU.")
	P.say("Ratvar?!")
	var/obj/item/toy/plush/a_winnar_is
	var/victory_chance = 10
	for(var/i in 1 to 10) //We only fight ten times max
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(!Adjacent(P))
			visible_message("<span class='warning'>The two plushies angrily flail at each other before giving up.</span>")
			clash_target = null
			P.clashing = FALSE
			return
		playsound(src, 'sound/magic/clockwork/ratvar_attack.ogg', 50, TRUE, frequency = 2)
		sleep(2.4)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(prob(victory_chance))
			a_winnar_is = src
			break
		P.SpinAnimation(5, 0)
		sleep(5)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		playsound(P, 'sound/magic/clockwork/narsie_attack.ogg', 50, TRUE, frequency = 2)
		sleep(3.3)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(prob(victory_chance))
			a_winnar_is = P
			break
		SpinAnimation(5, 0)
		victory_chance += 10
		sleep(5)
	if(!a_winnar_is)
		a_winnar_is = pick(src, P)
	if(a_winnar_is == src)
		say(pick("DIE.", "ROT."))
		P.say(pick("Nooooo...", "Not die. To y-", "Die. Ratv-", "Sas tyen re-"))
		playsound(src, 'sound/magic/clockwork/anima_fragment_attack.ogg', 50, TRUE, frequency = 2)
		playsound(P, 'sound/magic/demon_dies.ogg', 50, TRUE, frequency = 2)
		explosion(P, 0, 0, 1)
		qdel(P)
		clash_target = null
	else
		say("NO! I will not be banished again...")
		P.say(pick("Ha.", "Ra'sha fonn dest.", "You fool. To come here."))
		playsound(src, 'sound/magic/clockwork/anima_fragment_death.ogg', 62, TRUE, frequency = 2)
		playsound(P, 'sound/magic/demon_attack1.ogg', 50, TRUE, frequency = 2)
		explosion(src, 0, 0, 1)
		qdel(src)
		P.clashing = FALSE

/obj/item/toy/plush/narplush
	name = "\improper Nar'Sie plushie"
	desc = "A small stuffed doll of the elder goddess Nar'Sie. Who thought this was a good children's toy?"
	icon_state = "narplush"
	var/clashing
	var/is_invoker = TRUE
	gender = FEMALE	//it's canon if the toy is

/obj/item/toy/plush/narplush/Moved()
	. = ..()
	var/obj/item/toy/plush/plushvar/P = locate() in range(1, src)
	if(P && istype(P.loc, /turf/open) && !P.clash_target && !clashing)
		P.clash_of_the_plushies(src)

/obj/item/toy/plush/narplush/hugbox
	desc = "A small stuffed doll of the elder goddess Nar'Sie. Who thought this was a good children's toy? <b>It looks sad.</b>"
	is_invoker = FALSE

/obj/item/toy/plush/lizardplushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon_state = "plushie_lizard"
	item_state = "plushie_lizard"
	attack_verb = list("clawed", "hissed", "tail slapped")
	squeak_override = list('sound/weapons/slash.ogg' = 1)

/obj/item/toy/plush/lizardplushie/kobold
	name = "kobold plushie"
	desc = "An adorable stuffed toy that resembles a kobold."
	icon_state = "kobold"
	item_state = "kobold"

/obj/item/toy/plush/nukeplushie
	name = "operative plushie"
	desc = "A stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"
	item_state = "plushie_nuke"
	attack_verb = list("shot", "nuked", "detonated")
	squeak_override = list('sound/effects/hit_punch.ogg' = 1)

/obj/item/toy/plush/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "plushie_slime"
	item_state = "plushie_slime"
	attack_verb = list("blorbled", "slimed", "absorbed", "glomped")
	squeak_override = list('sound/effects/blobattack.ogg' = 1)
	gender = FEMALE	//given all the jokes and drawings, I'm not sure the xenobiologists would make a slimeboy

/obj/item/toy/plush/awakenedplushie
	name = "awakened plushie"
	desc = "An ancient plushie that has grown enlightened to the true nature of reality."
	icon_state = "plushie_awake"
	item_state = "plushie_awake"
	can_random_spawn = FALSE

/obj/item/toy/plush/awakenedplushie/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/edit_complainer)

/obj/item/toy/plush/beeplushie
	name = "bee plushie"
	desc = "A cute toy that resembles an even cuter bee."
	icon_state = "plushie_h"
	item_state = "plushie_h"
	attack_verb = list("stung")
	gender = FEMALE
	squeak_override = list('modular_citadel/sound/voice/scream_moth.ogg' = 1)

/obj/item/toy/plush/mothplushie
	name = "insect plushie"
	desc = "An adorable stuffed toy that resembles some kind of insect."
	icon_state = "bumble"
	item_state = "bumble"
	squeak_override = list('modular_citadel/sound/voice/mothsqueak.ogg' = 1)
	can_random_spawn = FALSE

/obj/item/toy/plush/lampplushie
	name = "lamp plushie"
	desc = "A toy lamp plushie, doesn't actually make light, but it still toggles on and off. Click clack!"
	icon_state = "plushie_lamp"
	item_state = "plushie_lamp"
	attack_verb = list("lit", "flickered", "flashed")
	squeak_override = list('sound/weapons/magout.ogg' = 1)

/obj/item/toy/plush/box
	name = "cardboard plushie"
	desc = "A toy box plushie, it holds cotten. Only a baddie would place a bomb through the postal system..."
	icon_state = "box"
	item_state = "box"
	attack_verb = list("open", "closed", "packed", "hidden", "rigged", "bombed", "sent", "gave")

/obj/item/toy/plush/slaggy
	name = "slag plushie"
	desc = "A piece of slag with some googly eyes and a drawn on mouth."
	icon_state = "slaggy"
	item_state = "slaggy"
	attack_verb = list("melted", "refined", "stared")

/obj/item/toy/plush/mr_buckety
	name = "bucket plushie"
	desc = "A bucket that is missing its handle with some googly eyes and a drawn on mouth."
	icon_state = "mr_buckety"
	item_state = "mr_buckety"
	attack_verb = list("filled", "dumped", "stared")

/obj/item/toy/plush/dr_scanny
	name = "scanner plushie"
	desc = "A old outdated scanner that has been modified to have googly eyes, a dawn on mouth and, heart."
	icon_state = "dr_scanny"
	item_state = "dr_scanny"
	attack_verb = list("scanned", "beeped", "stared")

/obj/item/toy/plush/borgplushie
	name = "robot plushie"
	desc = "An adorable stuffed toy of a robot."
	icon_state = "securityk9"
	item_state = "securityk9"
	attack_verb = list("beeped", "booped", "pinged")
	squeak_override = list('sound/machines/beep.ogg' = 1)

/obj/item/toy/plush/borgplushie/medihound
	icon_state = "medihound"
	item_state = "medihound"

/obj/item/toy/plush/borgplushie/scrubpuppy
	icon_state = "scrubpuppy"
	item_state = "scrubpuppy"

/obj/item/toy/plush/aiplush
	name = "AI plushie"
	desc = "A little stuffed toy AI core... it appears to be malfunctioning."
	icon_state = "exo"
	item_state = "exo"
	attack_verb = list("hacked", "detonated", "overloaded")
	squeak_override = list('sound/machines/beep.ogg' = 9, 'sound/machines/buzz-two.ogg' = 1)

/obj/item/toy/plush/mammal/fox
	icon_state = "fox"
	item_state = "fox"

/obj/item/toy/plush/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon_state = "plushie_snake"
	item_state = "plushie_snake"
	attack_verb = list("bitten", "hissed", "tail slapped")
	squeak_override = list('modular_citadel/sound/voice/hiss.ogg' = 1)

/obj/item/toy/plush/mammal
	name = "mammal plushie"
	desc = "An adorable stuffed toy resembling some sort of crew member."
	can_random_spawn = FALSE

/obj/item/toy/plush/catgirl/fermis
	name = "medcat plushie"
	desc = "An affectionate stuffed toy that resembles a certain medcat, comes complete with battery operated wagging tail!! You get the impression she's cheering you on to to find happiness and be kind to people."
	icon_state = "fermis"
	item_state = "fermis"
	attack_verb = list("cuddled", "petpatted", "wigglepurred")
	squeak_override = list('modular_citadel/sound/voice/merowr.ogg' = 1)

/obj/item/toy/plush/xeno
	name = "xenohybrid plushie"
	desc = "An adorable stuffed toy that resmembles a xenomorphic crewmember."
	squeak_override = list('sound/voice/hiss2.ogg' = 1)
	can_random_spawn = FALSE

/obj/item/toy/plush/bird
	name = "bird plushie"
	desc = "An adorable stuffed plushie that resembles an avian."
	attack_verb = list("peeped", "beeped", "poofed")
	squeak_override = list('modular_citadel/sound/voice/peep.ogg' = 1)
	can_random_spawn = FALSE

/obj/item/toy/plush/sergal
	name = "sergal plushie"
	desc = "An adorable stuffed plushie that resembles a sagaru."
	squeak_override = list('modular_citadel/sound/voice/merp.ogg' = 1)
	can_random_spawn = FALSE

/obj/item/toy/plush/mammal/dog
	desc = "An adorable stuffed toy that resembles a canine."
	attack_verb = list("barked", "boofed", "borked")
	squeak_override = list(
	'modular_citadel/sound/voice/bark1.ogg' = 1,
	'modular_citadel/sound/voice/bark2.ogg' = 1
	)

/obj/item/toy/plush/catgirl
	name = "feline plushie"
	desc = "An adorable stuffed toy that resembles a feline."
	attack_verb = list("headbutt", "scritched", "bit")
	squeak_override = list('modular_citadel/sound/voice/nya.ogg' = 1)
	can_random_spawn = FALSE


/obj/item/toy/plush/hairball
	name = "Hairball"
	desc = "A bundle of undigested fibers and scales. Yuck."
	icon_state = "Hairball"
	unstuffable = TRUE
	young = TRUE // Your own mouth-baby.
	squeak_override = list('sound/misc/splort.ogg'=1)
	attack_verb = list("sploshed", "splorted", "slushed")
	can_random_spawn = FALSE

/obj/item/toy/plush/plushling
	name = "peculiar plushie"
	desc = "An adorable stuffed toy- wait, did it just move?"
	can_random_spawn = FALSE
	var/absorb_cooldown = 100 //ticks cooldown between absorbs
	var/next_absorb = 0 //When can it absorb another plushie
	var/check_interval = 20
	var/next_check = 0

//Overrides parent proc
/obj/item/toy/plush/plushling/attack_self(mob/user)
	if(!user) //hmmmmm
		return
	to_chat(user, "<span class='warning'>You try to pet the plushie, but recoil as it bites your hand instead! OW!</span>")
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT,"plush_bite", /datum/mood_event/plush_bite)
	var/mob/living/carbon/human/H = user
	if(!H)
		return //Type safety.
	H.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
	addtimer(CALLBACK(H, /mob/living/carbon/human.proc/dropItemToGround, src, TRUE), 1)

/obj/item/toy/plush/plushling/New()
	var/initial_state = pick("plushie_lizard", "plushie_snake", "plushie_slime", "fox")
	icon_state = initial_state
	item_state = initial_state
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/item/toy/plush/plushling/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/toy/plush/plushling/process()
	if(world.time < next_absorb || world.time < next_check)
		return
	next_check = world.time + check_interval
	var/obj/item/toy/plush/target
	for(var/obj/item/toy/plush/possible_target in loc) //First, it tries to get anything in its same location, be it a tile or a backpack
		if(possible_target == src || istype(possible_target, /obj/item/toy/plush/plushling))
			continue
		target = possible_target
		break
	if(!target)
		if(!isturf(loc))
			return
		for(var/obj/item/toy/plush/P in oview(1, src)) //If that doesn't work, it hunts for plushies adjacent to its own tile
			if(istype(P, /obj/item/toy/plush/plushling)) //These do not hunt their own kind
				continue
			src.throw_at(P, 1, 2)
			visible_message("<span class='danger'>[src] leaps at [P]!</span>")
			break
		return
	if(istype(target, /obj/item/toy/plush/plushling)) //These do not consume their own.
		return
	next_absorb = world.time + absorb_cooldown
	plushie_absorb(target)

/obj/item/toy/plush/plushling/proc/plushie_absorb(obj/item/toy/plush/victim)
	if(!victim)
		return
	visible_message("<span class='warning'>[src] gruesomely mutilliates [victim], leaving nothing more than dust!</span>")
	if(victim.snowflake_id) //Snowflake code for snowflake plushies.
		set_snowflake_from_config(victim.snowflake_id)
		desc += " Wait, did it just move..?"
	else
		name = victim.name
		desc = victim.desc + " Wait, did it just move..?"
		icon_state = victim.icon_state
		item_state = victim.item_state
		squeak_override = victim.squeak_override
		attack_verb = victim.attack_verb
	new /obj/effect/decal/cleanable/ash(get_turf(victim))
	qdel(victim)

/obj/item/toy/plush/plushling/love(obj/item/toy/plush/Kisser, mob/living/user) //You shouldn't have come here, poor plush.
	if(!Kisser)
		return
	plushie_absorb(Kisser)
