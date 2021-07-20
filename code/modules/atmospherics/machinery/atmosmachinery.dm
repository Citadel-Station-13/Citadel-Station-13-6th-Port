// Quick overview:
//
// Pipes combine to form pipelines
// Pipelines and other atmospheric objects combine to form pipe_networks
//   Note: A single pipe_network represents a completely open space
//
// Pipes -> Pipelines
// Pipelines + Other Objects -> Pipe network

#define PIPE_VISIBLE_LEVEL 2
#define PIPE_HIDDEN_LEVEL 1

/obj/machinery/atmospherics
	anchored = TRUE
	move_resist = INFINITY				//Moving a connected machine without actually doing the normal (dis)connection things will probably cause a LOT of issues.
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	layer = GAS_PIPE_HIDDEN_LAYER //under wires
	plane = ABOVE_WALL_PLANE
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	/// See __DEFINES/atmospherics
	var/pipe_flags = NONE
	/// The layer we're on. Overriden by PIPE_ALL_LAYER
	var/pipe_layer = PIPE_LAYER_DEFAULT
	/// Does this interact with the environment or just with pipenets? If so, it needs to be TRUE so we set it to the right processing bracket.
	var/interacts_with_air = FALSE
	/// List of atmosmachinery we're connected to
	var/list/obj/machinery/atmospherics/connected
	/// Device type, determining the number of connections we have. If we're PIPE_ALL_LAYER, this is multiplied by total pipe layers.
	var/device_type = NONE
	/// Directions we'll connect in. Set dynamically by our dir.
	var/initialize_directions = NONE

	var/nodealert = 0
	var/can_unwrench = 0
	var/pipe_color

	var/static/list/iconsetids = list()
	var/static/list/pipeimages = list()

	var/image/pipe_vision_img = null

	var/construction_type
	var/pipe_state //icon_state as a pipe item
	var/on = FALSE

/obj/machinery/atmospherics/examine(mob/user)
	. = ..()
	if(is_type_in_list(src, GLOB.ventcrawl_machinery) && isliving(user))
		var/mob/living/L = user
		if(SEND_SIGNAL(L, COMSIG_CHECK_VENTCRAWL))
			. += "<span class='notice'>Alt-click to crawl through it.</span>"

/obj/machinery/atmospherics/Initialize(mapload, process = TRUE, setdir, setlayer, constructed = FALSE)
	if(!isnull(setdir))
		setDir(setdir)
	if(!isnull(setlayer))
		pipe_layer = setlayer
	if (!armor)
		armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70)
	. = ..()
	if(process)
		if(interacts_with_air)
			SSair.atmos_air_machinery += src
		else
			SSair.atmos_machinery += src
	if(!SSair.initialized && !constructed)
		// if not custom constructing, immediately init
		InitAtmos()

/**
 * Called once on init.
 */
/obj/machinery/atmospherics/proc/InitAtmos()
	connected = new /list(MaximumPossibleNodes())
	Join()

/**
 * Snowflaked because pipes are not nearly even machinery at this point
 * Called on construction to begin init.
 * The proper way to do this is to have constructed = FALSE in the new() call for pipes, and then call this to set everything.
 */
/obj/machinery/atmospherics/proc/InitConstructed(set_color, set_dir, set_layer)
	SHOULD_CALL_PARENT(TRUE)
	if(set_color)
		pipe_color = set_color
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	if(set_layer)
		SetPipingLayer(set_layer)
	var/turf/T = get_turf(src)
	level = T.intact ? 2 : 1
	if(set_dir)
		setDir(set_dir)
	if(!SSair.initialized)
		InitAtmos()

/**
 * Called to join its place in a network.
 */
/obj/machinery/atmospherics/proc/Join()
	if(QDELETED(src))
		CRASH("Attempted to Join() while waiting for GC")
	if(pipe_flags & PIPE_NETWORK_JOINED)
		CRASH("Attempted to Join() while already joined to network.")
	var/conflict
	if(!((conflict = CheckLocationConflict(loc, pipe_layer)) == PIPE_LOCATION_CLEAR))
		CRASH("Attempted to Join() with a conflict([conflict]) at location.")
	PreJoin()
	pipe_flags |= PIPE_NETWORK_JOINED
	if(Connect())
		QueueRebuild()
	update_appearance()

