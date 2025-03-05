extends Node2D

@onready var player_hand = get_hand(self)

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
		print("DEBUG: ", player, ' ', player_hand.get_children())
		print("---Player: ", player_hand, " connected to ", self)
		# connect the cards to know when they are pressed
		for card in player_hand.get_children():
			card.card_pressed.connect(_card_pressed_from_hand)


# disconnect the curr hand from player
func disconnect_hand_from_player(player):
	if self == player:
		player_hand = get_hand(player)
		print("---Player: ", player_hand, " disconnected from ", self)
		# connect the cards to know when they are pressed
		for card in player_hand.get_children():
			card.card_pressed.disconnect(_card_pressed_from_hand)

# plays a card when pressed if allowed
func _card_pressed_from_hand(card):
	if allowed_to_play_card:
		print("---Player: ", self, " played ", card.name, " from ", player_hand)
		
		player_hand.remove_child(card)
		allowed_to_play_card = false
		
		# for now extra info is null, only when its is special order
		# first one for 
		var info = null
		if card.name.split('_')[0] == "miso":
			info = "miso"
		card_played.emit(self, card, null)

func _player_allowed_to_play():
	allowed_to_play_card = true

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
