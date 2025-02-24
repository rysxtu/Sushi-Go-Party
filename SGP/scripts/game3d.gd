extends Node3D

const CARD = preload("res://scenes/card3D/cards/chopsticks.tscn")

func _ready():
	add_5_cards()

func add_5_cards()->void:
	for _x in 5:
		var card = CARD.instantiate()
		print(card)
		add_child(card)
