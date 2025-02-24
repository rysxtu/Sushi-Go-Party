extends Node2D

const NO_FRUIT_CARDS = 6
var rng = RandomNumberGenerator.new()
var num

func _ready():
	# generates a random number from 0 to 5
	# in the end we won't randomly generate
	num = rng.randi_range(0, NO_FRUIT_CARDS - 1)
	# destroy all cards except for one of them randomly
	free_all_except(num)

	
func free_all_except(num):
	var children = self.get_children()
	for i in children.size():
		if is_instance_valid(children[i]) and i != num:
			self.remove_child(children[i])
			children[i].queue_free()
			
func type():
	return "fruit"
	
func fruit_index():
	return num