/**
 * Called during Join() just before connecting
 */
/obj/machinery/atmospherics/proc/PreJoin()
	if(pipe_flags & PIPE_CARDINAL_AUTONORMALIZE)
		NormalizeCardinalDirections()
	SetInitDirections()

/**
 * Called to leave its place in a network.
 */
/obj/machinery/atmospherics/proc/Leave()
	if(QDELETED(src))
		CRASH("Attempted to Leave() while waiting for GC")
	if(!(pipe_flags & PIPE_NETWORK_JOINED))
		CRASH("Attempted to Leave() without being joined to network.")
	pipe_flags &= ~PIPE_NETWORK_JOINED
	Disconnect()
	update_appearance()

/obj/machinery/atmospherics/Moved(atom/OldLoc, Dir)
	. = ..()
	if(pipe_flags & PIPE_NETWORK_JOINED)
		stack_trace("Atmos machinery moved while network was joined. This is bad.")
		Leave()
		Join()

/obj/machinery/atmospherics/forceMove(atom/destination)
	Leave()
	. = ..()
	Join()

/**
 * Called to rebuild its pipenet(s)
 */
/obj/machinery/atmospherics/proc/Rebuild()
	pipe_flags &= ~PIPE_REBUILD_QUEUED
	Build()

/**
 * Queues us for a pipenet rebuild.
 */
/obj/machinery/atmospherics/proc/QueueRebuild()
	if(pipe_flags & PIPE_REBUILD_QUEUED)
		return
	SSair.queue_for_rebuild(src)
	pipe_flags |= PIPE_REBUILD_QUEUED

/obj/machinery/atmospherics/Destroy()
	Leave()
	SSair.atmos_machinery -= src
	SSair.atmos_air_machinery -= src

	dropContents()
	if(pipe_vision_img)
		qdel(pipe_vision_img)

	return ..()
	//return QDEL_HINT_FINDREFERENCE

/**
 * Connects us to our neighbors.
 * Does not build network, just sets nodes.
 * Returns if we found anyone.
 */
/obj/machinery/atmospherics/proc/Connect()
	. = FALSE
	connected = list()
	var/list/current = list()
	var/list/node_order = GetNodeOrder()
	for(var/i in 1 to device_type)
		for(var/obj/machinery/atmospherics/target in get_step(src, node_order[i]))
			if(current[target])
				continue
			if(CanConnect(other, i))
				. = TRUE
				current[target] = TRUE
				connected[GetNodePosition(node_order[i], other.layer)] = other
				var/their_order = other.GetNodePosition(get_dir(other, src), pipe_layer)
				if(!their_order)
					stack_trace("Couldn't find where to place ourselves in other's nodes. Us: [src]([COORD(src)]) Them: [other]([COORD(other)]")
				else if(their_order != null)
					stack_trace("Attempted to connect to something that's already connected on that side. Us: [src]([COORD(src)]) Them: [other]([COORD(other)]")
				other.connected[their_order] = src
				other.update_appearance()

/**
 * Determines node order.
 * This should always be deterministic!
 */
/obj/machinery/atmospherics/proc/GetNodePosition(dir, layer)
	. = 0
	for(var/D in GLOB.cardinals_multiz)
		if(D & GetInitDirections())
			++.
		if(D == dir)
			return D * ((pipe_flags * PIPE_ALL_LAYER)? (PIPE_LAYER_MIN - layer + 1) : 1)
	CRASH("Failed to find valid position ([dir], [layer])")

/**
 * Gets the order to scan nodes in.
 * This should always be deterministic!
 */
/obj/machinery/atmospherics/proc/GetNodeOrder()
	. = new /list(device_type)
	for(var/i in 1 to device_type)
		for(var/D in GLOB.cardinals_multiz)
			if(D & GetInitDirections())
				if(D in .)
					continue
				.[i] = D
				break

