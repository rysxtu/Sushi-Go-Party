extends Control

@export var scale_up := 1.4
var original_z_idx
var scale_x
var scale_y

var sprite
var hovering = false

signal icon_pressed(icon)

func _ready():
	sprite = self.get_node("Sprite2D")
	scale = self.get_scale()
	scale_x = scale[0]
	scale_y = scale[1]
	original_z_idx = self.z_index
	sprite.material.shader = load("res://shaders/link_icons.gdshader")
	
func _init():
	sprite = self.get_node("Sprite2D")`
	scale = self.get_scale()
	scale_x = scale[0]
	scale_y = scale[1]
	original_z_idx = self.z_index
	sprite.material.shader = load("res://shaders/link_icons.gdshader")

func _on_mouse_entered():
	hovering = true
	print("hovering")
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
				print("Clicked, linked: ", self)
