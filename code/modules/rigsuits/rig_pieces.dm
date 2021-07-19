/**
 * Initializes pieces
 */
/obj/item/rig/proc/initialize_pieces()
	wipe_pieces()
	rig_pieces = list()
	piece_components = list()
	PopulatePieces()

/**
 * Used to populate pieces. This is what you should be overriding.
 */
/obj/item/rig/proc/PopulatePieces()

/**
 * Destroys all pieces for garbage collection
 */
/obj/item/rig/proc/wipe_pieces()
	retract_all(silent = TRUE, immediate = TRUE)
	for(var/i in rig_pieces)
		qdel(i)
	rig_pieces = list()
	rig_pieces_by_type = list()
	piece_components = lisT()

/**
 * Resolves something into the rig piece component it has.
 * Returns null if it's not part of us
 */
/obj/item/rig/proc/resolve_piece_component(datum/component/rig_piece/I)
	if(istype(I))
		return piece_components[I]? I : null
	return rig_pieces[I]

/**
 * Adds a rig piece
 */
/obj/item/rig/proc/instantiate_piece(obj/item/I, component_path = /datum/component/rig_piece, slots = DEFAULT_SLOTS_AVAILABLE, size = DEFAULT_SIZE_AVAILABLE, integrity = DEFAULT_RIG_INTEGRITY)


/**
 * Adds a piece to this rig.
 */
/obj/item/rig/proc/add_piece(datum/component/rig_piece/P)
	var/obj/item/I
	if(istype(P))
		I = P.parent
	else
		I = P
		P = I.GetComponent(/datum/component/rig_piece)
	ASSERT(P)
	ASSERT(I)

	// ...

	ui_queue_piece(P)
	ui_queue_reflists()

/**
 * Deploys a piece
 *
 * @params
 * - P - what to deploy, either the item or the component
 * - force - knock off what they're wearing
 * - harder - knock off what they're wearing even if it's nodrop
 * - seal_immediately - seal immediately if rig is activated
 */
/obj/item/rig/proc/deploy(datum/component/rig_piece/P, mob/user, silent = FALSE, force = FALSE, harder = FALSE, seal_immediately = FALSE)
	P = resolve_piece_component(P)
	if(!P)
		CRASH("Attempted to deploy an invalid piece.")
	if(P.deployed)
		return
	var/obj/item/I = P.parent
	if(!P.deployOntoUser(wearer, force, harder))
		rig_message(user, "<span class='warning'>[I] fails to deploy onto you!</span>", "<span class='warning'>[I] failed to deploy.</span>")
		return FALSE
	INVOKE_ASYNC(src, .proc/seal, P, user, silent, seal_immediately)
	P.on_deploy(user, seal_immediately)
	return TRUE

/**
 * Attempts to deploy a piece.
 */
/obj/item/rig/proc/try_deploy(datum/component/rig_piece/P, mob/user, silent = FALSE, force = FALSE, harder = FALSE, seal_immediately = FALSE)
	P = resolve_piece_component(P)
	if(!P)
		CRASH("ATtempted to deploy an invalid piece.")
	return deploy(I, force, harder, seal_immediately)

/**
 * Retracts a piece. Ignores nodrop. Unseals immediately.
 *
 * @params
 * - P - what to retract, either the item or the component
 */
/obj/item/rig/proc/retract(datum/component/rig_piece/P, mob/user, silent = FALSE, immediate = FALSE)
	P = resolve_piece_component(P)
	if(!P)
		. = FALSE
		CRASH("Attempted to retract an invalid piece.")
	if(!P.deployed)
		return
	if(P.sealed)
		unseal(P, user, silent, immediate = TRUE)
	P.moveIntoRig()
	P.on_retract(user, immediate)
	rig_message(null, "[P.parent] retracts back into [src]!")
	return TRUE

/**
 * Attempts to retract a piece. Will attempt to unseal it if it's sealed first.
 *
 * @params
 * - P - what to retract, either the item or the component
 * - unseal_immediately - bypass unseal delay
 */
/obj/item/rig/proc/try_retract(datum/component/rig_piece/P, mob/user, silent = FALSE, unseal_immediately = FALSE)
	P = resolve_piece_component(P)
	if(!P)
		. = FALSE
		CRASH("Attempted to retract an invalid piece.")
	if(P.sealed)
		if(!unseal(P, user, silent, immediate = unseal_immediately))
			rig_message(user, null, "<span class='warning'>Unseal of [I] failed.</span>", TRUE)
			return FALSE
	return retract(P, user, silent, unseal_immediately)

/**
 * Retracts all pieces.
 */
/obj/item/rig/proc/retract_all(mob/user, silent = FALSE, immediate = FALSE)
	for(var/i in rig_pieces)
		retract(i, user, silent, immediate)

/**
 * Deploys all pieces.
 */
/obj/item/rig/proc/deploy_all(mob/user, silent = FALSE, force = FALSE, harder = FALSE, immediate = FALSE)
	for(var/i in rig_pieces)
		deploy(i, user, silent, force, harder, immediate)

/**
 * Seals a piece. Blocking call.
 */
/obj/item/rig/proc/seal(datum/component/rig_piece/P, mob/user, silent = FALSE, immediate = FALSE)

/**
 * Unseals a piece. Blocking call.
 */
/obj/item/rig/proc/unseal(datum/component/rig_piece/P, mob/user, silent = FALSE, immediate = FALSE)

/**
 * Seals all deployed pieces. Blocking call.
 */

/**
 * Unseals all deployed pieces. Blocking call.
 */

/// Gets the rig piece component of a rig piece type.
/obj/item/rig/proc/get_piece(piece_type)
	return rig_pieces_by_type[piece_type]
