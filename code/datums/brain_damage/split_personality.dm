#define OWNER 0
#define STRANGER 1

/datum/brain_trauma/severe/split_personality
	name = "Split Personality"
	desc = "Patient's brain is split into two personalities, which randomly switch control of the body."
	scan_desc = "complete lobe separation"
	gain_text = "<span class='warning'>You feel like your mind was split in two.</span>"
	lose_text = "<span class='notice'>You feel alone again.</span>"
	var/current_controller = OWNER
	var/initialized = FALSE //to prevent personalities deleting themselves while we wait for ghosts
	var/mob/living/split_personality/stranger_backseat //there's two so they can swap without overwriting
	var/mob/living/split_personality/owner_backseat

/datum/brain_trauma/severe/split_personality/on_gain()
	var/mob/living/M = owner
	if(M.stat == DEAD)	//No use assigning people to a corpse
		qdel(src)
		return
	..()
	make_backseats()
	get_ghost()
	RegisterSignal(M, COMSIG_MOB_DEATH, .proc/revert_to_normal)

/datum/brain_trauma/severe/split_personality/proc/make_backseats()
	stranger_backseat = new(owner, src)
	owner_backseat = new(owner, src)

/datum/brain_trauma/severe/split_personality/proc/get_ghost()
	set waitfor = FALSE
	var/list/mob/candidates = pollCandidatesForMob("Do you want to play as [owner]'s split personality?", ROLE_PAI, null, null, 75, stranger_backseat, POLL_IGNORE_SPLITPERSONALITY)
	if(LAZYLEN(candidates))
		var/mob/C = pick(candidates)
		C.transfer_ckey(stranger_backseat, FALSE)
		log_game("[key_name(stranger_backseat)] became [key_name(owner)]'s split personality.")
		message_admins("[ADMIN_LOOKUPFLW(stranger_backseat)] became [ADMIN_LOOKUPFLW(owner)]'s split personality.")
	else
		qdel(src)

/datum/brain_trauma/severe/split_personality/on_life()
	if(prob(3))
		switch_personalities()
	..()

/datum/brain_trauma/severe/split_personality/on_lose()
	if(current_controller != OWNER) //it would be funny to cure a guy only to be left with the other personality, but it seems too cruel
		switch_personalities(TRUE)
	QDEL_NULL(stranger_backseat)
	QDEL_NULL(owner_backseat)
	UnregisterSignal(owner, COMSIG_MOB_DEATH)
	..()

/datum/brain_trauma/severe/split_personality/proc/revert_to_normal()
	qdel(src)

/datum/brain_trauma/severe/split_personality/proc/switch_personalities(forced = FALSE)
	if(QDELETED(owner) || (owner.stat == DEAD && !forced) || QDELETED(stranger_backseat) || QDELETED(owner_backseat))
		return

	var/mob/living/split_personality/current_backseat
	var/mob/living/split_personality/free_backseat
	if(current_controller == OWNER)
		current_backseat = stranger_backseat
		free_backseat = owner_backseat
	else
		current_backseat = owner_backseat
		free_backseat = stranger_backseat

	log_game("[key_name(current_backseat)] assumed control of [key_name(owner)] due to [src]. (Original owner: [current_controller == OWNER ? owner.key : current_backseat.key])")
	to_chat(owner, "<span class='userdanger'>You feel your control being taken away... your other personality is in charge now!</span>")
	to_chat(current_backseat, "<span class='userdanger'>You manage to take control of your body!</span>")

	//Body to backseat

	var/h2b_id = owner.computer_id
	var/h2b_ip= owner.lastKnownIP
	owner.computer_id = null
	owner.lastKnownIP = null

	free_backseat.ckey = owner.ckey

	free_backseat.name = owner.name

	if(owner.mind)
		free_backseat.mind = owner.mind

	if(!free_backseat.computer_id)
		free_backseat.computer_id = h2b_id

	if(!free_backseat.lastKnownIP)
		free_backseat.lastKnownIP = h2b_ip

	//Backseat to body

	var/s2h_id = current_backseat.computer_id
	var/s2h_ip= current_backseat.lastKnownIP
	current_backseat.computer_id = null
	current_backseat.lastKnownIP = null

	owner.ckey = current_backseat.ckey
	owner.mind = current_backseat.mind

	if(!owner.computer_id)
		owner.computer_id = s2h_id

	if(!owner.lastKnownIP)
		owner.lastKnownIP = s2h_ip

	current_controller = !current_controller


