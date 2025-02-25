extends Node2D

@export var deck: Node2D

#types of cards
const NIGIRI_CARDS = {"nigiri": null}
const ROLL_CARDS = {"maki": null, "temaki": null, "uramaki": null}
const APPETIZER_CARDS = {"dumplings": null, "edamame": null, "eel": null, "onigiri": null, "miso_soup": null, "sashimi": null, "tempura": null, "tofu": null}
const SPECIAL_CARDS = {"chopsticks": null, "menu": null, "soy_sauce": null, "spoon": null, "special_order": null, "takeout_box": null, "wasabi": null, "tea": null}
const DESSERT_CARDS = {"pudding": null, "green_tea_ice_cream": null, "fruit_ww": null, "fruit_wp": null, "fruit_wt": null, "fruit_tt": null}

# simple cards are those who are easy to store (only no matters)
const SIMPLE_CARDS = {"maki": null, "temaki": null, "tempura": null, "sashimi": null, "dumplings": null, "eel": null, "tofu": null, "green": null, "pudding": null, "edamame": null, "tea": null, "soy": null}
# cards that take effect during the round
const DURING_ROUND_CARDS = {"uramaki": null, "miso": null}
# cards that requires another card
const DEPENDENT_CARDS = {"special": null}
# cards that have many typesL onigiri and fruits
const VARIATION_CARDS = {"fruit": null, "onigiri": null}

var cards_no = Global.cards_no
# number of player: initially set at 1
var players_number = Global.players_number
# dictionary to store the points of each person/bot
var players_points = {}
# dictionary to store the cards played of each person/bot
var players_played_cards = {}
# Round number and turn number
var round = 1
# record if a player has taken  a turn
var taken_turn = {}
# cards played in a turn (during round)
var played_dr_cards = []
# cards left in the round
var cards_left_in_round = 8

signal player_has_hand(player)

# need to add timer and rounds here

func _ready():
	Global.viewport_size = get_viewport().size
	
	# loads the cards from the deck selected
	# cards that will be in play
	var cards = Global.cards
	var cards_loaded = {}
	load_cards(cards, cards_loaded)
	Global.cards_loaded = cards_loaded
	
	# array that holds all dessert cards
	var desserts = []
	# get the desserts that need to be added per roun
	var desserts_per_round = dpr(players_number)
	make_deck(cards_loaded, desserts, desserts_per_round)
	# make number of player
	make_players(players_number, players_points)
	for player in players_points:
		populate_player_hand(player)

# make all the players in the game
func make_players(player_number, players_points):
	# loading player scene
	const path = "res://scenes/game/player.tscn"
	var player_scene = load(path)
	var player
	# creating player_number of players
	for i in player_number:
		player = player_scene.instantiate()
		player.name = "player_" + str(i)
		
		if player.name == "player_0":
			player.global_position = Vector2(100, 20)
		elif player.name == "player_1":
			player.global_position = Vector2(100, 170)
		else:
			player.global_position = Vector2(100, 330)
		
		player.card_played.connect(store_card_played)
		get_hand(player).name = "player_hand_" + str(i)
		self.add_child(player)
		players_points[player] = 0

# moves 8 cards to the players hand from the deck
func populate_player_hand(player):
	var card
	for i in 8:
		card = deck.get_children().pick_random()
		scale_card(card, 1)
		card.global_position = player.global_position
		move_node(card, deck, get_hand(player))
		flip_card_to_front(card)
	Global.emit_signal("player_has_hand", player)
	cards_left_in_round = 8
	
