/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon_state = "helmet"
	item_state = "helmet"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, energy = "25", "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 10)
	flags_inv = HIDEEARS
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	resistance_flags = NONE
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEHAIR
	var/list/protected_zones = list(BODY_ZONE_HEAD)

	dog_fashion = /datum/dog_fashion/head/helmet

	var/can_flashlight = FALSE //if a flashlight can be mounted. if it has a flashlight and this is false, it is permanently attached.
	var/obj/item/flashlight/seclite/attached_light
	var/datum/action/item_action/toggle_helmet_flashlight/alight


/obj/item/clothing/head/helmet/Initialize()
	. = ..()
	if(attached_light)
		alight = new(src)

/obj/item/clothing/head/helmet/Destroy()
	var/obj/item/flashlight/seclite/old_light = set_attached_light(null)
	if(old_light)
		qdel(old_light)
	return ..()


/obj/item/clothing/head/helmet/examine(mob/user)
	. = ..()
	if(attached_light)
		. += "It has \a [attached_light] [can_flashlight ? "" : "permanently "]mounted on it."
		if(can_flashlight)
			. += "<span class='info'>[attached_light] looks like it can be <b>unscrewed</b> from [src].</span>"
	else if(can_flashlight)
		. += "It has a mounting point for a <b>seclite</b>."
	. += "This helmet provides [armor.bullet]% bullet, [armor.laser]% laser, and [armor.melee]% melee resistance."

/obj/item/clothing/head/helmet/handle_atom_del(atom/A)
	if(A == attached_light)
		set_attached_light(null)
		update_helmlight()
		update_icon()
		QDEL_NULL(alight)
		qdel(A)
	return ..()


///Called when attached_light value changes.
/obj/item/clothing/head/helmet/proc/set_attached_light(obj/item/flashlight/seclite/new_attached_light)
	if(attached_light == new_attached_light)
		return
	. = attached_light
	attached_light = new_attached_light
	if(attached_light)
		attached_light.set_light_flags(attached_light.light_flags | LIGHT_ATTACHED)
		if(attached_light.loc != src)
			attached_light.forceMove(src)
	else if(.)
		var/obj/item/flashlight/seclite/old_attached_light = .
		old_attached_light.set_light_flags(old_attached_light.light_flags & ~LIGHT_ATTACHED)
		if(old_attached_light.loc == src)
			old_attached_light.forceMove(get_turf(src))

/obj/item/clothing/head/helmet/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(SLOT_HEAD))

/obj/item/clothing/head/helmet/sec
	can_flashlight = TRUE

/obj/item/clothing/head/helmet/sec/attackby(obj/item/I, mob/user, params)
	if(issignaler(I))
		var/obj/item/assembly/signaler/S = I
		if(attached_light) //Has a flashlight. Player must remove it, else it will be lost forever.
			to_chat(user, "<span class='warning'>The mounted flashlight is in the way, remove it first!</span>")
			return

		if(S.secured)
			qdel(S)
			var/obj/item/bot_assembly/secbot/A = new
			user.put_in_hands(A)
			to_chat(user, "<span class='notice'>You add the signaler to the helmet.</span>")
			qdel(src)
			return
	return ..()

/obj/item/clothing/head/helmet/alt
	name = "bulletproof helmet"
	desc = "A bulletproof combat helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "helmetalt"
	item_state = "helmetalt"
	armor = list("melee" = 25, "bullet" = 60, "laser" = 25, "energy" = 35, "bomb" = 50, "bio" = 40, "rad" = 10, "fire" = 60, "acid" = 10, "wound" = 50)
	can_flashlight = 1
	dog_fashion = null

/obj/item/clothing/head/helmet/alt/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/helmet/old
	name = "degrading helmet"
	desc = "Standard issue security helmet. Due to degradation the helmet's visor obstructs the users ability to see long distances."
	tint = 2

