//unsorted miscellaneous temporary visuals
/obj/effect/overlay/temp/dir_setting/bloodsplatter
	icon = 'icons/effects/blood.dmi'
	duration = 5
	randomdir = FALSE
	layer = BELOW_MOB_LAYER
	var/splatter_type = "splatter"

/obj/effect/overlay/temp/dir_setting/bloodsplatter/Initialize(mapload, set_dir)
	if(set_dir in GLOB.diagonals)
		icon_state = "[splatter_type][pick(1, 2, 6)]"
	else
		icon_state = "[splatter_type][pick(3, 4, 5)]"
	. = ..()
	var/target_pixel_x = 0
	var/target_pixel_y = 0
	switch(set_dir)
		if(NORTH)
			target_pixel_y = 16
		if(SOUTH)
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(EAST)
			target_pixel_x = 16
		if(WEST)
			target_pixel_x = -16
		if(NORTHEAST)
			target_pixel_x = 16
			target_pixel_y = 16
		if(NORTHWEST)
			target_pixel_x = -16
			target_pixel_y = 16
		if(SOUTHEAST)
			target_pixel_x = 16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
		if(SOUTHWEST)
			target_pixel_x = -16
			target_pixel_y = -16
			layer = ABOVE_MOB_LAYER
	animate(src, pixel_x = target_pixel_x, pixel_y = target_pixel_y, alpha = 0, time = duration)

/obj/effect/overlay/temp/dir_setting/bloodsplatter/xenosplatter
	splatter_type = "xsplatter"

/obj/effect/overlay/temp/dir_setting/speedbike_trail
	name = "speedbike trails"
	icon_state = "ion_fade"
	layer = BELOW_MOB_LAYER
	duration = 10
	randomdir = 0

/obj/effect/overlay/temp/dir_setting/firing_effect
	icon = 'icons/effects/effects.dmi'
	icon_state = "firing_effect"
	duration = 2

/obj/effect/overlay/temp/dir_setting/firing_effect/setDir(newdir)
	switch(newdir)
		if(NORTH)
			layer = BELOW_MOB_LAYER
			pixel_x = rand(-3,3)
			pixel_y = rand(4,6)
		if(SOUTH)
			pixel_x = rand(-3,3)
			pixel_y = rand(-1,1)
		else
			pixel_x = rand(-1,1)
			pixel_y = rand(-1,1)
	..()

/obj/effect/overlay/temp/dir_setting/firing_effect/energy
	icon_state = "firing_effect_energy"
	duration = 3

/obj/effect/overlay/temp/dir_setting/firing_effect/magic
	icon_state = "shieldsparkles"
	duration = 3

/obj/effect/overlay/temp/dir_setting/ninja
	name = "ninja shadow"
	icon = 'icons/mob/mob.dmi'
	icon_state = "uncloak"
	duration = 9

/obj/effect/overlay/temp/dir_setting/ninja/cloak
	icon_state = "cloak"

/obj/effect/overlay/temp/dir_setting/ninja/shadow
	icon_state = "shadow"

/obj/effect/overlay/temp/dir_setting/ninja/phase
	name = "ninja energy"
	icon_state = "phasein"

/obj/effect/overlay/temp/dir_setting/ninja/phase/out
	icon_state = "phaseout"

/obj/effect/overlay/temp/dir_setting/wraith
	name = "blood"
	icon = 'icons/mob/mob.dmi'
	icon_state = "phase_shift2"
	duration = 12

/obj/effect/overlay/temp/dir_setting/wraith/out
	icon_state = "phase_shift"

/obj/effect/overlay/temp/dir_setting/tailsweep
	icon_state = "tailsweep"
	duration = 4

/obj/effect/overlay/temp/wizard
	name = "water"
	icon = 'icons/mob/mob.dmi'
	icon_state = "reappear"
	duration = 5

/obj/effect/overlay/temp/wizard/out
	icon_state = "liquify"
	duration = 12

/obj/effect/overlay/temp/monkeyify
	icon = 'icons/mob/mob.dmi'
	icon_state = "h2monkey"
	duration = 22

/obj/effect/overlay/temp/monkeyify/humanify
	icon_state = "monkey2h"

/obj/effect/overlay/temp/borgflash
	icon = 'icons/mob/mob.dmi'
	icon_state = "blspell"
	duration = 5

/obj/effect/overlay/temp/guardian
	randomdir = 0

/obj/effect/overlay/temp/guardian/phase
	duration = 5
	icon_state = "phasein"

/obj/effect/overlay/temp/guardian/phase/out
	icon_state = "phaseout"

/obj/effect/overlay/temp/decoy
	desc = "It's a decoy!"
	duration = 15

