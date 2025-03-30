extends Node2D

@export var height_curve: Curve
@export var rotation_curve: Curve
@export var special_cards: Control
@export var takeout_confirm: Button
@export var see_deck: Button
@export var takeout_lbl: Label
@export var max_rotation_degrees := 10
@export var x_sep := 5
@export var y_min := 50
@export var y_max := -50
@export var hand_size := 600
@export var icon_manager: Control

const HAND_WIDTH = 200
const HAND_HEIGHT = 50
const HAND_ROT = 0.2

@onready var player_hand = get_hand(self)

var allowed_to_play_card = true
# store the card we need to add back to the deck
var add_card_back_to_hand

var takeout_turned_over_cards = {}

# to tell the board what cards have been played by who
signal card_played(player, card, extra_info)
# signal to tell that icon_manager should get rid of chopsticks icons as it has been used
signal chopsticks_played_ic(icon_name)

# CLEAN: temp for when chopsticks are played
@onready var test_chopticks_lbl = self.get_node("display/Temp_chopsticks")

# player script only deals with playing cards, not the ui
func _ready():
	Global.player_has_hand_sig.connect(_on_player_has_hand)
	Global.disconnect_hand_from_player.connect(disconnect_hand_from_player)
	Global.allowed_to_play.connect(_all_players_allowed_to_play)
	Global.player_allowed_to_play.connect(_player_allowed_to_play)
	Global.takeout_box.connect(_takeout_box)
	
# runs when all the cards have been instantiated in board
# and 8 cards are given to player
# or when player gets a new hand
func _on_player_has_hand(player):
	if self == player:
		player_hand = get_hand(player)
		#print("---Player: ", player_hand, " connected to ", self)
		# connect the cards to know when they are pressed
		for card in player_hand.get_children():
			card.visible = true
			flip_card_to_front(card)
			card.card_pressed.connect(_card_pressed_from_hand)
		# span the cards
		if player_hand.get_child_count() >= 1:
			_update_cards()

# disconnect the curr hand from player
func disconnect_hand_from_player(player):
	if self == player:
		player_hand = get_hand(player)
		#print("---Player: ", player_hand, " disconnected from ", self)
		# connect the cards to know when they are pressed
		for card in player_hand.get_children():
			card.visible = false
			flip_card_to_back(card)
			card.card_pressed.disconnect(_card_pressed_from_hand)

# have to fix the positioning of update cards
# positions and spans the cards
func _update_cards():
	var cards = player_hand.get_child_count()
	var Card = player_hand.get_child(0)
	var all_cards_size = Card.get_size().x * cards + x_sep * (cards - 1)
	var final_x_sep = x_sep
	
	if all_cards_size > hand_size:
		final_x_sep = (hand_size - Card.get_size().x * cards) / (cards - 1)
		all_cards_size = hand_size
	
	for i in cards:
		var card = player_hand.get_child(i)
		var y_multiplier := height_curve.sample(1.0 / (cards-1) * i)
		var rot_multiplier := rotation_curve.sample(1.0 / (cards-1) * i)
		
		if cards == 1:
			y_multiplier = height_curve.sample(0.5)
			rot_multiplier = 0.0
		
		var final_x: float = Card.get_size().x  * i + final_x_sep * i
		var final_y: float = y_min + y_max * y_multiplier

		card.position.x = final_x - all_cards_size / 2
		card.position.y = final_y
		card.rotation_degrees = max_rotation_degrees * rot_multiplier
		card.initial_position = card.position
		card.initial_rotation = card.rotation_degrees

# plays a card when pressed if allowed
func _card_pressed_from_hand(card):
	if allowed_to_play_card:
		var card_name = card.name.split('_')[0]
		print("---Player: ", self, " played ", card.name, " from ", player_hand)
		
		player_hand.remove_child(card)
		if player_hand.get_child_count() > 1:
			_update_cards()
		allowed_to_play_card = false
		
		# CLEAN, adding chopsticks back into hand
		if add_card_back_to_hand:
			var special_card = Global.cards_loaded[add_card_back_to_hand].instantiate()
			special_card.name = add_card_back_to_hand
			player_hand.add_child(special_card)
			special_card.card_pressed.connect(_card_pressed_from_hand)
			add_card_back_to_hand = null
			test_chopticks_lbl.visible = false
		
		# for now extra info is null, only when its is special order
		# first one for 
		var info = null
		if card_name == "miso":
			info = "miso"
		card_played.emit(self, card, null)

# runs when signale for new turn
func _all_players_allowed_to_play():
	allowed_to_play_card = true

# runs when signaled for player to have anotehr turn (e.g chopsticks)
func _player_allowed_to_play(player, type, card_order):
	if player == self:
		if player_hand.get_child_count() == 0:
			card_played.emit(self, null, null)
			chopsticks_played_ic.emit(type)
			return
		
		# remove card from special cards desiplay
		# need number
		# CLEAN: for card_order
		test_chopticks_lbl.visible = true
		if type == "chopsticks":
			# add card_order: type + "_" + str(card_order)
			add_card_back_to_hand = type + "_" + str(card_order)
			# should emit type + "_" + str(card_order) with order
			chopsticks_played_ic.emit(type + "_" + str(card_order))
		
		allowed_to_play_card = true

func _takeout_box(player):
	if self == player:
		# connect to icon pressed in icons
		var markers = icon_manager.get_node("markers")
		var icon
		# look through each marker
		for marker in markers.get_children():
			# ensure that there is an icon
			if marker is Marker2D and marker.get_child_count() > 0:
				icon = marker.get_child(0)
				icon.icon_pressed.connect(_turn_over_cards_tb)
		
		see_deck.emit_signal("pressed")
		takeout_confirm.visible = true
		takeout_lbl.visible = true

# function to collect all turned over cards
func _turn_over_cards_tb(icon):
	# in and turned over, then it means to turn it back up (not fliiping it anymore)
	if icon in takeout_turned_over_cards and takeout_turned_over_cards[icon] == 1:
		takeout_turned_over_cards[icon] = 0
		# get the sprite's shader
		icon.get_node("Sprite2D").material.set_shader_parameter("is_grey", false)
	else:
		takeout_turned_over_cards[icon] = 1
		icon.get_node("Sprite2D").material.set_shader_parameter("is_grey", true)
	print(takeout_turned_over_cards)

# confirm button pressed for takeout
func _confirm_turn_over():
	# have to send back the cards that have been turned over
	
	# disconnect icon pressed signal, so no confusion later
	var markers = icon_manager.get_node("markers")
	var icon
	# look through each marker
	for marker in markers.get_children():
		# ensure that there is an icon
		if marker is Marker2D and marker.get_child_count() > 0:
			icon = marker.get_child(0)
			icon.icon_pressed.disconnect(_turn_over_cards_tb)
	# hide the board and everything related to takeout
	see_deck.emit_signal("pressed")
	takeout_confirm.visible = false
	takeout_lbl.visible = false
	card_played.emit(self, null, null)

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

# make the top of a card visible
func flip_card_to_front(card):
	card.get_child(0).visible = true
	card.get_child(-2).visible = false
	card.mouse_filter = 0

# make the back of a card visible
func flip_card_to_back(card):
	card.get_child(0).visible = false
	card.get_child(-2).visible = true
	card.mouse_filter = 2