/obj/item/clothing/head/helmet/blueshirt
	name = "blue helmet"
	desc = "A reliable, blue tinted helmet reminding you that you <i>still</i> owe that engineer a beer."
	icon_state = "blueshift"
	item_state = "blueshift"
	custom_premium_price = PRICE_ABOVE_EXPENSIVE

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	item_state = "helmet"
	toggle_message = "You pull the visor down on"
	alt_toggle_message = "You push the visor up on"
	can_toggle = 1
	armor = list("melee" = 60, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "wound" = 40)
	flags_inv = HIDEEARS|HIDEFACE
	strip_delay = 80
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEFACE
	toggle_cooldown = 0
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	dog_fashion = null
	mutantrace_variation = STYLE_MUZZLE

/obj/item/clothing/head/helmet/attack_self(mob/user)
	if(can_toggle && !user.incapacitated())
		if(world.time > cooldown + toggle_cooldown)
			cooldown = world.time
			up = !up
			flags_1 ^= visor_flags
			flags_inv ^= visor_flags_inv
			flags_cover ^= visor_flags_cover
			icon_state = "[initial(icon_state)][up ? "up" : ""]"
			to_chat(user, "[up ? alt_toggle_message : toggle_message] \the [src]")

			user.update_inv_head()
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.head_update(src, forced = 1)

			if(active_sound)
				while(up)
					playsound(src.loc, "[active_sound]", 100, 0, 4)
					sleep(15)

/obj/item/clothing/head/helmet/justice
	name = "helmet of justice"
	desc = "WEEEEOOO. WEEEEEOOO. WEEEEOOOO."
	icon_state = "justice"
	toggle_message = "You turn off the lights on"
	alt_toggle_message = "You turn on the lights on"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	can_toggle = 1
	toggle_cooldown = 20
	active_sound = 'sound/items/weeoo1.ogg'
	dog_fashion = null

/obj/item/clothing/head/helmet/justice/escape
	name = "alarm helmet"
	desc = "WEEEEOOO. WEEEEEOOO. STOP THAT MONKEY. WEEEOOOO."
	icon_state = "justice2"
	toggle_message = "You turn off the light on"
	alt_toggle_message = "You turn on the light on"

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "An extremely robust, space-worthy helmet in a nefarious red and black stripe pattern."
	icon_state = "swatsyndie"
	item_state = "swatsyndie"
	armor = list("melee" = 30, "bullet" = 50, "laser" = 30, "energy" = 20, "bomb" = 55, "bio" = 60, "rad" = 15, "fire" = 60, "acid" = 30)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/swat/nanotrasen
	name = "\improper SWAT helmet"
	desc = "An extremely robust, space-worthy helmet with the Nanotrasen logo emblazoned on the top."
	icon_state = "swat"
	item_state = "swat"

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	flags_inv = HIDEEARS|HIDEHAIR
	icon_state = "thunderdome"
	item_state = "thunderdome"
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/head/helmet/roman
	name = "\improper Roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	flags_inv = HIDEEARS|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 20, "bomb" = 15, "bio" = 60, "rad" = 15, "fire" = 60, "acid" = 30)
	resistance_flags = FIRE_PROOF
	icon_state = "roman"
	item_state = "roman"
	strip_delay = 100
	dog_fashion = null

/obj/item/clothing/head/helmet/roman/fake
	desc = "An ancient helmet made of plastic and leather."
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 15, "bio" = 60, "rad" = 15, "fire" = 60, "acid" = 30)

/obj/item/clothing/head/helmet/roman/legionnaire
	name = "\improper Roman legionnaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/roman/legionnaire/fake
	desc = "An ancient helmet made of plastic and leather. Has a red crest on top of it."
	armor = list("tier" = 1, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	dog_fashion = null
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 15, "bio" = 60, "rad" = 15, "fire" = 60, "acid" = 30)

/obj/item/clothing/head/helmet/redtaghelm
	name = "red laser tag helmet"
	desc = "They have chosen their own end."
	icon_state = "redtaghelm"
	flags_cover = HEADCOVERSEYES
	item_state = "redtaghelm"
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 15, "bio" = 60, "rad" = 15, "fire" = 60, "acid" = 30)
	// Offer about the same protection as a hardhat.
	dog_fashion = null

