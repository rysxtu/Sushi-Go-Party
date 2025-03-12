extends Control

@export var player_points: Control

const label_path = "res://scenes/UI/player_points.tscn"
var label_ui = load(label_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player_points_sig.connect(manage_points)

func manage_points():
	pass


func init_player_points():
	for i in Global.players_number:
		var lbl = label_ui.instantiate()
		player_points.add_child(lbl)
		lbl.global_position = Vector2(200, 200)
		lbl.name = "player_" + str(i)
		lbl.txt = "player_" + str(i) + ": 0"
	
	for i in Global.bots_number:
		var lbl = label_ui.instantiate()
		player_points.add_child(lbl)
		lbl.global_position = Vector2(200, 200)
		lbl.name = "bot_" + str(i)
		lbl.txt = "bot_" + str(i) + ": 0"
		
