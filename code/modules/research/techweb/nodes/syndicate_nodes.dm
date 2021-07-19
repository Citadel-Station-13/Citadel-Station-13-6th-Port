
/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list("adv_engi", "adv_weaponry", "explosive_weapons")
	design_ids = list("decloner", "borg_syndicate_module", "suppressor", "largecrossbow", "donksofttoyvendor", "donksoft_refill", "syndiesleeper", "ci-thermals")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	hidden = TRUE

/datum/techweb_node/syndicate_basic/New()		//Crappy way of making syndicate gear decon supported until there's another way.
	. = ..()
	boost_item_paths = list()
	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/UI = new path
		if(!UI.item || !UI.illegal_tech)
			continue
		boost_item_paths |= UI.item	//allows deconning to unlock.

/datum/techweb_node/advanced_illegal_ballistics
	id = "advanced_illegal_ballistics"
	display_name = "Advanced Non-Standard Ballistics"
	description = "Ballistic ammunition for non-standard firearms. Usually the ones you don't have nor want to be involved with."
	design_ids = list("10mm","10mmap","10mminc","10mmhp","sl357","sl357ap","pistolm9mm","m45","bolt_clip","m10apbox","m10firebox","m10hpbox")
	prereq_ids = list("ballistic_weapons","syndicate_basic","explosive_weapons")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 25000) //This gives sec lethal mags/clips for guns from traitors, space, or anything in between.

//Helpers for debugging/balancing the techweb in its entirety!

/proc/total_techweb_points()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.research_points

/proc/total_techweb_points_printout()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.printout_points()
