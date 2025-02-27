extends Button

@export var plate: Control
@export var player_hand: Node2D

var deck_seeable = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# could also do on_hover instead and when key pressed
func _on_pressed():
	if deck_seeable == false:
		plate.visible = true
		player_hand.visible = false
	else:
		plate.visible = false
		player_hand.visible = true
	deck_seeable = !deck_seeable
	
