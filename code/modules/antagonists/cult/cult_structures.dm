/obj/structure/destructible/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'
	light_power = 2
	var/cooldowntime = 0
	break_sound = 'sound/hallucinations/veryfar_noise.ogg'
	debris = list(/obj/item/stack/sheet/runed_metal = 1)

/obj/structure/destructible/cult/proc/conceal() //for spells that hide cult presence
	density = FALSE
	visible_message("<span class='danger'>[src] fades away.</span>")
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes
	light_range = 0
	light_power = 0
	update_light()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/proc/reveal() //for spells that reveal cult presence
	density = initial(density)
	invisibility = 0
	visible_message("<span class='danger'>[src] suddenly appears!</span>")
	alpha = initial(alpha)
	light_range = initial(light_range)
	light_power = initial(light_power)
	update_light()
	START_PROCESSING(SSfastprocess, src)


/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += "<span class='notice'>\The [src] is [anchored ? "":"not "]secured to the floor.</span>"
	if((iscultist(user) || isobserver(user)) && cooldowntime > world.time)
		. += "<span class='cult italic'>The magic in [src] is too weak, [p_they()] will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>"

/obj/structure/destructible/cult/examine_status(mob/user)
	if(iscultist(user) || isobserver(user))
		var/t_It = p_they(TRUE)
		var/t_is = p_are()
		return "<span class='cult'>[t_It] [t_is] at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.</span>"
	return ..()

/obj/structure/destructible/cult/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/hostile/construct/builder))
		if(obj_integrity < max_integrity)
			M.DelayNextAction(CLICK_CD_MELEE)
			obj_integrity = min(max_integrity, obj_integrity + 5)
			Beam(M, icon_state="sendbeam", time=4)
			M.visible_message("<span class='danger'>[M] repairs \the <b>[src]</b>.</span>", \
				"<span class='cult'>You repair <b>[src]</b>, leaving [p_they()] at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.</span>")
			return TRUE
		else
			to_chat(M, "<span class='cult'>You cannot repair [src], as [p_theyre()] undamaged!</span>")
	else
		return ..()

/obj/structure/destructible/cult/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		anchored = !anchored
		density = !density
		to_chat(user, "<span class='notice'>You [anchored ? "":"un"]secure \the [src] [anchored ? "to":"from"] the floor.</span>")
		if(!anchored)
			icon_state = "[initial(icon_state)]_off"
		else
			icon_state = initial(icon_state)
	else
		return ..()

/obj/structure/destructible/cult/ratvar_act()
	if(take_damage(rand(25, 50), BURN) && src) //if we still exist
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/structure/destructible/cult/proc/check_menu(mob/living/user)
	if(!user || user.incapacitated() || !iscultist(user) || !anchored || cooldowntime > world.time)
		return FALSE
	return TRUE

/obj/structure/destructible/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar'Sie."
	icon_state = "talismanaltar"
	break_message = "<span class='warning'>The altar shatters, leaving only the wailing of the damned!</span>"

	var/static/image/radial_whetstone = image(icon = 'icons/obj/kitchen.dmi', icon_state = "cult_sharpener")
	var/static/image/radial_shell = image(icon = 'icons/obj/wizard.dmi', icon_state = "construct-cult")
	var/static/image/radial_unholy_water = image(icon = 'icons/obj/drinks.dmi', icon_state = "holyflask")

/obj/structure/destructible/cult/talisman/Initialize()
	. = ..()
	radial_unholy_water.color = "#333333"

/obj/structure/destructible/cult/talisman/ui_interact(mob/user)
	. = ..()

	if(!user.canUseTopic(src, TRUE))
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>You're pretty sure you know exactly what this is used for and you can't seem to touch it.</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='cultitalic'>You need to anchor [src] to the floor with your dagger first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cultitalic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return

	to_chat(user, "<span class='cultitalic'>You study the schematics etched into the altar...</span>")

	var/list/options = list("Eldritch Whetstone" = radial_whetstone, "Construct Shell" = radial_shell, "Flask of Unholy Water" = radial_unholy_water)
	var/choice = show_radial_menu(user, src, options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)

	var/reward
	switch(choice)
		if("Eldritch Whetstone")
			reward = /obj/item/sharpener/cult
		if("Construct Shell")
			reward = /obj/structure/constructshell
		if("Flask of Unholy Water")
			reward = /obj/item/reagent_containers/glass/beaker/unholywater

	if(!QDELETED(src) && reward && check_menu(user))
		cooldowntime = world.time + 2400
		new reward(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You kneel before the altar and your faith is rewarded with the [choice]!</span>")

/obj/structure/destructible/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar'Sie."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	break_message = "<span class='warning'>The force breaks apart into shards with a howling scream!</span>"

	var/static/image/radial_flagellant = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "cultrobes")
	var/static/image/radial_shielded = image(icon = 'icons/obj/clothing/suits.dmi', icon_state = "cult_armor")
	var/static/image/radial_mirror = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "mirror_shield")

