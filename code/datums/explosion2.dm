/// Creates a wave explosion at a certain place
/proc/wave_explosion(turf/target, power, factor = EXPLOSION_DEFAULT_FALLOFF_MULTIPLY, constant = EXPLOSION_DEFAULT_FALLOFF_SUBTRACT, flash = 0, fire = 0, atom/source, speed = 0,
	silent = FALSE, bypass_logging = FALSE, block_resistance = 1, start_immediately = TRUE)
	if(!istype(target) || (power <= EXPLOSION_POWER_DEAD))
		return
	if(!bypass_logging)
		var/logstring = "Wave explosion at [COORD(target)]: [power]/[factor]/[constant]/[flash]/[fire]/[speed] initial/factor/constant/flash/fire/speed"
		log_game(logstring)
		message_admins(logstring)
	return new /datum/wave_explosion(target, power, factor, constant, flash, fire, source, speed, silent, start_immediately, block_resistance)

/**
  * New force-blastwave explosion system
  */
/datum/wave_explosion
	/// Next unique numerical ID
	var/static/next_id = 0
	/// Our unique nuumerical ID
	var/id
	/// world.time we started at
	var/start_time
	/// Are we currently running?
	var/running = FALSE
	/// Are we currently finished?
	var/finished = FALSE
	/// What atom we originated from, if any
	var/atom/source

	/// Explosion power at which point to consider to be a dead expansion
	var/power_considered_dead = EXPLOSION_POWER_DEAD
	/// Explosion power we were initially at
	var/power_initial
	/// Base explosion power falloff multiplier (applied first)
	var/power_falloff_factor = EXPLOSION_DEFAULT_FALLOFF_MULTIPLY
	/// Base explosion power falloff subtract (applied second)
	var/power_falloff_constant = EXPLOSION_DEFAULT_FALLOFF_SUBTRACT
	/// Flash range
	var/flash_range = 0
	/// Fire probability per tile
	var/fire_probability = 0
	/// Are we silent/do we make the screenshake/sounds?
	var/silent = FALSE

	// Modifications
	/// Object damage mod
	var/object_damage_mod = 1
	/// Hard obstcales get this mod INSTEAD of object damage mod
	var/hard_obstacle_mod = 1
	/// Window shatter mod. Overrides both [hard_obstcale_mod] and [object_damage_mod]
	var/window_shatter_mod = 1
	/// Wall destruction mod
	var/wall_destroy_mod = 1
	/// Mob damage mod
	var/mob_damage_mod = 1
	/// Mob gib mod
	var/mob_gib_mod = 1
	/// Mob deafen mod
	var/mob_deafen_mod = 1
	/// block = block / this, if 0 any block is absolute
	var/block_resistance = 1

	// Rewrite count: 2
	// Each cycle is a "perfect ring".
	// We run into the problem that diagonal hitboxes don't exist on 2d grid games.
	// How we deal with this is this:
	// The first half of each cycle explodes cardinal directions awaiting expansion first
	// Diagonals get added to a potential diagonals list.
	// The second half of each cycle checks the potential diagonals list. If something isn't on the exploded list,
	// we know it's a valid diagonal and explode it.
	// Then all exploded turfs are flushed to exploded_last and it continues.
	// Direction bitflags use the WEX_DIR_X flags so we can keep track of more than one direction in a single field
	// The insanity begins when I realized that doing cardinals are easy but diagonals require:
	// - Tallying the explosive power that should go into it
	// - Exploding it afterwards using the tallied power rather than passed power (so corners aren't far weaker unless there's one side of it blocked)
	// Expanding the explosion power of the now exploded diagonal into the two dirs its cardinals are in
	// If this is done using a perfect algorithm it should be relatively efficient and result in a near-perfect shockwave simulation.

	/// The last ring that's been exploded. Any turfs in this will completely ignore the current cycle. Turf = TRUE
	var/list/turf/exploded_last = list()
	/// The "edges" + dirs that need to be processed this cycle. turf = dir flags
	var/list/turf/edges = list()
	/// The powers of the current turf edges. turf = power
	var/list/turf/powers = list()

	/// What cycle are we on?
	var/cycle
	/// When we started the current cycle
	var/cycle_start
	/// Time to wait between cycles
	var/cycle_speed = 0
	/// Current index for list
	var/index = 1