# stores the cards that each player has played
func store_card_played(player, card, extra_info):
	var card_name = card.name.split('_')[0]
	var variation 
	
	if player not in players_played_cards:
		players_played_cards[player] = {}
	if player not in taken_turn:
		taken_turn[player] = null
	
	# simple cards: number of this card played matters
	if extra_info == null and card_name in SIMPLE_CARDS:
		# background color: tea, soy sauce considered simple
		# only wasabi and nigiri are same colour
		if card_name not in players_played_cards[player]:
			if card_name == "maki":
				variation = int(card.name.split("_")[1])
				players_played_cards[player][card_name] = variation
			else:
				players_played_cards[player][card_name] = 1
		else:
			if card_name == "maki":
				variation = int(card.name.split("_")[1])
				players_played_cards[player][card_name] += variation
			else:
				players_played_cards[player][card_name] += 1
	elif extra_info == null and card_name in VARIATION_CARDS:
		# onigiri and fruits
		variation = card.name.split("_")[1]
		# creates a new set which records how many of each variation 
		# have been played
		if card_name not in players_played_cards[player]:
			players_played_cards[player][card_name] = {variation: 1}
		elif variation not in players_played_cards[player][card_name]:
			players_played_cards[player][card_name][variation] = 1
		else:
			players_played_cards[player][card_name][variation] += 1
	elif extra_info == null and card_name in DURING_ROUND_CARDS:
		# during round (call calc_points) : uramaki, miso soup
		played_dr_cards.append([card_name, card, player])
	elif extra_info and card_name in DEPENDENT_CARDS:
		# dependent: special order 
		pass
	# wasabi a bit different
	
	# wait for the card to be flipped over & animation
	# check if every player has taken their turn
	if taken_turn.size() == players_number:
		cards_left_in_round -= 1
		# displays icons fnction here
		turn_over()
		calc_points("during_round", played_dr_cards)
		played_dr_cards = []
		
	
	"""HARD"""
	# bonus action: chopsticks, spoon
	# look at deck & choose: menu
	# flip: takeout box

# manages when the hands needs to be swapped (when all cards have been played for a round)
# animation
func turn_over():
	# need to swap all the player_hands
	# can play animation here 
	var curr_player
	var next_player
	
	var extra_hand
	# shuffle hands from player_0 to last player, last player to second last player and so on
	for i in players_number:
		# disconnect the hand form the curr player
		curr_player = self.get_node("player_" + str(i))
		# make sure last player does not have a disconnected hand
		Global.emit_signal("disconnect_hand_from_player", curr_player)
		# send the hand to the next player
		if i == 0:
			extra_hand = get_hand(curr_player)
			curr_player.remove_child(curr_player.get_child(1))
		else:
			next_player = self.get_node("player_" + str(i - 1))
			move_node(get_hand(curr_player), curr_player, next_player)
			# connect the hand
			Global.emit_signal("player_has_hand", next_player)
	# last player get new hand
	next_player = self.get_node("player_" + str(players_number - 1))
	next_player.add_child(extra_hand)
	Global.emit_signal("player_has_hand", next_player)
		
	# if the hand we just receive is of length 1, end round
	if cards_left_in_round == 0:
		calc_points("round_end", null)
		# trigger reset round
		new_round()
	taken_turn = {}
	Global.emit_signal("allowed_to_play")

