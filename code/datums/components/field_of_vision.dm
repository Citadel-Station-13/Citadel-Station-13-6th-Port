#define CENTERED_RENDER_SOURCE(img, atom, FoV) \
	atom.render_target = atom.render_target || ref(atom);\
	img.render_source = atom.render_target;\
	if(atom.icon){\
		var/_cached_sizes = FoV.width_n_height_offsets[atom.icon];\
		if(!_cached_sizes){\
			var/icon/_I = icon(atom.icon);\
			var/list/L = list();\
			L += (_I.Width() - world.icon_size)/2;\
			L += (_I.Height() - world.icon_size)/2;\
			_cached_sizes = FoV.width_n_height_offsets[atom.icon] = L\
		}\
		img.pixel_x = _cached_sizes[1];\
		img.pixel_y = _cached_sizes[2];\
		img.loc = atom\
	}

#define REGISTER_NESTED_LOCS(source, list, comsig, proc) \
	for(var/k in get_nested_locs(source)){\
		var/atom/_A = k;\
		RegisterSignal(_A, comsig, proc);\
		list += _A\
	}

#define UNREGISTER_NESTED_LOCS(list, comsig, index) \
	for(var/k in index to length(list)){\
		var/atom/_A = list[k];\
		UnregisterSignal(_A, comsig);\
		list -= _A\
	}

/**
  * Field of Vision component. Does totally what you probably think it does,
  * ergo preventing players from seeing what's behind them.
  */
/datum/component/field_of_vision
	can_transfer = TRUE

/**
  * That special invisible, almost neigh indestructible movable
  * that holds both shadow cone mask and image and follows the player around.
  */
	var/atom/movable/fov_holder/fov
	///The current screen size this field of vision is meant to fit for.
	var/current_fov_size = list(15, 15)
	///How much is the cone rotated clockwise, purely backend. Please use rotate_shadow_cone() if you must.
	var/angle = 0
	/// Used to scale the shadow cone when rotating it to fit over the edges of the screen.
	var/rot_scale = 1
	/// The inner angle of this cone, right hardset to 90, 180, or 270 degrees, until someone figures out a way to make it dynamic.
	var/shadow_angle = FOV_90_DEGREES
	/// The mask portion of the cone, placed on a * render target plane so while not visible it still applies the filter.
	var/image/shadow_mask
	/// The visual portion of the cone, placed on the highest layer of the wall plane
	var/image/visual_shadow
/**
  * An image whose render_source is kept up to date to prevent the mob (or the topmost movable holding it) from being hidden by the mask.
  * Will make it use vis_contents instead once a few byonds bugs with images and vis contents are fixed.
  */
	var/image/owner_mask
/**
  * A circle image used to somewhat uncover the adjacent portion of the shadow cone, making mobs and objects behind us somewhat visible.
  * The owner mask is still required for those mob going over the default 32x32 px size btw.
  */
	var/image/adj_mask
	/// A list of nested locations the mob is in, to ensure the above image works correctly.
	var/list/nested_locs = list()
/**
  * A static list of offsets based on icon width and height, because render sources are centered unlike most other visuals,
  * and that gives us some problems when the icon is larger or smaller than world.icon_size
  */
	var/static/list/width_n_height_offsets = list()

/datum/component/field_of_vision/Initialize(fov_type = FOV_90_DEGREES, _angle = 0)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	angle = _angle
	shadow_angle = fov_type

/datum/component/field_of_vision/RegisterWithParent()
	. = ..()
	var/mob/M = parent
	if(M.client)
		generate_fov_holder(M, angle)
	RegisterSignal(M, COMSIG_MOB_CLIENT_LOGIN, .proc/on_mob_login)
	RegisterSignal(M, COMSIG_MOB_LOGOUT, .proc/on_mob_logout)
	RegisterSignal(M, COMSIG_MOB_GET_VISIBLE_MESSAGE, .proc/on_visible_message)
	RegisterSignal(M, COMSIG_MOB_EXAMINATE, .proc/on_examinate)
	RegisterSignal(M, COMSIG_MOB_FOV_VIEW, .proc/on_fov_view)
	RegisterSignal(M, COMSIG_MOB_CLIENT_CHANGE_VIEW, .proc/on_change_view)
	RegisterSignal(M, COMSIG_MOB_RESET_PERSPECTIVE, .proc/on_reset_perspective)
	RegisterSignal(M, COMSIG_MOB_FOV_VIEWER, .proc/is_viewer)

