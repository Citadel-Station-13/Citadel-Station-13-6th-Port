
/*
/tg/station13 /datum Pool:
---------------------------------
By RemieRichards

Creation/Deletion is laggy, so let's reduce reuse and recycle!

Usage:

To get a object, just call
 - PoolOrNew(type, arg) if you only want to pass one argument to New(), usually loc
 - PoolOrNew(type, list) if you want to pass multiple arguments to New()

To put a object back in the pool, call PlaceInPool(object)
This will call destroy on the object, set its loc to null,
and reset all of its vars to their default

You can override your object's destroy to return QDEL_HINT_PUTINPOOL
to ensure its always placed in this pool (this will only be acted on if qdel calls destroy, and destroy will not get called twice)

For almost all pooling purposes, it is better to use the QDEL hint than to pool it directly with PlaceInPool

*/

#define MAINTAINING_OBJECT_POOL_COUNT 500

var/global/list/GlobalPool = list()

//You'll be using this proc 90% of the time.
//It grabs a type from the pool if it can
//And if it can't, it creates one
//The pool is flexible and will expand to fit
//The new created atom when it eventually
//Goes into the pool

//Second argument can be a single arg
//Or a list of arguments
//Either way it gets passed to new

/proc/PoolOrNew(get_type,second_arg)
	if(!get_type)
		return

	. = GetFromPool(get_type,second_arg)

	if(!.)
		if(ispath(get_type))
			if(islist(second_arg))
				. = new get_type (arglist(second_arg))
			else
				. = new get_type (second_arg)


/proc/GetFromPool(get_type,second_arg)
	if(!get_type)
		return

	if(isnull(GlobalPool[get_type]))
		return

	if(length(GlobalPool[get_type]) == 0)
		return

	var/datum/pooled = pop(GlobalPool[get_type])
	if(pooled)
		pooled.gc_destroyed = null

		var/atom/movable/AM
		if(istype(pooled, /atom/movable))
			AM = pooled

		if(islist(second_arg))
			if(AM)
				AM.loc = second_arg[1] //we need to do loc setting explicetly before even calling New() to replicate new()'s behavior
			pooled.New(arglist(second_arg))

		else
			if(AM)
				AM.loc = second_arg
			pooled.New(second_arg)

		return pooled


/proc/PlaceInPool(datum/diver, destroy = 1)
	if(!istype(diver))
		return

	if(diver in GlobalPool[diver.type])
		return

	if(!GlobalPool[diver.type])
		GlobalPool[diver.type] = list()

	GlobalPool[diver.type] |= diver

	if(destroy)
		diver.Destroy()

	diver.gc_destroyed = 1

	diver.ResetVars()

var/list/exclude = list("animate_movement", "contents", "loc", "locs", "parent_type", "vars", "verbs", "type", "gc_destroyed")
var/list/pooledvariables = list()
//thanks to clusterfack @ /vg/station for these two procs
/datum/proc/createVariables()
	pooledvariables[type] = new/list()
	var/list/exclude = global.exclude + args

	for(var/key in vars)
		if(key in exclude)
			continue
		if(islist(vars[key]))
			pooledvariables[type][key] = list()
		else
			pooledvariables[type][key] = initial(vars[key])

/datum/proc/ResetVars()
	if(!pooledvariables[type])
		createVariables(args)

	for(var/key in pooledvariables[type])
		if (islist(pooledvariables[type][key]))
			vars[key] = list()
		else
			vars[key] = pooledvariables[type][key]

/atom/movable/ResetVars()
	..()
	loc = null
	contents = initial(contents) //something is really wrong if this object still has stuff in it by this point

/image/ResetVars()
	..()
	loc = null

/proc/returnToPool(const/datum/D)
	ASSERT(D)

	if(istype(D, /atom/movable) && length(GlobalPool[D.type]) > MAINTAINING_OBJECT_POOL_COUNT)
		#ifdef DEBUG_DATUM_POOL
		to_chat(world, text("DEBUG_DATUM_POOL: returnToPool([]) exceeds [] discarding...", D.type, MAINTAINING_OBJECT_POOL_COUNT))
		#endif

		qdel(D)
		return

	if(isnull(GlobalPool[D.type]))
		GlobalPool[D.type] = list()

	D.Destroy()
	D.ResetVars()

	#ifdef DEBUG_DATUM_POOL
	if(D in GlobalPool[D.type])
		to_chat(world, text("returnToPool has been called twice for the same datum of type [] time to panic.", D.type))
	#endif

	GlobalPool[D.type] |= D

	#ifdef DEBUG_DATUM_POOL
	to_chat(world, text("DEBUG_DATUM_POOL: returnToPool([]) [] left.", D.type, length(GlobalPool[D.type])))
	#endif

#undef MAINTAINING_OBJECT_POOL_COUNT