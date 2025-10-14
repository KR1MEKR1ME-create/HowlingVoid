/datum/species/tajaran
	name = "Таяран"
	id = SPECIES_TAJARAN
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_HATED_BY_DOGS,
		TRAIT_MUTANT_COLORS,
		TRAIT_CATLIKE_GRACE,
		TRAIT_WATER_HATER,
		TRAIT_FELINE,
		TRAIT_SENSITIVE_HEARING,
	)
	mutanttongue = /obj/item/organ/tongue/cat/tajaran
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list()
	payday_modifier = 1.0
	species_language_holder = /datum/language_holder/tajaran
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	examine_limb_id = SPECIES_MAMMAL
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant,
	)

/datum/species/tajaran/get_default_mutant_bodyparts()
	return list(
		"tail" = list("Cat (Big)", TRUE),
		"snout" = list("Mammal, Short", TRUE),
		"ears" = list("Cat, Alert", TRUE),
		"legs" = list("Normal Legs", FALSE),
	)

/obj/item/organ/tongue/cat/tajaran
	liked_foodtypes = GRAIN | MEAT
	disliked_foodtypes = CLOTH


/datum/species/tajaran/randomize_features()
	var/list/features = ..()
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of mostly coldish, animal, matching colors
	switch(random)
		if(1)
			main_color = "#BBAA88"
			second_color = "#AAAA99"
		if(2)
			main_color = "#777766"
			second_color = "#888877"
		if(3)
			main_color = "#AA9988"
			second_color = "#AAAA99"
		if(4)
			main_color = "#EEEEDD"
			second_color = "#FFEEEE"
		if(5)
			main_color = "#DDCC99"
			second_color = "#DDCCAA"
	features["mcolor"] = main_color
	features["mcolor2"] = second_color
	features["mcolor3"] = second_color
	return features

/datum/species/tajaran/get_random_body_markings(list/passed_features)
	var/name = pick("Tajaran", "Floof", "Floofer")
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings

/datum/species/tajaran/get_species_description()
	return placeholder_description

/datum/species/tajaran/get_species_lore()
	return list(placeholder_lore)

/datum/species/tajaran/prepare_human_for_preview(mob/living/carbon/human/cat)
	var/main_color = "#AA9988"
	var/second_color = "#AAAA99"

	cat.dna.features["mcolor"] = main_color
	cat.dna.features["mcolor2"] = second_color
	cat.dna.features["mcolor3"] = second_color
	cat.dna.mutant_bodyparts["snout"] = list(MUTANT_INDEX_NAME = "Mammal, Short", MUTANT_INDEX_COLOR_LIST = list(main_color, main_color, main_color))
	cat.dna.mutant_bodyparts["tail"] = list(MUTANT_INDEX_NAME = "Cat", MUTANT_INDEX_COLOR_LIST = list(second_color, main_color, main_color))
	cat.dna.mutant_bodyparts["ears"] = list(MUTANT_INDEX_NAME = "Cat, Alert", MUTANT_INDEX_COLOR_LIST = list(main_color, second_color, second_color))
	regenerate_organs(cat, src, visual_only = TRUE)
	cat.update_body(TRUE)


// Уворот от пуль
/datum/species/tajaran/proc/on_tajaran_bullet_hit(mob/living/carbon/human/tajaran, obj/projectile/hit_projectile)
	SIGNAL_HANDLER

	if(prob(25) && tajaran.stat == CONSCIOUS) //25% шанса, если цель всё еще жива и не в крите
		tajaran.visible_message(span_danger("[tajaran.get_visible_name()] [tajaran.gender == FEMALE ? "уклонилась" : "уклонился"] от пули!"))
		INVOKE_ASYNC(tajaran, TYPE_PROC_REF(/mob, emote), "hiss")
		playsound(tajaran.loc, "sound/items/weapons/effects/ric[rand(1, 5)]", 25, TRUE, -1)
		return PROJECTILE_INTERRUPT_HIT