/**
 * Disconnects us from our neighbors.
 * Immediately tears down networks.
 */
/obj/machinery/atmospherics/proc/Disconnect()
	Teardown()
	for(var/obj/machinery/atmospherics/other as anything in connected)
		var/pos = other.connected.Find(src)
		if(!pos)
			stack_trace("Couldn't find ourselves in other while disconnecting.")
			continue
		other.connected[pos] = null
		other.update_appearance()
	connected.len = 0
	connected.len = device_type

/**
 * Constructs our pipeline if we don't have one
 */
/obj/machinery/atmospherics/proc/Build()
	return

/**
 * Tears down our pipeline.
 */
/obj/machinery/atmospherics/proc/Teardown()
	return

/**
 * Gets the maximum number of nodes we can have.
 * This determines the size of our nodes list.
 */
/obj/machinery/atmospherics/proc/MaximumPossibleNodes()
	return device_type * ((pipe_flags & PIPE_ALL_LAYER)? PIPE_LAYER_TOTAL : 1)

/**
 * Calls update appearance on all connected nodes
 */
/obj/machinery/atmospherics/proc/UpdateConnectedIcons()
	for(var/obj/machinery/atmospherics/A in connected)
		A.update_appearance()

/**
 * If our pipe flags state to normalize cardinals, ensure that we're NORTH|SOUTH or EAST|WEST by normalizing to NORTH or EAST, instead of allowing all 4 directions.
 */
/obj/machinery/atmospherics/proc/NormalizeCardinalDirections()
	switch(dir)
		if(SOUTH)
			setDir(NORTH)
		if(WEST)
			setDir(EAST)

/**
 * Ensures our init directions are set properly
 */
/obj/machinery/atmospherics/proc/SetInitDirections()
	return

/**
 * Gets our init directions
 */
/obj/machinery/atmospherics/proc/GetInitDirections()
	return initialize_directions

/**
 * Modifies our piping layer.
 */
/obj/machinery/atmospherics/proc/SetPipingLayer(new_layer)
	if(!(CheckLocationConflict(loc, new_layer) != PIPE_LOCATION_CLEAR))
		CRASH("Attempted to set piping layer to a conflicting layer.")
	Leave()
	pipe_layer = (pipe_flags & PIPE_DEFAULT_LAYER_ONLY) ? PIPE_LAYER_DEFAULT : new_layer
	Join()
	update_appearance()

/**
 * Checks our current location for conflicts
 */
/obj/machinery/atmospherics/proc/CheckLocationConflict(turf/T = get_turf(src), layer = pipe_layer)
	var/turf_hogging = pipe_flags & PIPE_ONE_PER_TURF
	for(var/obj/machinery/atmospherics/A in T)
		if(A.pipe_flags & turf_hogging)
			return PIPE_LOCATION_TILE_HOGGED
		if((A.pipe_layer == pipe_layer) && (A.initialize_directions & initialize_directions))
			return PIPE_LOCATION_DIR_CONFLICT
	return PIPE_LOCATION_CLEAR

/**
 * Checks if a target pipe can be a node.
 */
/obj/machinery/atmospherics/proc/CanConnect(obj/machinery/atmospherics/other, node)
	return StandardConnectionCheck(other) && (pipe_flags & PIPE_NETWORK_JOINED) && (other.pipe_flags & PIPE_NETWORK_JOINED)

/**
 * Finds a connecting object in a direction + given layer
 * Explicitly does not return a list of objects.
 * The only things that should connect to more than one layer at a time right now are layer manifolds, and mains pipes
 * And in both cases there needs to be special handling.
 */
/// Unused for now - Attempting to have all behavior be generic for both one layer and all layer devices.
/obj/machinery/atmospherics/proc/FindConnecting(direction, layer = pipe_layer)
	for(var/obj/machinery/atmospherics/other in get_step(src, direction))
		if(CanConnect(other))
			return other

/**
 * Standard two-way connection check
 */
