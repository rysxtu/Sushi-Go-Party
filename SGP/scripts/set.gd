extends HBoxContainer

@export var cards: Array[Texture2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = self.get_children()
	for i in range(1, children.size()):
		children[i].set_picture(cards[i])
