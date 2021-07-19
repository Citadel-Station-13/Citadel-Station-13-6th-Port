#define BLURRY_VISION_ONE	1
#define BLURRY_VISION_TWO	2
#define BLIND_VISION_THREE	3

/obj/item/organ/eyes
	name = BODY_ZONE_PRECISE_EYES
	icon_state = "eyeballs"
	desc = "I see you!"
	zone = BODY_ZONE_PRECISE_EYES
	slot = ORGAN_SLOT_EYES
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	maxHealth = 0.5 * STANDARD_ORGAN_THRESHOLD		//half the normal health max since we go blind at 30, a permanent blindness at 50 therefore makes sense unless medicine is administered
	high_threshold = 0.3 * STANDARD_ORGAN_THRESHOLD	//threshold at 30
	low_threshold = 0.2 * STANDARD_ORGAN_THRESHOLD	//threshold at 15

	low_threshold_passed = "<span class='info'>Distant objects become somewhat less tangible.</span>"
	high_threshold_passed = "<span class='info'>Everything starts to look a lot less clear.</span>"
	now_failing = "<span class='warning'>Darkness envelopes you, as your eyes go blind!</span>"
	now_fixed = "<span class='info'>Color and shapes are once again perceivable.</span>"
	high_threshold_cleared = "<span class='info'>Your vision functions passably once more.</span>"
	low_threshold_cleared = "<span class='info'>Your vision is cleared of any ailment.</span>"

	var/sight_flags = 0
	var/see_in_dark = 2
	var/tint = 0
	var/left_eye_color = "" //set to a hex code to override a mob's eye color
	var/right_eye_color = ""
	var/old_left_eye_color = "fff"
	var/old_right_eye_color = "fff"
	var/flash_protect = 0
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha
	var/eye_damaged	= FALSE	//indicates that our eyes are undergoing some level of negative effect

/obj/item/organ/eyes/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE)
	. = ..()
	if(!.)
		return
	switch(eye_damaged)
		if(BLURRY_VISION_ONE, BLURRY_VISION_TWO)
			owner.overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, eye_damaged)
		if(BLIND_VISION_THREE)
			owner.become_blind(EYE_DAMAGE)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		old_left_eye_color = H.left_eye_color
		old_right_eye_color = H.right_eye_color

		if(left_eye_color)
			H.left_eye_color = left_eye_color
		else
			left_eye_color = H.left_eye_color

		if(right_eye_color)
			H.right_eye_color = right_eye_color
		else
			right_eye_color = H.right_eye_color

		if(!special)
			H.dna?.species?.handle_body(H) //regenerate eyeballs overlays.
	M.update_tint()
	owner.update_sight()

/obj/item/organ/eyes/Remove(special = FALSE)
	. = ..()
	var/mob/living/carbon/C = .
	if(QDELETED(C))
		return
	switch(eye_damaged)
		if(BLURRY_VISION_ONE, BLURRY_VISION_TWO)
			C.clear_fullscreen("eye_damage")
		if(BLIND_VISION_THREE)
			C.cure_blind(EYE_DAMAGE)
	if(ishuman(C) && left_eye_color && right_eye_color)
		var/mob/living/carbon/human/H = C
		H.left_eye_color = old_left_eye_color
		H.right_eye_color = old_right_eye_color
		if(!special)
			H.dna.species.handle_body(H)
	if(!special)
		C.update_tint()
		C.update_sight()


/obj/item/organ/eyes/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(!.)
		return
	var/old_damaged = eye_damaged
	switch(damage)
		if(INFINITY to maxHealth)
			eye_damaged = BLIND_VISION_THREE
		if(maxHealth to high_threshold)
			eye_damaged = BLURRY_VISION_TWO
		if(high_threshold to low_threshold)
			eye_damaged = BLURRY_VISION_ONE
		else
			eye_damaged = FALSE
	if(eye_damaged == old_damaged || !owner)
		return
	if(old_damaged == BLIND_VISION_THREE)
		owner.cure_blind(EYE_DAMAGE)
	else if(eye_damaged == BLIND_VISION_THREE)
		owner.become_blind(EYE_DAMAGE)
	if(eye_damaged && eye_damaged != BLIND_VISION_THREE)
		owner.overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, eye_damaged)
	else
		owner.clear_fullscreen("eye_damage")

/obj/item/organ/eyes/night_vision
	name = "shadow eyes"
	desc = "A spooky set of eyes that can see in the dark."
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/night_vision = TRUE

/obj/item/organ/eyes/night_vision/ui_action_click()
	sight_flags = initial(sight_flags)
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			sight_flags &= ~SEE_BLACKNESS
	owner.update_sight()

/obj/item/organ/eyes/night_vision/alien
	name = "alien eyes"
	desc = "It turned out they had them after all!"
	sight_flags = SEE_MOBS

/obj/item/organ/eyes/night_vision/zombie
	name = "undead eyes"
	desc = "Somewhat counterintuitively, these half-rotten eyes actually have superior vision to those of a living human."
	sight_flags = SEE_MOBS

