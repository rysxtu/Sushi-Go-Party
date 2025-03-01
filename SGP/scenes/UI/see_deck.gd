extends Button

@export var icon_manager: Control
@export var counter: Control
@export var player_hand: Node2D

var deck_seeable = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# could also do on_hover instead and when key pressed
func _on_pressed():
	if deck_seeable == false:
		counter.visible = true
		icon_manager.visible = true
		player_hand.visible = false
	else:
		counter.visible = false
		icon_manager.visible = false
		player_hand.visible = true
	deck_seeable = !deck_seeable
	
