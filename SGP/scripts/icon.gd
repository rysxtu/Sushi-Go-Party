extends Control

@export var sprite: Sprite2D
@export var scale_up := 1.4
var original_z_idx
var scale_x
var scale_y

var hovering = false
signal icon_pressed(icon)
signal highlight_wasabi(icon, type, highlight)

func _ready():
	Global.highlight.connect(highlight)
	scale = self.get_scale()
	scale_x = scale[0]
	scale_y = scale[1]
	original_z_idx = self.z_index
	sprite.material = sprite.material.duplicate()

# used to highlight wasabi and nigiri both when they are paired together
func highlight(icon_name, highlight):
	# check if we are an icon to highlight
	if icon_name in self.name:
		if highlight:
			sprite.material.set_shader_parameter("onoff",1)
			if is_inside_tree():
				var tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2(scale_up * scale_x, scale_up * scale_y), 0.01)
			self.z_index = 2
		else:
			sprite.material.set_shader_parameter("onoff",0)
			if is_inside_tree():
				var tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2(scale_x, scale_y), 0.01)
			self.z_index = original_z_idx

func _on_mouse_entered():
	
	# check if this icon has a pair that we walso want to highlight
	var icon_name = self.name.split("_")
	# wasabi pair for a nigiri icon
	if icon_name.size() == 3:
		var n = icon_name[2].insert(icon_name[2].length() - 1, "_")
		Global.emit_signal("highlight", n, true)
	# nigiri pair for a wasabi icon
	elif icon_name[0] == "wasabi" and icon_name[1] != "icon":
		Global.emit_signal("highlight", icon_name[0] + icon_name[1], true)
	
	hovering = true
	sprite.material.set_shader_parameter("onoff",1)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(scale_up * scale_x, scale_up * scale_y), 0.01)
	self.z_index = 2

func _on_mouse_exited():
	
	# check if this icon has a pair that we walso want to highlight
	var icon_name = self.name.split("_")
	# wasabi pair for a nigiri icon
	if icon_name.size() == 3:
		var n = icon_name[2].insert(icon_name[2].length() - 1, "_")
		Global.emit_signal("highlight", n, false)
	# nigiri pair for a wasabi icon
	elif icon_name[0] == "wasabi" and icon_name[1] != "icon":
		Global.emit_signal("highlight", icon_name[0] + icon_name[1], false)
	
	
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
