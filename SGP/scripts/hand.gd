extends Node3D

@onready var hand = $"."
@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve
const HAND_WIDTH = 2

const CARD = preload("res://scenes/card3D/cards/chopsticks.tscn")
var camera
var dest
var player_hand = []

func _ready():
	camera = get_viewport().get_camera_3d()
	dest = hand.global_transform

func add_card()->void:
	var card = CARD.instantiate()
	player_hand.append(card)
	card.name = "card" + str(player_hand.find(card))
	add_child(card)
	position_cards()
	

func pop_card()->void:
	if player_hand:
		var card = player_hand.pop_back()
		remove_child(card)
		card.queue_free()
		position_cards()

func remove_card(card)->void:
	remove_child(card)
	player_hand.erase(card)
	card.queue_free()

func card_ratio(card):
	var hand_ratio = 0.5
		
	if player_hand.size() > 1:
		hand_ratio = float(player_hand.find(card)) / float(player_hand.size() - 1)
	return hand_ratio

func position_cards():
	for card in player_hand:
		position_card(card, card_ratio(card), dest, camera)
	
func position_card(card, hand_ratio, dest, camera):
	var dest_c = dest
	dest_c.basis = camera.global_transform.basis
	dest.origin = camera.global_transform.origin
	dest_c.origin.x += spread_curve.sample(hand_ratio) * HAND_WIDTH
	dest_c.origin.y += height_curve.sample(hand_ratio)
	dest_c.origin.z += hand_ratio * 0.1
	dest_c.basis = dest_c.basis.rotated(Vector3(0, 0, 1), 0.3 * rotation_curve.sample(hand_ratio))
	
	card.global_transform = dest_c
	
func _process(delta):
	pass


func _on_button_pressed():
	add_card()
	print(player_hand)

func _on_remove_pressed():
	pop_card()
	print(player_hand)