/obj/machinery/atmospherics/proc/StandardConnectionCheck(obj/machinery/atmospherics/other, layer = pipe_layer)
	return (initialize_directions & get_dir(src, other)) && (get_dist(other) <= 1) && (other.initialize_directions & get_dir(other, src)) && StandardCanLayersConnect(other, layer) && other.StandardCanLayersConnect(src, layer)

/**
 * One way connection check
 */
/obj/machinery/atmospherics/proc/StandardCanLayersConnect(obj/machinery/atmospherics/other, layer = pipe_layer)
	return (other.pipe_layer == layer) || (other.pipe_flags & PIPE_ALL_LAYER)

/**
 * Used during pipeline builds.
 * Returns a list of things we're directly connected to.
 */
/obj/machinery/atmospherics/proc/DirectConnection(datum/pipeline/querying, obj/machinery/atmospherics/source)
	return list()

/**
 * Replaces a pipenet with another
 */
/obj/machinery/atmospherics/proc/ReplacePipeline(datum/pipeline/old, datum/pipeline/replacing)
	CRASH("Base ReplacePipeline called [old] [replacing] on [src]")

/**
 * Sets our pipenet to something. Used during pipeline initial builds.
 */
/obj/machinery/atmospherics/proc/SetPipeline(datum/pipeline/setting, obj/machinery/atmospherics/source)
	CRASH("Base SetPipeline called [setting] [source] on [src]")

/**
 * Nullifies a pipenet from us
 */
/obj/machinery/atmospherics/proc/NullifyPipeline(datum/pipeline/removing)
	CRASH("Base NullifyPipeline called [removing] on [src]")

/**
 * Releases our air to the environment
 */
/obj/machinery/atmospherics/proc/ReleaseAirToTurf()
	CRASH("Base ReleaseAirToTurf called on [src]")

/**
 * Returns all pipelines this is a part of.
 */
/obj/machinery/atmospherics/proc/ReturnPipelines()
	return list()

/**
 * Icon update proc: Updates our pipe layer visuals
 */
/obj/machinery/atmospherics/proc/update_layer()
	return

/**
 * Icon update proc: Updates our alpha
 */
/obj/machinery/atmospherics/proc/update_alpha()
	return

/obj/machinery/atmospherics/update_appearance(updates)
	. = ..()
	update_layer()
	update_alpha()

/obj/machinery/atmospherics/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe)) //lets you autodrop
		var/obj/item/pipe/pipe = W
		if(user.dropItemToGround(pipe))
			pipe.setPipingLayer(pipe_layer) //align it with us
			return TRUE
	else
		return ..()

/obj/machinery/atmospherics/wrench_act(mob/living/user, obj/item/I)
	if(!can_unwrench(user))
		return ..()

	var/turf/T = get_turf(src)
	if (level==1 && isturf(T) && T.intact)
		to_chat(user, "<span class='warning'>You must remove the plating first!</span>")
		return TRUE

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	add_fingerprint(user)

	var/unsafe_wrenching = FALSE
	var/internal_pressure = int_air.return_pressure()-env_air.return_pressure()

	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")

	if (internal_pressure > 2*ONE_ATMOSPHERE)
		to_chat(user, "<span class='warning'>As you begin unwrenching \the [src] a gush of air blows in your face... maybe you should reconsider?</span>")
		unsafe_wrenching = TRUE //Oh dear oh dear

	if(I.use_tool(src, user, 20, volume=50))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"<span class='notice'>You unfasten \the [src].</span>", \
			"<span class='italics'>You hear ratchet.</span>")
		investigate_log("was <span class='warning'>REMOVED</span> by [key_name(usr)]", INVESTIGATE_ATMOS)

		//You unwrenched a pipe full of pressure? Let's splat you into the wall, silly.
		if(unsafe_wrenching)
			unsafe_pressure_release(user, internal_pressure)
		deconstruct(TRUE)
	return TRUE

/obj/machinery/atmospherics/proc/can_unwrench(mob/user)
	return can_unwrench

