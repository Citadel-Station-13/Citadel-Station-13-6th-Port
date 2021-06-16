/datum/accent

/datum/accent/proc/modify_speech(list/speech_args, datum/source, mob/living/carbon/owner) //transforms the message in some way
	return speech_args

/datum/accent/lizard/modify_speech(list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/static/regex/lizard_hiss = new("s+", "g")
	var/static/regex/lizard_hiSS = new("S+", "g")
	if(message[1] != "*")
		message = lizard_hiss.Replace(message, "sss")
		message = lizard_hiSS.Replace(message, "SSS")
	speech_args[SPEECH_MESSAGE] = message
	return speech_args

/datum/accent/fly/modify_speech(list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
	speech_args[SPEECH_MESSAGE] = message
	return speech_args

/datum/accent/abductor/modify_speech(list/speech_args, datum/source)
	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/user = source
	var/obj/item/organ/tongue/abductor/A = user.getorgan(/obj/item/organ/tongue/abductor)
	var/rendered = "<span class='abductor'><b>[user.name]:</b> [message]</span>"
	user.log_talk(message, LOG_SAY, tag="abductor")
	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		var/obj/item/organ/tongue/abductor/T = C.getorgan(/obj/item/organ/tongue/abductor)
		if(!T || T.mothership != A.mothership)
			continue
		to_chat(C, rendered)
	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		to_chat(M, "[link] [rendered]")
	speech_args[SPEECH_MESSAGE] = ""
	return speech_args

/datum/accent/zombie/modify_speech(list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/list/message_list = splittext(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, -3) == "..."))//3 == length("...")
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	speech_args[SPEECH_MESSAGE] = jointext(message_list, " ")
	return speech_args

/datum/accent/alien/modify_speech(list/speech_args, datum/source)
	playsound(source, "hiss", 25, 1, 1)
	return speech_args

/datum/accent/fluffy/modify_speech(list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = replacetext(message, "ne", "nye")
		message = replacetext(message, "nu", "nyu")
		message = replacetext(message, "na", "nya")
		message = replacetext(message, "no", "nyo")
		message = replacetext(message, "ove", "uv")
		message = replacetext(message, "l", "w")
		message = replacetext(message, "r", "w")
	speech_args[SPEECH_MESSAGE] = lowertext(message)
	return speech_args

/datum/accent/span
	var/span_flag

/datum/accent/span/modify_speech(list/speech_args)
	speech_args[SPEECH_SPANS] |= span_flag
	return speech_args

//bone tongues either have the sans accent or the papyrus accent
/datum/accent/span/sans
	span_flag = SPAN_SANS

/datum/accent/span/papyrus
	span_flag = SPAN_PAPYRUS

/datum/accent/span/robot
	span_flag = SPAN_ROBOT

/datum/accent/dullahan/modify_speech(list/speech_args, datum/source, mob/living/carbon/owner)
	if(owner)
		if(isdullahan(owner))
			var/datum/component/dullahan/D = owner.GetComponent(/datum/component/dullahan)
			if(isobj(D.relay.loc))
				var/obj/O = D.relay.loc
				O.say(speech_args[SPEECH_MESSAGE])
				if(D.stored_head)
					var/worn_ear_item = D.stored_head.stored_items[3]
					if(istype(worn_ear_item, /obj/item/radio))
						owner.radio(speech_args[SPEECH_MESSAGE], owner.get_message_mode(speech_args[SPEECH_MESSAGE]), speech_args[SPEECH_SPANS])

	speech_args[SPEECH_MESSAGE] = ""
	return speech_args
