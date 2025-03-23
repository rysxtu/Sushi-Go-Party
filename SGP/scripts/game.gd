extends Node2D

@export var deck: Node2D
@export var end_game_btn: Button

#types of cards
const NIGIRI_CARDS = {"nigiri": null}
const ROLL_CARDS = {"maki": null, "temaki": null, "uramaki": null}
const APPETIZER_CARDS = {"dumplings": null, "edamame": null, "eel": null, "onigiri": null, "miso_soup": null, "sashimi": null, "tempura": null, "tofu": null}
const SPECIAL_CARDS = {"chopsticks": null, "menu": null, "soy_sauce": null, "spoon": null, "special": null, "takeout": null, "wasabi": null, "tea": null}
const DESSERT_CARDS = {"pudding": null, "green": null, "fruit": null}

# simple cards are those who are easy to store (only no matters)
const SIMPLE_CARDS = {"maki": null, "temaki": null, "tempura": null, "sashimi": null, "dumplings": null, "eel": null, "tofu": null, "green": null, "pudding": null, "edamame": null, "tea": null, "soy": null}
# cards that take effect during the round
const DURING_ROUND_CARDS = {"uramaki": null, "miso": null}
# cards that requires another card
const DEPENDENT_CARDS = {"special": null}
# cards that have many typesL onigiri and fruits
const VARIATION_CARDS = {"fruit": null, "onigiri": null}
# nigir and wasabi
const WASABI_CARDS = {"nigiri": null, "wasabi": null}
# hand size
var hand_size = [8, 10, 10, 9, 9, 8, 8, 7][Global.players_number + Global.bots_number - 1]

var cards_no = Global.cards_no
# number of player: initially set at 1
var players_number = Global.players_number
var bots_number = Global.bots_number
# dictionary to store the points of each person/bot
var players_points = {}
# dictionary to store the cards played of each person/bot
var players_played_cards = {}
# dictionary to store the desserts played of each person/bot
var players_played_desserts = {}
# Round number and turn number
var game_round = 1
# record if a player has taken  a turn
var taken_turn = {}
# cards left in the round
var cards_left_in_round = hand_size
# all desserts 
var desserts = []
var desserts_per_round = dpr()
# remembers which dessert cards were not played in a round, readded to deck
var desserts_in_round = []
var dessert_name = ""

var played_special_cards = [null, null, null, null, null, null, null, null, null, null, null, null]

var player_decks = {}
var card_name_to_icon = {}

signal player_has_hand_sig(player)
signal player_points_sig(player, points)

# need to add timer and rounds here

func _ready():
	Global.viewport_size = get_viewport().size
	Global.chopsticks_played.connect(chopsticks)
	# loads the cards from the deck selected
	# cards that will be in play
	var cards = Global.cards
	# make hand size known globally for icon managers
	Global.hand_size = hand_size
	var cards_loaded = {}
	load_cards(cards, cards_loaded)
	load_icons()
	make_deck(cards_loaded, desserts_per_round, true)
	# make number of player
	make_players(players_number, players_points)
	for player in players_points:
		populate_player_hand(player)
	Global.emit_signal("game_started_sig")
	Global.emit_signal("allowed_to_play")

# make all the players in the game
@warning_ignore("shadowed_variable")
func make_players(player_number, players_points):
	# loading player scene
	var path = "res://scenes/game/player.tscn"
	var player_scene = load(path)
	var player
	# creating player_number of players and bots
	for i in player_number:
		player = player_scene.instantiate()
		player.name = "player_" + str(i)
		
		# get the players's name tag and set its name
		player.get_child(0).get_node("Name").text = player.name
		if player.name == "player_0":
			player.global_position = Vector2(600, 500)
		else:
			player.global_position = Vector2(600, 300)
		
		player.card_played.connect(store_card_played)
		get_hand(player).name = "player_hand_" + str(i)
		player_decks[player] = get_hand(player)
		self.add_child(player)
		players_points[player] = 0
		
	# load bots
	path = "res://scenes/game/bot.tscn"
	var bot_scene = load(path)
	var bot
	var angle = 100
	for i in bots_number:
		bot = bot_scene.instantiate()
		bot.name = "bot_" + str(i)
		
		# get the bot's name tag and set its name
		bot.get_child(0).get_node("Name").text = bot.name
		bot.difficulty = Global.bot_difficulties[bot.name]
		if bot.name == "bot_0":
			bot.global_position = Vector2(600, 100)
		elif bot.name == "bot_1":
			bot.global_position = Vector2(770, 100)
		elif bot.name == "bot_2":
			bot.global_position = Vector2(940, 100)
		elif bot.name == "bot_3":
			bot.global_position = Vector2(1110, 100)
		elif bot.name == "bot_4":
			bot.global_position = Vector2(430, 100)
		elif bot.name == "bot_5":
			bot.global_position = Vector2(260, 100)
		elif bot.name == "bot_6":
			bot.global_position = Vector2(90, 100)
		bot.scale = Vector2(0.5, 0.5)
		
		bot.card_played.connect(store_card_played)
		get_hand(bot).name = "bot_hand_" + str(i)
		player_decks[bot] = get_hand(bot)
		self.add_child(bot)
		players_points[bot] = 0

