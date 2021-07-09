/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/cry/run_emote(mob/user, params)
	. = ..()
	if(. && isipcperson(user))
		do_fake_sparks(5,FALSE,user)

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "give daps to %t."
	restraint_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/mawp
	key = "mawp"
	key_third_person = "mawps"
	message = "mawps annoyingly."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/mawp/run_emote(mob/living/user, params)
	. = ..()
	if(.)
		if(ishuman(user) && user.prob_good(10))
			user.adjustEarDamage(-5, -5)

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	restraint_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	restraint_check = TRUE

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "wags their tail."

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.dna || !H.dna.species || !H.dna.species.can_wag_tail(H))
		return
	if(!H.dna.species.is_wagging_tail())
		H.dna.species.start_wagging_tail(H)
	else
		H.dna.species.stop_wagging_tail(H)

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check = TRUE)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	return H.dna && H.dna.species && H.dna.species.can_wag_tail(user)

/datum/emote/living/carbon/human/wag/select_message_type(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!H.dna || !H.dna.species)
		return
	if(H.dna.species.is_wagging_tail())
		. = null

/datum/emote/living/carbon/human/wing
	key = "wing"
	key_third_person = "wings"
	message = "their wings."

/datum/emote/living/carbon/human/wing/run_emote(mob/user, params)
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = user
		if(findtext(select_message_type(user), "open"))
			H.OpenWings()
		else
			H.CloseWings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(H.dna.species.mutant_bodyparts["wings"])
		. = "opens " + message
	else
		. = "closes " + message

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user, status_check = TRUE)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.dna && H.dna.species && (H.dna.features["wings"] != "None"))
		return TRUE

/mob/living/carbon/human/proc/OpenWings()
	if(!dna || !dna.species)
		return
	if(dna.species.mutant_bodyparts["wings"])
		dna.species.mutant_bodyparts["wingsopen"] = dna.species.mutant_bodyparts["wings"]
		dna.species.mutant_bodyparts -= "wings"
	update_body()

/mob/living/carbon/human/proc/CloseWings()
	if(!dna || !dna.species)
		return
	if(dna.species.mutant_bodyparts["wingsopen"])
		dna.species.mutant_bodyparts["wings"] = dna.species.mutant_bodyparts["wingsopen"]
		dna.species.mutant_bodyparts -= "wingsopen"
	update_body()
	if(isturf(loc))
		var/turf/T = loc
		T.Entered(src)

/datum/emote/sound/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	emote_type = EMOTE_AUDIBLE

/datum/emote/sound/human/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes."
	message_param = "buzzes at %t."
	sound = 'sound/machines/buzz-sigh.ogg'

/datum/emote/sound/human/buzz2
	key = "buzz2"
	message = "buzzes twice."
	sound = 'sound/machines/buzz-two.ogg'

/datum/emote/sound/human/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings."
	message_param = "pings at %t."
	sound = 'sound/machines/ping.ogg'

/datum/emote/sound/human/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes."
	sound = 'sound/machines/chime.ogg'

/datum/emote/sound/human/squeak
	key = "squeak"
	message = "squeaks."
	sound = 'sound/effects/mousesqueek.ogg'

//rock paper scissors emote handling
/mob/living/carbon/human/proc/beginRockPaperScissors(var/chosen_move)
	GLOB.rockpaperscissors_players[src] = list(chosen_move, ROCKPAPERSCISSORS_NOT_DECIDED)
	do_after_advanced(src, ROCKPAPERSCISSORS_TIME_LIMIT, src, DO_AFTER_REQUIRES_USER_ON_TURF|DO_AFTER_NO_COEFFICIENT|DO_AFTER_NO_PROGRESSBAR|DO_AFTER_DISALLOW_MOVING_ABSOLUTE_USER, CALLBACK(src, .proc/rockpaperscissors_tick))
	var/new_entry = GLOB.rockpaperscissors_players[src]
	if(new_entry[2] == ROCKPAPERSCISSORS_NOT_DECIDED)
		to_chat(src, "You put your hand back down.")
	GLOB.rockpaperscissors_players -= src

/mob/living/carbon/human/proc/rockpaperscissors_tick() //called every cycle of the progress bar for rock paper scissors while waiting for an opponent
	var/mob/living/carbon/human/opponent
	for(var/mob/living/carbon/human/potential_opponent in (GLOB.rockpaperscissors_players - src)) //dont play against yourself
		if(get_dist(src, potential_opponent) <= ROCKPAPERSCISSORS_RANGE)
			opponent = potential_opponent
			break
	if(opponent)
		//we found an opponent before they found us
		var/move_to_number = list("rock" = 0, "paper" = 1, "scissors" = 2)
		var/our_move = move_to_number[GLOB.rockpaperscissors_players[src][1]]
		var/their_move = move_to_number[GLOB.rockpaperscissors_players[opponent][1]]
		var/result_us = ROCKPAPERSCISSORS_WIN
		var/result_them = ROCKPAPERSCISSORS_LOSE
		if(our_move == their_move)
			result_us = ROCKPAPERSCISSORS_TIE
			result_them = ROCKPAPERSCISSORS_TIE
		else
			if(((our_move + 1) % 3) == their_move)
				result_us = ROCKPAPERSCISSORS_LOSE
				result_them = ROCKPAPERSCISSORS_WIN
		//we decided our results so set them in the list
		GLOB.rockpaperscissors_players[src][2] = result_us
		GLOB.rockpaperscissors_players[opponent][2] = result_them

		//show what happened
		src.visible_message("<b>[src]</b> makes [GLOB.rockpaperscissors_players[src][1]] with their hand!")
		opponent.visible_message("<b>[opponent]</b> makes [GLOB.rockpaperscissors_players[opponent][1]] with their hands!")
		switch(result_us)
			if(ROCKPAPERSCISSORS_TIE)
				src.visible_message("It was a tie!")
			if(ROCKPAPERSCISSORS_WIN)
				src.visible_message("<b>[src]</b> wins!")
			if(ROCKPAPERSCISSORS_LOSE)
				src.visible_message("<b>[opponent]</b> wins!")

		//make the progress bar end so that each player can handle the result
		return DO_AFTER_STOP

	//no opponent was found, so keep searching
	return DO_AFTER_PROCEED

//the actual emotes
/datum/emote/living/carbon/human/rockpaperscissors
	message = "is attempting to play rock paper scissors!"

/datum/emote/living/carbon/human/rockpaperscissors/rock
	key = "rock"

/datum/emote/living/carbon/human/rockpaperscissors/paper
	key = "paper"

/datum/emote/living/carbon/human/rockpaperscissors/scissors
	key = "scissors"

/datum/emote/living/carbon/human/rockpaperscissors/run_emote(mob/living/carbon/human/user, params)
	if(!(user in GLOB.rockpaperscissors_players)) //no using the emote again while already playing!
		. = ..()
		user.beginRockPaperScissors(key)
