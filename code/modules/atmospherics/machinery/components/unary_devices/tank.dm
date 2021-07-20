#define AIR_CONTENTS	((25*ONE_ATMOSPHERE)*(air_contents.return_volume())/(R_IDEAL_GAS_EQUATION*air_contents.return_temperature()))
/obj/machinery/atmospherics/component/unary/tank
	icon = 'icons/obj/atmospherics/pipes/pressure_tank.dmi'
	icon_state = "generic"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800
	density = TRUE
	layer = ABOVE_WINDOW_LAYER
	pipe_flags = PIPE_ONE_PER_TURF

	var/volume = 10000 //in liters
	/// The typepath of the gas this tank should be filled with.
	var/gas_type = 0

/obj/machinery/atmospherics/component/unary/tank/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_volume(volume)
	air_contents.set_temperature(T20C)
	if(gas_type)
		air_contents.set_moles(gas_type,AIR_CONTENTS)
		name = "[name] ([GLOB.gas_data.names[gas_type]])"
	setPipingLayer(pipe_layer)

/obj/machinery/atmospherics/component/unary/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/component/unary/tank/air/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_O2, AIR_CONTENTS * 0.21)
	air_contents.set_moles(GAS_N2, AIR_CONTENTS * 0.79)

/obj/machinery/atmospherics/component/unary/tank/carbon_dioxide
	gas_type = GAS_CO2

/obj/machinery/atmospherics/component/unary/tank/toxins
	icon_state = "orange"
	gas_type = GAS_PLASMA

/obj/machinery/atmospherics/component/unary/tank/nitrogen
	icon_state = "red"
	gas_type = GAS_N2

/obj/machinery/atmospherics/component/unary/tank/oxygen
	icon_state = "blue"
	gas_type = GAS_O2

/obj/machinery/atmospherics/component/unary/tank/nitrous
	icon_state = "red_white"
	gas_type = GAS_NITROUS

/obj/machinery/atmospherics/component/unary/tank/bz
	gas_type = GAS_BZ

// /obj/machinery/atmospherics/component/unary/tank/freon
// 	icon_state = "blue"
// 	gas_type = /datum/gas/freon

// /obj/machinery/atmospherics/component/unary/tank/halon
// 	icon_state = "blue"
// 	gas_type = /datum/gas/halon

// /obj/machinery/atmospherics/component/unary/tank/healium
// 	icon_state = "red"
// 	gas_type = /datum/gas/healium

// /obj/machinery/atmospherics/component/unary/tank/hydrogen
// 	icon_state = "grey"
// 	gas_type = /datum/gas/hydrogen

/obj/machinery/atmospherics/component/unary/tank/hypernoblium
	icon_state = "blue"
	gas_type = GAS_HYPERNOB

/obj/machinery/atmospherics/component/unary/tank/miasma
	gas_type = GAS_MIASMA

/obj/machinery/atmospherics/component/unary/tank/nitryl
	gas_type = GAS_NITRYL

/obj/machinery/atmospherics/component/unary/tank/pluoxium
	icon_state = "blue"
	gas_type = GAS_PLUOXIUM

// /obj/machinery/atmospherics/component/unary/tank/proto_nitrate
// 	icon_state = "red"
// 	gas_type = /datum/gas/proto_nitrate

/obj/machinery/atmospherics/component/unary/tank/stimulum
	icon_state = "red"
	gas_type = GAS_STIMULUM

/obj/machinery/atmospherics/component/unary/tank/tritium
	gas_type = GAS_TRITIUM

/obj/machinery/atmospherics/component/unary/tank/water_vapor
	icon_state = "grey"
	gas_type = GAS_H2O

// /obj/machinery/atmospherics/component/unary/tank/zauker
// 	gas_type = /datum/gas/zauker

// /obj/machinery/atmospherics/component/unary/tank/helium
// 	gas_type = /datum/gas/helium

// /obj/machinery/atmospherics/component/unary/tank/antinoblium
// 	gas_type = /datum/gas/antinoblium
