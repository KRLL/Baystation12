/obj/item/clothing/suit/furcoat
	var/dept = "winter"
	var/hood = 0
	var/open = 1
	blood_overlay_type = "coat"
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS
	flags = FPRINT | TABLEPASS


	New()
		update_icons()
		name = "[dept] furcoat"

	proc/update_icons()
		icon_state = "coat[dept]_[hood][open]"
		item_color = "coat[dept]_[hood][open]"

	verb/toggle_open()
		set name = "Toggle Furcoat Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(open)
			open = 0
			min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE/2		//1.0
			flags_inv += HIDEJUMPSUIT
			usr << "You unbatton the furcoat"
		else
			open = 1
			min_cold_protection_temperature = initial(min_cold_protection_temperature)
			flags_inv -= HIDEJUMPSUIT
			usr << "You button up the furcoat."

		update_icons()
		usr.update_inv_wear_suit()

	verb/toggle_hood()
		set name = "Toggle Furcoat Hood"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		var/mob/living/carbon/human/H = usr

		if(hood)
			hood = 0
			flags = initial(flags)
			cold_protection = initial(cold_protection)
			usr << "You take the hood off."
			H.head = null
		else
			if(H.head)
				usr << "You can't put the hood on while in helmet."
				return
			hood = 1
			flags += BLOCKHEADHAIR
			cold_protection += HEAD
			usr << "You put the hood on."
			var/obj/item/clothing/head/C = new(usr)
			C.canremove = 0
			H.head = C

		update_icons()
		usr.update_inv_wear_suit()
		H.update_hair()

/obj/item/clothing/suit/furcoat/captain
	dept = "captain"

/obj/item/clothing/suit/furcoat/cargo
	dept = "cargo"

/obj/item/clothing/suit/furcoat/prison
	dept = "prison"

/obj/item/clothing/suit/furcoat/hydro
	dept = "hydroponic"

/obj/item/clothing/suit/furcoat/medical
	dept = "medical"

/obj/item/clothing/suit/furcoat/mining
	dept = "mining"

/obj/item/clothing/suit/furcoat/security
	dept = "security"

//fluff

/obj/item/clothing/suit/furcoat/harvey
	dept = "harvey"

