#define DUMPTIME 3000

/datum/bank_account
	var/account_holder = "Rusty Venture"
	var/account_balance = 0
	var/datum/job/account_job
	var/list/bank_cards = list()
	var/add_to_accounts = TRUE
	var/transferable = TRUE
	var/account_id
	var/being_dumped = FALSE //pink levels are rising

/datum/bank_account/New(newname, job)
	account_holder = newname
	account_job = job
	account_id = rand(111111,999999)
	setup_unique_account_id()

/datum/bank_account/Destroy()
	if(add_to_accounts)
		SSeconomy.bank_accounts_by_id -= "[account_id]"
	return ..()

/// Proc guarantees the account_id possesses a unique number. If it doesn't, it tries to find a unique alternative. It then adds it to the `SSeconomy.bank_accounts_by_id` global list.
/datum/bank_account/proc/setup_unique_account_id()
	if(account_id && !SSeconomy.bank_accounts_by_id["[account_id]"])
		SSeconomy.bank_accounts_by_id["[account_id]"] = src
		return //Already unique
	for(var/i in 1 to 1000)
		account_id = rand(111111, 999999)
		if(!SSeconomy.bank_accounts_by_id["[account_id]"])
			break
	if(SSeconomy.bank_accounts_by_id["[account_id]"])
		stack_trace("Unable to find a unique account ID, substituting currently existing account of id [account_id].")
	SSeconomy.bank_accounts_by_id["[account_id]"] = src

/datum/bank_account/vv_edit_var(var_name, var_value) // just so you don't have to do it manually
	var/old_id = account_id
	. = ..()
	switch(var_name)
		if(NAMEOF(src, account_id))
			if(add_to_accounts)
				SSeconomy.bank_accounts_by_id -= "[old_id]"
				setup_unique_account_id()
		if(NAMEOF(src, add_to_accounts))
			if(add_to_accounts)
				setup_unique_account_id()
			else
				SSeconomy.bank_accounts_by_id -= "[account_id]"

/datum/bank_account/proc/_adjust_money(amt)
	account_balance += amt
	if(account_balance < 0)
		account_balance = 0

/datum/bank_account/proc/has_money(amt)
	return account_balance >= amt

/datum/bank_account/proc/adjust_money(amt)
	if((amt < 0 && has_money(-amt)) || amt > 0)
		_adjust_money(amt)
		return TRUE
	return FALSE

/datum/bank_account/proc/transfer_money(datum/bank_account/from, amount)
	if(!from.transferable || !from.has_money(amount))
		return FALSE
	adjust_money(amount)
	from.adjust_money(-amount)
	return TRUE

/datum/bank_account/proc/payday(amt_of_paychecks, free = FALSE)
	var/money_to_transfer = account_job.paycheck * amt_of_paychecks
	if(free)
		adjust_money(money_to_transfer)
	else
		var/datum/bank_account/D = SSeconomy.get_dep_account(account_job.paycheck_department)
		if(D)
			if(!transfer_money(D, money_to_transfer))
				bank_card_talk("ERROR: Payday aborted, departmental funds insufficient.")
				return FALSE
			else
				bank_card_talk("Payday processed, account now holds [account_balance] cr.")
				return TRUE
	bank_card_talk("ERROR: Payday aborted, unable to contact departmental account.")
	return FALSE

/datum/bank_account/proc/bank_card_talk(message, force)
	if(!message || !bank_cards.len)
		return
	for(var/obj/A in bank_cards)
		var/icon_source = A
		/*
		if(istype(A, /obj/item/card/id))
			var/obj/item/card/id/id_card = A
			if(id_card.uses_overlays)
				icon_source = id_card.get_cached_flat_icon()
		*/
		var/mob/card_holder = recursive_loc_check(A, /mob)
		if(ismob(card_holder)) //If on a mob
			if(!card_holder.client || (!(card_holder.client.prefs.chat_toggles & CHAT_BANKCARD) && !force))
				return

			card_holder.playsound_local(get_turf(card_holder), 'sound/machines/twobeep.ogg', 50, TRUE)
			if(card_holder.can_hear())
				to_chat(card_holder, "[icon2html(icon_source, card_holder)] <span class='notice'>[message]</span>")
		else if(isturf(A.loc)) //If on the ground
			for(var/mob/M in hearers(1,get_turf(A)))
				if(M.client && !(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force)
					return
				playsound(A, 'sound/machines/twobeep.ogg', 50, TRUE)
				A.audible_message("[icon2html(icon_source, hearers(A))] <span class='notice'>[message]</span>", null, 1)
				break
		else
			for(var/mob/M in A.loc) //If inside a container with other mobs (e.g. locker)
				if(!M.client || (!(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force))
					return
				M.playsound_local(get_turf(M), 'sound/machines/twobeep.ogg', 50, TRUE)
				if(M.can_hear())
					to_chat(M, "[icon2html(icon_source, M)] <span class='notice'>[message]</span>")

/datum/bank_account/department
	account_holder = "Guild Credit Agency"
	var/department_id = "REPLACE_ME"
	add_to_accounts = FALSE

/datum/bank_account/department/New(dep_id, budget)
	department_id = dep_id
	account_balance = budget
	account_holder = SSeconomy.department_accounts[dep_id]
	SSeconomy.generated_accounts += src

/datum/bank_account/remote // Bank account not belonging to the local station
	add_to_accounts = FALSE

/datum/bank_account/remote/non_transferable
	transferable = FALSE

#undef DUMPTIME
