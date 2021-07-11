/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	light_range = 2
	damage_type = BURN
	nodamage = FALSE
	hitsound = 'sound/weapons/frost.ogg'
	hitsound_wall = 'sound/weapons/frost.ogg'
	ricochets_max = 50	//Honk!
	ricochet_chance = 80
	is_reflectable = TRUE
	light_color = LIGHT_COLOR_BLUE
	flag = "energy"
	var/temperature = 100

/obj/item/projectile/temp/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.adjust_bodytemperature(((100-blocked)/100)*(temperature - L.bodytemperature)) // the new body temperature is adjusted by 100-blocked % of the delta between body temperature and the bullet's effect temperature

/obj/item/projectile/temp/hot
	name = "heat beam"
	icon_state = "lava"
	damage = 10
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	temperature = 400
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/temp/cryo
	name = "cryo beam"
	range = 3
	temperature = -240 // Single slow shot reduces temp greatly
