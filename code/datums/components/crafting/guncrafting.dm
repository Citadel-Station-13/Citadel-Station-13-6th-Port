//Gun crafting parts til they can be moved elsewhere

// PARTS //

/obj/item/weaponcrafting
	icon = 'icons/obj/improvised.dmi'

/obj/item/weaponcrafting/silkstring
	name = "silkstring"
	desc = "A long piece of silk with some resemblance to cable coil."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "silkstring"

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."
	icon_state = "receiver"

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	icon_state = "riflestock"

/obj/item/weaponcrafting/stock/attackby(obj/item/S, mob/user, params)
	. = ..()
	if(istype(S, /obj/item/pipe))
		return
	if(istype(S, /obj/item/weaponcrafting/receiver))
		var/R = /obj/item/weaponcrafting/receiver/stock
		to_chat(user, "<span class='notice'>You add [S] to [src]!</span>")
		qdel(S)
		qdel(src)
		new R(user.loc, 1)

/obj/item/weaponcrafting/receiver/stock
	name = "receiver stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood, this one has a modular receiver attached."
	icon_state = "mounted_receiver"

/obj/item/weaponcrafting/receiver/stock/attackby(obj/item/P, mob/user, params)
	. = ..()
	if(istype(P, /obj/item/pipe))
		var/B = /obj/item/weaponcrafting/receiver/stock/barreled
		to_chat(user, "<span class='notice'>You add [P] to [src]!</span>")
		qdel(P)
		qdel(src)
		new B(user.loc, 1)

/obj/item/weaponcrafting/receiver/stock/barreled
	name = "gun assembly"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood. This one has a modular receiver attached."
	icon_state = "mounted_receiver_piped"

/obj/item/weaponcrafting/receiver/stock/barrled/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/stack/packageWrap))
		var/G = /obj/item/weaponcrafting/receiver/stock/barreled/gun
		if(W.use(15))
			to_chat(user, "<span class='notice'>You add [W] to [src]!</span>")
			qdel(src)
			new G(user.loc, 1)
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of package wrap if you want to attach this pipe!</span>")

/obj/item/weaponcrafting/receiver/stock/barreled/gun
	name = "gun assembly"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood. This one has a modular receiver firmly attached. Adding a new pipe would allow for a rifle to be made."
	icon_state = "mounted_receiver_piped_wrapped"

/obj/item/weaponcrafting/receiver/stock/barreled/gun/attackby(obj/item/D, mob/user, params)
	if(istype(D, TOOL_SCREWDRIVER))
		to_chat(user, "<span class='notice'>You start attaching the gun to the frame...</span>")
		if(D.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>Improvised shotgun completed!</span>")
			var/obj/item/gun/ballistic/revolver/doublebarrel/improvised/I = /obj/item/gun/ballistic/revolver/doublebarrel/improvised
			new I(user.loc, 1)
			qdel(src)
	if(istype(D, /obj/item/pipe))
		to_chat(user, "<span class='notice'>The barrle is extended, making a longer gun!</span>")
		var/obj/item/weaponcrafting/receiver/stock/barreled/gun/long/R = /obj/item/weaponcrafting/receiver/stock/barreled/gun/long
		new R(user.loc, 1)
		qdel(src)
		qdel(D)

//To be added later
/*	if(istype(D, TOOL_SAW))
		if(D.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>The barrle is sawn off making a smaller gun!</span>")
			var/L = /obj/item/weaponcrafting/receiver/stock/barrled/gun/short
			new L(user.loc, 1)
			qdel(src)
*/


/obj/item/weaponcrafting/receiver/stock/barreled/gun/long
	name = "rifle gun assembly"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood. This one has a modular receiver firmly attached with an extended barrel."
	icon_state = "mounted_receiver_piped_wrapped"

/obj/item/weaponcrafting/receiver/stock/barreled/gun/long/attackby(obj/item/D, mob/user, params)
	. = ..()
	if(istype(D, TOOL_SCREWDRIVER))
		to_chat(user, "<span class='notice'>You start attaching the gun to the frame...</span>")
		if(D.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>Improvised rifle completed!</span>")
			var/obj/item/gun/ballistic/shotgun/boltaction/improvised/B = /obj/item/gun/ballistic/shotgun/boltaction/improvised
			new B(user.loc, 1)
			qdel(src)
/*
/obj/item/weaponcrafting/receiver/stock/barreled/gun/short
	name = "small gun assembly"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood. This one has a modular receiver firmly attached with a shortend barrel. Using a drill will allow the gun to use high caliber rounds well a screwdriver will be low caliber."
	icon_state = "pistol"

/obj/item/weaponcrafting/receiver/stock/barreled/gun/short/attackby(obj/item/D, mob/user, params)
	if(istype(D, TOOL_SCREWDRIVER))
		to_chat(user, "<span class='notice'>You start attaching the gun to the frame...</span>")
		if(D.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>Improvised pistol completed!</span>")
			var/M = /obj/item/gun/ballistic/revolver/makeshift_pistol
			new M(user.loc, 1)
			qdel(src)
	if(istype(D, TOOL_DRILL))
		to_chat(user, "<span class='notice'>You start attaching the gun to the frame...</span>")
		if(D.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>Improvised high caliber pistol Completed!</span>")
			var/H = /obj/item/gun/ballistic/revolver/makeshift
			new H(user.loc, 1)
			qdel(src)
*/