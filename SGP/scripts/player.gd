extends Node2D

@export var height_curve: Curve
@export var rotation_curve: Curve
@export var max_rotation_degrees := 10
@export var x_sep := 5
@export var y_min := 50
@export var y_max := -50
@export var hand_size := 600

const HAND_WIDTH = 200
const HAND_HEIGHT = 50
const HAND_ROT = 0.2

@onready var player = $"."
@onready var player_hand = self.get_node("player_hand")

var allowed_to_play_card = true

# to tell the board what cards have been played by who
signal card_played(player, card, extra_info)
# to display the played card in icons (should be received by icons)
signal display_card_icon(player, card, extra_info)

func _ready():
	Global.player_has_hand.connect(_on_player_has_hand)

# runs when all the cards have been instantiated in board
# and 8 cards are given to player
func _on_player_has_hand(player):
	if self == player:
		# connect the cards to know when they are pressed
		for card in player_hand.get_children():
			card.card_pressed.connect(_card_pressed_from_hand)
		# span the cards
		_update_cards()

# have to fix the positioning of update cards

# positions and spans the cards
func _update_cards():
	var cards := player_hand.get_child_count()
	var Card = player_hand.get_child(0)
	var all_cards_size = Card.get_size().x * cards + x_sep * (cards - 1)
	var final_x_sep = x_sep
	
	if all_cards_size > hand_size:
		final_x_sep = (hand_size - Card.get_size().x * cards) / (cards - 1)
		all_cards_size = hand_size

	var offset = (hand_size - all_cards_size) / 2
	
	for i in cards:
		var card := player_hand.get_child(i)
		var y_multiplier := height_curve.sample(1.0 / (cards-1) * i)
		var rot_multiplier := rotation_curve.sample(1.0 / (cards-1) * i)
		
		if cards == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0
		
		var final_x: float = offset + Card.get_size().x  * i + final_x_sep * i
		var final_y: float = y_min + y_max * y_multiplier

		card.position.x = final_x - all_cards_size / 2
		card.position.y = final_y
		card.rotation_degrees = max_rotation_degrees * rot_multiplier
		card.initial_position = card.position
		card.initial_rotation = card.rotation_degrees

# plays a card when pressed if allowed
func _card_pressed_from_hand(card):
	if allowed_to_play_card:
		print("played ", card, " from hand")
		player_hand.remove_child(card)
		card.queue_free()
		_update_cards()
		allowed_to_play_card = false
		
		# for now extra info is null, only when its is special order
		# first one for 
		card_played.emit(self, card, null)
		display_card_icon.emit(self, card, null)

# moves cards between nodes
func move_card(card, old_node, new_node): 
	old_node.remove_child(card) 
	new_node.add_child(card)

# scales card
func scale_card(card, ratio):
	card.scale.x = ratio
	card.scale.y = ratio
	
