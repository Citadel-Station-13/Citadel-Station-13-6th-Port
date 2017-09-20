/mob/living/simple_animal/hostile/megafauna/dragon
	vore_active = TRUE

/mob/living/simple_animal/hostile/megafauna/dragon/Initialize()
	var/list/datum/belly/stomachs = list(
				new /datum/belly/megafauna/dragon/maw(src),
				new /datum/belly/megafauna/dragon/gullet(src),
				new /datum/belly/megafauna/dragon/gut(src))
	for(var/datum/belly/X in stomachs)
		vore_organs[X.name] = X
	var/datum/belly/selecting = stomachs[1]
	vore_selected = selecting.name
	return ..()

/datum/belly/megafauna/dragon
	human_prey_swallow_time = 50 // maybe enough to switch targets if distracted
	nonhuman_prey_swallow_time = 50

/datum/belly/megafauna/dragon/maw
	name = "maw"
	inside_flavor = "The maw of the dreaded Ash drake closes around you, engulfing you into a swelteringly hot, disgusting enviroment. The acidic saliva tingles over your form while that tongue pushes you further back...towards the dark gullet beyond."
	vore_verb = "scoop"
	transferlocation = /datum/belly/megafauna/dragon/gullet
	transferchance = 100
	vore_sound = 'sound/vore/pred/taurswallow.ogg'
	swallow_time = 100

/datum/belly/megafauna/dragon/gullet
	name = "gullet"
	inside_flavor = "A ripple of muscle and arching of the tongue pushes you down like any other food. Food you've become the moment you were consumed. The dark ambience of the outside world is replaced with working, wet flesh. Your only light being what you brought with you."
	swallow_time = 150
	transferlocation = /datum/belly/megafauna/dragon/gut
	transferchance = 100
	swallow_time = 50

/datum/belly/megafauna/dragon/gut
	name = "stomach"
	vore_capacity = 5 //I doubt this many people will actually last in the gut, but...
	inside_flavor = "With a rush of burning ichor greeting you, you're introduced to the Drake's stomach. Wrinkled walls greedily grind against you, acidic slimes working into your body as you become fuel and nutriton for a superior predator. All that's left is your body's willingness to resist your destiny."
	digest_mode = DM_DRAGON
	digest_burn = 5