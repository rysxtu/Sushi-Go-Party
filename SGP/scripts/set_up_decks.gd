extends Control

@export var custom: Button
@export var mfm: Button
@export var sg: Button
@export var ps: Button
@export var mm: Button
@export var pp: Button
@export var cc: Button
@export var bb: Button
@export var dft: Button
@export var menu_v_box_container: VBoxContainer
@export var custom_h_box_container: HBoxContainer
@export var Menu_select: TabContainer

@export var select_button: Button

var states = {"custom": 0, "mfm": 0, "sg": 0, "ps": 0, 
			  "mm": 0, "pp": 0, "cc": 0,
			  "bb": 0, "dft": 0}
			
var cards = {
			"nigiri": 0, "maki": 0, "temaki": 0, "uramaki": 0,
			"tempura": 0, "sashimi": 0, "dumplings": 0, "eel": 0, 
			"tofu": 0, "onigiri": 0, "edamame": 0, "miso_soup": 0,
			"chopsticks": 0, "soy_sauce": 0, "tea": 0, "menu": 0, 
			"spoon": 0, "special_order": 0, "takeout_box": 0, 
			"wasabi": 0, "pudding": 0, "green_tea_ice_cream": 0, 
			"fruit": 0
			}

var custom_states = {"1": 0, "2": 0, "3": 0, "4": 0, 
			  "5": 0, "6": 0, "7": 0,
			  "8": 0}

var no_selected = 1

# only allows one menu to be seleect at a time
func button_click(button_name, obj):
	if states[button_name] == 0:
		for state in states:
			states[state] = 0
		states[button_name] = 1
		
		for child in menu_v_box_container.get_children():
			if child != obj and child != null:
				if child is Button:
					child.button_pressed = false
					child.modulate = Color(.4, .4, .4, .7)
			elif child != null:
					child.modulate = Color(1, 1, 1)
		select_button.disabled = false
				
	elif  states[button_name] == 1:
		for state in states:
			states[state] = 0
		reset_select(menu_v_box_container)
	print(states)

# deselect the higlighted menu
func _input(event:InputEvent):
	if event is InputEventMouseButton:
		var e:InputEventMouseButton = event
		
		if e.button_mask == MOUSE_BUTTON_RIGHT and Menu_select.current_tab == 0:
			reset_select(menu_v_box_container)
		elif e.button_mask == MOUSE_BUTTON_RIGHT and Menu_select.current_tab == 1:
			reset_custom_select()

# move to the playing scene
func _on_select_button_pressed():
	Global.states = states
	cards_in_play()
	Global.cards = cards
	print(cards)
	print("switch scene")
	get_tree().change_scene_to_file("res://scenes/UI/lobby.tscn")
	

# identitfy what cards will be in the game
func cards_in_play():
	for preset in states:
		if states[preset] == 1:
			var deck_chosen
			if preset != "custom":
				deck_chosen = get_node(str(menu_v_box_container.get_path()) + "/" + str(preset))
				for card in deck_chosen.get_child(0).get_children():
					cards[card.get_name()] += 1
			else:
				deck_chosen = custom
				for card in deck_chosen.get_child(0).get_children():
					var name = card.texture.get_path().split("/")[-1].split(".")[0]
					cards[name] += 1
			

# reset the selection of a menu
func reset_select(v_box: VBoxContainer):
	for child in v_box.get_children():
		if child != null:
			if child is Button:
				child.button_pressed = false
				child.modulate = Color(1,1,1)
	select_button.disabled = true

# when changing tabs, ensure selection is redone
func _on_menu_select_tab_changed(tab):
	if tab == 1:
		for state in states:
			states[state] = 0
		states["custom"] = 1
		reset_select(menu_v_box_container)
	else:
		for state in states:
			states[state] = 0

func reset_custom_select():
	for card in custom.get_child(0).get_children():
		card.texture = null

# action when pressed
func _on_mfm_pressed():
	button_click("mfm", mfm)

func _on_sg_pressed():
	button_click("sg", sg)

func _on_ps_pressed():
	button_click("ps", ps)

func _on_mm_pressed():
	button_click("mm", mm)

func _on_pp_pressed():
	button_click("pp", pp)

func _on_cc_pressed():
	button_click("cc", cc)

func _on_bb_pressed():
	button_click("bb", bb)

func _on_dft_pressed():
	button_click("dft", dft)

func _on_custom_pressed():
	button_click("custom", custom)

func _on_card_1_has_texture():
	custom_states["1"] = 1
func _on_card_1_no_texture():
	custom_states["1"] = 0

func _on_card_2_has_texture():
	custom_states["2"] = 1
func _on_card_2_no_texture():
	custom_states["2"] = 0

func _on_card_3_has_texture():
	custom_states["3"] = 1
func _on_card_3_no_texture():
	custom_states["3"] = 0

func _on_card_4_has_texture():
	custom_states["4"] = 1
func _on_card_4_no_texture():
	custom_states["4"] = 0

func _on_card_5_has_texture():
	custom_states["5"] = 1
func _on_card_5_no_texture():
	custom_states["5"] = 0

func _on_card_6_has_texture():
	custom_states["6"] = 1
func _on_card_6_no_texture():
	custom_states["6"] = 0

func _on_card_7_has_texture():
	custom_states["7"] = 1
func _on_card_7_no_texture():
	custom_states["7"] = 0
	
func _on_card_8_has_texture():
	custom_states["8"] = 1
func _on_card_8_no_texture():
	custom_states["8"] = 0

func _process(delta):
	if Menu_select.current_tab == 1:
		var sum = 0
		for state in custom_states:
			sum += custom_states[state]
		
		if sum == 8:
			select_button.disabled = false


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/lobby.tscn")
	
