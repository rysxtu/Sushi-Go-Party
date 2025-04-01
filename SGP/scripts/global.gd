extends Node

var viewport_size
var players_number = 1
var bots_number = 0
var states = {}
var cards = {}
# stores the scene of each card that we can play
var cards_loaded = {}
var hand_size = 0
var online
var icons = {}
var markers_mapping = {}

# how many cards there are of each type
var cards_no = {
	"nigiri_1": 4, "nigiri_2": 5, "nigiri_3": 3, "maki_1": 4, "maki_2": 5, "maki_3": 3, "temaki": 12, "uramaki_3": 4, "uramaki_4": 5, "uramaki_5": 3,
	"tempura": 8, "sashimi": 8, "dumplings": 8, "eel": 8, "tofu": 8, "onigiri_1": 2, "onigiri_2": 2, "onigiri_3": 2, "onigiri_4": 2, "edamame": 8, "miso_soup": 8,
	"chopsticks_1": 1, "chopsticks_2": 1, "chopsticks_3": 1, "soy_sauce": 3, "tea": 3, "menu_7": 1, "menu_8": 1, "menu_9": 1, "spoon_4": 1, "spoon_5": 1, "spoon_6": 1, "special_order": 3, "takeout_box_10": 1, "takeout_box_11": 1, "takeout_box_12": 1, "wasabi": 3, 
	"pudding": 15, "green_tea_ice_cream": 15, "fruit_ww": 2, "fruit_wp": 3, "fruit_wt": 3, "fruit_tt": 2, "fruit_pp": 2, "fruit_pt": 3
	}

"""POINTS"""
# most, least
var maki_points = [6, 3]

var uramaki_curr_points = 2
const uramaki_points = [2, 5, 8]
const dumplings_points = [1, 3, 6, 10, 15]
const fruits_points = [-2, 0, 1, 3, 6, 10]
const onigiri_points = [1, 4, 9, 16]

# signals players when they have their hands and can play
signal player_has_hand_sig(player)
# signal for a player to have thier points displayed (redundant?)
signal player_points_sig(player, points)
# signal to icon_manager and counter that round is over, and player
signal round_over()
# signal to icon_manager and counter that turn is over, and player
signal turn_over()
# signal to disconnect a hand from a player
signal disconnect_hand_from_player(player)
# signal for all players to be able to play
signal allowed_to_play()
# signal for a players to be able to play again (chopsticks), need order
signal player_allowed_to_play(player, type, card_order)
# tell all players that game has started
signal game_started_sig()
# to display the played card in icons (should be received by icons)
signal display_card_icon(player, card, extra_info)

# signal to allow players to have special options, e.g chopsticks, spoon
signal display_special_option(player, card_order, type)

# signal to record chopsticks being played
signal chopsticks_played(player, card_order, played)

# signal to allow player to take takeout box actions
signal takeout_box(player)
# get rid of the zeros that wasabi may have left sometimes
signal turn_over_card(player, card, zeros)
# rename nigiri's with wasabi when the wasabi is tunred over
signal rename_nigiri_wasabi_icons_tb(player, wasabi_number)
# rename wasabi when they are played to acount for any turned over ones
signal rename_wasabi_icons_tb(player)
# signal to highlight wasabi and nigiri icons together
signal highlight(icon_name, highlight)

# signal to allow players to look at 4 from dexk and choose 1
signal menu(player, menu_options)


"""STUFF FOR BOTS"""
# played_cards for search trees for bot algorithms
var player_played_cards = {}

# difficulties of bots
var bot_difficulties = {}
