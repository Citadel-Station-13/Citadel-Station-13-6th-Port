#define ARCADE_WEIGHT_TRICK 4
#define ARCADE_WEIGHT_USELESS 2
#define ARCADE_WEIGHT_RARE 1
#define ARCADE_RATIO_PLUSH 0.20 // average 1 out of 6 wins is a plush.

GLOBAL_LIST_INIT(arcade_prize_pool, list(
		/obj/item/toy/balloon = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/beach_ball = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/cattoy = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/clockwork_watch = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/dummy = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/eightball = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/eightball/haunted = ARCADE_WEIGHT_RARE,
		/obj/item/storage/box/actionfigure = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/foamblade = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/gun = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/gun/justicar = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/gun/m41 = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/katana = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/minimeteor = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/nuke = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/redbutton = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/spinningtoy = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/sword = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/sword/cx = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/talking/AI = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/talking/codex_gigas = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/talking/griffin = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/talking/owl = ARCADE_WEIGHT_USELESS,
		/obj/item/toy/toy_dagger = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/toy_xeno = ARCADE_WEIGHT_TRICK,
		/obj/item/toy/windupToolbox = ARCADE_WEIGHT_TRICK,

		/mob/living/simple_animal/bot/secbot/grievous/toy = ARCADE_WEIGHT_RARE,
		/obj/item/clothing/mask/facehugger/toy = ARCADE_WEIGHT_RARE,
		/obj/item/gun/ballistic/automatic/toy/pistol/unrestricted = ARCADE_WEIGHT_TRICK,
		/obj/item/hot_potato/harmless/toy = ARCADE_WEIGHT_RARE,
		/obj/item/dualsaber/toy = ARCADE_WEIGHT_RARE,
		/obj/item/dualsaber/hypereutactic/toy = ARCADE_WEIGHT_RARE,
		/obj/item/dualsaber/hypereutactic/toy/rainbow = ARCADE_WEIGHT_RARE,

		/obj/item/storage/box/snappops = ARCADE_WEIGHT_TRICK,
		/obj/item/clothing/under/syndicate/tacticool = ARCADE_WEIGHT_TRICK,
		/obj/item/gun/ballistic/shotgun/toy/crossbow = ARCADE_WEIGHT_TRICK,
		/obj/item/storage/box/fakesyndiesuit = ARCADE_WEIGHT_TRICK,
		/obj/item/storage/crayons = ARCADE_WEIGHT_USELESS,
		/obj/item/coin/antagtoken = ARCADE_WEIGHT_USELESS,
		/obj/item/stack/tile/fakespace/loaded = ARCADE_WEIGHT_TRICK,
		/obj/item/stack/tile/fakepit/loaded = ARCADE_WEIGHT_TRICK,
		/obj/item/restraints/handcuffs/fake = ARCADE_WEIGHT_TRICK,
		/obj/item/clothing/gloves/fingerless/pugilist/hug = ARCADE_WEIGHT_TRICK,

		/obj/item/grenade/chem_grenade/glitter/pink = ARCADE_WEIGHT_TRICK,
		/obj/item/grenade/chem_grenade/glitter/blue = ARCADE_WEIGHT_TRICK,
		/obj/item/grenade/chem_grenade/glitter/white = ARCADE_WEIGHT_TRICK,

		/obj/item/extendohand/acme = ARCADE_WEIGHT_TRICK,
		/obj/item/card/emagfake	= ARCADE_WEIGHT_TRICK,
		/obj/item/clothing/shoes/wheelys = ARCADE_WEIGHT_RARE,
		/obj/item/clothing/shoes/kindleKicks = ARCADE_WEIGHT_RARE,
		/obj/item/storage/belt/military/snack = ARCADE_WEIGHT_RARE,

		/obj/item/clothing/mask/fakemoustache/italian = ARCADE_WEIGHT_RARE,
		/obj/item/clothing/suit/hooded/wintercoat/ratvar/fake = ARCADE_WEIGHT_TRICK,
		/obj/item/clothing/suit/hooded/wintercoat/narsie/fake = ARCADE_WEIGHT_TRICK
))

/obj/machinery/computer/arcade
	name = "random arcade"
	desc = "random arcade machine"
	icon_state = "arcade"
	icon_keyboard = "no_keyboard"
	icon_screen = "invaders"
	light_color = LIGHT_COLOR_GREEN
	var/list/prize_override

/obj/machinery/computer/arcade/proc/Reset()
	return

/obj/machinery/computer/arcade/Initialize()
	. = ..()
	// If it's a generic arcade machine, pick a random arcade
	// circuit board for it and make the new machine
	if(!circuit)
		var/list/gameodds = list(/obj/item/circuitboard/computer/arcade/battle = 33,
								/obj/item/circuitboard/computer/arcade/orion_trail = 33,
								/obj/item/circuitboard/computer/arcade/minesweeper = 33,
								/obj/item/circuitboard/computer/arcade/amputation = 2)
		var/thegame = pickweight(gameodds)
		var/obj/item/circuitboard/CB = new thegame()
		var/obj/machinery/computer/arcade/A = new CB.build_path(loc, CB)
		A.setDir(dir)
		return INITIALIZE_HINT_QDEL

	Reset()

/obj/machinery/computer/arcade/proc/prizevend(mob/user, prizes = 1)
	// if(user.mind?.get_skill_level(/datum/skill/gaming) >= SKILL_LEVEL_LEGENDARY && HAS_TRAIT(user, TRAIT_GAMERGOD))
	// 	visible_message("<span class='notice'>[user] inputs an intense cheat code!</span>",
	// 	"<span class='notice'>You hear a flurry of buttons being pressed.</span>")
	// 	say("CODE ACTIVATED: EXTRA PRIZES.")
	// 	prizes *= 2
	for(var/i = 0, i < prizes, i++)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "arcade", /datum/mood_event/arcade)
		if(prob(0.0001)) //1 in a million
			new /obj/item/gun/energy/pulse/prize(src)
			visible_message("<span class='notice'>[src] dispenses.. woah, a gun! Way past cool.</span>", "<span class='notice'>You hear a chime and a shot.</span>")
			user.client.give_award(/datum/award/achievement/misc/pulse, user)
			return

		var/prizeselect
		if(prize_override)
			prizeselect = pickweight(prize_override)
		else
			prizeselect = pickweight(GLOB.arcade_prize_pool)
		var/atom/movable/the_prize = new prizeselect(get_turf(src))
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
		visible_message("<span class='notice'>[src] dispenses [the_prize]!</span>", "<span class='notice'>You hear a chime and a clunk.</span>")


/obj/machinery/computer/arcade/emp_act(severity)
	. = ..()
	var/override = FALSE
	if(prize_override)
		override = TRUE

	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return

	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(var/i = num_of_prizes; i > 0; i--)
		if(override)
			empprize = pickweight(prize_override)
		else
			empprize = pickweight(GLOB.arcade_prize_pool)
		new empprize(loc)
	explosion(loc, -1, 0, 1+num_of_prizes, flame_range = 1+num_of_prizes)

/obj/machinery/computer/arcade/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/arcadeticket))
		var/obj/item/stack/arcadeticket/T = O
		var/amount = T.get_amount()
		if(amount <2)
			to_chat(user, "<span class='warning'>You need 2 tickets to claim a prize!</span>")
			return
		prizevend(user)
		T.pay_tickets()
		T.update_icon()
		O = T
		to_chat(user, "<span class='notice'>You turn in 2 tickets to the [src] and claim a prize!</span>")
		return