/datum/component/field_of_vision/UnregisterFromParent()
	. = ..()
	var/mob/M = parent
	if(!QDELETED(fov))
		if(M.client)
			UnregisterSignal(M, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_MOVABLE_MOVED, COMSIG_MOB_DEATH, COMSIG_LIVING_REVIVE))
			M.client.images -= owner_mask
			M.client.images -= shadow_mask
			M.client.images -= visual_shadow
			M.client.images -= adj_mask
		qdel(fov, TRUE) // Forced.
		fov = null
		QDEL_NULL(owner_mask)
		QDEL_NULL(adj_mask)
	if(length(nested_locs))
		UNREGISTER_NESTED_LOCS(nested_locs, COMSIG_MOVABLE_MOVED, 1)
	UnregisterSignal(M, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT,
							COMSIG_MOB_GET_VISIBLE_MESSAGE, COMSIG_MOB_EXAMINATE,
							COMSIG_MOB_FOV_VIEW, COMSIG_MOB_RESET_PERSPECTIVE,
							COMSIG_MOB_CLIENT_CHANGE_VIEW, COMSIG_MOB_FOV_VIEWER))

/**
  * Generates the holder and images (if not generated yet) and adds them to client.images.
  * Run when the component is registered to a player mob, or upon login.
  */
/datum/component/field_of_vision/proc/generate_fov_holder(mob/M, _angle = 0)
	if(QDELETED(fov))
		fov = new(get_turf(M))
		fov.icon_state = "[shadow_angle]"
		fov.dir = M.dir
		shadow_mask = image('icons/misc/field_of_vision.dmi', fov, "[shadow_angle]", FIELD_OF_VISION_LAYER)
		shadow_mask.plane = FIELD_OF_VISION_PLANE
		visual_shadow = image('icons/misc/field_of_vision.dmi', fov, "[shadow_angle]_v", FIELD_OF_VISION_LAYER)
		visual_shadow.plane = FIELD_OF_VISION_VISUAL_PLANE
		owner_mask = new
		owner_mask.appearance_flags = RESET_TRANSFORM
		owner_mask.plane = FIELD_OF_VISION_BLOCKER_PLANE
		adj_mask = image('icons/misc/field_of_vision.dmi', fov, "adj_mask", FIELD_OF_VISION_LAYER)
		adj_mask.appearance_flags = RESET_TRANSFORM
		adj_mask.plane = FIELD_OF_VISION_BLOCKER_PLANE
		if(_angle)
			rotate_shadow_cone(_angle)
	fov.alpha = M.stat == DEAD ? 0 : 255
	RegisterSignal(M, COMSIG_MOB_DEATH, .proc/hide_fov)
	RegisterSignal(M, COMSIG_LIVING_REVIVE, .proc/show_fov)
	RegisterSignal(M, COMSIG_ATOM_DIR_CHANGE, .proc/on_dir_change)
	RegisterSignal(M, COMSIG_MOVABLE_MOVED, .proc/on_mob_moved)
	RegisterSignal(M, COMSIG_ROBOT_UPDATE_ICONS, .proc/manual_centered_render_source)
	var/atom/A = M
	if(M.loc && !isturf(M.loc))
		REGISTER_NESTED_LOCS(M, nested_locs, COMSIG_MOVABLE_MOVED, .proc/on_loc_moved)
		A = nested_locs[nested_locs.len]
	CENTERED_RENDER_SOURCE(owner_mask, A, src)
	M.client.images += shadow_mask
	M.client.images += visual_shadow
	M.client.images += owner_mask
	M.client.images += adj_mask
	if(M.client.view != "[current_fov_size[1]]x[current_fov_size[2]]")
		resize_fov(current_fov_size, getviewsize(M.client.view))

///Rotates the shadow cone to a certain degree. Backend shenanigans.
/datum/component/field_of_vision/proc/rotate_shadow_cone(new_angle)
	var/simple_degrees = SIMPLIFY_DEGREES(new_angle - angle)
	var/to_scale = cos(simple_degrees) * sin(simple_degrees)
	if(to_scale)
		var/old_rot_scale = rot_scale
		rot_scale = 1 + to_scale
		if(old_rot_scale != rot_scale)
			visual_shadow.transform = shadow_mask.transform = shadow_mask.transform.Scale(rot_scale/old_rot_scale)
	visual_shadow.transform = shadow_mask.transform = shadow_mask.transform.Turn(fov.transform, simple_degrees)

