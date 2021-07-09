/datum/fantasy_affix/cosmetic_prefixes
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD | AFFIX_EVIL

	var/list/goodPrefixes
	var/list/badPrefixes

/datum/fantasy_affix/cosmetic_prefixes/New()
	goodPrefixes = list(
		"greater",
		"major",
		"blessed",
		"superior",
		"empowered",
		"honed",
		"true",
		"glorious",
		"robust",
		)
	badPrefixes = list(
		"lesser",
		"minor",
		"blighted",
		"inferior",
		"enfeebled",
		"rusted",
		"unsteady",
		"tragic",
		"gimped",
		"cursed",
		)

	weight = (length(goodPrefixes) + length(badPrefixes)) * 10

/datum/fantasy_affix/cosmetic_prefixes/apply(datum/component/fantasy/comp, newName)
	if(comp.quality > 0 || (comp.quality == 0 && prob(50)))
		return "[pick(goodPrefixes)] [newName]"
	else
		return "[pick(badPrefixes)] [newName]"

/datum/fantasy_affix/tactical
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD
	weight = 1 // Very powerful, no one should have such power

/datum/fantasy_affix/tactical/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	var/list/dat = list(/datum/element/tactical)
	master._AddElement(dat)
	comp.appliedElements += list(dat)
	return "tactical [newName]"

/datum/fantasy_affix/pyromantic
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/pyromantic/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/igniter, clamp(comp.quality, 1, 10))
	return "pyromantic [newName]"

/datum/fantasy_affix/vampiric
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD
	weight = 5

/datum/fantasy_affix/vampiric/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/lifesteal, comp.quality)
	return "vampiric [newName]"

/datum/fantasy_affix/lucky
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD
	weight = 3

#define LUCKY_AFFIX "lucky affix"

/datum/fantasy_affix/lucky/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/luck)
	SEND_SIGNAL(master, COMSIG_ADD_LUCK_SOURCE, LUCKY_AFFIX, comp.quality)
	return "lucky [newName]"

/datum/fantasy_affix/lucky/remove(datum/component/fantasy/comp)
	SEND_SIGNAL(comp.parent, COMSIG_CLEAR_LUCK_SOURCE, LUCKY_AFFIX)

#undef LUCKY_AFFIX

#define UNLUCKY_AFFIX "unlucky affix"

/datum/fantasy_affix/lucky
	placement = AFFIX_PREFIX
	alignment = AFFIX_BAD
	weight = 3

/datum/fantasy_affix/unlucky/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/luck)
	SEND_SIGNAL(master, COMSIG_ADD_LUCK_SOURCE, UNLUCKY_AFFIX, comp.quality)
	return "unlucky [newName]"

/datum/fantasy_affix/unlucky/remove(datum/component/fantasy/comp)
	SEND_SIGNAL(comp.parent, COMSIG_CLEAR_LUCK_SOURCE, UNLUCKY_AFFIX)

#undef UNLUCKY_AFFIX
