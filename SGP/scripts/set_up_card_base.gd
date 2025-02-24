extends MarginContainer


@onready var pop_up = $Pop_up

@onready var timer = $Timer
@onready var card_base = $"."
@onready var sprite_2d = $Sprite2D
@export var picture: Texture2D

const POP_UP_MULTI = 1.75
var show_pop_up = 0
var hovering = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var card_size = card_base.size
	sprite_2d.set_texture(picture)
	sprite_2d.scale *= card_size / sprite_2d.texture.get_size()
	
	pop_up.set_texture(picture)
	pop_up.scale = POP_UP_MULTI * sprite_2d.scale

func _on_mouse_entered():
	timer.start()
	hovering = 1
	
func _on_mouse_exited():
	timer.stop()
	hovering = 0
	pop_up.visible = false

func _on_timer_timeout():
	if hovering:
		pop_up.visible = true