/datum/wave_explosion/New(turf/initial, power, factor = EXPLOSION_DEFAULT_FALLOFF_MULTIPLY, constant = EXPLOSION_DEFAULT_FALLOFF_SUBTRACT, flash = 0, fire = 0, atom/source, speed = 0, silent = FALSE, autostart = TRUE, block_resistance = 1)
	id = ++next_id
	if(next_id > SHORT_REAL_LIMIT)
		next_id = 0
	SSexplosions.wave_explosions += src
	src.power_initial = power
	src.power_falloff_factor = factor
	src.power_falloff_constant = constant
	src.flash_range = flash
	src.fire_probability = fire
	src.source = source
	src.cycle_speed = speed
	src.silent = silent
	src.block_resistance = block_resistance
	if(!istype(initial))
		stack_trace("Wave explosion created without a turf. This better be for debugging purposes.")
		return
	if(autostart)
		start(initial)

/datum/wave_explosion/Destroy()
	if(running)
		stop(FALSE)
	return ..()

/// IF THIS DOESN'T GET DETECTED BLAME @silicons IT'S NOT MY FUCKING FAULT
/datum/wave_explosion/proc/start(list/turf/_starting)
	if(running)
		CRASH("Attempted to start() a running wave explosion")
	if(!islist(_starting))
		_starting = list(_starting)
	var/list/mob/to_flash = list()
	var/list/feedback = list()
	var/list/mob/mob_potential_shake = list()
	var/list/mob/closest_to = list()
	for(var/i in 1 to _starting.len)
		var/turf/starting = _starting[i]
		edges[starting] = WEX_ALLDIRS
		powers[starting] = power_initial
		var/x0 = starting.x
		var/y0 = starting.y
		var/z0 = starting.z
		var/area/areatype = get_area(starting)
		feedback += list(list("power" = power_initial, factor = "factor", constant = "constant", flash = "flash", fire = "fire", speed = "speed", "x" = x0, "y" = y0, "z" = z0, "area" = areatype.type, "time" = TIME_STAMP("YYYY-MM-DD hh:mm:ss", 1)))
		// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
		// Stereo users will also hear the direction of the explosion!

		// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
		// 3/7/14 will calculate to 80 + 35

		if(!silent)
			for(var/mob/M in GLOB.player_list)
				// Double check for client
				var/turf/M_turf = get_turf(M)
				if(M_turf && M_turf.z == z0)
					var/dist = get_dist(M_turf, starting)
					if(isnull(mob_potential_shake[M]))
						mob_potential_shake[M] = dist
						closest_to[M] = starting
					else if(mob_potential_shake[M] < dist)
						mob_potential_shake[M] = dist
						closest_to[M] = starting

		// Flash mobs
		if(flash_range)
			for(var/mob/living/L in viewers(flash_range, starting))
				to_flash |= L

	if(!silent)
		var/frequency = get_rand_frequency()
		var/sound/explosion_sound = sound(get_sfx("explosion"))
		var/sound/far_explosion_sound = sound('sound/effects/explosionfar.ogg')

		var/far_dist = sqrt(power_initial) * 7.5

		for(var/mob/M in mob_potential_shake)
			var/dist = mob_potential_shake[M]
			var/baseshakeamount
			if(sqrt(power_initial) - dist > 0)
				baseshakeamount = sqrt((sqrt(power_initial) - dist)*0.1)
			// If inside the blast radius + world.view - 2
			if(dist <= round(2 * sqrt(power_initial) + world.view - 2, 1))
				M.playsound_local(closest_to[M], null, 100, 1, frequency, max_distance = 5, S = explosion_sound)
				if(baseshakeamount > 0)
					shake_camera(M, 25, clamp(baseshakeamount, 0, 10))
			// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
			else if(dist <= far_dist)
				var/far_volume = clamp(far_dist, 30, 50) // Volume is based on explosion size and dist
				far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
				M.playsound_local(closest_to[M], null, far_volume, 1, frequency, max_distance = 5, S = far_explosion_sound)
				if(baseshakeamount > 0)
					shake_camera(M, 10, clamp(baseshakeamount*0.25, 0, 2.5))

	for(var/i in 1 to to_flash.len)
		var/mob/living/L = to_flash[i]
		L.flash_act()

	SSblackbox.record_feedback("associative", "wave_explosion", 1, feedback)

	if(!cycle)
		cycle = 1
	SSexplosions.active_wave_explosions += src
	running = TRUE
	cycle_start = world.time - cycle_speed
	tick()

