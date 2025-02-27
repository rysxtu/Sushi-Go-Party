extends Control

@export var sprite: Sprite2D
@export var scale_up := 1.5
var scale_x
var scale_y

func _ready():
	scale = self.get_scale()
	scale_x = scale[0]
	scale_y = scale[1]

func _on_mouse_entered():
	sprite.material.set_shader_parameter("onoff",1)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(scale_up * scale_x, scale_up * scale_y), 0.01)


func _on_mouse_exited():
	sprite.material.set_shader_parameter("onoff",0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(scale_x, scale_y), 0.01)