# moves 8 cards to the players hand from the deck
func populate_player_hand(player):
	var card
	
	if player.name.contains("player"):
		for i in hand_size:
			card = deck.get_children().pick_random()
			scale_card(card, 1)
			card.global_position = player.global_position
			move_node(card, deck, get_hand(player))
			flip_card_to_front(card)
	else:
		for i in hand_size:
			card = deck.get_children().pick_random()
			card.visible = false
			scale_card(card, 1)
			card.global_position = player.global_position
			move_node(card, deck, get_hand(player))
			
	Global.emit_signal("player_has_hand_sig", player)
	cards_left_in_round = hand_size

# cards played in a turn (during round)
var played_dr_cards = []
# stores the cards that each player has played
func store_card_played(player, card, extra_info):
	var card_name = card.name.split('_')[0]
	var variation 
	
	if player not in players_played_cards:
		players_played_cards[player] = {}
	if player not in players_played_desserts:
		players_played_desserts[player] = {}
	if player not in taken_turn:
		taken_turn[player] = null
	
	# simple cards: number of this card played matters
	if extra_info == null and card_name in SIMPLE_CARDS:
		# background color: tea, soy sauce considered simple

		# make sure current desserts are stored in full dessert pile as well as current
		if card_name in DESSERT_CARDS:
			update_player_dict(players_played_desserts, player, card_name)
			desserts_in_round.erase(card)
		
		# maki is set up differently from update_player_dict()
		if card_name == "maki":
			# variations is how many maki we have
			variation = int(card.name.split("_")[1])
			if "maki" not in players_played_cards[player]:
				# store how many maki we have, and how many maki cards we have
				players_played_cards[player]["maki"] = [variation, 1]
			else:
				players_played_cards[player]["maki"][0] += variation
				players_played_cards[player]["maki"][1] += 1
		else:
			update_player_dict(players_played_cards, player, card_name)
		Global.emit_signal("display_card_icon", player, card, "")
	elif extra_info == null and card_name in VARIATION_CARDS:
		# onigiri and fruits
		variation = card.name.split("_")[1]
		
		# make sure current desserts are stored in full dessert pile as well as current
		if card_name in DESSERT_CARDS:
			update_player_dict(players_played_desserts, player, card_name, false, 1, variation)
			# get rid of it so it doesnt get readded to deck at end of turn
			desserts_in_round.erase(card)
		# store the variations of onigiri and fruits as sets
		update_player_dict(players_played_cards, player, card_name, false, 1, variation)
		Global.emit_signal("display_card_icon", player, card, "")
	elif extra_info == null and card_name in DURING_ROUND_CARDS:
		# during round (call calc_points) : uramaki, miso soup
		played_dr_cards.append([card_name, card, player])
		if card_name == "uramaki":
			Global.emit_signal("display_card_icon", player, card, "")
	elif extra_info == null and card_name in WASABI_CARDS:
		# nigiri and wasabi
		if card_name == "nigiri":
			variation = int(card.name.split("_")[1])
			# check if wasabi is in the player_played cards and if there is an empty one
			if "wasabi" in players_played_cards[player] and players_played_cards[player]["wasabi"][0] > 0:
				players_played_cards[player]["wasabi"][0] -= 1
				players_played_cards[player]["wasabi"][1].append(variation)
				Global.emit_signal("display_card_icon", player, card, "wasabi")
			else:
				# store as just nigiri
				update_player_dict(players_played_cards, player, "nigiri", false, 1, variation)
				Global.emit_signal("display_card_icon", player, card, "")
		else:
			if "wasabi" not in players_played_cards[player]:
				players_played_cards[player]["wasabi"] = [1, []]
			else:
				players_played_cards[player]["wasabi"][0] += 1
			Global.emit_signal("display_card_icon", player, card, "")
	elif extra_info and card_name in DEPENDENT_CARDS:
		# dependent: special order 
		pass
		Global.emit_signal("display_card_icon", player, card, "")
	elif card_name == "chopsticks":
		# store in played cards dictionary
		update_player_dict(players_played_cards, player, card_name)
		# create button to allow the play of chopsticks
		
		# need chopsticks number
		Global.emit_signal("display_chopsticks_option", player, 3)
		Global.emit_signal("display_card_icon", player, card, "")
	
	# wait for the card to be flipped over & animation
	# check if every player has taken their turn
	if taken_turn.size() == Global.players_number + Global.bots_number:
		# do the extra actions from special cards, need timer and animation here
		# temp chopsticks
		# CLEAN and implement card_order
		print(played_special_cards)
		for i in range(0, 12):
			if played_special_cards[i]:
				Global.emit_signal("player_allowed_to_play", played_special_cards[i], "chopsticks")
				played_special_cards[i] = null
				return
		
		cards_left_in_round -= 1
		calc_points("during_round", played_dr_cards)
		# displays icons fnction here
		turn_over()
		
	
	"""HARD"""
	# bonus action: chopsticks, spoon
	# look at deck & choose: menu
	# flip: takeout box

