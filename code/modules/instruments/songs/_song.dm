#define MUSICIAN_HEARCHECK_MINDELAY 4
#define MUSIC_MAXLINES 1000
#define MUSIC_MAXLINECHARS 300

/datum/song
	/// Name of the song
	var/name = "Untitled"

	/// The atom we're attached to/playing from
	var/atom/parent

	/// Our song lines
	var/list/lines

	/// delay between notes in deciseconds
	var/tempo = 5

	/// Are we currently playing?
	var/playing = FALSE

	/// Are we currently editing?
	var/editing = TRUE
	/// Is the help screen open?
	var/help = FALSE

	/// Repeats left
	var/repeat = 0
	/// Maximum times we can repeat
	var/max_repeats = 10

	/// Our volume
	var/volume = 100
	/// Max volume
	var/max_volume = 100
	/// Min volume - This is so someone doesn't decide it's funny to set it to 1 and play invisible songs.
	var/min_volume = 50

	/// What instruments our built in picker can use. The picker won't show unless this is longer than one.
	var/list/allowed_instrument_ids = list("r3grand")

	//////////// Cached instrument variables /////////////
	/// Instrument we are currently using
	var/datum/instrument/using_instrument
	/// Cached legacy ext for legacy instruments
	var/cached_legacy_ext
	/// Cached legacy dir for legacy instruments
	var/cached_legacy_dir
	/// Cached list of samples, referenced directly from the instrument for synthesized instruments
	var/list/cached_samples
	/// Are we operating in legacy mode (so if the instrument is a legacy instrument)
	var/legacy = FALSE
	//////////////////////////////////////////////////////

	/////////////////// Playing variables ////////////////
	/**
	  * Only used in synthesized playback - The chords we compiled. Non assoc list of lists:
	  * list(list(key1, key2, key3..., tempo_divisor), list(key1, key2..., tempo_divisor), ...)
	  * tempo_divisor always exists
	  * if key1 (and so if there's no keys) doesn't exist it's a rest
	  * Compilation happens when we start playing and is cleared after we finish playing.
	  */
	var/list/compiled_chords
	/// Key as text = channel as number
	var/list/channels_reserved
	/// Key as text = current volume
	var/list/keys_playing
	//////////////////////////////////////////////////////

	/// Last world.time we checked for who can hear us
	var/last_hearcheck = 0
	/// The list of mobs that can hear us
	var/list/hearing_mobs
	/// If this is enabled, some things won't be strictly cleared when they usually are (liked compiled_chords on play stop)
	var/debug_mode = FALSE
	/// Last time we processed decay
	var/last_process_decay

	/////////////////////// DO NOT TOUCH THESE ///////////////////
	var/octave_min = INSTRUMENTS_MIN_OCTAVE
	var/octave_max = INSTRUMENTS_MAX_OCTAVE
	var/key_min = 0
	var/key_max = 127
	var/static/list/note_offset_lookup = list(9, 11, 0, 2, 4, 5, 7)
	var/static/list/accent_lookup = list("b" = -1, "s" = 1, "#" = 1, "n" = 0)
	//////////////////////////////////////////////////////////////

	///////////// !!FUN!! - Only works in synthesized mode! /////////////////
	/// Note numbers to shift.
	var/note_shift = 0
	var/note_shift_min = -100
	var/note_shift_max = 100
	/// Frequency numbers to shift. Probably a horrible idea.
	var/frequency_shift = 0
	var/frequency_shift_min = -30
	var/frequency_shift_max = 30
	var/can_noteshift = TRUE
	var/can_freqshift = FALSE
	/// The kind of sustain we're using
	var/sustain_mode = SUSTAIN_LINEAR
	/// When a note is considered dead if it is below this in volume
	var/sustain_dropoff_volume = 10
	/// Total duration of linear sustain for 100 volume note to get to SUSTAIN_DROPOFF
	var/sustain_linear_duration = 10
	/// Exponential sustain dropoff rate per decisecond
	var/sustain_exponential_dropoff = 1.045
	////////// DO NOT DIRECTLY SET THESE!
	/// Do not directly set, use update_sustain()
	var/cached_linear_dropoff = 10
	/// Do not directly set, use update_sustain()
	var/cached_exponential_dropoff = 1.07
	/////////////////////////////////////////////////////////////////////////

/datum/song/New(atom/parent, list/allowed_instrument_ids)
	SSinstruments.on_song_new(src)
	lines = list()
	tempo = sanitize_tempo(tempo)
	src.parent = parent
	src.allowed_instrument_ids = islist(allowed_instrument_ids)? allowed_instrument_ids : list(allowed_instrument_ids)
	if(length(allowed_instrument_ids))
		set_instrument(allowed_instrument_ids[1])
	hearing_mobs = list()
	volume = clamp(volume, min_volume, max_volume)

/datum/song/Destroy()
	SSinstruments.on_song_del(src)
	stop_playing()
	lines = null
	using_instrument = null
	allowed_instrument_ids = null
	parent = null
	return ..()

/datum/song/proc/do_hearcheck()
	last_hearcheck = world.time
	var/list/old = hearing_mobs.Copy()
	hearing_mobs.len = 0
	var/turf/source = get_turf(parent)
	for(var/mob/M in get_hearers_in_view(15, source))
		if(!(M?.client?.prefs?.toggles & SOUND_INSTRUMENTS))
			continue
		hearing_mobs[M] = get_dist(M, source)
	var/list/exited = old - hearing_mobs
	for(var/i in exited)
		terminate_sound_mob(i)

