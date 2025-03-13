extends Control

@export var player_points: VBoxContainer
var player_to_lbl = {}
var points_dict = {}

const label_path = "res://scenes/UI/player_points.tscn"
var label_ui = load(label_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player_points_sig.connect(record_points)
	Global.round_over.connect(display_points)
	init_player_points()

func record_points(player, points):
	points_dict[player.name] = points

func display_points():
	for player_name in points_dict:
		player_to_lbl[player_name].text = player_name + ": " + str(points_dict[player_name])

func init_player_points():
	for i in Global.players_number:
		var lbl = label_ui.instantiate()
		player_points.add_child(lbl)
		lbl.global_position = Vector2(200, 200)
		lbl.name = "player_" + str(i)
		lbl.text = "player_" + str(i) + ": 0"
		player_to_lbl["player_" + str(i)] = lbl
	
	for i in Global.bots_number:
		var lbl = label_ui.instantiate()
		player_points.add_child(lbl)
		lbl.global_position = Vector2(200, 100)
		lbl.name = "bot_" + str(i)
		lbl.text = "bot_" + str(i) + ": 0"
		player_to_lbl["bot_" + str(i)] = lbl
		
