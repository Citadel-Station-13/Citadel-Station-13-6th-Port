/mob/living/silicon/Login()
	if(mind && SSticker.mode)
		SSticker.mode.remove_cultist(mind, 0, 0)
		SSticker.mode.remove_revolutionary(mind, 0)
	..()
