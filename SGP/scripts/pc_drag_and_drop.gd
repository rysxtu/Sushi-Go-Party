extends TextureRect

func _get_drag_data(at_position):
	var preview_texture = TextureRect.new()
 
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.modulate = Color(1,1,1, .6)
	preview_texture.size = Vector2(50,59)
 
	var preview = Control.new()
	preview.add_child(preview_texture)
 
	set_drag_preview(preview)
 
	return preview_texture.texture
 
