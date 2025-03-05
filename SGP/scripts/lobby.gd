extends Control

@export var play_button: Button

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