// Зов месы
/datum/species/tajaran
	var/death_count = 0
	var/death_count_max = 8 // В результате ровно 9 смертей

/datum/species/tajaran/on_species_gain(mob/living/carbon/human/H, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	if(!H)
		return
	//// === Шерсть ===
	H.physiology.heat_mod += 0.25        // на 25% больше урона от жара
	H.physiology.cold_mod -= 0.25        // на 25% меньше урона от холода
	bodytemp_normal = 308
	bodytemp_cold_damage_limit = 245
	bodytemp_heat_damage_limit = 325
	// === Счётчик смертей и уворот от пуль ===
	RegisterSignal(H, COMSIG_LIVING_DEATH, PROC_REF(on_tajaran_death))
	RegisterSignal(H, COMSIG_PROJECTILE_PREHIT, PROC_REF(on_tajaran_bullet_hit))

	// === Квирки (ночное зрение и фотофобия) ===
	if(!H.quirks)
		H.quirks = list()

	var/found_photophobia = FALSE
	var/found_nightvision = FALSE
	for(var/datum/quirk/Q in H.quirks)
		if(istype(Q, /datum/quirk/photophobia))
			found_photophobia = TRUE
		if(istype(Q, /datum/quirk/night_vision))
			found_nightvision = TRUE

	if(!found_photophobia)
		var/datum/quirk/photophobia/P = new()
		P.quirk_holder = H
		H.quirks += P
		P.add(H.client)

	if(!found_nightvision)
		var/datum/quirk/night_vision/N = new()
		N.quirk_holder = H
		H.quirks += N
		N.add(H.client)

	// === Способность слуха ===
	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		var/datum/action/cooldown/spell/teshari_hearing/hearing_action = new
		hearing_action.Grant(H)

	// === Способность вылизываться ===
	var/datum/action/cooldown/tajaran_grooming/G = new()
	G.Grant(H)

	// === Охотничий нюх ===
	var/datum/action/cooldown/tajaran_scent_scan/scent = new()
	scent.Grant(H)

/datum/species/tajaran/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	if(!H)
		return

	UnregisterSignal(H, list(COMSIG_LIVING_DEATH, COMSIG_PROJECTILE_PREHIT))

	var/obj/item/organ/ears/ears = H.get_organ_slot(ORGAN_SLOT_EARS)
	if(ears)
		ears.damage_multiplier = initial(ears.damage_multiplier)

	H.remove_status_effect(/datum/status_effect/agent_pinpointer/scan/tajaran_scent)
// === Счётчик смертей ===
/datum/species/tajaran/proc/on_tajaran_death(mob/living/carbon/human/tajaran)
	SIGNAL_HANDLER
	death_count++
	if(death_count == death_count_max)
		to_chat(tajaran, span_danger("Ты чувствуешь, что это твоя последняя жизнь..."))
	if(death_count < death_count_max)
		return
	if(!HAS_TRAIT(tajaran, TRAIT_DNR))
		tajaran.visible_message(span_warning("[tajaran.get_visible_name()] исчерпал все свои жизни и больше не встанет."))
		ADD_TRAIT(tajaran, TRAIT_DNR, ADMIN_TRAIT)


// === Вылизывание ===
/datum/action/cooldown/tajaran_grooming
	name = "Уход за собой"
	desc = "Ты вылизываешь шерсть, смывая кровь и грязь. Может остановить кровотечение и немного лечит."
	button_icon = 'modular_nova/modules/organs/icons/cyber_tongue.dmi'
	button_icon_state = "cybertongue"
	cooldown_time = 1 SECONDS

/datum/action/cooldown/tajaran_grooming/Activate(mob/living/carbon/human/H)
	if(!H)
		return

	H.visible_message(
		span_notice("[H] вылизывается!"),
		span_notice("Ты вылизываешься!")
	)
	if(!do_after(H, 15 SECONDS, H))
		if(H.gender == FEMALE)
			to_chat(H, span_warning("Ты отвлеклась и перестала вылизываться..."))
		else
			to_chat(H, span_warning("Ты отвлёкся и перестал вылизываться..."))
		return

	H.wash(CLEAN_TYPE_BLOOD)
	var/heal_brute = 1
	var/heal_burn = 0
	var/obj/item/bodypart/target_BP = H.get_bodypart(H.zone_selected)
	if(target_BP)
		if(target_BP.heal_damage(heal_brute, heal_burn))
			H.update_damage_overlays()
		if(target_BP.wounds)
			for(var/datum/wound/W in target_BP.wounds)
				if(W.blood_flow > 0 && prob(45))
					W.blood_flow = 0

	var/self_msg = ""
	var/around_msg = ""
	if(H.gender == FEMALE)
		self_msg = "Ты вылизалась!"
		around_msg = "[H] вылизалась!"
	else
		self_msg = "Ты вылизался!"
		around_msg = "[H] вылизался!"

	H.visible_message(span_notice(around_msg), span_notice(self_msg))

/datum/action/cooldown/tajaran_scent_scan
	name = "Охотничий нюх"
	desc = "Таяры могут принюхаться, чтобы ощутить свежие следы рядом и отследить носителя отпечатков."
	button_icon = 'modular_nova/modules/organs/icons/cyber_tongue.dmi'
	button_icon_state = "cybertongue"
	cooldown_time = 30 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/tajaran_scent_scan/Activate(atom/target)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return FALSE

	var/turf/current_turf = get_turf(H)
	if(!current_turf)
		return FALSE

	H.visible_message(
		span_notice("[H] принюхивается, пытаясь уловить следы."),
		span_notice("Ты принюхиваешься, пытаясь уловить следы.")
	)

	if(!do_after(H, 3 SECONDS, H))
		to_chat(H, span_warning("Ты теряешь след."))
		return FALSE

	var/list/atoms_to_scan = list(current_turf)
	for(var/atom/movable/thing in current_turf)
		if(thing == H)
			continue
		if(thing.invisibility > H.see_invisible)
			continue
		atoms_to_scan += thing

	var/list/messages = list()
	var/list/fingerprints_found = list()

	for(var/atom/scanned_atom as anything in atoms_to_scan)
		var/list/log_entry = gather_forensic_data(scanned_atom)
		if(!length(log_entry))
			continue

		var/formatted_message = format_forensic_message(scanned_atom, log_entry)
		if(formatted_message)
			messages += formatted_message

		var/list/found_prints = log_entry[DETSCAN_CATEGORY_FINGERS]
		if(LAZYLEN(found_prints))
			for(var/print in found_prints)
				if(!istext(print))
					continue
				if(print in fingerprints_found)
					continue
				fingerprints_found += print

	if(!LAZYLEN(messages))
		to_chat(H, span_notice("Ты не чуешь ничего примечательного."))
		StartCooldown()
		return TRUE

	H.balloon_alert(H, "запах уловлен")
	to_chat(H, span_notice("Ты улавливаешь запахи вокруг:"))
	for(var/entry in messages)
		to_chat(H, span_info(entry))

	var/mob/living/carbon/human/target_to_track = find_best_target(H, fingerprints_found)
	if(target_to_track)
		H.remove_status_effect(/datum/status_effect/agent_pinpointer/scan/tajaran_scent)
		var/datum/status_effect/agent_pinpointer/scan/tajaran_scent/scent_effect = H.apply_status_effect(/datum/status_effect/agent_pinpointer/scan/tajaran_scent)
		if(scent_effect)
			scent_effect.set_target(target_to_track)
			to_chat(H, span_notice("Запах ведёт к [target_to_track]."))
	else if(LAZYLEN(fingerprints_found))
		to_chat(H, span_warning("Запах отпечатков ни с кем не совпадает."))

	StartCooldown()
	return TRUE


/datum/action/cooldown/tajaran_scent_scan/proc/gather_forensic_data(atom/scanned_atom)
	if(!scanned_atom)
		return list()

	var/list/log_entry = list()

	var/list/atom_fibers = GET_ATOM_FIBRES(scanned_atom)
	if(LAZYLEN(atom_fibers))
		log_entry[DETSCAN_CATEGORY_FIBER] = atom_fibers.Copy()

	var/list/blood = GET_ATOM_BLOOD_DNA(scanned_atom)
	if(LAZYLEN(blood))
		log_entry[DETSCAN_CATEGORY_BLOOD] = blood.Copy()

	if(ishuman(scanned_atom))
		var/mob/living/carbon/human/scanned_human = scanned_atom
		if(!scanned_human.gloves)
			var/fingerprint = md5(scanned_human.dna?.unique_identity)
			if(fingerprint)
				LAZYADD(log_entry[DETSCAN_CATEGORY_FINGERS], fingerprint)
	else if(!ismob(scanned_atom))
		var/list/atom_fingerprints = GET_ATOM_FINGERPRINTS(scanned_atom)
		if(LAZYLEN(atom_fingerprints))
			log_entry[DETSCAN_CATEGORY_FINGERS] = atom_fingerprints.Copy()

	if(scanned_atom.reagents)
		for(var/datum/reagent/present_reagent as anything in scanned_atom.reagents.reagent_list)
			LAZYADD(log_entry[DETSCAN_CATEGORY_DRINK], list(present_reagent.name = present_reagent.volume))

			if(istype(present_reagent, /datum/reagent/blood))
				var/list/reagent_data = present_reagent.data
				if(islist(reagent_data))
					var/blood_DNA = reagent_data["blood_DNA"]
					var/blood_type = reagent_data["blood_type"]
					if(blood_DNA && blood_type)
						if(!log_entry[DETSCAN_CATEGORY_BLOOD])
							log_entry[DETSCAN_CATEGORY_BLOOD] = list()
						LAZYSET(log_entry[DETSCAN_CATEGORY_BLOOD], blood_DNA, blood_type)

	return log_entry


/datum/action/cooldown/tajaran_scent_scan/proc/format_forensic_message(atom/scanned_atom, list/log_entry)
	if(!length(log_entry))
		return null

	var/list/lines = list("<b>\\The [scanned_atom]</b>")

	var/list/fibers = log_entry[DETSCAN_CATEGORY_FIBER]
	if(LAZYLEN(fibers))
		lines += "&bull; Волокна: [english_list(fibers)]"

	var/list/blood_data = log_entry[DETSCAN_CATEGORY_BLOOD]
	if(LAZYLEN(blood_data))
		var/list/blood_lines = list()
		for(var/blood_identity in blood_data)
			var/blood_type = blood_data[blood_identity] || "неизвестно"
			blood_lines += "[blood_identity] ([blood_type])"
		lines += "&bull; Следы крови: [blood_lines.Join(", ")]"

	var/list/prints = log_entry[DETSCAN_CATEGORY_FINGERS]
	if(LAZYLEN(prints))
		lines += "&bull; Отпечатки: [prints.Join(", ")]"

	var/list/reagent_traces = log_entry[DETSCAN_CATEGORY_DRINK]
	if(LAZYLEN(reagent_traces))
		var/list/reagent_lines = list()
		for(var/reagent_name in reagent_traces)
			var/amount = reagent_traces[reagent_name]
			reagent_lines += "[reagent_name] ([round(amount, 0.1)] u)"
		lines += "&bull; Частицы: [reagent_lines.Join(", ")]"

	return lines.Join("<br>")


/datum/action/cooldown/tajaran_scent_scan/proc/find_best_target(mob/living/carbon/human/sniffer, list/fingerprints)
	if(!sniffer || !LAZYLEN(fingerprints))
		return null

	var/list/fingerprint_lookup = list()
	for(var/fingerprint in fingerprints)
		if(istext(fingerprint))
			fingerprint_lookup[fingerprint] = TRUE

	if(!LAZYLEN(fingerprint_lookup))
		return null

	var/turf/sniffer_turf = get_turf(sniffer)
	var/mob/living/carbon/human/best_target
	var/best_distance = INFINITY

	for(var/mob/living/carbon/human/candidate as anything in GLOB.human_list)
		if(candidate == sniffer)
			continue
		if(QDELETED(candidate))
			continue
		if(candidate.stat == DEAD)
			continue
		if(!candidate.dna?.unique_identity)
			continue

		var/current_fingerprint = md5(candidate.dna.unique_identity)
		if(!fingerprint_lookup[current_fingerprint])
			continue

		var/turf/candidate_turf = get_turf(candidate)
		if(!candidate_turf || !sniffer_turf)
			continue

		var/dist = get_dist(sniffer_turf, candidate_turf)
		if(isnull(best_target) || dist < best_distance)
			best_distance = dist
			best_target = candidate

	return best_target


/datum/status_effect/agent_pinpointer/scan/tajaran_scent
	id = "tajaran_scent"
	duration = 45 SECONDS
	tick_interval = 2 SECONDS
	minimum_range = 1
	range_mid = 6
	range_far = 20
	range_fuzz_factor = 0
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/scan/tajaran_scent
	var/datum/weakref/target_ref

/datum/status_effect/agent_pinpointer/scan/tajaran_scent/proc/set_target(mob/living/carbon/human/target)
	if(target)
		target_ref = WEAKREF(target)
	else
		target_ref = null
	scan_target = target

/datum/status_effect/agent_pinpointer/scan/tajaran_scent/scan_for_target()
	scan_target = target_ref?.resolve()
	if(!scan_target)
		qdel(src)

/atom/movable/screen/alert/status_effect/agent_pinpointer/scan/tajaran_scent
	name = "След"
	desc = "Ты чувствуешь направление источника запаха."


/datum/species/tajaran/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Уход за собой",
			SPECIES_PERK_DESC = "Таяры могут зализывать раны, чтобы избавиться от кровотечения, а так же смывать с себя кровь.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_EYE_DROPPER,
			SPECIES_PERK_NAME = "Кошачий глаз",
			SPECIES_PERK_DESC = "Таяры видят в темноте лучше, чем люди, но яркий свет их слепит лучше.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_CAT,
			SPECIES_PERK_NAME = "Инстинкт охотника",
			SPECIES_PERK_DESC = "Таяры обладают очень хорошей реакцией. Они имеют шанс уклониться от любой атаки.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Кошачий слух",
			SPECIES_PERK_DESC = "Таяры лучше слышат. Вы можете слышать даже самые тихие звуки, но из-за этого повышается риск повреждения слуха.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HEADPHONES_SIMPLE,
			SPECIES_PERK_NAME = "Кошачий нюх",
			SPECIES_PERK_DESC = "У таяр - отменный нюх. Вы можете принюхаться, чтобы найти свежие следы поблизости и отследить носителя отпечатков!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Шерсть",
			SPECIES_PERK_DESC = "Вы хорошо переносите холод, но вам тяжело в жару. Интересный факт, а вы знали что шерсть хорошо горит? :)",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_FALLING,
			SPECIES_PERK_NAME = "Мягкая посадка",
			SPECIES_PERK_DESC = "Таяры не страдают от падений с высоты и приземляются на ноги.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shower",
			SPECIES_PERK_NAME = "Гидрофобия",
			SPECIES_PERK_DESC = "Таяры не любят воду и получают дискомфорт, будучи мокрыми.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Кусаца :3",
			SPECIES_PERK_DESC = "Таяры могут кусаться.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "Девять жизней",
			SPECIES_PERK_DESC = "Таяры имеют девять жизней. Когда жизни заканчиваются, смерть становится постоянной.",
		),
	)


	return to_add