# calculates the points each player has at the end of the round
# need to change due to special_order
func calc_points(calc_type, played_dr_cards):
	var played_cards
	
	if calc_type == "round_end":
		var maki = []
		var p_most_ = 0
		
		for player in players_played_cards:
			played_cards = players_played_cards[player]
			
			for card in played_cards:
				if card == "sashimi":
					players_points[player] += (played_cards[card] / 3) * 10
				elif card == "dumplings":
					var p = played_cards[card] * (played_cards[card] + 1) / 2
					if played_cards[card] > 5:
						p = 15
					players_points[player] += p
				elif card == "eel":
					players_points[player] += -3 if played_cards[card] == 1 else 5
				elif card == "tempura":
					players_points[player] += (played_cards[card] / 2) * 5
				elif card == "tofu":
					var p = 0
					if played_cards[card] == 1:
						p = 2
					elif played_cards[card] == 2:
						p = 6
					players_points[player] += p
				elif card == "maki":
					maki.append([played_cards[card], player])
			
		if maki:
		# give points to players with largest and second largest no of maki
			maki.sort()
			maki.reverse()
			
			var count = 0
			for i in maki.size() - 1:
				if count == 2:
					break
				players_points[maki[i][1]] += Global.maki_points[count]
				if maki[i] != maki[i + 1]:
					count += 1
			if count < 2:
				players_points[maki[maki.size() - 1][1]] += Global.maki_points[count]
	elif calc_type == "during_round" and played_dr_cards:
		var miso_per_turn = 0
		var miso_player
		var not_counted_uramaki = []
		
		for tuple in played_dr_cards:
			if tuple[0] == "miso":
				miso_per_turn += 1
				miso_player = tuple[2]
			else:
				# uramakis are always discarded
				add_back_to_deck(tuple[1])
				# only if we can award points do it
				if Global.uramaki_curr_points >= 0:
					var variation = int(tuple[1].name.split("_")[1])
					if "uramaki" not in players_played_cards[tuple[2]]:
						# count number of uramaki, and if points have been allocated
						players_played_cards[tuple[2]]["uramaki"] = [variation, false]
					elif players_played_cards[tuple[2]]["uramaki"][0] < 10:
						players_played_cards[tuple[2]]["uramaki"][0] += variation
					print("Board: ", players_played_cards)
					if players_played_cards[tuple[2]]["uramaki"][0] >= 10 and not players_played_cards[tuple[2]]["uramaki"][1]:
						not_counted_uramaki.append([players_played_cards[tuple[2]]["uramaki"][0], tuple[2]])
					print("Board: ", not_counted_uramaki)
		# send back into deck if > 1
		# could add animation for played nbut failed
		if miso_per_turn > 1:
			for tuple in played_dr_cards:
				if tuple[0] == "miso":
					add_back_to_deck(tuple[1])
		elif miso_per_turn == 1:
			players_points[miso_player] += 3
			if "miso" not in players_played_cards[miso_player]:
				players_played_cards[miso_player]["miso"] = 1
			else:
				players_played_cards[miso_player]["miso"] += 1
		
		# check for any ties in uramaki, if any player has uramaki > 10
		if not_counted_uramaki:
			not_counted_uramaki.sort()
			not_counted_uramaki.reverse()
			var n = not_counted_uramaki.size()
			
			if n > 1:
				# checking for ties and awarding points
				var i = 0
				var allowed = Global.uramaki_curr_points
				while i < n - 1 and not_counted_uramaki[i][0] == not_counted_uramaki[i + 1][0] and allowed >= 0:
					players_points[not_counted_uramaki[i][1]] += Global.uramaki_points[Global.uramaki_curr_points]
					# make sure that the player can no longer add uramaki
					players_played_cards[not_counted_uramaki[i][1]]["uramaki"][1] = true
					allowed -= 1
					i += 1
				if i > 0 and not_counted_uramaki[i - 1][0] == not_counted_uramaki[i][0] and allowed >= 0:
					players_points[not_counted_uramaki[i][1]] += Global.uramaki_points[Global.uramaki_curr_points]
					# make sure that the player can no longer add uramaki
					players_played_cards[not_counted_uramaki[i][1]]["uramaki"][1] = true
					allowed -= 1
					i += 1
				Global.uramaki_curr_points = allowed
				
				# check for no ties
				while i < n and Global.uramaki_curr_points >= 0:
					players_points[not_counted_uramaki[i][1]] += Global.uramaki_points[Global.uramaki_curr_points]
					players_played_cards[not_counted_uramaki[i][1]]["uramaki"][1] = true
					Global.uramaki_curr_points -= 1
			else:
				players_points[not_counted_uramaki[0][1]] += Global.uramaki_points[Global.uramaki_curr_points]
				# make sure that the player can no longer add uramaki
				players_played_cards[not_counted_uramaki[0][1]]["uramaki"][1] = true
				Global.uramaki_curr_points -= 1
			
			
			
			# check for second largests and things
			
	elif calc_type == "game_end":
		pass
	print("Board: ", players_points)