/**
  * Resizes the shadow to match the current screen size.
  * Run when the client view size is changed, or if the player has a viewsize different than "15x15" on login/comp registration.
  */
/datum/component/field_of_vision/proc/resize_fov(list/old_view, list/view)
	current_fov_size = view
	var/old_size = max(old_view[1], old_view[2])
	var/new_size = max(view[1], view[2])
	if(old_size == new_size) //longest edges are still of the same length.
		return
	visual_shadow.transform = shadow_mask.transform = shadow_mask.transform.Scale(new_size/old_size)

/datum/component/field_of_vision/proc/on_mob_login(mob/source, client/client)
	generate_fov_holder(source, angle)

/datum/component/field_of_vision/proc/on_mob_logout(mob/source)
	UnregisterSignal(source, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_MOVABLE_MOVED, COMSIG_MOB_DEATH,
								COMSIG_LIVING_REVIVE, COMSIG_ROBOT_UPDATE_ICONS))
	if(length(nested_locs))
		UNREGISTER_NESTED_LOCS(nested_locs, COMSIG_MOVABLE_MOVED, 1)

/datum/component/field_of_vision/proc/on_dir_change(mob/source, old_dir, new_dir)
	fov.dir = new_dir

///Hides the shadow, other visibility comsig procs will take it into account. Called when the mob dies.
/datum/component/field_of_vision/proc/hide_fov(mob/source)
	fov.alpha = 0

/// Shows the shadow. Called when the mob is revived.
/datum/component/field_of_vision/proc/show_fov(mob/source)
	fov.alpha = 255

/// Hides the shadow when looking through other items, shows it otherwise.
/datum/component/field_of_vision/proc/on_reset_perspective(mob/source, atom/target)
	if(source.client.eye == source || source.client.eye == source.loc)
		fov.alpha = 255
	else
		fov.alpha = 0

/// Called when the client view size is changed.
/datum/component/field_of_vision/proc/on_change_view(mob/source, client, list/old_view, list/view)
	resize_fov(old_view, view)

/**
  * Called when the owner mob moves around. Used to keep shadow located right behind us,
  * As well as modify the owner mask to match the topmost item.
  */
/datum/component/field_of_vision/proc/on_mob_moved(mob/source, atom/oldloc, dir, forced)
	var/turf/T
	if(!isturf(source.loc)) //Recalculate all nested locations.
		UNREGISTER_NESTED_LOCS( nested_locs, COMSIG_MOVABLE_MOVED, 1)
		REGISTER_NESTED_LOCS(source, nested_locs, COMSIG_MOVABLE_MOVED, .proc/on_loc_moved)
		var/atom/movable/topmost = nested_locs[nested_locs.len]
		T = topmost.loc
		CENTERED_RENDER_SOURCE(owner_mask, topmost, src)
	else
		T = source.loc
		if(length(nested_locs))
			UNREGISTER_NESTED_LOCS(nested_locs, COMSIG_MOVABLE_MOVED, 1)
			CENTERED_RENDER_SOURCE(owner_mask, source, src)
	if(T)
		fov.forceMove(T, harderforce = TRUE)

/// Pretty much like the above, but meant for other movables the mob is stored in (bodybags, boxes, mechs etc).
/datum/component/field_of_vision/proc/on_loc_moved(atom/movable/source, atom/oldloc, dir, forced)
	if(isturf(source.loc) && isturf(oldloc)) //This is the case of the topmost movable loc moving around the world, skip.
		fov.forceMove(source.loc, harderforce = TRUE)
		return
	var/atom/movable/prev_topmost = nested_locs[nested_locs.len]
	if(prev_topmost != source)
		UNREGISTER_NESTED_LOCS(nested_locs, COMSIG_MOVABLE_MOVED, nested_locs.Find(source) + 1)
	REGISTER_NESTED_LOCS(source, nested_locs, COMSIG_MOVABLE_MOVED, .proc/on_loc_moved)
	var/atom/movable/topmost = nested_locs[nested_locs.len]
	if(topmost != prev_topmost)
		CENTERED_RENDER_SOURCE(owner_mask, topmost, src)
		if(topmost.loc)
			fov.forceMove(topmost.loc, harderforce = TRUE)