/obj/item/organ/eyes/night_vision/nightmare
	name = "burning red eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon_state = "burning_eyes"

/obj/item/organ/eyes/night_vision/mushroom
	name = "fung-eye"
	desc = "While on the outside they look inert and dead, the eyes of mushroom people are actually very advanced."

///Robotic

/obj/item/organ/eyes/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "Your vision is augmented."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/eyes/robotic/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	to_chat(owner, "<span class='warning'>Static obfuscates your vision!</span>")
	owner.flash_act(visual = 1)
	if(severity >= 70)
		owner.adjustOrganLoss(ORGAN_SLOT_EYES, 20)


/obj/item/organ/eyes/robotic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	left_eye_color = "000"
	right_eye_color = "000"
	see_in_dark = 8
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/eyes/robotic/thermals
	name = "thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."
	left_eye_color = "FC0"
	right_eye_color = "FC0"
	sight_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = -1
	see_in_dark = 8

/obj/item/organ/eyes/robotic/meson
	name = "meson eyes"
	desc = "These cybernetic eye implants will give you meson vision."
	left_eye_color = "66F"
	right_eye_color = "66F"
	see_in_dark = 2
	sight_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/organ/eyes/robotic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someone's head?"
	left_eye_color ="fee5a3"
	right_eye_color ="fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = 2
	tint = INFINITY
	var/obj/item/flashlight/eyelight/eye

/obj/item/organ/eyes/robotic/flashlight/emp_act(severity)
	return

/obj/item/organ/eyes/robotic/flashlight/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE)
	..()
	if(!eye)
		eye = new /obj/item/flashlight/eyelight()
	eye.on = TRUE
	eye.forceMove(M)
	eye.update_brightness(M)
	M.become_blind("flashlight_eyes")

/obj/item/organ/eyes/robotic/flashlight/Remove(special = FALSE)
	if(!QDELETED(owner))
		eye.on = FALSE
		eye.update_brightness(owner)
		eye.forceMove(src)
		owner.cure_blind("flashlight_eyes")
	return ..()

// Welding shield implant
/obj/item/organ/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	flash_protect = 2

/obj/item/organ/eyes/robotic/shield/emp_act(severity)
	return

#define RGB2EYECOLORSTRING(definitionvar) ("[copytext_char(definitionvar, 2, 3)][copytext_char(definitionvar, 4, 5)][copytext_char(definitionvar, 6, 7)]")

/obj/item/organ/eyes/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Special glowing eyes, used by snowflakes who want to be special."
	left_eye_color = "000"
	right_eye_color = "000"
	actions_types = list(/datum/action/item_action/organ_action/use, /datum/action/item_action/organ_action/toggle)
	var/current_color_string = "#ffffff"
	var/active = FALSE
	var/max_light_beam_distance = 5
	var/light_beam_distance = 5
	var/light_object_range = 1
	var/light_object_power = 2
	var/list/obj/effect/abstract/eye_lighting/eye_lighting
	var/obj/effect/abstract/eye_lighting/on_mob
	var/image/mob_overlay

/obj/item/organ/eyes/robotic/glow/Initialize()
	. = ..()
	mob_overlay = image('icons/mob/human_face.dmi', "eyes_glow_gs")

/obj/item/organ/eyes/robotic/glow/Destroy()
	terminate_effects()
	. = ..()

/obj/item/organ/eyes/robotic/glow/Remove(special = FALSE)
	terminate_effects()
	. = ..()

/obj/item/organ/eyes/robotic/glow/proc/terminate_effects()
	if(owner && active)
		deactivate(TRUE)
	active = FALSE
	clear_visuals(TRUE)

/obj/item/organ/eyes/robotic/glow/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		prompt_for_controls(owner)

/obj/item/organ/eyes/robotic/glow/proc/toggle_active()
	if(active)
		deactivate()
	else
		activate()

/obj/item/organ/eyes/robotic/glow/proc/prompt_for_controls(mob/user)
	var/C = input(owner, "Select Color", "Select color", "#ffffff") as color|null
	if(!C || QDELETED(src) || QDELETED(user) || QDELETED(owner) || owner != user)
		return
	var/range = input(user, "Enter range (0 - [max_light_beam_distance])", "Range Select", 0) as null|num
	if(!isnum(range))
		return

	set_distance(clamp(range, 0, max_light_beam_distance))
	assume_rgb(C)

#define MAX_SATURATION 192
#define MAX_LIGHTNESS 256

