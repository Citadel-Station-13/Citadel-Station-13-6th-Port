// Citadel-specific negative moodlets

/datum/mood_event/plushjack
	description = "<span class='warning'>I have butchered a plush recently.</span>\n"
	mood_change = -1
	timeout = 1200

/datum/mood_event/plush_nostuffing
	description = "<span class='warning'>A plush I tried to pet had no stuffing...</span>\n"
	mood_change = -1
	timeout = 1200

/datum/mood_event/emptypred
	description = "<span class='nicegreen'>I had to let someone out.</span>\n"
	mood_change = -2
	timeout = 600

/datum/mood_event/emptyprey
	description = "<span class='nicegreen'>It feels quite cold out here.</span>\n"
	mood_change = -2
	timeout = 600
/datum/mood_event/baddrink
	description = "<span class='warning'>That drink makes me feel depressed.</span>\n"
	mood_change = -10
	timeout = 200
/datum/mood_event/awfuldrink
	description = "<span class='warning'>That drink will kill me!.</span>\n"
	mood_change = -20
	timeout = 1200