/// I can either be a datum, id, or path (if the instrument has no id).
/datum/song/proc/set_instrument(datum/instrument/I)
	stop_playing()
	if(using_instrument)
		using_instrument.songs_using -= src
	using_instrument = null
	cached_samples = null
	cached_legacy_ext = null
	cached_legacy_dir = null
	legacy = null
	if(istext(I) || ispath(I))
		I = SSinstruments.instrument_data[I]
	if(istype(I))
		using_instrument = I
		I.songs_using += src
		var/legacy = CHECK_BITFIELD(I, INSTRUMENT_LEGACY)
		if(legacy)
			cached_legacy_ext = I.legacy_instrument_ext
			cached_legacy_dir = I.legacy_instrument_dir
			legacy = TRUE
		else
			samples = I.samples
			legacy = FALSE

/// THIS IS A BLOCKING CALL.
/datum/song/proc/start_playing(mob/user)
	if(playing)
		return
	if(!using_instrument?.ready())
		to_chat(user, "<span class='warning'>An error has occured with [src]. Please reset the instrument.</span>")
		return
	playing = TRUE
	updateDialog()
	channels_reserved = list()
	keys_playing = list()
	//we can not afford to runtime, since we are going to be doing sound channel reservations and if we runtime it means we have a channel allocation leak.
	//wrap the rest of the stuff to ensure stop_playing() is called.
	last_process_decay = world.time
	START_PROCESSING(SSinstruments, src)
	. = do_play_lines(user)
	stop_playing()
	updateDialog()

/datum/song/proc/stop_playing()
	if(!playing)
		return
	playing = FALSE
	if(!debug_mode)
		compiled_chords = null
	hearing_mobs.len = 0
	STOP_PLAYING(SSinstruments, src)
	terminate_all_sounds(TRUE)

/// THIS IS A BLOCKING CALL.
/datum/song/proc/do_play_lines(user)
	if(!playing)
		return
	do_hearcheck()
	if(legacy)
		do_play_lines_legacy(user)
	else
		do_play_lines_synthesized(user)

/datum/song/proc/should_stop_playing(mob/user)
	return QDELETED(parent) || !using_instrument || !playing

/datum/song/proc/sanitize_tempo(new_tempo)
	new_tempo = abs(new_tempo)
	return CLAMP(round(new_tempo, world.tick_lag), world.tick_lag, 5 SECONDS)

/datum/song/proc/get_bpm()
	return 600 / tempo

/datum/song/proc/set_bpm(bpm)
	tempo = sanitize_tempo(600 / bpm)

/// Updates the window for our user. Override in subtypes.
/datum/song/proc/updateDialog(mob/user)
	ui_interact(user)

/datum/song/process(wait)
	if(!now_playing)
		return PROCESS_KILL
	process_decay()

/datum/song/proc/update_sustain()
	// Exponential is easy
	cached_exponential_dropoff = sustain_exponential_dropoff
	// Linear, not so much, since it's a target duration from 100 volume rather than an exponential rate.
	var/target_duration = sustain_linear_duration
	var/volume_diff = max(0, volume - sustain_dropoff_volume)
	var/volume_decrease_per_decisecond = volume_diff / target_duration
	cached_linear_dropoff = volume_decrease_per_decisecond

/datum/song/proc/set_volume(volume)
	src.volume = CLAMP(volume, max(0, min_volume), min(100, max_volume))
	update_sustain()
	updateDialog()

/datum/song/proc/set_dropoff_volume(volume)
	sustain_dropoff_volume = CLAMP(volume, INSTRUMENT_SUSTAIN_MIN_DROPOFF, 100)
	update_sustain()
	updateDialog()

/datum/song/proc/set_exponential_drop_rate(drop)
	sustain_exponential_dropoff = CLAMP(drop, INSTRUMENT_EXP_FALLOFF_MIN, INSTRUMENT_EXP_FALLOFF_MAX)
	update_sustain()
	updateDialog()

/datum/song/proc/set_linear_falloff_duration(duration)
	sustain_linear_duration = CLAMP(duration, 0, INSTRUMENT_MAX_TOTAL_SUSTAIN)
	update_sustain()
	updateDialog()

/datum/song/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, volume))
				set_volume(var_value)
			if(NAMEOF(src, sustain_dropoff_volume))
				set_dropoff_volume(var_value)
			if(NAMEOF(src, sustain_exponential_dropoff))
				set_exponential_drop_rate(var_value)
			if(NAMEOF(src, sustain_lienar_duration))
				set_linear_falloff_duration(var_value)

// subtype for handheld instruments, like violin
/datum/song/handheld

/datum/song/handheld/updateDialog(mob/user)
	parent.interact(user)

/datum/song/handheld/should_stop_playing(mob/user)
	. = ..()
	if(.)
		return TRUE
	var/obj/item/instrument/I = parent
	return I.should_stop_playing(user)

// subtype for stationary structures, like pianos
/datum/song/stationary

/datum/song/stationary/updateDialog(mob/user)
	parent.interact(user)

/datum/song/stationary/should_stop_playing(mob/user)
	. = ..()
	if(.)
		return TRUE
	var/obj/structure/musician/M = parent
	return M.should_stop_playing(user)
