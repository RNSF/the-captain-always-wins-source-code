class_name Better
extends Control


signal bet_made(bet: LiarsDice.Round.Bet)

@export var is_locked := false :
	set(new_value):
		is_locked = new_value
		place_bet_button.disabled = is_locked

@export var block_mouse_input := false:
	set(new_value):
		block_mouse_input = new_value
		if not is_node_ready(): await ready
		mouse_blocker.visible = block_mouse_input

@onready var die_count_incrementor : IncrementorUI = $HBoxContainer/DieCount/Incrementor
@onready var die_face_incrementor : IncrementorUI = $HBoxContainer/DieFace/Incrementor
@onready var die_count_label : Label = $HBoxContainer/DieCount/Label
@onready var die_face_texture_rect : DieTextureRect = $HBoxContainer/DieFace/DieTextureRect
@onready var place_bet_button : Button = $HBoxContainer/Button
@onready var mouse_blocker : Control = $MouseBlocker

@onready var bet_place_sound : AudioStreamPlayer = $Sounds/BetPlace


var minimum_bet : LiarsDice.Round.Bet = LiarsDice.Round.Bet.new(3, 4)
var maximum_bet : LiarsDice.Round.Bet = LiarsDice.Round.Bet.new(20, 6)
var current_bet : LiarsDice.Round.Bet = minimum_bet.duplicate()


func _ready() -> void:
	die_count_incrementor.value_changed.connect(_on_die_count_changed)
	die_face_incrementor.value_changed.connect(_on_die_face_changed)
	_update_current_bet()


func _on_die_count_changed(old_count: int, new_count: int) -> void:
	current_bet.amount = new_count
	_update_current_bet()


func _on_die_face_changed(old_face: int, new_face: int) -> void:
	current_bet.value = new_face
	_update_current_bet()


func _update_current_bet() -> void:
	die_count_incrementor.min_value = minimum_bet.amount if current_bet.value >= minimum_bet.value else minimum_bet.amount + 1
	die_face_incrementor.min_value = minimum_bet.value if current_bet.amount == minimum_bet.amount else 1
	die_count_incrementor.max_value = maximum_bet.amount
	die_face_incrementor.max_value = maximum_bet.value
	die_count_incrementor.value = current_bet.amount
	die_face_incrementor.value = current_bet.value
	assert(maximum_bet.value == LiarsDice.DIE_MAX)
	die_count_label.text = str(current_bet.amount) + "x"
	die_face_texture_rect.face = current_bet.value


func override_current_bet(new_bet: LiarsDice.Round.Bet) -> void:
	current_bet.amount = new_bet.amount
	current_bet.value = new_bet.value
	_update_current_bet()


func _on_button_pressed() -> void:
	bet_place_sound.play()
	bet_made.emit(current_bet)
