extends Node2D

@onready var player_hand = get_hand(self)

@export var difficulty = 'e'
var allowed_to_play_card = true

# to tell the board what cards have been played by who
signal card_played(player, card, extra_info)


func _ready():
	Global.player_has_hand_sig.connect(_on_player_has_hand)
	Global.disconnect_hand_from_player.connect(disconnect_hand_from_player)
	Global.allowed_to_play.connect(_player_allowed_to_play)
	
# runs when all the cards have been instantiated in board
# and 8 cards are given to player
# or when player gets a new hand
func _on_player_has_hand(player):
	if self == player:
		player_hand = get_hand(player)
		#print("---Player: ", player_hand, " connected to ", self)
		
# disconnect the curr hand from player
func disconnect_hand_from_player(player):
	if self == player:
		player_hand = get_hand(player)
		#print("---Player: ", player_hand, " disconnected from ", self)

var rng = RandomNumberGenerator.new()
# when bot is able to play calculate
func _player_allowed_to_play():
	allowed_to_play_card = true
	
	# bot is able to play a card
	if allowed_to_play_card and player_hand.get_child_count() > 0:
		# code to choose card
		
		var card_to_play = random_card()
		if difficulty == 'e':
			# code to wait a bit before a pick
			#var random_wait =  rng.randf_range(.5, 2.0)
			#await get_tree().create_timer(random_wait).timeout;
			card_to_play = simple_greedy()
		elif difficulty == 'm':
			# want a search tree
			pass
		elif difficulty == 'h':
			pass
		
		print("---Player: ", self, " played ", card_to_play.name, " from ", player_hand)
		
		player_hand.remove_child(card_to_play)
		allowed_to_play_card = false
		
		var info = null
		if card_to_play.name.split('_')[0] == "miso":
			info = "miso"
		card_played.emit(self, card_to_play, null)
		

# picks a card at random to play
func random_card():
	var random_n = rng.randi_range(0, player_hand.get_child_count() - 1)
	var card = player_hand.get_child(random_n)
	
	return card

# choose the card that gives the maximum points per card, no regard for conditions
func simple_greedy():
	const ppc = {
	"nigiri_1": 1, "nigiri_2": 2, "nigiri_3": 3, "maki_1": 1, "maki_2": 2, "maki_3": 2.7, "temaki": 0, "uramaki_3": 1, "uramaki_4": 2, "uramaki_5": 3,
	"tempura": 2.5, "sashimi": 3.33, "dumplings": 2, "eel": 3.5, "tofu": 3, "onigiri_1": 2, "onigiri_2": 2, "onigiri_3": 2, "onigiri_4": 2, "edamame": 8, "miso_soup": 3,
	"chopsticks": 0, "soy_sauce": 0, "tea": 2, "menu": 0, "spoon": 30, "special_order": 0, "takeout_box": 0, "wasabi": 2.9, 
	"pudding": 0, "green_tea_ice_cream": 2.9, "fruit_ww": 0, "fruit_wp": 0, "fruit_wt": 0, "fruit_tt": 0, "fruit_pp": 0, "fruit_pt": 0
	}
	var best_card
	var best_card_points = 0
	var best_cards = []
	var best_cards_n = 0
	
	for card in player_hand.get_children():
		var t = card.name.rstrip("0123456789")
		t = t.rstrip("_")
		
		if ppc[t] > best_card_points:
			best_card_points = ppc[t]
	
	for card in player_hand.get_children():
		var t = card.name.rstrip("0123456789")
		t = t.rstrip("_")
		
		if ppc[t] == best_card_points:
			best_cards.append(card)
			best_cards_n += 1
	
	var random_n = rng.randi_range(0, best_cards_n - 1)
	best_card = best_cards[random_n]
	
	return best_card

"""HELPER FUNCTIONS"""

# moves cards between nodes
func move_card(card, old_node, new_node): 
	old_node.remove_child(card) 
	new_node.add_child(card)

# scales card
func scale_card(card, ratio):
	card.scale.x = ratio
	card.scale.y = ratio

# returns the player's hand
func get_hand(player):
	return player.get_child(1)
