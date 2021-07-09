/datum/component/luck
	var/cached = 0
	var/list/sources = list()

/datum/component/luck/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ADD_LUCK_SOURCE, .proc/add_source)
	RegisterSignal(parent, COMSIG_CLEAR_LUCK_SOURCE, .proc/clear_source)
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/add_parent_luck)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/clear_parent_luck)

/datum/component/luck/proc/add_source(var/name, var/amt)
	sources[name] = amt // we just override if there was one before
	cached = 0
	for(var/S in sources)
		cached += sources[S]

/datum/component/luck/proc/clear_source(var/name)
	sources -= name
	cached = 0
	for(var/S in sources)
		cached += sources[S]

/datum/component/luck/proc/add_parent_luck(mob/equipper)
	equipper.AddComponent(/datum/component/luck)
	SEND_SIGNAL(equipper, COMSIG_ADD_LUCK_SOURCE, "[parent]", cached)

/datum/component/luck/proc/clear_parent_luck(mob/user)
	SEND_SIGNAL(user, COMSIG_CLEAR_LUCK_SOURCE, "[parent]")


/atom/proc/get_luck()
	. = 0
	var/datum/component/luck/luck = GetComponent(/datum/component/luck)
	if(luck)
		. = luck.cached

/atom/proc/prob_good(probability, atom/enemy)
	var/luck = get_luck()
	if(enemy)
		luck -= enemy.get_luck()
	. = prob(probability)
	while(!. && luck > 0)
		. = . || prob(probability/(luck+1))
		luck--
	while(. && luck < 0)
		. = . && prob(1-(probability/(luck+1)))
		luck++

/atom/proc/prob_if_lucky(probability)
	if(get_luck())
		prob_good(probability)

/atom/proc/prob_bad(probability, atom/enemy)
	var/luck = get_luck()
	if(enemy)
		luck -= enemy.get_luck()
	. = prob(probability)
	while(. && luck > 0)
		. = . && prob(1-(probability/(luck+1)))
		luck--
	while(!. && luck < 0)
		. = . || prob(probability/(luck+1))
		luck++

/atom/proc/rand_good(min, max, atom/enemy)
	var/luck = get_luck()
	if(enemy)
		luck -= enemy.get_luck()
	. = rand(min, max)
	var/avg = (max+min)/2
	while(luck != 0)
		if(luck < 0)
			if(prob(50))
				. = . + rand(min, avg) / 2
			luck++
		else
			if(prob(50))
				. = . + rand(avg, max) / 2
			luck--

/atom/proc/rand_bad(min, max, atom/enemy)
	var/luck = get_luck()
	if(enemy)
		luck -= enemy.get_luck()
	. = rand(min, max)
	var/avg = (max+min)/2
	while(luck != 0)
		if(luck > 0)
			if(prob(50))
				. = . + rand(min, avg) / 2
			luck--
		else
			if(prob(50))
				. = . + rand(avg, max) / 2
			luck++
