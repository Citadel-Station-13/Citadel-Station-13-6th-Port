/**
 * Componentized rig pieces.
 *
 * Should only be added to items.
 * **CURRENTLY DOES NOT SUPPORT DETACHING/SWAPPING**.
 */
/datum/component/rig_piece
	can_transfer = FALSE		// hahaha no.
	/// Our host rig piece, if it exists.
	var/obj/item/rig/rig
	/// Should we get armor, pressure, thermal shielding etc transferred to us. Used to ensure no stacking if we ever get uniform rigs.
	var/apply_effects = RIG_PIECE_APPLY_ARMOR | RIG_PIECE_APPLY_THERMALS | RIG_PIECE_APPLY_PRESSURE
	/// Separate cycle delay - time needed to fully seal a piece on deploy, separate from rig's innate activation/deactivation delays
	var/cycle_delay = 0
	/// Piece type bitflag - each rig can only have one of each type.
	var/piece_type = NONE
	/// Slots available - this is per rig zone this is responsible for, not total!
	var/slots = DEFAULT_SLOTS_AVAILABLE
	/// Max combined size - this is per rig zone this is responsible for, not total!
	var/size = DEFAULT_SIZE_AVAILABLE
	/// Innate weight - this is not per rig zone and is instead just on this piece.
	var/innate_weight = 0
	/// Damage by rig zone. Lazy list.
	var/list/damage_by_zone
	/// Needs to be fully sealed to provide pressure protection
	var/pressure_shielding_requires_sealing = TRUE
	/// Needs to be fully sealed to provide temperature protection
	var/temperature_shielding_requires_sealing = TRUE
	/// Are we sealed?
	var/sealed = FALSE
	/// Are we deployed?
	var/deployed = FALSE
	/// The slot we deploy to, for humans. It is currently infeasible to dynamically detect this.
	var/equip_slot
	/// Max health
	var/maxhealth = DEFAULT_RIG_INTEGRITY

/datum/component/rig_piece/Initialize(obj/item/rig/rig, rig_creation = FALSE, apply_effects, cycle_delay, piece_type, slots, size, maxhealth, weight)
	. = ..()
	if(. & COMPONENT_INCOMPATIBLE)
		return
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(!isnull(apply_effects))
		src.apply_effects = apply_effects
	if(!isnull(cycle_delay))
		src.cycle_delay = cycle_delay
	if(!isnull(piece_type))
		// no multiple types for the moment.
		ASSERT(!MODULUS(log(2, piece_type), 1))
		src.piece_type = piece_type
	if(!isnull(slots))
		src.slots = slots
	if(!isnull(maxhealth))
		src.maxhealth = maxhealth
	if(!isnull(weight))
		src.innate_weight = weight
	if(!isnull(size))
		src.size = size
	var/obj/item/I = parent
	I.resistance_flags |= (ACID_PROOF | INDESTRUCTIBLE | FIRE_PROOF)	// rig damage is handled separately.
	if(!rig)
		stack_trace("Rig piece created without being directly instantiated by a rig control module. This isn't supported right now, but is being allowed anyways.")
		return
	RegisterToRig(rig, rig_creation)

/datum/component/rig_piece/Destroy()
	UnregisterFromRig()
	return ..()

/**
 * Sets us up with a rig
 */
/datum/component/rig_piece/proc/RegisterToRig(obj/item/rig/rig)


/**
 * Cleans us up from a rig. Never use outside of deletion, rig-swapping isn't supported yet.
 */
/datum/component/rig_piece/proc/UnregisterFromRig(obj/item/rig/rig)
	var/obj/item/I = parent
	. = list()
	.["name"] = I.name
	.["sealed"] = sealed
	.["deployed"] = deployed
	.["slots"] = slots
	.["size"] = size
	.["weight"] = innate_weight
	.["maxhealth"] = maxhealth

/**
 * Gets our TGUI data.
 */
/datum/component/rig_piece/proc/rig_ui_data(mob/user)


/**
 * Moves our parent back into our rig
 */
/datum/component/rig_piece/proc/moveIntoRig()
	var/obj/item/I = parent
	I.forceMove(rig)
	deployed = FALSE

/**
 * Deploys onto a user.
 *
 * @params
 * - L - person to deploy onto
 * - force - knock off anything conflicting in the slot
 * - harder - knock off nodrop items too
 */
/datum/component/rig/proc/deployOntoUser(mob/living/L, force = FALSE, harder = FALSE)
	if(!equip_slot)
		CRASH("Invalid equip slot")
	var/obj/item/existing = L.get_item_by_slot(equip_slot)
	if(existing && (!force || !L.dropItemToGround(existing, harder)))
		return FALSE
	if(!L.equip_to_slot_if_possible(parent, equip_slot, FALSE, TRUE, TRUE, TRUE, FALSE))
		return FALSE
	deployed = TRUE

