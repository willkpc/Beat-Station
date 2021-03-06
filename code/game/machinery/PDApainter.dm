/obj/machinery/pdapainter
	name = "PDA painter"
	desc = "A PDA painting machine. To use, simply insert your PDA and choose the desired preset paint scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = 1
	anchored = 1
	var/obj/item/device/pda/storedpda = null
	var/list/colorlist = list()


/obj/machinery/pdapainter/update_icon()
	overlays.Cut()

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return

	if(storedpda)
		overlays += "[initial(icon_state)]-closed"

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

	return

/obj/machinery/pdapainter/New()
	..()
	var/blocked = list(/obj/item/device/pda/silicon/ai, /obj/item/device/pda/silicon/robot, /obj/item/device/pda/silicon/pai, /obj/item/device/pda/heads,
						/obj/item/device/pda/clear, /obj/item/device/pda/syndicate)

	for(var/P in typesof(/obj/item/device/pda)-blocked)
		var/obj/item/device/pda/D = new P

		//D.name = "PDA Style [colorlist.len+1]" //Gotta set the name, otherwise it all comes up as "PDA"
		D.name = D.icon_state //PDAs don't have unique names, but using the sprite names works.

		src.colorlist += D


/obj/machinery/pdapainter/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/device/pda))
		if(storedpda)
			to_chat(user, "There is already a PDA inside.")
			return
		else
			var/obj/item/device/pda/P = usr.get_active_hand()
			if(istype(P))
				user.drop_item()
				storedpda = P
				P.loc = src
				P.add_fingerprint(usr)
				update_icon()
				nanomanager.update_uis(src)

/obj/machinery/pdapainter/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	data["storedpda"] = storedpda
	if(storedpda)
		data["pda_name"] = storedpda.name

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "pda_painter.tmpl", "PDA Painter UI", 400, 120)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/pdapainter/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["choice"])
		switch(href_list["choice"])
			if("eject_pda")
				if(storedpda)
					storedpda.loc = get_turf(src.loc)
					if(!usr.get_active_hand())
						usr.put_in_hands(storedpda)
					storedpda = null
					update_icon()
				else
					to_chat(usr, "<span class='notice'>The [src] is empty.</span>")
			if("paint_pda")
				if(storedpda)
					var/obj/item/device/pda/P = null
					P = input(usr, "Select your color!", "PDA Painting") as null|anything in colorlist
					if(!P)
						return
					if(!in_range(src, usr))
						return

					storedpda.icon_state = P.icon_state
					storedpda.desc = P.desc

				else
					to_chat(usr, "<span class='notice'>The [src] is empty.</span>")
			if("insert_pda")
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/device/pda))
					if(storedpda)
						to_chat(usr, "There is already a PDA inside.")
						return
					else
						var/obj/item/device/pda/P = I
						if(istype(P))
							usr.drop_item()
							storedpda = P
							P.loc = src
							P.add_fingerprint(usr)
							update_icon()

	nanomanager.update_uis(src)

/obj/machinery/pdapainter/attack_hand(mob/user as mob)
	..()
	src.add_fingerprint(user)
	ui_interact(user)

	/*if(storedpda)
		var/obj/item/device/pda/P
		P = input(user, "Select your color!", "PDA Painting") as null|anything in colorlist
		if(!P)
			return
		if(!in_range(src, user))
			return

		storedpda.icon_state = P.icon_state
		storedpda.desc = P.desc

	else
		to_chat(user, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/pdapainter/verb/ejectpda()
	set name = "Eject PDA"
	set category = "Object"
	set src in oview(1)

	if(storedpda)
		storedpda.loc = get_turf(src.loc)
		storedpda = null
		update_icon()
	else
		to_chat(usr, "<span class='notice'>The [src] is empty.</span>")


/obj/machinery/pdapainter/power_change()
	..()
	update_icon()*/