/mob/living/split_personality
	name = "split personality"
	real_name = "unknown conscience"
	var/mob/living/carbon/body
	var/datum/brain_trauma/severe/split_personality/trauma

/mob/living/split_personality/Initialize(mapload, _trauma)
	if(iscarbon(loc))
		body = loc
		name = body.real_name
		real_name = body.real_name
		trauma = _trauma
	return ..()

/mob/living/split_personality/BiologicalLife(seconds, times_fired)
	if(!(. = ..()))
		return
	if(QDELETED(body))
		qdel(src) //in case trauma deletion doesn't already do it

	//if one of the two ghosts, the other one stays permanently
	if(!body.client && trauma.initialized)
		trauma.switch_personalities()
		qdel(trauma)

/mob/living/split_personality/Login()
	..()
	to_chat(src, "<span class='notice'>As a split personality, you cannot do anything but observe. However, you will eventually gain control of your body, switching places with the current personality.</span>")
	to_chat(src, "<span class='warning'><b>Do not commit suicide or put the body in a deadly position. Behave like you care about it as much as the owner.</b></span>")

/mob/living/split_personality/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, "<span class='warning'>You cannot speak, your other self is controlling your body!</span>")
	return FALSE

/mob/living/split_personality/emote(act, m_type = null, message = null, intentional = FALSE)
	return

///////////////BRAINWASHING////////////////////

/datum/brain_trauma/severe/split_personality/brainwashing
	name = "Split Personality"
	desc = "Patient's brain is split into two personalities, which randomly switch control of the body."
	scan_desc = "complete lobe separation"
	gain_text = ""
	lose_text = "<span class='notice'>You are free of your brainwashing.</span>"
	can_gain = FALSE
	var/codeword
	var/objective

/datum/brain_trauma/severe/split_personality/brainwashing/New(obj/item/organ/brain/B, _permanent, _codeword, _objective)
	..()
	if(_codeword)
		codeword = _codeword
	else
		codeword = pick(strings("ion_laws.json", "ionabstract")\
			| strings("ion_laws.json", "ionobjects")\
			| strings("ion_laws.json", "ionadjectives")\
			| strings("ion_laws.json", "ionthreats")\
			| strings("ion_laws.json", "ionfood")\
			| strings("ion_laws.json", "iondrinks"))

/datum/brain_trauma/severe/split_personality/brainwashing/on_gain()
	..()
	var/mob/living/split_personality/traitor/traitor_backseat = stranger_backseat
	traitor_backseat.codeword = codeword
	traitor_backseat.objective = objective

/datum/brain_trauma/severe/split_personality/brainwashing/make_backseats()
	stranger_backseat = new /mob/living/split_personality/traitor(owner, src, codeword, objective)
	owner_backseat = new(owner, src)

/datum/brain_trauma/severe/split_personality/brainwashing/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [owner]'s brainwashed mind?", null, null, null, 75, stranger_backseat)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		C.transfer_ckey(stranger_backseat, FALSE)
	else
		qdel(src)

/datum/brain_trauma/severe/split_personality/brainwashing/on_life()
	return //no random switching

/datum/brain_trauma/severe/split_personality/brainwashing/handle_hearing(datum/source, list/hearing_args)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == hearing_args[HEARING_SPEAKER])
		return
	var/message = hearing_args[HEARING_RAW_MESSAGE]
	if(findtext(message, codeword))
		hearing_args[HEARING_RAW_MESSAGE] = replacetext(message, codeword, "<span class='warning'>[codeword]</span>")
		addtimer(CALLBACK(src, /datum/brain_trauma/severe/split_personality.proc/switch_personalities), 10)

