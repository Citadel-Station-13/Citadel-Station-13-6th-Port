
/*
	Uplink Items:
	Unlike categories, uplink item entries are automatically sorted alphabetically on server init in a global list,
	When adding new entries to the file, please keep them sorted by category.
*/

// Implants

/datum/uplink_item/implants/adrenal
	name = "Adrenal Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will inject a chemical \
			cocktail which removes all incapacitating effects, lets the user run faster and has a mild healing effect."
	item = /obj/item/storage/box/syndie_kit/imp_adrenal
	cost = 8
	player_minimum = 25

/datum/uplink_item/implants/antistun
	name = "CNS Rebooter Implant"
	desc = "This implant will help you get back up on your feet faster after being stunned. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/anti_stun
	cost = 12
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated at the user's will. It will attempt to free the \
			user from common restraints such as handcuffs."
	item = /obj/item/storage/box/syndie_kit/imp_freedom
	cost = 5

/datum/uplink_item/implants/warp
	name = "Warp Implant"
	desc = "An implant injected into the body and later activated at the user's will. Allows the user to teleport to where they were 10 seconds ago. Has a 10 second cooldown."
	item = /obj/item/storage/box/syndie_kit/imp_warp
	cost = 6
	exclude_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/implants/hijack
	name = "Hijack Implant"
	desc = "An implant that will let you hack into the APCs on station, allowing you to control them at will and the machinery within those rooms."
	item = /obj/item/implanter/hijack
	cost = 14 //really overkill, 14 tc, can still get caught in a room you haven't hijacked and you're fucked.
	surplus = 0 //nope not having hijack implants with surplus crates nope nope nope nope
	restricted = TRUE

/datum/uplink_item/implants/radio
	name = "Internal Syndicate Radio Implant"
	desc = "An implant injected into the body, allowing the use of an internal Syndicate radio. \
			Used just like a regular headset, but can be disabled to use external headsets normally and to avoid detection."
	item = /obj/item/storage/box/syndie_kit/imp_radio
	cost = 4
	restricted = TRUE

/datum/uplink_item/implants/microbomb
	name = "Microbomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. \
			The more implants inside of you, the higher the explosive power. \
			This will permanently destroy your body, however."
	item = /obj/item/storage/box/syndie_kit/imp_microbomb
	cost = 2
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/implants/macrobomb
	name = "Macrobomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. \
			Upon death, releases a massive explosion that will wipe out everything nearby."
	item = /obj/item/storage/box/syndie_kit/imp_macrobomb
	cost = 20
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)
	restricted = TRUE

/datum/uplink_item/implants/reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/reviver
	cost = 8
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/implants/stealthimplant
	name = "Stealth Implant"
	desc = "This one-of-a-kind implant will make you almost invisible as long as you don't don't excessively move around. \
			On activation, it will conceal you inside a chameleon cardboard box that is only revealed once someone bumps into it."
	item = /obj/item/implanter/stealth
	cost = 8

/datum/uplink_item/implants/storage
	name = "Storage Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will open a small bluespace \
			pocket capable of storing two regular-sized items."
	item = /obj/item/storage/box/syndie_kit/imp_storage
	cost = 8

/datum/uplink_item/implants/thermals
	name = "Thermal Eyes"
	desc = "These cybernetic eyes will give you thermal vision. Comes with a free autosurgeon."
	item = /obj/item/autosurgeon/thermal_eyes
	cost = 8
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated at the user's will. Has no telecrystals and must be charged by the use of physical telecrystals. \
			Undetectable (except via surgery), and excellent for escaping confinement."
	item = /obj/item/storage/box/syndie_kit/imp_uplink
	cost = 4
	// An empty uplink is kinda useless.
	surplus = 0
	restricted = TRUE

/datum/uplink_item/implants/xray
	name = "X-ray Vision Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/xray_eyes
	cost = 10
	surplus = 0
	include_modes = list(/datum/game_mode/nuclear, /datum/game_mode/nuclear/clown_ops)

/datum/uplink_item/implants/epitaph
	name = "Epitaph Implant"
	desc = "An implant that will go straight into one's brain. It will grant the user a killer personality that will give both the ability to skip time in their parries."
	item = /obj/item/implanter/epitaph
	cost = 14 //kinda like holoparasite but can fuck you up if your second personality is a retard, that's my justification for the price.
	surplus = 0