# preps the game scene for a new round
func new_round():
	print("Board: ", players_points)
	round += 1
	for player in players_points:
		populate_player_hand(player)
	Global.uramaki_curr_points = 2
	players_played_cards = {}

# populates the cards_loaded dictionary with 
# the names of what cards we need
func load_cards(cards, cards_loaded):
	var path
	for card in cards:
		if cards[card] >= 1:
			# get the correct number of cards needed for each type
			if card == "nigiri" or card == "maki":
				for i in range(1, 4):
					path = "res://scenes/card2D/playing_card/" + str(card) + "_" + str(i) + ".tscn"
					cards_loaded[str(card) + "_" + str(i)] = (load(path))
			elif card == "onigiri":
				for i in range(1, 5):
					path = "res://scenes/card2D/playing_card/" + str(card) + "_" + str(i) + ".tscn"
					cards_loaded[str(card) + "_" + str(i)] = (load(path))
			elif card == "uramaki":
				for i in range(3, 6):
					path = "res://scenes/card2D/playing_card/" + str(card) + "_" + str(i) + ".tscn"
					cards_loaded[str(card) + "_" + str(i)] = (load(path))
			elif card == "fruit":
				path = "res://scenes/card2D/playing_card/" + str(card) + "_ww.tscn"
				cards_loaded[str(card) + "_ww"] = (load(path))
				path = "res://scenes/card2D/playing_card/" + str(card) + "_wp.tscn"
				cards_loaded[str(card) + "_wp"] = (load(path))
				path = "res://scenes/card2D/playing_card/" + str(card) + "_wt.tscn"
				cards_loaded[str(card) + "_wt"] = (load(path))
				path = "res://scenes/card2D/playing_card/" + str(card) + "_tt.tscn"
				cards_loaded[str(card) + "_tt"] = (load(path))
				path = "res://scenes/card2D/playing_card/" + str(card) + "_pp.tscn"
				cards_loaded[str(card) + "_pp"] = (load(path))
				path = "res://scenes/card2D/playing_card/" + str(card) + "_pt.tscn"
				cards_loaded[str(card) + "_pt"] = (load(path))
			else:
				path = "res://scenes/card2D/playing_card/" + str(card) + ".tscn"
				cards_loaded[str(card)] = (load(path))

# instantiate the cards in the cards_loaded dict
# also names them and adds them as a child of the deck node
func make_deck(cards_loaded, desserts, desserts_per_round):
	for card in cards_loaded:
		# if card is a dessert only put a few into the deck initially
		if card in DESSERT_CARDS:
			for i in cards_no[card]:
				instantiate_card(cards_loaded, card, i, false, desserts)
		else:
			for i in cards_no[card]:
				instantiate_card(cards_loaded, card, i, true, null)
	
	var d_card
	for i in desserts_per_round[round - 1]:
		d_card = desserts.pick_random()
		desserts.erase(d_card)
		deck.add_child(d_card)

# instantiate needed cards, stores to deck or append to desserts
func instantiate_card(cards_loaded, card, number, to_deck, desserts):
	var card_copy = cards_loaded[card].instantiate()
	card_copy.name = str(card) + "_" + str(number)
	card_copy.global_position = deck.global_position
	scale_card(card_copy, 0.7)
	# flips card so we cant see what it is
	flip_card_to_back(card_copy)
	if to_deck:
		deck.add_child(card_copy)
	else:
		desserts.append(card_copy)


""" Helper Functions Below"""
# moves node between nodes
func move_node(node, old_node, new_node): 
	old_node.remove_child(node) 
	new_node.add_child(node)

# returns the player's hand
func get_hand(player):
	return player.get_child(1)

func scale_card(card, ratio):
	card.scale.x = ratio
	card.scale.y = ratio

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

# determines how many desserts are inserted per round
func dpr(player_num):
	if players_number <= 5:
		return [5, 3, 2]
	return [7, 5, 3]

func add_back_to_deck(card):
	flip_card_to_back(card)
	card.global_position = deck.global_position
	card.rotation = 0
	deck.add_child(card)