/obj/effect/overlay/temp/decoy/Initialize(mapload, atom/mimiced_atom)
	. = ..()
	alpha = initial(alpha)
	if(mimiced_atom)
		name = mimiced_atom.name
		appearance = mimiced_atom.appearance
		setDir(mimiced_atom.dir)
		mouse_opacity = 0

/obj/effect/overlay/temp/decoy/fading/Initialize(mapload, atom/mimiced_atom)
	. = ..()
	animate(src, alpha = 0, time = duration)

/obj/effect/overlay/temp/decoy/fading/fivesecond
	duration = 50

/obj/effect/overlay/temp/small_smoke
	icon_state = "smoke"
	duration = 50

/obj/effect/overlay/temp/fire
	icon = 'icons/effects/fire.dmi'
	icon_state = "3"
	duration = 20

/obj/effect/overlay/temp/revenant
	name = "spooky lights"
	icon_state = "purplesparkles"

/obj/effect/overlay/temp/revenant/cracks
	name = "glowing cracks"
	icon_state = "purplecrack"
	duration = 6

/obj/effect/overlay/temp/gravpush
	name = "gravity wave"
	icon_state = "shieldsparkles"
	duration = 5

/obj/effect/overlay/temp/telekinesis
	name = "telekinetic force"
	icon_state = "empdisable"
	duration = 5

/obj/effect/overlay/temp/emp
	name = "emp sparks"
	icon_state = "empdisable"

/obj/effect/overlay/temp/emp/pulse
	name = "emp pulse"
	icon_state = "emppulse"
	duration = 8
	randomdir = 0

/obj/effect/overlay/temp/gib_animation
	icon = 'icons/mob/mob.dmi'
	duration = 15

/obj/effect/overlay/temp/gib_animation/Initialize(mapload, gib_icon)
	icon_state = gib_icon // Needs to be before ..() so icon is correct
	. = ..()

/obj/effect/overlay/temp/gib_animation/animal
	icon = 'icons/mob/animal.dmi'

/obj/effect/overlay/temp/dust_animation
	icon = 'icons/mob/mob.dmi'
	duration = 15

/obj/effect/overlay/temp/dust_animation/Initialize(mapload, dust_icon)
	icon_state = dust_icon // Before ..() so the correct icon is flick()'d
	. = ..()

/obj/effect/overlay/temp/mummy_animation
	icon = 'icons/mob/mob.dmi'
	icon_state = "mummy_revive"
	duration = 20

/obj/effect/overlay/temp/heal //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/overlay/temp/heal/Initialize(mapload, set_color)
	if(set_color)
		add_atom_colour(set_color, FIXED_COLOUR_PRIORITY)
	. = ..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)

/obj/effect/overlay/temp/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 4

/obj/effect/overlay/temp/explosion
	name = "explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	pixel_x = -32
	pixel_y = -32
	duration = 8

/obj/effect/overlay/temp/explosion/fast
	icon_state = "explosionfast"
	duration = 4

/obj/effect/overlay/temp/blob
	name = "blob"
	icon_state = "blob_attack"
	alpha = 140
	randomdir = 0
	duration = 6

/obj/effect/overlay/temp/impact_effect
	icon_state = "impact_bullet"
	duration = 5

/obj/effect/overlay/temp/impact_effect/Initialize(mapload, atom/target, obj/item/projectile/P)
	if(target == P.original) //the projectile hit the target originally clicked
		pixel_x = P.p_x + target.pixel_x - 16 + rand(-4,4)
		pixel_y = P.p_y + target.pixel_y - 16 + rand(-4,4)
	else
		pixel_x = target.pixel_x + rand(-4,4)
		pixel_y = target.pixel_y + rand(-4,4)
	. = ..()

/obj/effect/overlay/temp/impact_effect/red_laser
	icon_state = "impact_laser"
	duration = 4

/obj/effect/overlay/temp/impact_effect/red_laser/wall
	icon_state = "impact_laser_wall"
	duration = 10

/obj/effect/overlay/temp/impact_effect/blue_laser
	icon_state = "impact_laser_blue"
	duration = 4

/obj/effect/overlay/temp/impact_effect/green_laser
	icon_state = "impact_laser_green"
	duration = 4

/obj/effect/overlay/temp/impact_effect/purple_laser
	icon_state = "impact_laser_purple"
	duration = 4

/obj/effect/overlay/temp/impact_effect/ion
	icon_state = "shieldsparkles"
	duration = 6

/obj/effect/overlay/temp/heart
	name = "heart"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	duration = 25

/obj/effect/overlay/temp/heart/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)
	animate(src, pixel_y = pixel_y + 32, alpha = 0, time = 25)