/// A hacky comsig proc for things that somehow decide to change icon on the go. may make a change_icon_file() proc later but...
/datum/component/field_of_vision/proc/manual_centered_render_source(mob/source, old_icon)
	if(!isturf(source.loc))
		return
	CENTERED_RENDER_SOURCE(owner_mask, source, src)

#undef CENTERED_RENDER_SOURCE
#undef REGISTER_NESTED_LOCS
#undef UNREGISTER_NESTED_LOCS

/**
  * Byond doc is not entirely correct on the integrated arctan() proc.
  * When both x and y are negative, the output is also negative, cycling clockwise instead of counter-clockwise.
  * That's also why I am extensively using the SIMPLIFY_DEGREES macro here.
  *
  * Overall this is the main macro that calculates wheter a target is within the shadow cone angle or not.
  */
#define FOV_ANGLE_CHECK(mob, target, zero_x_y_statement, success_statement) \
	var/turf/T1 = get_turf(target);\
	var/turf/T2 = get_turf(mob);\
	if(!T1 || !T2){\
		zero_x_y_statement\
	}\
	var/_x = (T1.x - T2.x);\
	var/_y = (T1.y - T2.y);\
	if(ISINRANGE(_x, -1, 1) && ISINRANGE(_y, -1, 1)){\
		zero_x_y_statement\
	}\
	var/dir = (mob.dir & (EAST|WEST)) || mob.dir;\
	var/_degree = -angle;\
	var/_half = shadow_angle/2;\
	switch(dir){\
		if(EAST){\
			_degree += 180;\
		}\
		if(NORTH){\
			_degree += 270;\
		}\
		if(SOUTH){\
			_degree += 90;\
		}\
	}\
	var/_min = SIMPLIFY_DEGREES(_degree - _half);\
	var/_max = SIMPLIFY_DEGREES(_degree + _half);\
	if((_min > _max) ? !ISINRANGE(SIMPLIFY_DEGREES(arctan(_x, _y)), _max, _min) : ISINRANGE(SIMPLIFY_DEGREES(arctan(_x, _y)), _min, _max)){\
		success_statement;\
	}

/datum/component/field_of_vision/proc/on_examinate(mob/source, atom/target)
	if(fov.alpha)
		FOV_ANGLE_CHECK(source, target, return, return COMPONENT_DENY_EXAMINATE|COMPONENT_EXAMINATE_BLIND)

/datum/component/field_of_vision/proc/on_visible_message(mob/source, atom/target, message, range, list/ignored_mobs)
	if(fov.alpha)
		FOV_ANGLE_CHECK(source, target, return, return COMPONENT_NO_VISIBLE_MESSAGE)

/datum/component/field_of_vision/proc/on_fov_view(mob/source, list/atoms)
	if(!fov.alpha)
		return
	for(var/k in atoms)
		var/atom/A = k
		FOV_ANGLE_CHECK(source, A, continue, atoms -= A)

/datum/component/field_of_vision/proc/is_viewer(mob/source, atom/center, depth, list/viewers_list)
	if(fov.alpha)
		FOV_ANGLE_CHECK(source, center, return, viewers_list -= source)

#undef FOV_ANGLE_CHECK

/**
  * The shadow cone's mask and visual images holder which can't locate inside the mob,
  * lest they inherit the mob opacity and cause a lot of hindrance
  */
/atom/movable/fov_holder
	name = "field of vision holder"
	pixel_x = -224 //the image is about 480x480 px, ergo 15 tiles (480/32) big, and we gotta center it.
	pixel_y = -224
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FIELD_OF_VISION_PLANE
	anchored = TRUE

/atom/movable/fov_holder/ConveyorMove()
	return

/atom/movable/fov_holder/has_gravity(turf/T)
	return FALSE

/atom/movable/fov_holder/ex_act(severity)
	return FALSE

/atom/movable/fov_holder/singularity_act()
	return

/atom/movable/fov_holder/singularity_pull()
	return

/atom/movable/fov_holder/blob_act()
	return

/atom/movable/fov_holder/onTransitZ()
	return

/// Prevents people from moving these after creation, because they shouldn't be.
/atom/movable/fov_holder/forceMove(atom/destination, no_tp=FALSE, harderforce = FALSE)
	if(harderforce)
		return ..()

/// Last but not least, these shouldn't be deleted by anything but the component itself
/atom/movable/fov_holder/Destroy(force = FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()