/obj/item/clothing/head/helmet/bluetaghelm
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	flags_cover = HEADCOVERSEYES
	item_state = "bluetaghelm"
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 15, "bio" = 60, "rad" = 15, "fire" = 60, "acid" = 30)
	// Offer about the same protection as a hardhat.
	dog_fashion = null

/obj/item/clothing/head/helmet/knight
	name = "medieval helmet"
	desc = "A classic metal helmet worn by all ranks of knights and horsemen of the Old Era."
	icon_state = "knight_green"
	item_state = "knight_green"
	armor = list("melee" = 35, "bullet" = 20, "laser" = 30, "energy" = 10, "bomb" = 15, "bio" = 60, "rad" = 15, "fire" = 60, "acid" = 30)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	dog_fashion = null
	mutantrace_variation = STYLE_MUZZLE


/obj/item/clothing/head/helmet/knight/Initialize(mapload)
	. = ..()
	var/datum/component = GetComponent(/datum/component/wearertargeting/earprotection)
	qdel(component)

/obj/item/clothing/head/helmet/knight/blue
	name = "blue medieval helmet"
	desc = "A classic metal helmet worn by all ranks of knights and horsemen of the Old Era.<br>This one is painted blue."
	icon_state = "knight_blue"
	item_state = "knight_blue"

/obj/item/clothing/head/helmet/knight/yellow
	name = "yellow medieval helmet"
	desc = "A classic metal helmet worn by all ranks of knights and horsemen of the Old Era.<br>This one is painted yellow."
	icon_state = "knight_yellow"
	item_state = "knight_yellow"

/obj/item/clothing/head/helmet/knight/red
	name = "red medieval helmet"
	desc = "A classic metal helmet worn by all ranks of knights and horsemen of the Old Era.<br>This one is painted red."
	icon_state = "knight_red"
	item_state = "knight_red"

/obj/item/clothing/head/helmet/knight/templar
	name = "crusader helmet"
	desc = "Deus Vult."
	icon_state = "knight_templar"
	item_state = "knight_templar"

/obj/item/clothing/head/helmet/knight/greyscale
	name = "knight helmet"
	desc = "A classic medieval helmet, if you hold it upside down you could see that it's actually a bucket."
	icon_state = "knight_greyscale"
	item_state = "knight_greyscale"
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS //Can change color and add prefix

/obj/item/clothing/head/helmet/skull
	name = "skull helmet"
	desc = "An intimidating tribal helmet, it doesn't look very comfortable."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 15, "bio" = 60, "rad" = 15, "fire" = 60, "acid" = 30)
	icon_state = "skull"
	item_state = "skull"
	strip_delay = 100
	mutantrace_variation = STYLE_MUZZLE

/obj/item/clothing/head/helmet/infiltrator
	name = "insidious helmet"
	desc = "(V) An insidious armored combat helmet signed with Syndicate insignia. The visor is coated with a resistant paste guaranteed to withstand bright flashes perfectly."
	icon_state = "infiltrator"
	item_state = "infiltrator"
	armor = list("tier" = 5, "energy" = 40, "bomb" = 70, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flash_protect = 2
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	dynamic_hair_suffix = ""
	dynamic_fhair_suffix = ""
	strip_delay = 80
	mutantrace_variation = STYLE_MUZZLE

//LightToggle

/obj/item/clothing/head/helmet/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/head/helmet/update_icon_state()
	var/state = "[initial(icon_state)]"
	if(attached_light)
		if(attached_light.on)
			state += "-flight-on" //"helmet-flight-on" // "helmet-cam-flight-on"
		else
			state += "-flight" //etc.

	icon_state = state
	return ..()

/obj/item/clothing/head/helmet/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_helmet_flashlight))
		toggle_helmlight()
	else
		..()