/datum/wave_explosion/proc/stop(delete = TRUE)
	SSexplosions.active_wave_explosions -= src
	SSexplosions.currentrun -= src
	edges = null
	powers = null
	exploded_last = null
	cycle = null
	running = FALSE
	qdel(src)

#define SHOULD_SUSPEND ((cycle_start + cycle_speed) > world.time)

/**
  * Called by SSexplosions to propagate this.
  * Return TRUE if postponed
  */
/datum/wave_explosion/proc/tick()
	/// Each tick goes through one full cycle.
	// This can be changed to a "continuous process" system where indexes are tracked if needed.
	if(!src.edges.len)
		// we're done
		finished = TRUE
		stop(TRUE)
		return TRUE
	if(SHOULD_SUSPEND)
		return TRUE
	// Set up variables
	var/turf/T
	var/turf/expanding
	var/power
	var/returned
	var/blocked
	var/dir
	// insanity define to explode a turf with a certain amount of power, direction, and set returned.
#define WEX_ACT(_T, _P, _D)  \
	returned = max(0, _T.wave_explode(_P, src, _D)); \
	blocked = _P - returned; \
	if(!block_resistance) { \
		if(blocked > EXPLOSION_POWER_NO_RESIST_THRESHOLD) { \
			returned = 0; \
		} \
	} \
	else if(blocked) { \
		returned = _P - (blocked / block_resistance); \
	}; \
	returned = round((returned * power_falloff_factor) - power_falloff_constant, EXPLOSION_POWER_QUANTIZATION_ACCURACY); \
	if(prob(fire_probability)) { \
		new /obj/effect/hotspot(_T); \
	};

	// Cache hot lists
	var/list/turf/edges = src.edges
	var/list/turf/powers = src.powers
	var/list/turf/exploded_last = src.exploded_last

	// prepare expansions
	var/list/turf/edges_next = list()
	var/list/turf/powers_next = list()
	var/list/turf/powers_returned = list()
	var/list/turf/diagonals = list()
	var/list/turf/diagonal_powers = list()
	var/list/turf/diagonal_powers_max = list()

	// to_chat(world, "DEBUG: cycle start edges [english_list_assoc(edges)]")

	// Process cardinals:
	// Explode all cardinals and expand in directions, gathering all cardinals it should go to.
	// Power for when things meet in the middle should be the greatest of the two.
	for(var/i in edges)
		T = i
		power = powers[T]
		dir = edges[T]
		WEX_ACT(T, power, dir)
		if(returned < power_considered_dead)
			continue
		powers_returned[T] = returned
	// diagonal power calc when multiple things hit one diagonal
#define CALCULATE_DIAGONAL_POWER(existing, adding, maximum) min(maximum, existing + adding)
	// diagonal hitting cardinal expansion
#define CALCULATE_DIAGONAL_CROSS_POWER(existing, adding) max(existing, adding)
	// insanity define to mark the next set of cardinals.
#define CARDINAL_MARK(ndir, cdir, edir) \
	if(edir & cdir) { \
		CARDINAL_MARK_NOCHECK(ndir, cdir, edir); \
	};

#define CARDINAL_MARK_NOCHECK(ndir, cdir, edir) \
	expanding = get_step(T,ndir); \
	if(expanding && !exploded_last[expanding] && !edges[expanding]) { \
		powers_next[expanding] = max(powers_next[expanding], returned); \
		edges_next[expanding] = (cdir | edges_next[expanding]); \
	};

	// insanity define to do diagonal marking as 2 substeps
