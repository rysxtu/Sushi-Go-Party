# handles icon display
extends Control
# the root player node
@export var _self: Node2D
@export var plate: Control

const WASABI_ADJUSTMENT = -8
const VARIATION_CARDS = {"fruit": null, "onigiri": null, "nigiri": null}
var card_name_to_icon = Global.icons
var icon_no = 0

var markers
# used globally to ensure that the icon can be displayed when the turn is oevr
var new_icon 
var my_points = 0

func _ready():
	Global.display_card_icon.connect(add_icon)
	Global.round_over.connect(reset)
	Global.turn_over.connect(display_icons)
	
	const path = "res://scenes/game/display_"
	var markers_local = load(path + str(Global.hand_size) + ".tscn").instantiate()
	markers_local.name = "markers"
	markers = markers_local
	self.add_child(markers)
	
func reset():
	for child in markers.get_children():
		if child is Marker2D:
			for panel in child.get_children():
				child.remove_child(panel)
	icon_no = 0

func add_icon(player, card, info):
	if _self == player:
		var card_name = card.name.split("_")[0]
		var side_icon
		
		print("---------Plate_", _self.name, " to plate: ",card.name)
		
		# have to look out for variations
		if card_name in VARIATION_CARDS:
			var variation = card.name.split("_")[1]
			new_icon = card_name_to_icon[card_name + '_' + variation].instantiate()
		else:
			new_icon = card_name_to_icon[card_name].instantiate()
			
		# dont show until round is over
		new_icon.visible = false
		
		# check for extra info
		# check if variation card is nigiri and if it was added with wasabi
		if card_name == "nigiri" and info == "wasabi":
			side_icon = card_name_to_icon["wasabi"].instantiate()
			side_icon.scale.x = 0.5
			side_icon.scale.y = 0.5
			new_icon.add_child(side_icon)
			var new_icon_size = new_icon.get_size()
			side_icon.position = Vector2(new_icon_size.x / 2 + WASABI_ADJUSTMENT, new_icon_size.y / 2 + WASABI_ADJUSTMENT)
		
		# display
		var marker = markers.get_node("Icon" + str(icon_no + 1))
		marker.add_child(new_icon)
		icon_no += 1

func display_icons():
	new_icon.visible = true

