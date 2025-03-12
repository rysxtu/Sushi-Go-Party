extends Control

@export var single_player: Button
@export var multi_player: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_multi_button_pressed():
	Global.online = true
	get_tree().change_scene_to_file("res://scenes/UI/lobby.tscn")


func _on_single_button_pressed():
	Global.online = false
	get_tree().change_scene_to_file("res://scenes/UI/set_up.tscn")
