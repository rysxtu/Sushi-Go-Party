extends Control

@export var sprite: Sprite2D
@export var scale_up := 1.75
var original_z_idx
var scale_x
var scale_y

var hovering = false

signal icon_pressed(icon)

func _ready():
	scale = self.get_scale()
	scale_x = scale[0]
	scale_y = scale[1]
	original_z_idx = self.z_index
	sprite.material = sprite.material.duplicate()

func _on_mouse_entered():
	hovering = true
	sprite.material.set_shader_parameter("onoff",1)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(scale_up * scale_x, scale_up * scale_y), 0.01)
	self.z_index = 2

func _on_mouse_exited():
	hovering = false
	sprite.material.set_shader_parameter("onoff",0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(scale_x, scale_y), 0.01)
	self.z_index = original_z_idx

func _input(event):
	if event is InputEventMouseButton:
		var e:InputEventMouseButton = event
		if e.button_mask == MOUSE_BUTTON_LEFT:
			if hovering:
				icon_pressed.emit(self)
				print("Clicked: ", self)
