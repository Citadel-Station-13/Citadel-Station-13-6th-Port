#define TRAITOR_HUMAN /datum/traitor_class/human/freeform
#define TRAITOR_AI /datum/traitor_class/ai

#define NUKE_RESULT_FLUKE 0
#define NUKE_RESULT_NUKE_WIN 1
#define NUKE_RESULT_CREW_WIN 2
#define NUKE_RESULT_CREW_WIN_SYNDIES_DEAD 3
#define NUKE_RESULT_DISK_LOST 4
#define NUKE_RESULT_DISK_STOLEN 5
#define NUKE_RESULT_NOSURVIVORS 6
#define NUKE_RESULT_WRONG_STATION 7
#define NUKE_RESULT_WRONG_STATION_DEAD 8

//fugitive end results
#define FUGITIVE_RESULT_BADASS_HUNTER 0
#define FUGITIVE_RESULT_POSTMORTEM_HUNTER 1
#define FUGITIVE_RESULT_MAJOR_HUNTER 2
#define FUGITIVE_RESULT_HUNTER_VICTORY 3
#define FUGITIVE_RESULT_MINOR_HUNTER 4
#define FUGITIVE_RESULT_STALEMATE 5
#define FUGITIVE_RESULT_MINOR_FUGITIVE 6
#define FUGITIVE_RESULT_FUGITIVE_VICTORY 7
#define FUGITIVE_RESULT_MAJOR_FUGITIVE 8

#define APPRENTICE_DESTRUCTION "destruction"
#define APPRENTICE_BLUESPACE "bluespace"
#define APPRENTICE_ROBELESS "robeless"
#define APPRENTICE_HEALING "healing"
#define APPRENTICE_MARTIAL "martial"


//ERT Types
#define ERT_BLUE "Blue"
#define ERT_RED  "Red"
#define ERT_AMBER "Amber"
#define ERT_DEATHSQUAD "Deathsquad"

//ERT subroles
#define ERT_SEC "sec"
#define ERT_MED "med"
#define ERT_ENG "eng"
#define ERT_LEADER "leader"
#define DEATHSQUAD "ds"
#define DEATHSQUAD_LEADER "ds_leader"

//Shuttle hijacking
#define HIJACK_NEUTRAL 0 //Does not stop hijacking but itself won't hijack
#define HIJACK_HIJACKER 1 //Needs to be present for shuttle to be hijacked
#define HIJACK_PREVENT 2 //Prevents hijacking same way as non-antags

//Syndicate Contracts
#define CONTRACT_STATUS_INACTIVE 1
#define CONTRACT_STATUS_ACTIVE 2
#define CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE 3
#define CONTRACT_STATUS_EXTRACTING 4
#define CONTRACT_STATUS_COMPLETE 5
#define CONTRACT_STATUS_ABORTED 6

#define CONTRACT_PAYOUT_LARGE 1
#define CONTRACT_PAYOUT_MEDIUM 2
#define CONTRACT_PAYOUT_SMALL 3

#define CONTRACT_UPLINK_PAGE_CONTRACTS "CONTRACTS"
#define CONTRACT_UPLINK_PAGE_HUB "HUB"

//Lingblood stuff
#define LINGBLOOD_DETECTION_THRESHOLD 1
#define LINGBLOOD_EXPLOSION_MULT 2
#define LINGBLOOD_EXPLOSION_THRESHOLD (LINGBLOOD_DETECTION_THRESHOLD * LINGBLOOD_EXPLOSION_MULT) //Hey, important to note here: the explosion threshold is explicitly more than, rather than more than or equal to. This stops a single loud ability from triggering the explosion threshold.

///Heretics --
GLOBAL_LIST_EMPTY(living_heart_cache)	//A list of all living hearts in existance, for us to iterate through.


#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))
#define IS_HERETIC_MONSTER(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic_monster))

#define PATH_SIDE "Side"

#define PATH_ASH "Ash"
#define PATH_RUST "Rust"
#define PATH_FLESH "Flesh"
#define PATH_VOID "Void"

//Overthrow time to update heads obj
#define OBJECTIVE_UPDATING_TIME 300

//Gangshit
#define NOT_DOMINATING			-1
#define MAX_LEADERS_GANG		4
#define INITIAL_DOM_ATTEMPTS	3

//Bloodsucker defines
// Bloodsucker related antag datums
#define ANTAG_DATUM_BLOODSUCKER			/datum/antagonist/bloodsucker
#define ANTAG_DATUM_VASSAL				/datum/antagonist/vassal
//#define ANTAG_DATUM_HUNTER				/datum/antagonist/vamphunter   Disabled for now

// BLOODSUCKER
#define BLOODSUCKER_LEVEL_TO_EMBRACE	3
#define BLOODSUCKER_FRENZY_TIME	25		// How long the vamp stays in frenzy.
#define BLOODSUCKER_FRENZY_OUT_TIME	300	// How long the vamp goes back into frenzy.
#define BLOODSUCKER_STARVE_VOLUME	5	// Amount of blood, below which a Vamp is at risk of frenzy.

#define CAT_STRUCTURE	"Structures"

#define MARTIALART_HUNTER "hunter-fu"

//Blob
#define BLOB_REROLL_TIME 2400 // blob gets a free reroll every X time
#define BLOB_SPREAD_COST 4
#define BLOB_ATTACK_REFUND 2 //blob refunds this much if it attacks and doesn't spread
#define BLOB_REFLECTOR_COST 15

//Objectives-Ambitions Panel
#define REQUEST_NEW_OBJECTIVE "new_objective"
#define REQUEST_DEL_OBJECTIVE "del_objective"
#define REQUEST_WIN_OBJECTIVE "win_objective"
#define REQUEST_LOSE_OBJECTIVE "lose_objective"