// Throws the user when they unwrench a pipe with a major difference between the internal and environmental pressure.
/obj/machinery/atmospherics/proc/unsafe_pressure_release(mob/user, pressures = null)
	if(!user)
		return
	if(!pressures)
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		pressures = int_air.return_pressure() - env_air.return_pressure()

	user.visible_message("<span class='danger'>[user] is sent flying by pressure!</span>","<span class='userdanger'>The pressure sends you flying!</span>")

	// if get_dir(src, user) is not 0, target is the edge_target_turf on that dir
	// otherwise, edge_target_turf uses a random cardinal direction
	// range is pressures / 250
	// speed is pressures / 1250
	user.throw_at(get_edge_target_turf(user, get_dir(src, user) || pick(GLOB.cardinals)), pressures / 250, pressures / 1250)

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(can_unwrench)
			var/obj/item/pipe/stored = new construction_type(loc, null, dir, src)
			stored.setPipingLayer(pipe_layer)
			if(!disassembled)
				stored.obj_integrity = stored.max_integrity * 0.5
			transfer_fingerprints_to(stored)
	..()

/obj/machinery/atmospherics/proc/getpipeimage(iconset, iconstate, direction, col=rgb(255,255,255), pipe_layer=2)

	//Add identifiers for the iconset
	if(iconsetids[iconset] == null)
		iconsetids[iconset] = num2text(iconsetids.len + 1)

	//Generate a unique identifier for this image combination
	var/identifier = iconsetids[iconset] + "_[iconstate]_[direction]_[col]_[pipe_layer]"

	if((!(. = pipeimages[identifier])))
		var/image/pipe_overlay
		pipe_overlay = . = pipeimages[identifier] = image(iconset, iconstate, dir = direction)
		pipe_overlay.color = col
		PIPE_LAYER_SHIFT(pipe_overlay, pipe_layer)

/obj/machinery/atmospherics/Entered(atom/movable/AM)
	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		L.ventcrawl_layer = pipe_layer
	return ..()

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)
	return ..()

#define VENT_SOUND_DELAY 30

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	direction &= initialize_directions
	if(!direction || !(direction in GLOB.cardinals)) //cant go this way.
		return

	if(user in buckled_mobs)// fixes buckle ventcrawl edgecase fuck bug
		return

	var/obj/machinery/atmospherics/target_move = FindConnecting(direction, user.ventcrawl_layer)
	if(target_move)
		if(target_move.can_crawl_through())
			if(is_type_in_typecache(target_move, GLOB.ventcrawl_machinery))
				user.forceMove(target_move.loc) //handle entering and so on.
				user.visible_message("<span class='notice'>You hear something squeezing through the ducts...</span>", "<span class='notice'>You climb out the ventilation system.")
			else
				var/list/pipenetdiff = ReturnPipelines() ^ target_move.ReturnPipelines()
				if(pipenetdiff.len)
					user.update_pipe_vision(target_move)
				user.forceMove(target_move)
				user.client.eye = target_move  //Byond only updates the eye every tick, This smooths out the movement
				if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
					user.last_played_vent = world.time
					playsound(src, 'sound/machines/ventcrawl.ogg', 50, 1, -3)
	else if(is_type_in_typecache(src, GLOB.ventcrawl_machinery) && can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
		user.forceMove(loc)
		user.visible_message("<span class='notice'>You hear something squeezing through the ducts...</span>", "<span class='notice'>You climb out the ventilation system.")

/obj/machinery/atmospherics/AltClick(mob/living/L)
	if(is_type_in_typecache(src, GLOB.ventcrawl_machinery))
		return SEND_SIGNAL(L, COMSIG_HANDLE_VENTCRAWL, src)
	return ..()

/obj/machinery/atmospherics/proc/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	user.sight |= (SEE_TURFS|BLIND)

//Used for certain children of obj/machinery/atmospherics to not show pipe vision when mob is inside it.
/obj/machinery/atmospherics/proc/can_see_pipes()
	return TRUE

/obj/machinery/atmospherics/proc/update_layer()
	layer = initial(layer) + (pipe_layer - PIPE_LAYER_DEFAULT) * PIPE_LAYER_LCHANGE
