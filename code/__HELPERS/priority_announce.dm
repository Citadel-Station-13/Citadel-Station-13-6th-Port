/proc/priority_announce(text, title = "", sound = "attention", type , sender_override)
	if(!text)
		return

	var/announcement

	if(type == "Priority")
		announcement += "<h1 class='alert'>Priority Announcement</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
	else if(type == "Captain")
		announcement += "<h1 class='alert'>Captain Announces</h1>"
		GLOB.news_network.SubmitArticle(html_encode(text), "Captain's Announcement", "Station Announcements", null)

	else
		if(!sender_override)
			announcement += "<h1 class='alert'>[command_name()] Update</h1>"
		else
			announcement += "<h1 class='alert'>[sender_override]</h1>"
		if (title && length(title) > 0)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"

		if(!sender_override)
			if(title == "")
				GLOB.news_network.SubmitArticle(text, "Central Command Update", "Station Announcements", null)
			else
				GLOB.news_network.SubmitArticle(title + "<br><br>" + text, "Central Command", "Station Announcements", null)

	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	announcement += "<br>"

	var/s = sound(get_announcer_sound(sound))
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, announcement)
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				SEND_SOUND(M, s)

/proc/get_announcer_sound(soundid)
	if(isfile(soundid))
		return soundid
	else if(!istext(soundid))
		CRASH("Invalid type passed to get_announcer_sound()")
	switch(GLOB.announcertype) //These are all individually hardcoded to allow the announcer sounds to be included in the rsc, reducing lag from sending resources midgame.
		if("classic")
			switch(soundid)
				if("aimalf")
					. = 'sound/announcer/classic/aimalf.ogg'
				if("aliens")
					. = 'sound/announcer/classic/aliens.ogg'
				if("animes")
					. = 'sound/announcer/classic/animes.ogg'
				if("attention")
					. = 'sound/announcer/classic/attention.ogg'
				if("commandreport")
					. = 'sound/announcer/classic/commandreport.ogg'
				if("granomalies")
					. = 'sound/announcer/classic/granomalies.ogg'
				if("intercept")
					. = 'sound/announcer/classic/intercept.ogg'
				if("ionstorm")
					. = 'sound/announcer/classic/ionstorm.ogg'
				if("meteors")
					. = 'sound/announcer/classic/meteors.ogg'
				if("newAI")
					. = 'sound/announcer/classic/newAI.ogg'
				if("outbreak5")
					. = 'sound/announcer/classic/outbreak5.ogg'
				if("outbreak7")
					. = 'sound/announcer/classic/outbreak7.ogg'
				if("poweroff")
					. = 'sound/announcer/classic/poweroff.ogg'
				if("poweron")
					. = 'sound/announcer/classic/poweron.ogg'
				if("radiation")
					. = 'sound/announcer/classic/radiation.ogg'
				if("shuttlecalled")
					. = 'sound/announcer/classic/shuttlecalled.ogg'
				if("shuttledock")
					. = 'sound/announcer/classic/shuttledock.ogg'
				if("shuttlerecalled")
					. = 'sound/announcer/classic/shuttlerecalled.ogg'
				if("spanomalies")
					. = 'sound/announcer/classic/spanomalies.ogg'
				if("welcome")
					. = 'sound/announcer/classic/welcome.ogg'
		if("medibot")
			switch(soundid)
				if("aimalf")
					. = 'sound/announcer/classic/aimalf.ogg'
				if("aliens")
					. = 'sound/announcer/medibot/aliens.ogg'
				if("animes")
					. = 'sound/announcer/medibot/animes.ogg'
				if("attention")
					. = 'sound/announcer/medibot/attention.ogg'
				if("commandreport")
					. = 'sound/announcer/medibot/commandreport.ogg'
				if("granomalies")
					. = 'sound/announcer/medibot/granomalies.ogg'
				if("intercept")
					. = 'sound/announcer/medibot/intercept.ogg'
				if("ionstorm")
					. = 'sound/announcer/medibot/ionstorm.ogg'
				if("meteors")
					. = 'sound/announcer/medibot/meteors.ogg'
				if("newAI")
					. = 'sound/announcer/medibot/newAI.ogg'
				if("outbreak5")
					. = 'sound/announcer/medibot/outbreak5.ogg'
				if("outbreak7")
					. = 'sound/announcer/medibot/outbreak7.ogg'
				if("poweroff")
					. = 'sound/announcer/medibot/poweroff.ogg'
				if("poweron")
					. = 'sound/announcer/medibot/poweron.ogg'
				if("radiation")
					. = 'sound/announcer/medibot/radiation.ogg'
				if("shuttlecalled")
					. = 'sound/announcer/medibot/shuttlecalled.ogg'
				if("shuttledock")
					. = 'sound/announcer/medibot/shuttledocked.ogg'
				if("shuttlerecalled")
					. = 'sound/announcer/medibot/shuttlerecalled.ogg'
				if("spanomalies")
					. = 'sound/announcer/medibot/spanomalies.ogg'
				if("welcome")
					. = 'sound/announcer/medibot/welcome.ogg'

/proc/print_command_report(text = "", title = null, announce=TRUE)
	if(!title)
		title = "Classified [command_name()] Update"

	if(announce)
		priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", "commandreport")

	var/datum/comm_message/M  = new
	M.title = title
	M.content =  text

	SScommunications.send_message(M)

/proc/minor_announce(message, title = "Attention:", alert, html_encode = TRUE)
	if(!message)
		return

	if (html_encode)
		title = html_encode(title)
		message = html_encode(message)

	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, "<span class='minorannounce'><font color = red>[title]</font color><BR>[message]</span><BR>")
			if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
				if(alert)
					SEND_SOUND(M, sound('sound/misc/notice1.ogg'))
				else
					SEND_SOUND(M, sound('sound/misc/notice2.ogg'))