# manages when the hands needs to be swapped (when all cards have been played for a round)
# animation
func turn_over():
	Global.emit_signal("turn_over")
	# need to swap all the player_hands
	# can play animation here 
	var curr_deck 
	var prev_deck 
	var first_player
	for player in player_decks:
		# disconnect the hand form the curr player
		curr_deck = get_hand(player)
		Global.emit_signal("disconnect_hand_from_player", player)
		player.remove_child(curr_deck)
		# connect the previous deck to player
		if prev_deck:
			player_decks[player] = prev_deck
			player.add_child(prev_deck)
			Global.emit_signal("player_has_hand_sig", player)
		else:
			first_player = player
		# prev_deck will be added to next player
		prev_deck = curr_deck
	
	# make sure first player also gets hand
	if prev_deck and first_player:
		player_decks[first_player] = prev_deck
		first_player.add_child(prev_deck)
		Global.emit_signal("player_has_hand_sig", first_player)
		
	# if the hand we just receive is of length 1, end round
	if cards_left_in_round == 0:
		# make sure to disconnect anything
		for player in players_points:
			Global.emit_signal("disconnect_hand_from_player", player)
			
		calc_points("round_end", null)
		# trigger reset round
		new_round()
	
	Global.player_played_cards = players_played_cards
	played_dr_cards = []
	taken_turn = {}
	Global.emit_signal("allowed_to_play")