/**
 * Called by rig on successful deploy
 */
/datum/component/rig_piece/proc/on_deploy(mob/living/wearer, instant_seal)
	if(!instant_seal)
		to_chat(wearer, "<span class='notice'>Your [parent] deploys around your [get_zone_string(wearer)]</span>")
	else
		to_chat(wearer, "<span class='notice'>Your [parent] deploys around you [get_zone_string(wearer)], locking into place with some mechanical clicks.</span>")
	rig.ui_queue_component(src)

/**
 * Called by rig on successful retract
 */
/datum/component/rig_piece/proc/on_retract(mob/living/wearer, instant_seal)
	if(!instant_seal)
		to_chat(wearer, "<span class='notice'>Your [parent] retracts from your [get_zone_string(wearer)]</span>")
	else
		to_chat(wearer, "<span class='notice'>Your [parent] unlocks itself and retracts from your [get_zone_string(wearer)]</span>")
	rig.ui_queue_component(src)

/**
 * Called by rig on seal
 */
/datum/component/rig_piece/proc/on_seal(mob/living/wearer, instant_seal)
	if(!instant_seal)
		to_chat(wearer, "<span class='notice'>[parent] locks into place with some mechanical clicks.</span>")
	sealed = TRUE
	update_item()
	rig.ui_queue_component(src)

/**
 * Called by rig on unseal
 */
/datum/component/rig_piece/proc/on_unseal(mob/living/wearer, instant_seal)
	if(!instant_seal)
		to_chat(wearer, "<span class='notice'>[parent] loosens, mechanical locks clicking out of place.</span>")
	sealed = FALSE
	update_item()
	rig.ui_queue_component(src)

/**
 * Updates item stats.
 */
/datum/component/rig_piece/proc/update_item()
	var/obj/item/I = parent
	I.armor = ((apply_effects & RIG_PIECE_APPLY_ARMOR) && rig)? rig.get_user_armor() : getArmor()
	I.max_heat_protection_temperature = ((apply_effects & RIG_PIECE_APPLY_THERMALS) && rig && (sealed || !temperature_shielding_requires_sealing))? rig.get_heat_shielding() : initial(I.max_heat_protection_temperature)
	I.min_cold_protection_temperature = ((apply_effects & RIG_PIECE_APPLY_THERMALS) && rig && (sealed || !temperature_shielding_requires_sealing))? rig.get_cold_shielding() : initial(I.min_cold_protection_temperature)
	if(!istype(I, /obj/item/clothing))
		return
	var/obj/item/clothing/C = I
	var/initial_flags = initial(C.clothing_flags)
	if(!rig || !(apply_effects & RIG_PIECE_APPLY_PRESSURE))
		C.clothing_flags = initial_flags
	else
		C.clothing_flags &= ~(STOPSPRESSUREDAMAGE | ALLOWINTERNALS | THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT)
		if(rig.is_thick_material())
			C.clothing_flags |= THICKMATERIAL
		if(rig.is_gas_smoke_shielded())
			C.clothing_flags |= BLOCK_GAS_SMOKE_EFFECT
		if(rig.is_internals_allowed())
			C.clothing_flags |= ALLOWINTERNALS
		if(rig.is_pressure_shielded())
			C.clothing_flags |= STOPSPRESSUREDAMAGE
	if(!(initial_flags & STOPSPRESSUREDAMAGE) && (!rig || (!sealed && pressure_shielding_requires_sealing)))
		C.clothing_flags &= ~STOPSPRESSUREDAMAGE
	else
		C.clothing_flags |= STOPSPRESSUREDAMAGE
	update_sealed_icon()

/datum/component/rig_piece/proc/update_sealed_icon()
	#warn TODO: Update worn icon for sealed/unsealed sprites.

/**
 * Get the zone string of "body", "head", "feet", etc.
 */
/datum/component/rig_piece/proc/get_zone_string(mob/wearer)
	return "body"

/datum/component/rig_piece/head
	piece_type = RIG_PIECE_HEAD
	equip_slot = SLOT_HEAD

/datum/component/rig_piece/suit
	piece_type = RIG_PIECE_SUIT
	equip_slot = SLOT_WEAR_SUIT

/datum/component/rig_piece/gauntlets
	piece_type = RIG_PIECE_GAUNTLETS
	equip_slot = SLOT_GLOVES

/datum/component/rig_piece/boots
	piece_type = RIG_PIECE_BOOTS
	equip_slot = SLOT_SHOES