/datum/brain_trauma/severe/split_personality/brainwashing/handle_speech(datum/source, list/speech_args)
	if(findtext(speech_args[SPEECH_MESSAGE], codeword))
		speech_args[SPEECH_MESSAGE] = "" //oh hey did you want to tell people about the secret word to bring you back?

/mob/living/split_personality/traitor
	name = "split personality"
	real_name = "unknown conscience"
	var/objective
	var/codeword

/mob/living/split_personality/traitor/Login()
	..()
	to_chat(src, "<span class='notice'>As a brainwashed personality, you cannot do anything yet but observe. However, you may gain control of your body if you hear the special codeword, switching places with the current personality.</span>")
	to_chat(src, "<span class='notice'>Your activation codeword is: <b>[codeword]</b></span>")
	if(objective)
		to_chat(src, "<span class='notice'>Your master left you an objective: <b>[objective]</b>. Follow it at all costs when in control.</span>")

//////////////////////////EPITAPH//////////////////////////

/datum/brain_trauma/severe/split_personality/epitaph
	name = "Split Personality"
	desc = "Patient's brain shows a strangely unique amalgamation between the lobes, yet a clear fracture shows. You doubt this will be fixable at all."
	scan_desc = "lobe fracture"
	gain_text = "<span class='warning'>You feel like your soul and mind is split in two. One to reign them all... one to deceive them all. Who are you?</span>"
	var/nextswitch = 0
	var/datum/action/cooldown/epitaphswitch/givebutton
	var/epitaphname
	var/datum/action/epitaphCommunicate/communicateOne
	var/datum/action/epitaphCommunicate/communicateTwo
	var/datum/action/cooldown/epitaphHandsummon/handAction
	// Outfit Vars
	var/list/original_items = list()

	// Identity Vars
	var/prev_skin_tone
	var/prev_hair_style
	var/prev_facial_hair_style
	var/prev_hair_color
	var/prev_facial_hair_color
	var/prev_underwear
	var/prev_undie_color
	var/prev_undershirt
	var/prev_shirt_color
	var/prev_socks
	var/prev_socks_color
	var/prev_disfigured
	var/list/prev_features	// For lizards and such

/datum/brain_trauma/severe/split_personality/epitaph/on_gain()
	. = ..()
	if (QDELETED(src))
		return
	epitaphname = SelectName()
	nextswitch = world.time + 10 MINUTES

/datum/brain_trauma/severe/split_personality/epitaph/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [owner]'s Epitaph personality?", ROLE_PAI, null, null, 300, stranger_backseat, POLL_IGNORE_SPLITPERSONALITY)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		C.transfer_ckey(stranger_backseat, FALSE)
		log_game("[key_name(stranger_backseat)] became [key_name(owner)]'s Epitaph personality.")
		message_admins("[ADMIN_LOOKUPFLW(stranger_backseat)] became [ADMIN_LOOKUPFLW(owner)]'s Epitaph personality.")
		givebutton = new /datum/action/cooldown/epitaphswitch
		givebutton.epitaphparent = src
		givebutton.Grant(owner)
		communicateOne = new /datum/action/epitaphCommunicate
		communicateTwo = new /datum/action/epitaphCommunicate
		communicateOne.epitaphparent = src
		communicateTwo.epitaphparent = src
		communicateOne.Grant(owner_backseat)
		communicateTwo.Grant(stranger_backseat)
		handAction = new /datum/action/cooldown/epitaphHandsummon
		handAction.Grant(owner)

	else
		var/datum/action/cooldown/epitaphreoffer = new /datum/action/cooldown/epitaphreoffering
		epitaphreoffer.Grant(owner)
		qdel(src)

/datum/brain_trauma/severe/split_personality/epitaph/on_life() //overrides parent proc
	if(owner.stat == DEAD)
		if(current_controller != OWNER)
			switch_personalities()
	else if(world.time > nextswitch)
		switch_personalities()

/datum/brain_trauma/severe/split_personality/epitaph/on_lose()
	if(givebutton)
		givebutton.Remove()
	if(communicateOne)
		communicateOne.Remove()
	if(communicateTwo)
		communicateTwo.Remove()
	if(handAction)
		handAction.Remove()
	..()