# calculates the points each player has at the end of the round
# need to change due to special_order
@warning_ignore("shadowed_variable")
func calc_points(calc_type, played_dr_cards):
	var played_cards
	
	if calc_type == "round_end":
		var makis_played = []
		var temakis_played = []
		var edamame_played = [0, []]
		var soy_sauce_played = 0
		
		for player in players_played_cards:
			played_cards = players_played_cards[player]
			
			# add points for each card played, or gather all cards for global analysis
			for card in played_cards:
				count_nonglobal_p(player, card)
				
				# these cards need global information
				if card == "maki":
					makis_played.append([played_cards[card][0], player])
				elif card == "temaki":
					temakis_played.append([played_cards[card], player])
				elif card == "edamame":
					edamame_played[0] += played_cards[card]
					edamame_played[1].append(player)
				elif card == "soy":
					soy_sauce_played = 1
			
			# if not temaki played, means 0 played for this player
			if "temaki" not in played_cards:
				temakis_played.append([0, player])
		
		if makis_played:
			count_global_p(makis_played, "maki")
		if temakis_played:
			count_global_p(temakis_played, "temaki")
		if edamame_played[0] != 0:
			count_global_p(edamame_played, "edamame")
		if soy_sauce_played == 1:
			count_global_p(null, "soy_sauce")
			
		send_points_to_players()
			
	elif calc_type == "during_round" and played_dr_cards:
		var miso_per_turn = 0
		var miso_player
		var miso_card
		var not_counted_uramaki = []
		
		for tuple in played_dr_cards:
			if tuple[0] == "miso":
				miso_per_turn += 1
				miso_card = tuple[1]
				miso_player = tuple[2]
			else:
				# record uramaki playe dby players in not_counted_uramaki, to determine points
				record_uramaki(tuple, not_counted_uramaki)

		# record miso, points will be awarded here at end of round, also displays it if only 1 played
		record_miso(miso_per_turn, miso_player, miso_card)
		
		# award points to uramaki now
		if not_counted_uramaki:
			count_global_p(not_counted_uramaki, "uramaki")
	elif calc_type == "game_end":
		# desserts
		var puddings_played = []
		print("DEBUG desserts played: ", players_played_desserts)
		for player in players_played_desserts:
			var played_desserts
			# number of dessert played or types played
			if dessert_name in players_played_desserts[player]:
				played_desserts = players_played_desserts[player][dessert_name]
			else:
				played_desserts = 0
				
			count_green_p(player, dessert_name)
			count_fruit_p(player, dessert_name)
			if dessert_name == "pudding":
				# number of pudding from each player appended
				puddings_played.append([played_desserts, player])
		
		count_pudding_p(puddings_played)
		send_points_to_players()
	print("Board: \n", "   ", players_played_cards, "\n", "   ", players_played_desserts)
	print("Board: ", players_points)

# preps the game scene for a new round
func new_round():
	print("Board: ", players_points)
	game_round += 1
	
	if game_round >= 4:
		end_game()
		return
	
	# remake the deck, making sure not to delete any leftover desserts
	for child in deck.get_children():
		deck.remove_child(child)
		# this check could be fatser
		if child not in desserts_in_round:
			child.queue_free()
	for d_card in desserts_in_round:
		deck.add_child(d_card)
	make_deck(Global.cards_loaded, desserts_per_round, false)
	
	for player in players_points:
		populate_player_hand(player)
		
	players_played_cards = {}
	Global.emit_signal("round_over")
	Global.uramaki_curr_points = 2

func end_game():
	Global.emit_signal("round_over")
	calc_points("game_end", null)
	Global.player_played_cards = {}
	
	# ADD: need stats displayed
	
	end_game_btn.visible = true


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
				dessert_name = "fruit"
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
				# store the dessert we are dealing with
				if card in DESSERT_CARDS:
					dessert_name = card
				path = "res://scenes/card2D/playing_card/" + str(card) + ".tscn"
				cards_loaded[str(card)] = (load(path))
	Global.cards_loaded = cards_loaded

# instantiate the cards in the cards_loaded dict
# also names them and adds them as a child of the deck node
func make_deck(cards_loaded, desserts_per_round, initial):
	for card in cards_loaded:
		var card_name = card.split('_')[0]
		# if card is a dessert only put a few into the deck initially
		if card_name in DESSERT_CARDS and initial:
			for i in cards_no[card]:
				instantiate_card(cards_loaded, card, i, false)
		elif card_name not in DESSERT_CARDS:
			for i in cards_no[card]:
				instantiate_card(cards_loaded, card, i, true)
				
	var d_card
	for j in desserts_per_round[game_round - 1]:
		d_card = desserts.pick_random()
		desserts.erase(d_card)
		desserts_in_round.append(d_card)
		deck.add_child(d_card)

# instantiate needed cards, stores to deck or append to desserts
func instantiate_card(cards_loaded, card, number, to_deck):
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

# function to do with anything chopsticks
func chopsticks(player, card_order, played):
	if played == true:
		played_special_cards[card_order] = player
	else:
		played_special_cards[card_order] = null

"""Point Functions Below"""

# function that adds points for cards that dont require knowledge on all cards
func count_nonglobal_p(player, card):
	# look into speeding up, this is like ~64 operations
	count_sashimi_p(player, card)
	count_dumplings_p(player, card)
	count_eel_p(player, card)
	count_tempura_p(player, card)
	count_tofu_p(player, card)
	count_miso_p(player, card)
	count_tea_p(player, card)
	count_nigiri_p(player, card)
	count_wasabi_p(player, card)
	count_green_p(player, card)
	count_fruit_p(player, card)
	count_onigiri_p(player, card)
	
