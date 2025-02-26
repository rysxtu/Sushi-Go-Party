extends Node

var viewport_size
var players_number = 1
var states = {}
var cards = {}
var cards_loaded = {}

# how many cards there are of each type
var cards_no = {
	"nigiri_1": 4, "nigiri_2": 5, "nigiri_3": 3, "maki_1": 4, "maki_2": 5, "maki_3": 3, "temaki": 12, "uramaki_3": 4, "uramaki_4": 5, "uramaki_5": 3,
	"tempura": 8, "sashimi": 8, "dumplings": 8, "eel": 8, "tofu": 8, "onigiri_1": 2, "onigiri_2": 2, "onigiri_3": 2, "onigiri_4": 2, "edamame": 8, "miso_soup": 8,
	"chopsticks": 3, "soy_sauce": 3, "tea": 3, "menu": 3, "spoon": 3, "special_order": 3, "takeout_box": 3, "wasabi": 3, 
	"pudding": 15, "green_tea_ice_cream": 15, "fruit_ww": 2, "fruit_wp": 3, "fruit_wt": 3, "fruit_tt": 2, "fruit_pp": 2, "fruit_pt": 3
	}

"""POINTS"""
# most, least
var maki_points = [6, 3]
var temaki_points = [4, -4]

var uramaki_curr_points = 2
const uramaki_points = [2, 5, 8]
const dumplings_points = [1, 3, 6, 10, 15]
const fruits_points = [-2, 0, 1, 3, 6, 10]

signal player_has_hand(player)
signal disconnect_hand_from_player(player)
signal allowed_to_play()
