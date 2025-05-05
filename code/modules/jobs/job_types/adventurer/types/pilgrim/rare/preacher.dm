/datum/advclass/pilgrim/rare/preacher
	name = "Preacher"
	tutorial = "A devout follower of Psydon, you came to this land with nothing more than \
	the clothes on your back and the faith in your heart. \n\
	Sway these nonbelievers to the right path!"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_PLAYER_GRENZ
	outfit = /datum/outfit/job/adventurer/preacher
	category_tags = list(CTAG_PILGRIM)
	maximum_possible_slots = 1
	pickprob = 30
	min_pq = 0

	cmode_music = 'sound/music/cmode/church/CombatInquisitor.ogg'

/datum/outfit/job/adventurer/preacher/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/shortboots
	belt = /obj/item/storage/belt/leather/rope
	beltr = /obj/item/flashlight/flare/torch/lantern
	shirt = /obj/item/clothing/shirt/undershirt/priest
	pants = /obj/item/clothing/pants/tights/black
	neck = /obj/item/clothing/neck/psycross
	head = /obj/item/clothing/head/brimmed
	r_hand = /obj/item/book/psybibble
	beltl = /obj/item/handheld_bell
	if(H.mind)
		H.mind?.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
		H.mind?.adjust_skillrank(/datum/skill/misc/music, 1, TRUE)
		H.mind?.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind?.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/convert_faith)
		if(!H.has_language(/datum/language/oldpsydonic))
			H.grant_language(/datum/language/oldpsydonic)
			to_chat(H, "<span class='info'>I can speak Old Psydonic with ,m before my speech.</span>")
		H.set_patron(/datum/patron/psydon)
	ADD_TRAIT(H, TRAIT_FOREIGNER, TRAIT_GENERIC)

/obj/effect/proc_holder/spell/invoked/convert_faith
	name = "New Devotion"
	desc = "Show them the true path."
	overlay_state = "psy_recruit"
	antimagic_allowed = FALSE //this is not magic
	recharge_time = 30 SECONDS
	range = 2
	stat_allowed = TRUE
	sound = 'sound/misc/handbell.ogg' // very tempted to use the WOLOLOL
	/// Your new patron here
	var/new_patron = /datum/patron/psydon
	var/accept_message = list("I believe.", "I accept.", "This is my path now.", "I walk with you.", "So be it.")
	var/refuse_message = list("I refuse.", "Not my path.", "I won't turn.", "My faith stays.", "Never.")

/obj/effect/proc_holder/spell/invoked/convert_faith/cast(list/targets, mob/living/user)
	. = ..()
	if(!ishuman(targets[1]))
		return
	var/mob/living/carbon/human/human_target = targets[1]
	to_chat(user, "<span class='notice'>I begin to preach to [human_target] </span>")
	if(!do_after(user, 2 SECONDS, user))
		return
	if(!can_convert(human_target))
		human_target.say(pick(refuse_message), forced = "[name]")
		return
	var/prompt = alert(human_target, "Do you wish to follow [new_patron]?", "[new_patron]", "Yes", "No")
	if(prompt == "Yes")
		human_target.say(pick(accept_message), forced = "[name]")
		human_target.set_patron(new_patron)
		human_target.grant_language(/datum/language/oldpsydonic)
		return
	human_target.say(pick(refuse_message), forced = "[name]")

/obj/effect/proc_holder/spell/invoked/convert_faith/proc/can_convert(mob/living/carbon/human/human_target)
	if(human_target.job in GLOB.church_positions) // those devoted to the ten would not abandon their faith
		return FALSE
	return TRUE
