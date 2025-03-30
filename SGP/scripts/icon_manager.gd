# handles icon display
extends Control
# the root player node
@export var _self: Node2D
@export var points_label: Label
@export var plate: Control
@export var special_cards: Control

const WASABI_ADJUSTMENT = -8
const VARIATION_CARDS = {"onigiri": null, "nigiri": null, "maki": null, "fruit": null, "uramaki": null}
const SPECIAL_CARDS = {"chopsticks": null, "spoon": null, "special": null, "menu": null, "takeout": null}
var card_name_to_icon = Global.icons
var icon_no = 0

var markers

# arr of all icons on board
var icons = []

# icon_manager script deals with a player's ui
func _ready():
	Global.player_points_sig.connect(display_points)
	Global.display_card_icon.connect(add_icon)
	Global.round_over.connect(reset)
	_self.chopsticks_played_ic.connect(chopsticks_played)
	Global.display_chopsticks_option.connect(display_chopstick_option)
	
	# set up the positioning of the icons
	const path = "res://scenes/game/display_"
	var markers_local = load(path + str(Global.hand_size) + ".tscn").instantiate()
	
	for i in Global.hand_size:
		icons.append(null)
	
	markers_local.name = "markers"
	markers = markers_local
	self.add_child(markers)

# reset the icons on displays
func reset():
	for child in markers.get_children():
		if child is Marker2D:
			for panel in child.get_children():
				child.remove_child(panel)
	
	# get rid of any special orders
	for child in special_cards.get_children():
		special_cards.remove_child(child)
	
	# reset icons array 
	for i in range(Global.hand_size):
		icons[i] = null

# add an icon to the board
func add_icon(player, card, info):
	print(icons)
	if _self == player:
		var card_name = card.name.split("_")[0]
		var new_icon
		var side_icon
		
		print("---------Plate_", _self.name, " to plate: ",card.name)
		
		# have to look out for variations
		if card_name in VARIATION_CARDS:
			var variation = card.name.split("_")[1]
			# these two cards need to be spawned correcly 
			if card_name in {"onigiri": null, "nigiri": null}:
				new_icon = card_name_to_icon[card_name + '_' + variation].instantiate()
			else:
				# these only need to have their name info
				new_icon = card_name_to_icon[card_name].instantiate()
			new_icon.name = card_name + '_' + variation
		elif card_name not in SPECIAL_CARDS:
			new_icon = card_name_to_icon[card_name].instantiate()
			new_icon.name = card_name
		
		# have to watch out for special cards, e.g chopsticks
		
		# check if variation card is nigiri and if it was added with wasabi
		if card_name == "nigiri" and info != "":
			new_icon.name += "_wasabi"
			side_icon = card_name_to_icon["wasabi"].instantiate()
			side_icon.scale.x = 0.5
			side_icon.scale.y = 0.5
			new_icon.add_child(side_icon)
			var new_icon_size = new_icon.get_size()
			side_icon.position = Vector2(new_icon_size.x / 2 + WASABI_ADJUSTMENT, new_icon_size.y / 2 + WASABI_ADJUSTMENT)
		# if card is wasabi name it apporpiately so takeout box can be implemented nicely
		if card_name == "wasabi":
			new_icon.name += "_" + str(info)
		
		# O(n), searching for empty spot
		for i in range(Global.hand_size):
			if icons[i] == null and new_icon:
				icons[i] = new_icon
				var marker = markers.get_node("Icon" + str(i + 1))
				marker.add_child(new_icon)
				break
		icon_no += 1

# get rids of the chopsticks ui when a chopsticks are used
func chopsticks_played(icon_name):
	# remove the icon from the special_cards area, so we cant replay it
	for child in special_cards.get_children():
		# should be child.name
		if child.name == icon_name:
			special_cards.remove_child(child)
	
	# remove the chopstick icon from the board, as it has been used
	for i in range(Global.hand_size):
		# shoykd be icons[i].name
		if icons[i] && icons[i].name == icon_name:
			icons[i] = null
			var marker_w_chopstick = markers.get_node("Icon" + str(i + 1))
			var chopstick = marker_w_chopstick.get_child(0)
			marker_w_chopstick.remove_child(chopstick)
			chopstick.queue_free()
			break

# displays the chopstick ui, allowing player to use chopsticks
func display_chopstick_option(player, card_order):
	if player == _self:
		print("display")
		var chopstick = Global.icons["chopsticks"].instantiate()
		
		chopstick.name = "chopsticks_" + str(card_order)
		
		# CLEAN: the get_child(1) is dependent
		chopstick.get_child(1).material.set_local_to_scene(true)
		chopstick.scale = Vector2(.9, .9)
		chopstick.player = _self
		chopstick.clickable = true
		
		special_cards.add_child(chopstick)

func display_points(player, points):
	if _self == player:
		points_label.text = "Points: " + str(points)