#define DIAGONAL_SUBSTEP(ndir, cdir, edir) \
	expanding = get_step(T,ndir); \
	if(expanding && !exploded_last[expanding] && !edges[expanding]) { \
		if(!edges_next[expanding]) { \
			diagonal_powers_max[expanding] = max(diagonal_powers_max[expanding], returned, powers[T]); \
			diagonal_powers[expanding] = CALCULATE_DIAGONAL_POWER(diagonal_powers[expanding], returned, diagonal_powers_max[expanding]); \
			diagonals[expanding] = (cdir | diagonals[expanding]); \
		}; \
		else { \
			powers_next[expanding] = CALCULATE_DIAGONAL_CROSS_POWER(powers_next[expanding], returned); \
		}; \
	};

	// insanity define to mark the diagonals that would otherwise be missed
#define DIAGONAL_MARK(ndir, cdir, edir) \
	if(edir & cdir) { \
		DIAGONAL_MARK_NOCHECK(ndir, cdir, edir); \
	};

	// this only works because right now, WEX_DIR_X is the same as a byond dir
	// and we know we're only passing in one dir at a time.
	// if this ever stops being the case, and explosions break when you touch this, now you know why.
#define DIAGONAL_MARK_NOCHECK(ndir, cdir, edir) \
	DIAGONAL_SUBSTEP(turn(ndir, 90), turn(cdir, 90), edir); \
	DIAGONAL_SUBSTEP(turn(ndir, -90), turn(cdir, -90), edir);

	// mark
#define MARK(ndir, cdir, edir) \
	if(edir & cdir) { \
		CARDINAL_MARK_NOCHECK(ndir, cdir, edir); \
		DIAGONAL_MARK_NOCHECK(ndir, cdir, edir); \
	};
		CARDINAL_MARK(NORTH, WEX_DIR_NORTH, dir)
		CARDINAL_MARK(SOUTH, WEX_DIR_SOUTH, dir)
		CARDINAL_MARK(EAST, WEX_DIR_EAST, dir)
		CARDINAL_MARK(WEST, WEX_DIR_WEST, dir)

	// to_chat(world, "DEBUG: cycle mid edges_next [english_list_assoc(edges_next)]")

	// Sweep after cardinals for diagonals
	for(var/i in edges)
		T = i
		power = powers[T]
		dir = edges[T]
		returned = powers_returned[T]
		DIAGONAL_MARK(NORTH, WEX_DIR_NORTH, dir)
		DIAGONAL_MARK(SOUTH, WEX_DIR_SOUTH, dir)
		DIAGONAL_MARK(EAST, WEX_DIR_EAST, dir)
		DIAGONAL_MARK(WEST, WEX_DIR_WEST, dir)

	// to_chat(world, "DEBUG: cycle mid diagonals [english_list_assoc(diagonals)]")

	// Process diagonals:
	for(var/i in diagonals)
		T = i
		power = diagonal_powers[T]
		dir = diagonals[T]
		WEX_ACT(T, power, dir)
		if(returned < power_considered_dead)
			continue
		CARDINAL_MARK(NORTH, WEX_DIR_NORTH, dir)
		CARDINAL_MARK(SOUTH, WEX_DIR_SOUTH, dir)
		CARDINAL_MARK(EAST, WEX_DIR_EAST, dir)
		CARDINAL_MARK(WEST, WEX_DIR_WEST, dir)

	// to_chat(world, "DEBUG: cycle end edges_next [english_list_assoc(edges_next)]")

	// flush lists
	src.exploded_last = edges + diagonals
	src.edges = edges_next
	src.powers = powers_next
	cycle++
	cycle_start = world.time

#undef SHOULD_SUSPEND

#undef WEX_ACT

#undef DIAGONAL_SUBSTEP
#undef DIAGONAL_MARK
#undef CARDINAL_MARK
#undef MARK
