/datum/job/raisa_agent
	title = JOB_RAISA_AGENT
	description = "Help security solve crimes or take on private cases for wealthy clients. \
		Look badass and abuse every substance."
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Security Director"
	selection_color = "#490A0D"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW

	employers = list(
		/datum/employer/scp
	)

	outfits = list(
		"Default" = list(
			SPECIES_HUMAN = /datum/outfit/job/raisa_agent,
			SPECIES_TESHARI = /datum/outfit/job/raisa_agent,
			SPECIES_VOX = /datum/outfit/job/raisa_agent,
			SPECIES_PLASMAMAN = /datum/outfit/job/raisa_agent/plasmaman,
		),
	)

	departments_list = list(
		/datum/job_department/security,
	)

	paycheck = PAYCHECK_MEDIUM

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 25,
		/obj/item/ammo_box/c38 = 25,
		/obj/item/ammo_box/c38/dumdum = 5,
		/obj/item/ammo_box/c38/hotshot = 5,
		/obj/item/ammo_box/c38/iceblox = 5,
		/obj/item/ammo_box/c38/match = 5,
		/obj/item/ammo_box/c38/trac = 5,
	)

	family_heirlooms = list(/obj/item/reagent_containers/food/drinks/bottle/whiskey)
	rpg_title = "Thiefcatcher"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN


/datum/outfit/job/raisa_agent
	name = JOB_RAISA_AGENT
	jobtype = /datum/job/raisa_agent

	id_trim = /datum/id_trim/job/raisa_agent
	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/det_suit
	belt = /obj/item/modular_computer/tablet/pda/detective
	gloves = /obj/item/clothing/gloves/forensic
	head = /obj/item/clothing/head/fedora/det_hat
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/storage/fancy/cigarettes/dromedaryco

	l_hand = /obj/item/storage/briefcase/crimekit

	chameleon_extras = list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/gun/ballistic/revolver/detective,
		)


/datum/outfit/job/raisa_agent/plasmaman
	name = JOB_RAISA_AGENT + " (Plasmaman)"

	uniform = /obj/item/clothing/under/plasmaman/enviroslacks
	gloves = /obj/item/clothing/gloves/color/plasmaman/white
	head = /obj/item/clothing/head/helmet/space/plasmaman/white
	mask = /obj/item/clothing/mask/breath
	r_hand = /obj/item/tank/internals/plasmaman/belt/full

/datum/outfit/job/raisa_agent/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/clothing/mask/cigarette/cig = H.wear_mask
	if(istype(cig)) //Some species specfic changes can mess this up (plasmamen)
		cig.light("")

	if(visualsOnly)
		return
