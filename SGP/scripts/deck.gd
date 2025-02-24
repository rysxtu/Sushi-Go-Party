extends Node

"""
The deck will have cards instantialised under it once the game 
starts. They should be allocated under more folder (?)

we need player hands as well.

In play / out of play
"""

# this hash map is for identifing what fruits are in play
# use fruit_type funntion to get the index
var index_to_fruit_type = {
							0: "2_Melon",
							1: "2_Pinapple",
							2: "2_Tangerine",
							3: "Melon_pinapple",
							4: "Melon_tangerine",
							5: "Pinapple_tangerine"
							}

# all the cards in here
# we want to preload all the scripts so we can instance
var cards = ["Fruits"]

func _ready():
	# testing how the deck would work by printing out each card
	for child in self.get_children():
		if child.type() == "fruit":
			print(index_to_fruit_type[child.fruit_index()])
