#define BASE_PIXEL_OFFSET 224
#define BASE_TURF_OFFSET 2
#define WIDE_SHADOW_THRESHOLD 80
#define OFFSET_MULTIPLIER_SIZE 32
#define CORNER_OFFSET_MULTIPLIER_SIZE 16
#define LIGHT_POWER_MULTIPLIER 240

#define CHECK_OCCLUSION(TARGV, T) \
	if (!isturf(T)) { \
		TARGV = FALSE; \
	} \
	else if (T.opacity) { \
		TARGV = TRUE; \
	} \
	else if (T.blocks_light == -1) { \
		TARGV = T.check_blocks_light(); \
	} \
	else if (T.blocks_light) { \
		TARGV = TRUE; \
	}


	/*else if (T.contents.len) { \
		for (var/obj/machinery/door/D in T) { \
			if (D.opacity) { \
				TARGV = TRUE; \
				break; \
			} \
		} \
	}*/

GLOBAL_LIST_EMPTY(lighting_range_cache)
GLOBAL_LIST_EMPTY(lighting_shadow_cache)
GLOBAL_LIST_EMPTY(lighting_wall_cache)
GLOBAL_VAR(lights)

// Casts shadows from occluding objects for a given light.

/atom/movable/light/proc/cast_light(var/force_cast)
	if(!SSlighting.initialized && !force_cast)
		GLOB.init_lights |= src
		return

	light_color = null

	temp_appearance = list()

	//cap light range to 7
	light_range = min(7, light_range)
	var/effectivepow = light_power
	if(effectivepow < 0)
		effectivepow = -effectivepow
		blend_mode = BLEND_SUBTRACT
		layer = 5
	else
		blend_mode = BLEND_ADD
		layer = 1

	alpha = min(255,max(0,round(effectivepow*LIGHT_POWER_MULTIPLIER)))

	if(light_type == LIGHT_SOFT_FLICKER)
		animate(src, alpha = alpha - rand(30, 60), time = rand(1,4), loop = -1, easing = SINE_EASING)

	for(var/turf/T in range(light_range, src))
		affecting_turfs |= T

	if(!isturf(loc))
		for(var/turf/T in affecting_turfs)
			T.lumcount = -1
			T.affecting_lights -= src
		affecting_turfs.Cut()
		return

	for(var/turf/T in affecting_turfs)
		T.affecting_lights |= src


	if(light_type == LIGHT_DIRECTIONAL)
		icon = 'icons/lighting/directional_overlays.dmi'
		light_range = 2.5
	else
		pixel_x = pixel_y = -(world.icon_size * light_range)
		light_range = round(light_range)
		switch(light_range)
			if(1)
				icon = 'icons/lighting/light_range_1.dmi'
				pixel_x += holder.pixel_x
				pixel_y += holder.pixel_y
			if(2)
				icon = 'icons/lighting/light_range_2.dmi'
			if(3)
				icon = 'icons/lighting/light_range_3.dmi'
			if(4)
				icon = 'icons/lighting/light_range_4.dmi'
			if(5)
				icon = 'icons/lighting/light_range_5.dmi'
			if(6)
				icon = 'icons/lighting/light_range_6.dmi'
			if(7)
				icon = 'icons/lighting/light_range_7.dmi'
			else
				qdel(src)
				return

	icon_state = "white"

	var/mutable_appearance/I = GLOB.lighting_range_cache[icon]
	if (!I)
		I = image(icon)
		I.layer = 4
		I.icon_state = "overlay"
		GLOB.lighting_range_cache[icon] = I

	if(light_type == LIGHT_DIRECTIONAL)
		var/turf/next_turf = get_step(src, dir)
		for(var/i = 1 to 3)
			var/occluded
			CHECK_OCCLUSION(occluded, next_turf)
			if(occluded)
				I.icon_state = "[I.icon_state]_[i]"
				break
			next_turf = get_step(next_turf, dir)

	temp_appearance += I

	if(light_type == LIGHT_DIRECTIONAL)
		follow_holder_dir()

	//no shadows
	if(light_range < 2 || light_type == LIGHT_DIRECTIONAL)
		overlays = temp_appearance
		temp_appearance = null
		return

	for(var/turf/target_turf in view(light_range, src))
		var/occluded
		CHECK_OCCLUSION(occluded, target_turf)
		if(!occluded)
			continue

		//get the x and y offsets for how far the target turf is from the light
		var/x_offset = target_turf.x - x
		var/y_offset = target_turf.y - y

		var/num = 1
		if((abs(x_offset) > 0 && !y_offset) || (abs(y_offset) > 0 && !x_offset))
			num = 2


		//due to only having one set of shadow templates, we need to rotate and flip them for up to 8 different directions
		//first check is to see if we will need to "rotate" the shadow template
		var/xy_swap = 0
		if(abs(x_offset) > abs(y_offset))
			xy_swap = 1

		var/shadowoffset = 16 + 32 * light_range


		//due to the way the offsets are named, we can just swap the x and y offsets to "rotate" the icon state

		var/shadowicon
		switch(light_range)
			if(2)
				if(num == 1)
					shadowicon = 'icons/lighting/light_range_2_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_2_shadows2.dmi'
			if(3)
				if(num == 1)
					shadowicon = 'icons/lighting/light_range_3_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_3_shadows2.dmi'
			if(4)
				if(num == 1)
					shadowicon = 'icons/lighting/light_range_4_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_4_shadows2.dmi'
			if(5)
				if(num == 1)
					shadowicon = 'icons/lighting/light_range_5_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_5_shadows2.dmi'
			if(6)
				if(num == 1)
					shadowicon = 'icons/lighting/light_range_6_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_6_shadows2.dmi'
			if(7)
				if(num == 1)
					shadowicon = 'icons/lighting/light_range_7_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_7_shadows2.dmi'

		I = GLOB.lighting_shadow_cache[shadowicon]
		if (!I)
			I = image(shadowicon)
			I.layer = 2
			GLOB.lighting_shadow_cache[shadowicon] = new /mutable_appearance(I)

		if(xy_swap)
			I.icon_state = "[abs(y_offset)]_[abs(x_offset)]"
		else
			I.icon_state = "[abs(x_offset)]_[abs(y_offset)]"


		var/matrix/M = matrix()

		//TODO: rewrite this comment:
		//using scale to flip the shadow template if needed
		//horizontal (x) flip is easy, we just check if the offset is negative
		//vertical (y) flip is a little harder, if the shadow will be rotated we need to flip if the offset is positive,
		// but if it wont be rotated then we just check if its negative to flip (like the x flip)
		var/x_flip
		var/y_flip
		if(xy_swap)
			x_flip = y_offset > 0 ? -1 : 1
			y_flip = x_offset < 0 ? -1 : 1
		else
			x_flip = x_offset < 0 ? -1 : 1
			y_flip = y_offset < 0 ? -1 : 1

		M.Scale(x_flip, y_flip)

		//here we do the actual rotate if needed
		if(xy_swap)
			M.Turn(90)

		//warning: you are approaching shitcode (this is where we move the shadow to the correct quadrant based on its rotation and flipping)
		//shadows are only as big as a quarter or half of the light for optimization

		//please for the love of god change this if there's a better way

		if(num == 1)
			if((x_flip == 1 && y_flip == 1 && xy_swap == 0) || (x_flip == -1 && y_flip == 1 && xy_swap == 1))
				M.Translate(shadowoffset, shadowoffset)
			else if((x_flip == 1 && y_flip == -1 && xy_swap == 0) || (x_flip == 1 && y_flip == 1 && xy_swap == 1))
				M.Translate(shadowoffset, 0)
			else if((xy_swap == 0 && x_flip == -y_flip) || (xy_swap == 1 && x_flip == -1 && y_flip == -1))
				M.Translate(0, shadowoffset)
		else
			if(x_flip == 1 && y_flip == 1 && xy_swap == 0)
				M.Translate(0, shadowoffset)
			else if(x_flip == 1 && y_flip == 1 && xy_swap == 1)
				M.Translate(shadowoffset / 2, shadowoffset / 2)
			else if(x_flip == 1 && y_flip == -1 && xy_swap == 1)
				M.Translate(-shadowoffset / 2, shadowoffset / 2)

		//apply the transform matrix
		I.transform = M

		//and add it to the lights overlays
		temp_appearance += I.appearance

		var/targ_dir = get_dir(target_turf, src)

		var/blocking_dirs = 0
		for(var/d in GLOB.cardinals)
			var/turf/T = get_step(target_turf, d)
			occluded= FALSE
			CHECK_OCCLUSION(occluded, T)
			if(occluded)
				blocking_dirs |= d

		var/lwc_key = "[blocking_dirs]-[targ_dir]"
		I = GLOB.lighting_wall_cache[lwc_key]
		if (!I)
			I = image('icons/lighting/wall_lighting.dmi')
			I.layer = 3
			I.icon_state = lwc_key
			GLOB.lighting_wall_cache[lwc_key] = new /mutable_appearance(I)

		I.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size)
		I.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size)

		temp_appearance += I.appearance

	overlays = temp_appearance
	temp_appearance.Cut()

#undef BASE_PIXEL_OFFSET
#undef BASE_TURF_OFFSET
#undef WIDE_SHADOW_THRESHOLD
#undef OFFSET_MULTIPLIER_SIZE
#undef CORNER_OFFSET_MULTIPLIER_SIZE