func count_global_p(arr, arr_name):
	if arr_name == "maki":
		count_maki_p(arr)
	elif arr_name == "uramaki":
		count_uramaki_p(arr)
	elif arr_name == "temaki":
		count_temaki_p(arr)
	elif arr_name == "edamame":
		count_edamame_p(arr)
	elif arr_name == "soy_sauce":
		count_soy_sauce_p()

func count_sashimi_p(player, card):
	if card == "sashimi":
		players_points[player] += (players_played_cards[player]["sashimi"] / 3) * 10

func count_onigiri_p(player, card):
	if card == "onigiri":
		# minus from keys, until all zero and make groups of however many unique e.g [3, 1], 3 unique and 1 separate groups
		
		# keep track of how many are in a group
		var group_count = 0
		var onigiri_played = players_played_cards[player]["onigiri"]
		
		# ensure no key errors
		for i in range(1, 5):
			if str(i) not in onigiri_played:
				onigiri_played[str(i)] = 0

		# while another group can be formed
		var i = 1
		while onigiri_played["1"] > 0 or onigiri_played["2"] > 0 or onigiri_played["3"] > 0 or onigiri_played["4"] > 0:
			
			if onigiri_played[str(i)] > 0:
				onigiri_played[str(i)] -= 1
				group_count += 1
			i += 1
			
			# reset group counting
			if i > 4:
				players_points[player] += Global.onigiri_points[group_count - 1]
				i = 1
				group_count = 0
		
		# check if last group was counted
		if group_count > 0:
			players_points[player] += Global.onigiri_points[group_count - 1]

func count_dumplings_p(player, card):
	if card == "dumplings":
		var p = (players_played_cards[player]["dumplings"] * (players_played_cards[player]["dumplings"] + 1)) / 2
		if players_played_cards[player]["dumplings"] > 5:
			p = 15
		players_points[player] += p

func count_eel_p(player, card):
	if card == "eel":
		players_points[player] += -3 if players_played_cards[player]["eel"] == 1 else 5

func count_tempura_p(player, card):
	if card == "tempura":
		players_points[player] += (players_played_cards[player]["tempura"] / 2) * 5

func count_tofu_p(player, card):
	if card == "tofu":
		var p = 0
		if players_played_cards[player]["tofu"] == 1:
			p = 2
		elif players_played_cards[player]["tofu"] == 2:
			p = 6
		players_points[player] += p
		
func count_miso_p(player, card):
	if card == "miso":
		players_points[player] += players_played_cards[player]["miso"] * 3

func count_tea_p(player, card):
	if card == "tea":
		var p = 0
		# check normal cards
		for c in players_played_cards[player]:
			if c == "maki":
				p = max(p, players_played_cards[player][c][1])
			elif c != "nigiri" and c != "wasabi":
				# simple cards, except maki
				if typeof(players_played_cards[player][c]) == TYPE_INT:
					p = max(p, players_played_cards[player][c])
				# variation cards
				elif typeof(players_played_cards[player][c]) == TYPE_DICTIONARY:
					var total = sum(players_played_cards[player][c].values())
					p = max(p, total)
			else:
				# calculate the points of wasabit and nigiri together
				var tot_wasabi_nigiri = 0
				if "nigiri" in players_played_cards[player]:
					if typeof(players_played_cards[player]["nigiri"]) == TYPE_DICTIONARY:
						tot_wasabi_nigiri += sum(players_played_cards[player]["nigiri"].values())
				elif "wasabi" in players_played_cards[player]:
					if typeof(players_played_cards[player]["wasabi"]) == TYPE_ARRAY:
						tot_wasabi_nigiri += players_played_cards[player]["wasabi"][1].size()
				p = max(p, tot_wasabi_nigiri)
		players_points[player] += p * players_played_cards[player]["tea"]

func count_nigiri_p(player, card):
	if card == "nigiri":
		var p = 0
		for type in players_played_cards[player]["nigiri"]:
			p += players_played_cards[player]["nigiri"][type] * type
		players_points[player] += p
		