/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/flashlight/seclite))
		if(can_flashlight && !attached_light)
			var/obj/item/flashlight/seclite/S = I
			if(!user.transferItemToLoc(S, src))
				return
			to_chat(user, "<span class='notice'>You click [S] into place on [src].</span>")
			set_attached_light(S)
			update_helmlight()
			update_icon()
			alight = new(src)
			if(loc == user)
				alight.Grant(user)
		return
	return ..()


/obj/item/clothing/head/helmet/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(can_flashlight && attached_light) //if it has a light but can_flashlight is false, the light is permanently attached.
		I.play_tool_sound(src)
		to_chat(user, "<span class='notice'>You unscrew [attached_light] from [src].</span>")
		attached_light.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(attached_light)

		var/obj/item/flashlight/removed_light = set_attached_light(null)
		update_helmlight()
		removed_light.update_brightness(user)
		update_icon()
		user.update_inv_head()
		QDEL_NULL(alight)
		return TRUE


/obj/item/clothing/head/helmet/proc/toggle_helmlight()
	set name = "Toggle Helmetlight"
	set category = "Object"
	set desc = "Click to toggle your helmet's attached flashlight."

	if(!attached_light)
		return

	var/mob/user = usr
	if(user.incapacitated())
		return
	attached_light.on = !attached_light.on
	attached_light.update_brightness()
	to_chat(user, "<span class='notice'>You toggle the helmet light [attached_light.on ? "on":"off"].</span>")

	playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
	update_helmlight()


/obj/item/clothing/head/helmet/proc/update_helmlight()
	if(attached_light)
		update_icon()

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()


/obj/item/clothing/head/helmet/durathread
	name = "makeshift helmet"
	desc = "A hardhat with strips of leather and durathread for additional blunt protection."
	icon_state = "durathread"
	item_state = "durathread"


/obj/item/clothing/head/helmet/rus_helmet
	name = "russian helmet"
	desc = "(III) It can hold a bottle of vodka."
	icon_state = "rus_helmet"
	item_state = "rus_helmet"
	armor = list("tier" = 3,"energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 20, "fire" = 30, "acid" = 50)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small/rushelmet

/obj/item/clothing/head/helmet/rus_ushanka
	name = "battle ushanka"
	desc = "(II) 100% bear."
	icon_state = "rus_ushanka"
	item_state = "rus_ushanka"
	clothing_flags = THICKMATERIAL
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	armor = list("tier" = 2,"energy" = 5, "bomb" = 5, "bio" = 50, "rad" = 20, "fire" = -10, "acid" = 0)

/obj/item/clothing/head/helmet/police
	name = "police officer's hat"
	desc = "A police officer's Hat. This hat emphasizes that you are THE LAW."
	icon_state = "policehelm"
	dynamic_hair_suffix = ""
	armor = list("tier" = 2)
	
/obj/item/clothing/head/helmet/armyhelmet
	name = "steel helmet"
	desc = "a steel helmet, inspired by several pre-war designs. It provides some protection against impacts, cuts, and medium-velocity bullets."
	icon = 'icons/fallout/clothing/helmets.dmi'
	mob_overlay_icon = 'icons/fallout/onmob/clothes/helmet.dmi'
	icon_state = "armyhelmet"
	item_state = "armyhelmet"
	armor = list("melee" = 20, "bullet" = 45, "laser" = 20, "energy" = 15, "bomb" = 20, "bio" = 30, "rad" = 20, "fire" = 60, "acid" = 0)
	
/obj/item/clothing/head/helmet/armyhelmet/heavy
	name = "heavy steel helmet"
	desc = "a steel helmet, inspired by several pre-war designs. This one has been modified by oasis citizens to provide more protection to the face and neck."
	icon_state = "armyhelmetheavy"
	item_state = "armyhelmetheavy"
	armor = list("melee" = 30, "bullet" = 50, "laser" = 30, "energy" = 20, "bomb" = 25, "bio" = 30, "rad" = 20, "fire" = 60, "acid" = 0)
	slowdown = 0.025
