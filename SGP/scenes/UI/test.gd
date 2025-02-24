extends TextureRect

@onready var texture_rect = $TextureRect
@export var picture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var card_size = self.size
	texture_rect.set_texture(picture)
	texture_rect.scale *= card_size / texture_rect.texture.get_size()