/obj/item/organ/eyes/robotic/glow/proc/assume_rgb(newcolor)
	var/current_color = RGB2EYECOLORSTRING(newcolor)
	left_eye_color = current_color
	right_eye_color = current_color
	var/list/hsv = ReadHSV(RGBtoHSV(newcolor))
	hsv[2] = clamp(hsv[2], 0, MAX_SATURATION)
	hsv[3] = clamp(hsv[3], 0, MAX_LIGHTNESS)
	var/new_hsv = hsv(hsv[1], hsv[2], hsv[3])
	current_color_string = HSVtoRGB(new_hsv)
	sync_light_effects()
	cycle_mob_overlay()
	if(!QDELETED(owner) && ishuman(owner))		//Other carbon mobs don't have eye color.
		owner.dna.species.handle_body(owner)

#undef MAX_SATURATION
#undef MAX_LIGHTNESS

/obj/item/organ/eyes/robotic/glow/proc/cycle_mob_overlay()
	remove_mob_overlay()
	mob_overlay.color = current_color_string
	add_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/add_mob_overlay()
	if(!QDELETED(owner))
		owner.add_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/proc/remove_mob_overlay()
	if(!QDELETED(owner))
		owner.cut_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/emp_act()
	. = ..()
	if(!active || . & EMP_PROTECT_SELF)
		return
	deactivate(silent = TRUE)

/obj/item/organ/eyes/robotic/glow/proc/activate(silent = FALSE)
	start_visuals()
	if(!silent)
		to_chat(owner, "<span class='warning'>Your [src] clicks and makes a whining noise, before shooting out a beam of light!</span>")
	active = TRUE
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, .proc/update_visuals)
	cycle_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/deactivate(silent = FALSE)
	clear_visuals()
	if(!silent)
		to_chat(owner, "<span class='warning'>Your [src] shuts off!</span>")
	active = FALSE
	UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)
	remove_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/update_visuals(datum/source, olddir, newdir)
	if((LAZYLEN(eye_lighting) < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	var/turf/scanfrom = get_turf(owner)
	var/scandir = owner.dir
	if (newdir && scandir != newdir) // COMSIG_ATOM_DIR_CHANGE happens before the dir change, but with a reference to the new direction.
		scandir = newdir
	if(!istype(scanfrom))
		clear_visuals()
	var/turf/scanning = scanfrom
	var/stop = FALSE
	on_mob.forceMove(scanning)
	for(var/i in 1 to light_beam_distance)
		scanning = get_step(scanning, scandir)
		if(!scanning)
			break
		if(scanning.opacity || scanning.has_opaque_atom)
			stop = TRUE
		var/obj/effect/abstract/eye_lighting/L = LAZYACCESS(eye_lighting, i)
		if(stop)
			L.forceMove(src)
		else
			L.forceMove(scanning)

/obj/item/organ/eyes/robotic/glow/proc/clear_visuals(delete_everything = FALSE)
	if(delete_everything)
		QDEL_LIST(eye_lighting)
		QDEL_NULL(on_mob)
	else
		for(var/i in eye_lighting)
			var/obj/effect/abstract/eye_lighting/L = i
			L.forceMove(src)
		if(!QDELETED(on_mob))
			on_mob.forceMove(src)

/obj/item/organ/eyes/robotic/glow/proc/start_visuals()
	if(!islist(eye_lighting))
		regenerate_light_effects()
	if((LAZYLEN(eye_lighting) < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	sync_light_effects()
	update_visuals()

/obj/item/organ/eyes/robotic/glow/proc/set_distance(dist)
	light_beam_distance = dist
	regenerate_light_effects()

/obj/item/organ/eyes/robotic/glow/proc/regenerate_light_effects()
	clear_visuals(TRUE)
	on_mob = new(src)
	for(var/i in 1 to light_beam_distance)
		LAZYADD(eye_lighting,new /obj/effect/abstract/eye_lighting(src))
	sync_light_effects()

/obj/item/organ/eyes/robotic/glow/proc/sync_light_effects()
	for(var/I in eye_lighting)
		var/obj/effect/abstract/eye_lighting/L = I
		L.set_light(light_object_range, light_object_power, current_color_string)
	if(on_mob)
		on_mob.set_light(1, 1, current_color_string)

/obj/effect/abstract/eye_lighting
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/obj/item/organ/eyes/robotic/glow/parent

/obj/effect/abstract/eye_lighting/Initialize()
	. = ..()
	parent = loc
	if(!istype(parent))
		return INITIALIZE_HINT_QDEL

/obj/item/organ/eyes/insect
	name = "insect eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, with no improvement to low light vision."
	flash_protect = -1

/obj/item/organ/eyes/ipc
	name = "ipc eyes"
	icon_state = "cybernetic_eyeballs"

/obj/item/organ/eyes/ipc/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	to_chat(owner, "<span class='warning'>Alert: Perception visuals damaged!</span>")
	owner.flash_act(visual = 1)
	if(severity >= 70)
		owner.adjustOrganLoss(ORGAN_SLOT_EYES, 20)

/obj/item/organ/eyes/night_vision/arachnid
	name = "arachnid eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, offset by basic night vision."
	see_in_dark = 4
	flash_protect = -1

#undef BLURRY_VISION_ONE
#undef BLURRY_VISION_TWO
#undef BLIND_VISION_THREE
