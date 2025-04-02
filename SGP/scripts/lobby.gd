extends Control

@export var play_button: Button
@export var player_container: VBoxContainer

const bot_ui_path = "res://scenes/UI/bot_ui.tscn"
var bot_ui = load(bot_ui_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.cards:
		play_button.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_back_button_pressed():
	Global.states = {}
	Global.cards = {}
	get_tree().change_scene_to_file("res://scenes/UI/home_screen.tscn")

func _on_play_button_pressed():
	print(Global.cards)
	print("switch scene to game")
	get_tree().change_scene_to_file("res://scenes/Game/Board.tscn")

func _on_select_button_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/set_up.tscn")

func _on_add_bots_pressed():
	"""
	var new_bot_ui = bot_ui.instantiate()
	new_bot_ui.global_position = player_container.global_position
	player_container.add_child(new_bot_ui)
	"""
	Global.bots_number += 1

func _on_remove_bots_pressed():
	if Global.bots_number > 0:
		"""
		var rmv_bot_ui = player_container.get_child(-1)
		player_container.remove_child(rmv_bot_ui)
		rmv_bot_ui.queue_free()
		"""
		Global.bots_number -= 1