func count_wasabi_p(player, card):
	if card == "wasabi":
		var p = 0
		for nigiri in players_played_cards[player]["wasabi"][1]:
			p += 3 * nigiri
		players_points[player] += p

func count_green_p(player, card):	
	if card == "green":
		players_points[player] += 12 * (players_played_desserts[player]["green"] / 4)

func count_fruit_p(player, card):
	if card == "fruit":
	# add points for each type of fruit
		var types = {'w': 0, 't': 0, 'p': 0}
		for variation in players_played_desserts[player]["fruit"]:
			for chr in variation:
				types[chr] += players_played_desserts[player]["fruit"][variation]
		for type in types:
			if types[type] > 5:
				players_points[player] += Global.fruits_points[5]
			else:
				players_points[player] += Global.fruits_points[types[type]]

func count_maki_p(makis_played):
	# give points to players with largest and second largest no of maki
	makis_played.sort()
	makis_played.reverse()
	
	var count = 0
	for i in makis_played.size() - 1:
		if count == 2:
			break
		players_points[makis_played[i][1]] += Global.maki_points[count]
		if makis_played[i] != makis_played[i + 1]:
			count += 1
	if count < 2:
		players_points[makis_played[makis_played.size() - 1][1]] += Global.maki_points[count]

func count_pudding_p(puddings_played):
	# if pudding was played
	if puddings_played:
		# sort to help find max and min
		puddings_played.sort()
		var minimum = puddings_played[0][0]
		var maximum = puddings_played[-1][0]
		
		print("DDBJD ", players_points)
		# if only one value, give them all max points
		if minimum == maximum and maximum != 0:
			for tuple in puddings_played:
				players_points[tuple[1]] += 6
		else:
			for tuple in puddings_played:
				if tuple[0] == minimum:
					players_points[tuple[1]] -= 6
				elif tuple[0] == maximum and maximum:
					players_points[tuple[1]] += 6
		print("DDBJD ", players_points)

# function to get call uramaki played during a turn by all players
func record_uramaki(tuple, not_counted_uramaki):
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
		if players_played_cards[tuple[2]]["uramaki"][0] >= 10 and not players_played_cards[tuple[2]]["uramaki"][1]:
			not_counted_uramaki.append([players_played_cards[tuple[2]]["uramaki"][0], tuple[2]])

func count_uramaki_p(not_counted_uramaki):
	#not_counted_uramaki is an array with players who have reached >10 uramaki and have not been awarded points yet
	# check for any ties in uramaki, if any player has uramaki > 10
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
	
func record_miso(miso_per_turn, miso_player, miso_card):
	# send back into deck if > 1
	# could add animation for played nbut failed
	if miso_per_turn == 1:
		if "miso" not in players_played_cards[miso_player]:
			players_played_cards[miso_player]["miso"] = 1
		else:
			players_played_cards[miso_player]["miso"] += 1
		Global.emit("display_card_icon", miso_player, miso_card, "")

# assume that if everyone has the least and the most, then just add
func count_temaki_p(temaki_played):
	# give points to players with largest and del from smallest
	temaki_played.sort()
	var n = temaki_played.size()
	
	# max number of temaki played and min number played
	var max_count = temaki_played[n - 1][0]
	var min_count = temaki_played[0][0]

	for i in n:
		# minus from players who played the least, not in two player game, and not if max == min
		if temaki_played[i][0] == min_count and (players_number + bots_number) > 2 and min_count != max_count:
			players_points[temaki_played[i][1]] -= 4
		if temaki_played[i][0] == max_count:
			players_points[temaki_played[i][1]] += 4

func count_edamame_p(edamame_played):
	# check for each player, how many edamame they played
	var tot_other_edamame = 0
	var played = 0
	for player in edamame_played[1]:
		# get how many edamame the player has played, and how many other edamame were played
		played = players_played_cards[player]["edamame"]
		tot_other_edamame = edamame_played[0] - played
		
		# max an edamame is worth is 4
		if tot_other_edamame >= 4:
			players_points[player] += 4 * played
		else:
			players_points[player] += tot_other_edamame * played