/datum/brain_trauma/severe/split_personality/epitaph/switch_personalities()
	. = ..()
	nextswitch = world.time + 15 MINUTES
	if(current_controller != OWNER)
		ADD_TRAIT(owner, TRAIT_PUGILIST, EPITAPH_TRAIT)
		Epitaph_Disguise_FaceName()
	else
		REMOVE_TRAIT(owner, TRAIT_PUGILIST, EPITAPH_TRAIT)
		DeactivatePower()

//EPITAPH reoffering aka 'I wasted 17 TC for nothing admins hlep' fix
/datum/action/cooldown/epitaphreoffering
	name = "Reoffer"
	desc = "Attempt to gain power once more."
	button_icon = 'icons/mob/actions/epitaph.dmi'
	button_icon_state = "epitaphswitch"
	cooldown_time = 3 MINUTES

/datum/action/cooldown/epitaphreoffering/New(Target)
	. = ..()
	StartCooldown()

/datum/action/cooldown/epitaphreoffering/Trigger()
	if(!..())
		return
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	C.gain_trauma(/datum/brain_trauma/severe/split_personality/epitaph, TRAUMA_RESILIENCE_ABSOLUTE)
	qdel(src)

//EPITAPH BODYCHANGES aka copypasta galore
/datum/action/cooldown/epitaphswitch
	name = "Epitaph"
	desc = "Relent your mind inwards to allow for your other self to take the reins."
	button_icon = 'icons/mob/actions/epitaph.dmi'
	button_icon_state = "epitaphswitch"
	cooldown_time = 3 MINUTES
	var/datum/brain_trauma/severe/split_personality/epitaph/epitaphparent

/datum/action/cooldown/epitaphswitch/Trigger()
	. = ..()
	if(!.)
		return FALSE
	if(owner != epitaphparent.owner)
		return FALSE
	epitaphparent.switch_personalities()
	StartCooldown()

/datum/brain_trauma/severe/split_personality/epitaph/proc/Epitaph_Disguise_FaceName()

	// Change Name/Voice
	var/mob/living/carbon/human/H = owner
	H.name_override = epitaphname
	H.name = H.name_override
	H.SetSpecialVoice(H.name_override)
	to_chat(owner, "<span class='warning'>Your mind dives inwards. Your other self is now in control.</span>")

	// Store Prev Appearance
	prev_skin_tone = H.skin_tone
	prev_hair_style = H.hair_style
	prev_facial_hair_style = H.facial_hair_style
	prev_hair_color = H.hair_color
	prev_facial_hair_color = H.facial_hair_color
	prev_underwear = H.underwear
	prev_undie_color = H.undie_color
	prev_undershirt = H.undershirt
	prev_shirt_color = H.shirt_color
	prev_socks = H.socks
	prev_socks_color = H.socks_color
	//prev_eye_color
	prev_disfigured = HAS_TRAIT(H, TRAIT_DISFIGURED) // I was disfigured! //prev_disabilities = H.disabilities
	prev_features = H.dna.features

	// Change Appearance
	H.skin_tone = random_skin_tone()
	H.hair_style = random_hair_style(H.gender)
	H.facial_hair_style = pick(random_facial_hair_style(H.gender),"Shaved")
	H.hair_color = "ff0deb"
	H.facial_hair_color = "ff82f5"
	H.underwear = random_underwear(H.gender)
	H.undershirt = random_undershirt(H.gender)
	H.socks = random_socks(H.gender)

	// Apply Appearance
	H.update_body() // Outfit and underware, also body.
	//H.update_mutant_bodyparts() // Lizard tails etc
	H.update_hair()
	H.update_body_parts()

