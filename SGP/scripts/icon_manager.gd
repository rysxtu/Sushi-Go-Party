# handles icon display
extends Control

# the root player node
@export var _self: Node2D
@export var points: Label

const VARIATION_CARDS = {"fruit": null, "onigiri": null, "nigiri": null}
var card_name_to_icon = {}


func _ready():
	Global.player_points_sig.connect(display_points)
	_self.display_card_icon.connect(add_icon)
	load_icons()


func add_icon(player, card, info):	
	if _self == player:
		var card_name = card.name.split("_")[0]
		var new_icon
		
		print("---------Plate_", _self.name, " to plate: ",card.name)
		
		# have to look out for variations
		if card_name in VARIATION_CARDS:
			var variation = card.name.split("_")[1]
			new_icon = card_name_to_icon[card_name + '_' + variation].instantiate()
		else:
			new_icon = card_name_to_icon[card_name].instantiate()
		# change this pos
		new_icon.global_position = _self.global_position
		self.add_child(new_icon)

func display_points(player, points):
	if _self == player:
		pass
		#points.text = "Points: " + str(points)

func load_icons():
	var path
	for card in Global.cards:
		var card_name = card.split("_")[0]
		if Global.cards[card] >= 1:
			if "fruit" in card:
				path = "res://scenes/icons/fruit_icon.tscn"
				card_name_to_icon["fruit"] = (load(path))
				
				# need to get specific fruit
			elif card_name == "nigiri":
				for i in 3:
					path = "res://scenes/icons/nigiri" + '_' + str(i + 1) + "_icon.tscn"
					card_name_to_icon["nigiri" + '_' + str(i + 1)] = (load(path))
			else:
				# get the correct number of cards needed for each type
				path = "res://scenes/icons/" + card_name + "_icon.tscn"
				card_name_to_icon[card_name] = (load(path))
	print(card_name_to_icon)