func count_soy_sauce_p():
	# have to have max no backgrounds, and check for soy
	var max_backgrounds = 0
	var player_to_backgrounds = {}
	var count = 0
	
	# get the max number of backgrounds
	for player in players_played_cards:
		var backgrounds = {}
		for card in players_played_cards[player]:
			if card == "wasabi" and "nigiri" not in backgrounds and card not in backgrounds:
				backgrounds["wasabi"] = null
			elif card == "nigiri" and "wasabi" not in backgrounds and card not in backgrounds:
				backgrounds["nigiri"] = null
			elif card not in backgrounds:
				backgrounds[card] = null
		count = backgrounds.size()
		player_to_backgrounds[player] = count
		max_backgrounds = max(max_backgrounds, count)
	
	print("DEBUG ", player_to_backgrounds)
	for player in players_played_cards:
		# has max number of background and has play soy_sauce
		if player_to_backgrounds[player] == max_backgrounds and "soy" in players_played_cards[player]:
			# 4 points for each soy sauce card
			print("DEBUG ", players_points[player])
			players_points[player] += 4 * players_played_cards[player]["soy"]
			print("DEBUG ", players_points[player])

# load icons to be displayed
func load_icons():
	var path
	for card in Global.cards:
		var card_name = card.split("_")[0]
		if Global.cards[card] >= 1:
			if "fruit" in card:
				path = "res://scenes/icons/fruit_icon.tscn"
				card_name_to_icon["fruit"] = (load(path))
				
				# need to get specific fruit
			elif "onigiri" in card:
				for i in 4:
					path = "res://scenes/icons/onigiri" + '_' + str(i + 1) + "_icon.tscn"
					card_name_to_icon["onigiri" + '_' + str(i + 1)] = (load(path))
			elif card_name == "nigiri":
				for i in 3:
					path = "res://scenes/icons/nigiri" + '_' + str(i + 1) + "_icon.tscn"
					card_name_to_icon["nigiri" + '_' + str(i + 1)] = (load(path))
			else:
				# get the correct number of cards needed for each type
				path = "res://scenes/icons/" + card_name + "_icon.tscn"
				card_name_to_icon[card_name] = (load(path))
	Global.icons = card_name_to_icon
	
""" Helper Functions Below"""
# function to help store cards
# increment_val is true if we want to just increament a string: int pair, set_info is for incrementing string: set pairs
func update_player_dict(dict, player,key, increment=true, val=1, variation=null):
	if increment:
		if key not in dict[player]:
			dict[player][key] = val
		else:
			dict[player][key] += val
	elif variation:
		if key not in dict[player]:
			dict[player][key] = {variation: 1}
		elif variation not in dict[player][key]:
			dict[player][key][variation] = 1
		else:
			dict[player][key][variation] += 1

# select k-th smallest element, using quick sort
func quick_select(arr, left, right, k):
	if left == right:
		return arr[left]
	var pivotIndex = left + floor(randi() % (right - left + 1))
	pivotIndex = qs_partition(arr, left, right, pivotIndex)
	if k == pivotIndex:
		return arr[k]
	elif k < pivotIndex:
		return quick_select(arr, left, pivotIndex - 1, k)
	else:
		return quick_select(arr, pivotIndex + 1, right, k) 

# helper function to quick select algo
func qs_partition(arr, left, right, pivotIndex):
	var pivotValue = arr[pivotIndex]
	swap(arr, pivotIndex, right)
	var storeIndex = left
	
	for i in right - left - 1:
		if arr[i] < pivotValue:
			swap(arr, i, storeIndex)
			storeIndex += 1
	swap(arr, right, storeIndex)
	return storeIndex

# swap two elements based on index
func swap(arr, idx1, idx2):
	var temp = arr[idx2]
	arr[idx2] = arr[idx1]
	arr[idx2] = temp
	

# moves node between nodes
func move_node(node, old_node, new_node): 
	old_node.remove_child(node) 
	new_node.add_child(node)

# send points to each player's UI
func send_points_to_players():
	for player in players_points:
		Global.emit_signal("player_points_sig", player, players_points[player])

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
func dpr():
	if players_number <= 5:
		return [5, 3, 2]
	return [7, 5, 3]

# not needed
func add_back_to_deck(card):
	flip_card_to_back(card)
	card.global_position = deck.global_position
	card.rotation = 0
	deck.add_child(card)

func sum(array):
	var s = 0
	for element in array:
		s += element
	return s
