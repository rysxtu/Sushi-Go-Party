# handles icon display
extends Control
# the root player node
@export var _self: Node2D
@export var points_label: Label
@export var plate: Control
@export var special_cards: Control

const WASABI_ADJUSTMENT = -8
const VARIATION_CARDS = {"onigiri": null, "nigiri": null}
var card_name_to_icon = Global.icons
var icon_no = 0

var markers

# arr of all icons on board
var icons = []

func _ready():
	Global.player_points_sig.connect(display_points)
	Global.display_card_icon.connect(add_icon)
	Global.round_over.connect(reset)
	_self.chopsticks_played.connect(chopsticks_played)
	
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
			new_icon = card_name_to_icon[card_name + '_' + variation].instantiate()
			new_icon.name = card_name + '_' + variation
		else:
			new_icon = card_name_to_icon[card_name].instantiate()
			new_icon.name = card_name
		
		# have to watch out for special cards, e.g chopsticks
		
		# check for extra info
		# check if variation card is nigiri and if it was added with wasabi
		if card_name == "nigiri" and info == "wasabi":
			side_icon = card_name_to_icon["wasabi"].instantiate()
			side_icon.scale.x = 0.5
			side_icon.scale.y = 0.5
			new_icon.add_child(side_icon)
			var new_icon_size = new_icon.get_size()
			side_icon.position = Vector2(new_icon_size.x / 2 + WASABI_ADJUSTMENT, new_icon_size.y / 2 + WASABI_ADJUSTMENT)
		
		# O(n), searching for empty spot
		for i in range(Global.hand_size):
			if icons[i] == null:
				icons[i] = new_icon
				var marker = markers.get_node("Icon" + str(i + 1))
				marker.add_child(new_icon)
				break
		icon_no += 1

func chopsticks_played(icon_name):
	# remove the icon from the special_cards area, so we cant replay it
	for child in special_cards.get_children():
		# should be child.name
		if child.name.split('_')[0] == icon_name:
			special_cards.remove_child(child)
	
	# remove the chopstick icon from the board, as it has been used
	for i in range(Global.hand_size):
		if icons[i] && icons[i].name.split('_')[0] == icon_name:
			icons[i] = null
			var marker_w_chopstick = markers.get_node("Icon" + str(i + 1))
			var chopstick = marker_w_chopstick.get_child(0)
			marker_w_chopstick.remove_child(chopstick)
			chopstick.queue_free()
			break
	
		

func display_points(player, points):
	if _self == player:
		points_label.text = "Points: " + str(points)

