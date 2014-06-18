//Control Computer Module
/obj/item/modular/module/computer
	name = "Computer Module"
	needing_modules = list(/obj/item/modular/module/powersystem)

	New()
		verbs -= /obj/item/modular/module/computer/verb/open_gui

	attach(obj/item/clothing/suit/armor/modular/O as obj)
		O.verbs += /obj/item/modular/module/computer/verb/open_gui

	detach(obj/item/clothing/suit/armor/modular/O as obj)
		O.verbs -= /obj/item/modular/module/computer/verb/open_gui

	p_step()
		var/obj/item/clothing/suit/armor/modular/O = loc
		var/obj/item/modular/module/powersystem/sys = O.get_module(/obj/item/modular/module/powersystem)
		if(!sys.use(200))
			loc.verbs -= /obj/item/modular/module/computer/verb/open_gui
		else
			if(!(/obj/item/modular/module/computer/verb/open_gui in loc.verbs))
				loc.verbs += /obj/item/modular/module/computer/verb/open_gui

	verb/open_gui()
		set name = "Open GUI"
		set category = "Modular Suit"
		set src in view(0)

		var/dat = "Modular Suit:"
		var/datum/browser/popup = new(usr, "mod_comp_gui", "Suit Computer", 400, 240)
		popup.set_content(dat)
		popup.open()