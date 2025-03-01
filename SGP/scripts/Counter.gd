extends Control

# player
@export var _self: Node2D

const COUNTERS = {"maki": null, "uramaki": null, "pudding": null, "green": null, "fruit": null}
const DESSERTS = {"pudding": null, "green": null, "fruit": null}
const VARIATIONS = {"maki": null, "uramaki": null, "fruit": null}
const NO_VARIATIONS = {"pudding": null, "green": null}
const CHR_TO_FRUIT = {'t': "tangerine", 'p': "pineapple", 'w': "watermelon"}
const FRUITS = {"tangerine": null, "pineapple": null, "watermelon": null}

# counter for only rounds
var round_counters = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# signal that emits when a deck has loaded in
	Global.game_started_sig.connect(load_counters)
	# signal that runs when a card is played by the player
	Global.display_card_icon.connect(add_to_counter)
	Global.round_over.connect(reset_counters_on_round)

# function that runs when the deck has been selected and loads in the proper counters
func load_counters():
	# hide the counters and icons that aren't in the deck
	for card in Global.cards:
		if Global.cards[card] == 1:
			var card_name = card.split('_')[0]
			if card_name in COUNTERS:
				if card_name != "fruit":
					show_display(card_name)
					if card_name not in DESSERTS:
						round_counters.append(card_name)
				else:
					# get types of fruits
					for fruit in FRUITS:
						show_display(fruit)

# add to the counter when a card is played
func add_to_counter(player, card, extra_info):
	if player == _self:
		var card_name = card.name.split('_')[0]
		
		# check if we need to count the card
		if card_name in COUNTERS:
			# get the label we need
			
			if card_name in VARIATIONS:
				var variation = card.name.split('_')[1]
				
				if card_name == "fruit":
					for chr in variation:
						var lbl = self.get_node(CHR_TO_FRUIT[chr] + "_counter") 
						lbl.text = str(int(lbl.text) + 1)
				else:
					# maki and uramaki rolls
					var lbl = self.get_node(card_name + "_counter") 
					lbl.text = str(int(lbl.text) + int(variation))
			else:
				# pudding and green tea ice cream
				var lbl = self.get_node(card_name + "_counter") 
				lbl.text = str(int(lbl.text) + 1)

# reset roll counters
func reset_counters_on_round():
	for counter in round_counters:
		reset_counter(counter)

func reset_counter(counter_name):
	var lbl = self.get_node(counter_name + "_counter")
	lbl.text = "0"

# hide the icon and the counter
func show_display(card_name):
	var icon = self.get_node(card_name + "_icon")
	icon.visible = true
	var lbl = self.get_node(card_name + "_counter")
	lbl.visible = true
