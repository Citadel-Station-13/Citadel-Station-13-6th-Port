/**
  * # Ninja Mask
  *
  * Space ninja's mask.  Makes you sound like a real anime girl.  Barely able to be considered a real upside.
  *
  * A mask which only spawns as a part of space ninja's starting kit.  Functions as a gas mask.
  *
  */
/obj/item/clothing/mask/gas/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	strip_delay = 120
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	modifies_speech = TRUE

/obj/item/clothing/mask/gas/space_ninja/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_NODROP, NINJA_SUIT_TRAIT)

/obj/item/clothing/mask/gas/space_ninja/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		var/list/temp_message = splittext(message, " ")
		var/list/pick_list = list()
		for(var/i in 1 to temp_message.len)
			pick_list += i
		for(var/i in 1 to abs(temp_message.len/3))
			var/H = pick(pick_list)
			if(findtext(temp_message[H], "*") || findtext(temp_message[H], ";") || findtext(temp_message[H], ":"))
				continue
			temp_message[H] = ninjaspeak(temp_message[H])
			pick_list -= H
		message = temp_message.Join(" ")

		//The Alternate speech mod is now the main one.
		message = replacetext(message, "l", "r")
		message = replacetext(message, "rr", "ru")
		message = replacetext(message, "v", "b")
		message = replacetext(message, "f", "hu")
		message = replacetext(message, "'t", "")
		message = replacetext(message, "t ", "to ")
		message = replacetext(message, " I ", " ai ")
		message = replacetext(message, "th", "z")
		message = replacetext(message, "is", "izu")
		message = replacetext(message, "ziz", "zis")
		message = replacetext(message, "se", "su")
		message = replacetext(message, "br", "bur")
		message = replacetext(message, "ry", "ri")
		message = replacetext(message, "you", "yuu")
		message = replacetext(message, "ck", "cku")
		message = replacetext(message, "eu", "uu")
		message = replacetext(message, "ow", "au")
		message = replacetext(message, "are", "aa")
		message = replacetext(message, "ay", "ayu")
		message = replacetext(message, "ea", "ii")
		message = replacetext(message, "ch", "chi")
		message = replacetext(message, "than", "sen")
		message = replacetext(message, ".", "")
		message = lowertext(message)
		speech_args[SPEECH_MESSAGE] = message