/obj/structure/destructible/cult/forge/ui_interact(mob/user)
	. = ..()

	if(!user.canUseTopic(src, TRUE))
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>The heat radiating from [src] pushes you back.</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='cultitalic'>You need to anchor [src] to the floor with your dagger first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return

	to_chat(user, "<span class='cultitalic'>You study the schematics etched into the forge...</span>")


	var/list/options = list("Shielded Robe" = radial_shielded, "Flagellant's Robe" = radial_flagellant, "Mirror Shield" = radial_mirror)
	var/choice = show_radial_menu(user, src, options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)

	var/reward
	switch(choice)
		if("Shielded Robe")
			reward = /obj/item/clothing/suit/hooded/cultrobes/cult_shield
		if("Flagellant's Robe")
			reward = /obj/item/clothing/suit/hooded/cultrobes/berserker
		if("Mirror Shield")
			reward = /obj/item/shield/mirror

	if(!QDELETED(src) && reward && check_menu(user))
		cooldowntime = world.time + 2400
		new reward(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You work the forge as dark knowledge guides your hands, creating the [choice]!</span>")

/obj/structure/destructible/cult/forge/attackby(obj/item/I, mob/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>The heat radiating from [src] pushes you back.</span>")
		return
	if(istype(I, /obj/item/ingot))
		var/obj/item/ingot/notsword = I
		to_chat(user, "You heat the [notsword] in the [src].")
		notsword.workability = "shapeable"

/obj/structure/destructible/cult/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	light_range = 1.5
	light_color = LIGHT_COLOR_RED
	break_sound = 'sound/effects/glassbr2.ogg'
	break_message = "<span class='warning'>The blood-red crystal falls to the floor and shatters!</span>"
	var/heal_delay = 25
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/destructible/cult/pylon/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/structure/destructible/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/cult/pylon/process()
	if(!anchored)
		return
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(iscultist(L) || isshade(L) || isconstruct(L))
				if(L.health != L.maxHealth)
					new /obj/effect/temp_visual/heal(get_turf(src), "#960000")
					if(ishuman(L))
						L.adjustBruteLoss(-1, 0, only_organic = FALSE)
						L.adjustFireLoss(-1, 0, only_organic = FALSE)
						L.updatehealth()
					if(isshade(L) || isconstruct(L))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.adjustHealth(-3)
				if(ishuman(L) && L.blood_volume < (BLOOD_VOLUME_NORMAL * L.blood_ratio))
					L.AddIntegrationBlood(1)
			CHECK_TICK
	if(last_corrupt <= world.time)
		var/list/validturfs = list()
		var/list/cultturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/open/floor/engine/cult))
				cultturfs |= T
				continue
			var/static/list/blacklisted_pylon_turfs = typecacheof(list(
				/turf/closed,
				/turf/open/floor/engine/cult,
				/turf/open/space,
				/turf/open/lava,
				/turf/open/chasm))
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/open/floor/plating))
				T.PlaceOnTop(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
			else
				T.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		else
			var/turf/open/floor/engine/cult/F = safepick(cultturfs)
			if(F)
				new /obj/effect/temp_visual/cult/turf/floor(F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay*2

/obj/structure/destructible/cult/tome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = "<span class='warning'>The books and tomes of the archives burn into ash as the desk shatters!</span>"

	var/static/image/radial_blindfold = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "blindfold")
	var/static/image/radial_curse = image(icon = 'icons/obj/cult.dmi', icon_state ="shuttlecurse")
	var/static/image/radial_veilwalker = image(icon = 'icons/obj/cult.dmi', icon_state ="shifter")

/obj/structure/destructible/cult/tome/ui_interact(mob/user)
	. = ..()

	if(!user.canUseTopic(src, TRUE))
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>These books won't open and it hurts to even try and read the covers.</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='cultitalic'>You need to anchor [src] to the floor with your dagger first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return

	to_chat(user, "<span class='cultitalic'>You flip through the black pages of the archives...</span>")

	var/list/options = list("Zealot's Blindfold" = radial_blindfold, "Shuttle Curse" = radial_curse, "Veil Walker Set" = radial_veilwalker)
	var/choice = show_radial_menu(user, src, options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)

	var/reward
	switch(choice)
		if("Zealot's Blindfold")
			reward = /obj/item/clothing/glasses/hud/health/night/cultblind
		if("Shuttle Curse")
			reward = /obj/item/shuttle_curse
		if("Veil Walker Set")
			reward = /obj/effect/spawner/bundle/veil_walker
	if(!QDELETED(src) && reward && check_menu(user))
		cooldowntime = world.time + 2400
		new reward(get_turf(src))
		to_chat(user, "<span class='cultitalic'>You summon the [choice] from the archives!</span>")

/obj/effect/spawner/bundle/veil_walker
	items = list(/obj/item/cult_shift, /obj/item/flashlight/flare/culttorch)

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return
