extends Control

@export var difficulty_select: OptionButton

const index_to_diff = ["e", "m", "h"]

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.bot_difficulties[self.name] = index_to_diff[difficulty_select.get_selected_id()]


func _on_difficulty_select_item_selected(index):
	# set bot difficulty to what is selected in global
	Global.bot_difficulties[self.name] = index_to_diff[index]
	print("SETUP: ", Global.bot_difficulties)

