extends TextureRect

signal has_texture
signal no_texture

# allows for a drag and drop feature
func _get_drag_data(at_position):
	no_texture.emit()
	var preview_texture = TextureRect.new()
 
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.modulate = Color(1,1,1, .6)
	preview_texture.size = Vector2(50,59)
 
	var preview = Control.new()
	preview.add_child(preview_texture)
 
	set_drag_preview(preview)
	texture = null
	
	return preview_texture.texture
 
func _can_drop_data(_pos, data):
	return data is Texture2D
 
func _drop_data(_pos, data):
	has_texture.emit()
	texture = data
