/mob/living/Login()
	..()
	//Mind updates
	sync_mind()
//ambition start
	if(mind.memory || mind.antag_datums)
		to_chat(src, "<i>[mind.show_memory()]</i>")
//ambition end

	//Round specific stuff
	if(SSticker.mode)
		switch(SSticker.mode.name)
			if("sandbox")
				CanBuild()

	update_damage_hud()
	update_health_hud()

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	if(ranged_ability)
		ranged_ability.add_ranged_ability(src, "<span class='notice'>You currently have <b>[ranged_ability]</b> active!</span>")
	if((vore_flags & VORE_INIT) && !(vore_flags & VOREPREF_INIT)) //Vore's been initialized, voreprefs haven't. If this triggers then that means that voreprefs failed to load due to the client being missing.
		copy_from_prefs_vr()
