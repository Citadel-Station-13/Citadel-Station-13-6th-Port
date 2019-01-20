/obj/structure/arenabonfire
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon = 'icons/obj/memestation.dmi'
	icon_state = "arenabonfire"
	light_color = LIGHT_COLOR_PURPLE
	density = FALSE
	anchored = TRUE
	buckle_lying = 0
	var/burning = 1
	var/burn_icon = "bonfire_on_fire" //for a softer more burning embers icon, use "bonfire_warm"
	var/grill = FALSE
	var/fire_stack_strength = 5

/obj/structure/arenabonfire/dense
	density = TRUE

/obj/structure/arenabonfire/prelit/Initialize()
	. = ..()
	StartBurning()

/obj/structure/arenabonfire/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE
	if(mover.throwing)
		return TRUE
	return ..()

/obj/structure/arenabonfire/attackby(obj/item/W, mob/user, params)
	if(W.is_hot())
		StartBurning()
	if(grill)
		if(user.a_intent != INTENT_HARM && !(W.item_flags & ABSTRACT))
			if(user.temporarilyRemoveItemFromInventory(W))
				W.forceMove(get_turf(src))
				var/list/click_params = params2list(params)
				//Center the icon where the user clicked.
				if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
					return
				//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
				W.pixel_x = CLAMP(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
				W.pixel_y = CLAMP(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
		else
			return ..()


/obj/structure/arenabonfire/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(burning)
		to_chat(user, "<span class='warning'>You need to extinguish [src] before removing the logs!</span>")
		return
	if(!has_buckled_mobs() && do_after(user, 50, target = src))
		for(var/I in 1 to 5)
			var/obj/item/grown/log/L = new /obj/item/grown/log(src.loc)
			L.pixel_x += rand(1,4)
			L.pixel_y += rand(1,4)
		if(can_buckle || grill)
			new /obj/item/stack/rods(loc, 1)
		qdel(src)
		return

/obj/structure/arenabonfire/proc/StartBurning()
	if(!burning)
		icon_state = burn_icon
		burning = TRUE
		set_light(6)
		Burn()
		START_PROCESSING(SSobj, src)

/obj/structure/arenabonfire/fire_act(exposed_temperature, exposed_volume)
	StartBurning()

/obj/structure/arenabonfire/Crossed(atom/movable/AM)
	if(burning & !grill)
		Burn()

/obj/structure/arenabonfire/proc/Burn()
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000,100,1)
	for(var/A in current_location)
		if(A == src)
			continue
		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 500)
		else if(isliving(A))
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()

/obj/structure/arenabonfire/proc/Cook()
	var/turf/current_location = get_turf(src)
	for(var/A in current_location)
		if(A == src)
			continue
		else if(isliving(A)) //It's still a fire, idiot.
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()
		else if(istype(A, /obj/item) && prob(20))
			var/obj/item/O = A
			O.microwave_act()

/obj/structure/arenabonfire/process()
	if(!grill)
		Burn()
	else
		Cook()

/obj/structure/arenabonfire/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(..())
		M.pixel_y += 13

/obj/structure/arenabonfire/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
	if(..())
		buckled_mob.pixel_y -= 13


/obj/item/firing_pin/arena_pin
	name = "arena firing pin"
	desc = "This safety firing pin allows weapons to be fired within 9 meters of an arena bonfire."
	fail_message = "<span class='warning'>TOO FAR FROM BONFIRE!.</span>"
	pin_removeable = FALSE

/obj/item/firing_pin/arena_pin/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	for(var/obj/structure/arenabonfire/M in range(user, 9))
		return TRUE
	return FALSE