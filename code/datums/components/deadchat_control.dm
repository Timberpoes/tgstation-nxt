#define DEMOCRACY_MODE "democracy"
#define ANARCHY_MODE "anarchy"

/datum/component/deadchat_control
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/timerid

	var/list/datum/callback/inputs = list()
	var/list/ckey_to_cooldown = list()
	var/orbiters = list()
	var/deadchat_mode
	var/input_cooldown
	///Callback thats invoked when the component is added, allows for changing up any vars on the component.
	var/datum/callback/on_removal

/datum/component/deadchat_control/Initialize(_deadchat_mode, _inputs, _input_cooldown = 12 SECONDS, _removal_callback)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_BEGIN, .proc/orbit_begin)
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_STOP, .proc/orbit_stop)
	RegisterSignal(parent, COMSIG_VV_TOPIC, .proc/handle_vv_topic)
	deadchat_mode = _deadchat_mode
	inputs = _inputs
	input_cooldown = _input_cooldown
	removal_callback = _removal_callback
	if(deadchat_mode == DEMOCRACY_MODE)
		timerid = addtimer(CALLBACK(src, .proc/democracy_loop), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	notify_ghosts("[parent] is now deadchat controllable!", source = parent, action = NOTIFY_ORBIT, header="Something Interesting!")

/datum/component/deadchat_control/Destroy(force, silent)
	on_removal?.Invoke()
	inputs = null
	orbiters = null
	ckey_to_cooldown = null
	return ..()

/datum/component/deadchat_control/proc/deadchat_react(mob/source, message)
	SIGNAL_HANDLER

	message = lowertext(message)
	if(!inputs[message])
		return
	if(deadchat_mode == ANARCHY_MODE)
		var/cooldown = ckey_to_cooldown[source.ckey]
		if(cooldown)
			return MOB_DEADSAY_SIGNAL_INTERCEPT
		inputs[message].Invoke()
		ckey_to_cooldown[source.ckey] = TRUE
		addtimer(CALLBACK(src, .proc/remove_cooldown, source.ckey), input_cooldown)
	else if(deadchat_mode == DEMOCRACY_MODE)
		ckey_to_cooldown[source.ckey] = message
	return MOB_DEADSAY_SIGNAL_INTERCEPT

/datum/component/deadchat_control/proc/remove_cooldown(ckey)
	ckey_to_cooldown.Remove(ckey)

/datum/component/deadchat_control/proc/democracy_loop()
	if(QDELETED(parent) || deadchat_mode != DEMOCRACY_MODE)
		deltimer(timerid)
		return
	var/result = count_democracy_votes()
	if(!isnull(result))
		inputs[result].Invoke()
		var/message = "<span class='deadsay italics bold'>[parent] has done action [result]!<br>New vote started. It will end in [input_cooldown/10] seconds.</span>"
		for(var/M in orbiters)
			to_chat(M, message)
	else
		var/message = "<span class='deadsay italics bold'>No votes were cast this cycle.</span>"
		for(var/M in orbiters)
			to_chat(M, message)

/datum/component/deadchat_control/proc/count_democracy_votes()
	if(!length(ckey_to_cooldown))
		return
	var/list/votes = list()
	for(var/command in inputs)
		votes["[command]"] = 0
	for(var/vote in ckey_to_cooldown)
		votes[ckey_to_cooldown[vote]]++
		ckey_to_cooldown.Remove(vote)

	// Solve which had most votes.
	var/prev_value = 0
	var/result
	for(var/vote in votes)
		if(votes[vote] > prev_value)
			prev_value = votes[vote]
			result = vote

	if(result in inputs)
		return result

/datum/component/deadchat_control/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, deadchat_mode))
		return
	ckey_to_cooldown = list()
	if(var_value == DEMOCRACY_MODE)
		timerid = addtimer(CALLBACK(src, .proc/democracy_loop), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	else
		deltimer(timerid)

/datum/component/deadchat_control/proc/orbit_begin(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	RegisterSignal(orbiter, COMSIG_MOB_DEADSAY, .proc/deadchat_react)
	orbiters |= orbiter

/datum/component/deadchat_control/proc/orbit_stop(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	if(orbiter in orbiters)
		UnregisterSignal(orbiter, COMSIG_MOB_DEADSAY)
		orbiters -= orbiter

///This proc ensures you can remove this component from vv
/datum/component/deadchat_control/proc/handle_vv_topic(datum/source, mob/user, list/href_list)
	SIGNAL_HANDLER
	if(!href_list[VV_HK_DEADCHAT_PLAYS] || !check_rights(R_FUN))
		return
	. = COMPONENT_VV_HANDLED
	INVOKE_ASYNC(src, .proc/async_handle_vv_topic, user, href_list)

///Handle vv sleeps so make it async
/datum/component/deadchat_control/proc/async_handle_vv_topic(mob/user, list/href_list)
	if(alert(user, "Remove deadchat control from [parent]?", "Deadchat Plays [parent]", "Remove", "Cancel") == "Remove")
		to_chat(user, "<span class='notice'>Deadchat can no longer control [parent].</span>")
		log_admin("[key_name(user)] has removed deadchat control from [parent]")
		message_admins("<span class='notice'>[key_name(user)] has removed deadchat control from [parent]</span>")
		qdel(src)
		return
