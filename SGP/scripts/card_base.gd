extends Panel

@onready var card_base = $"."
@onready var front = $front
@onready var back = $back
@export var front_img: Texture2D
@export var back_img: Texture2D
@export var scale_up := 1.5
var initial_position: Vector2
var initial_rotation: float
var initial_size: Vector2
const POP_UP_MULTI = 2
var show_pop_up = 0
var hovering = 0

signal card_pressed(card)

# Called when the node enters the scene tree for the first time.
func _ready():
	# scale card
	initial_size = self.size
	var card_size = card_base.size
	front.set_texture(front_img)
	front.scale *= card_size / front.texture.get_size()
	back.set_texture(back_img)
	back.scale *= card_size / back.texture.get_size()
	

func _on_mouse_entered() -> void:
	# mouse is currently hovering this card
	hovering = 1
	# animation to enlarge card
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(scale_up, scale_up), 0.01)
	# want to find the max that a card is below and tween up
	tween.tween_property(self, "position:y", -self.get_size().y / 1.5, 0.1)
	tween.tween_property(self, "rotation_degrees", 0, 0.1)
	self.z_index = 1

func _on_mouse_exited() -> void:
	# mouse is no longer hovering
	hovering = 0
	# animation to de-enlarg card
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.01)
	tween.tween_property(self, "position:y", initial_position.y, 0.1)
	tween.tween_property(self, "rotation_degrees", initial_rotation, 0.1)
	self.z_index = 0

func _input(event):
	if event is InputEventMouseButton and event.pressed and hovering == 1:
		# if mouse if hovering over this card and clicked
		if event.button_index == MOUSE_BUTTON_LEFT:
			# play card with left mouse button
			print("------Card: ", self, " pressed")
			card_pressed.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# displat card info with right mouse button
			print("------Card: card info:",  self)