/datum/brain_trauma/severe/split_personality/epitaph/proc/DeactivatePower(mob/living/user = owner)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user

		// Revert Identity
		H.UnsetSpecialVoice()
		H.name_override = null
		H.name = H.real_name

		// Revert Appearance
		H.skin_tone = prev_skin_tone
		H.hair_style = prev_hair_style
		H.facial_hair_style = prev_facial_hair_style
		H.hair_color = prev_hair_color
		H.facial_hair_color = prev_facial_hair_color
		H.underwear = prev_underwear
		H.undie_color = prev_undie_color
		H.undershirt = prev_undershirt
		H.shirt_color = prev_shirt_color
		H.socks = prev_socks
		H.socks_color = prev_socks_color
		H.dna.features = prev_features
		// Apply Appearance
		H.update_body() // Outfit and underware, also body.
		H.update_hair()
		H.update_body_parts()	// Body itself, maybe skin color?

/datum/brain_trauma/severe/split_personality/epitaph/proc/SelectName()
	// Names
	if (owner.gender == MALE)
		. = pick("Desmond","Rudolph","Dracul","Vlad","Pyotr","Gregor","Cristian","Christoff","Marcu","Andrei","Constantin","Gheorghe","Grigore","Ilie","Iacob","Luca","Mihail","Pavel","Vasile","Octavian","Sorin", \
						"Sveyn","Aurel","Alexe","Iustin","Theodor","Dimitrie","Octav","Damien","Magnus","Caine","Abel", // Romanian/Ancient
						"Lucius","Gaius","Otho","Balbinus","Arcadius","Romanos","Alexios","Vitellius",  // Latin
						"Melanthus","Teuthras","Orchamus","Amyntor","Axion",  // Greek
						"Thoth","Thutmose","Osorkon,","Nofret","Minmotu","Khafra", // Egyptian
						"Dio","Doppio","Diavolo")

	else
		. = pick("Islana","Tyrra","Greganna","Pytra","Hilda","Andra","Crina","Viorela","Viorica","Anemona","Camelia","Narcisa","Sorina","Alessia","Sophia","Gladda","Arcana","Morgan","Lasarra","Ioana","Elena", \
						"Alina","Rodica","Teodora","Denisa","Mihaela","Svetla","Stefania","Diyana","Kelssa","Lilith", // Romanian/Ancient
						"Alexia","Athanasia","Callista","Karena","Nephele","Scylla","Ursa",  // Latin
						"Alcestis","Damaris","Elisavet","Khthonia","Teodora",  // Greek
						"Nefret","Ankhesenpep") // Egyptian

//COMMUNICATION

/datum/action/epitaphCommunicate
	name = "Communicate"
	desc = "Use nearby objects to commune with your other self."
	icon_icon = 'icons/mob/actions/epitaph.dmi'
	button_icon_state = "epitaphcommune"
	var/datum/brain_trauma/severe/split_personality/epitaph/epitaphparent

/datum/action/epitaphCommunicate/Trigger()
	var/obj/item/epitaphOuija
	for(var/obj/item/I in oview(3, epitaphparent.owner))
		if(!istype(I.loc, /turf))
			continue
		epitaphOuija = I
		break
	if(!epitaphOuija)
		to_chat(owner, "<span class='warning'>There's no object nearby to commune through.</span>")
		return
	var/input = stripped_input(owner, "Please enter a message to tell your other personality through a nearby object.", "Epitaph", "")
	if(!input)
		return
	to_chat(epitaphparent.owner, "<span class='hear'>[epitaphOuija] communes \"[input]\"</span>")

//ZE HANDO ACTION

/datum/action/cooldown/epitaphHandsummon
	name = "Epitaph's Hand"
	desc = "Skip past time to avoid your attacker's movements via parries."
	icon_icon = 'icons/mob/actions/epitaph.dmi'
	button_icon_state = "epitaphhand"
	cooldown_time = 30 SECONDS
	var/amToggle = FALSE
	var/obj/item/melee/epitaphhand/EH

/datum/action/cooldown/epitaphHandsummon/Trigger()
	. = ..()
	if(!.)
		return
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	if(!amToggle)
		EH = new /obj/item/melee/epitaphhand(get_turf(C))
		if(!C.put_in_hands(EH))
			qdel(EH)
		else
			amToggle = !amToggle
	else
		if(EH)
			C.dropItemToGround(EH, TRUE)
		amToggle = !amToggle
		StartCooldown()

#undef OWNER
#undef STRANGER
