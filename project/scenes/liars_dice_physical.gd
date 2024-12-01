class_name LiarsDicePhysical
extends Node

signal interact_pressed
signal player_shot
signal navy_shot
signal cups_raised
signal ready_for_credits

@export var player_camera : PlayerCamera
@export var gui_panel : GuiPanel
@export var pirate_gun : Gun
@export var captain_gun : Gun
@export var captain_dailogue_point : Node3D
@export var pirate_left_dailogue_point : Node3D
@export var pirate_right_dailogue_point : Node3D
@export var die_spawning_particles : GPUParticles3D
@export var die_spawning_sound : AudioStreamPlayer
@onready var cups := get_tree().get_nodes_in_group(&"Cups")
@onready var player_models := get_tree().get_nodes_in_group(&"PlayerModels")
@onready var better : Better = gui_panel.better
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var dialogue_points := {
	Dialogue.Actor.CAPTAIN: captain_dailogue_point,
	Dialogue.Actor.PIRATE_LEFT: pirate_left_dailogue_point,
	Dialogue.Actor.PIRATE_RIGHT: pirate_right_dailogue_point,
}


var cups_and_dice_visible : bool = false :
	set(new_value):
		cups_and_dice_visible = new_value
		for cup: Cup in cups:
			cup.visible = cups_and_dice_visible and cup.player in LiarsDice.alive_players

var is_captain_gun_drawn : bool = false :
	set(new_value):
		is_captain_gun_drawn = new_value
		captain_gun.state = Gun.State.DRAWN if is_captain_gun_drawn else Gun.State.UNDRAWN

func _ready() -> void:
	assert(pirate_gun, "Missing gun!")
	assert(player_camera, "Missing player camera!")
	assert(better, "Missing better!")
	assert(captain_gun, "Missing captain's gun!")
	assert(captain_dailogue_point, "Missing dialogue point.")
	assert(pirate_left_dailogue_point, "Missing dialogue point.")
	assert(pirate_right_dailogue_point, "Missing dialogue point.")
	assert(die_spawning_sound)
	assert(die_spawning_particles)
	cups.sort_custom(func(a: Cup, b: Cup) -> bool: return a.player < b.player)
	player_models.sort_custom(func(a: PlayerModel, b: PlayerModel) -> bool: return a.player < b.player)
	player_models.insert(0, null)
	LiarsDice.physical = self
	update_alive_players()
	better.hide()
	update_betting_lock()
	reset()


func _process(delta: float) -> void:
	if Debug.is_just_pressed("test_2"):
		is_captain_gun_drawn = !is_captain_gun_drawn


func update_betting_lock() -> void:
	better.is_locked = (Dialogue.display and Dialogue.display.is_someone_speaking) or Dialogue.is_betting_locked


func reset() -> void:
	cups_and_dice_visible = false
	is_captain_gun_drawn = false


func _input(event: InputEvent):
	if event.is_action_pressed(&"interact") and GameMaster.player_in_world:
		interact_pressed.emit()


func start_game() -> void:
	Dialogue.is_betting_locked = false
	pirate_gun.can_pickup = false
	cups_and_dice_visible = true
	better.visible = false
	for cup: Cup in cups:
		cup.snap_to_state(Cup.State.AT_REVEAL)
		cup.target_state = Cup.State.AT_PLAYER
		cup.target_raised = false
		for die: Die in cup.dice.get_children():
			die.is_alive = true
	
	for model: PlayerModel in player_models:
		if is_instance_valid(model): model.turn_direction = 0
	
	die_spawning_sound.play()
	die_spawning_particles.emitting = true
	
	player_camera.transition_state(PlayerCamera.State.IN_GAME)


func get_player_bet(minimum_bet: LiarsDice.Round.Bet, maximum_bet: LiarsDice.Round.Bet) -> LiarsDice.Round.Bet:
	better.show()
	better.minimum_bet = minimum_bet
	better.maximum_bet = maximum_bet
	better.override_current_bet(minimum_bet)
	await better.bet_made
	var bet = better.current_bet.duplicate()
	better.hide()
	return bet


func reveal_dice() -> void:
	for cup: Cup in cups:
		cup.target_state = Cup.State.AT_REVEAL
		cup.target_raised = false
	player_camera.transition_state(PlayerCamera.State.AT_REVEAL)
	
	#await player_camera.state_transition_completed
	await get_tree().create_timer(0.2).timeout
	animation_player.stop()
	animation_player.play("drum_roll")
	await cups_raised
	await interact_pressed
	
	await kill_unwanted_dice()
	
	await interact_pressed
	
	player_camera.transition_state(PlayerCamera.State.IN_GAME)
	
	await player_camera.state_transition_completed


func kill_unwanted_dice() -> void:
	for cup: Cup in cups:
		for die: Die in cup.dice.get_children():
			if die.face != LiarsDice.round.current_bet.value:
				die.is_alive = false
				await get_tree().create_timer(0.05).timeout


func _lift_cups() -> void:
	for cup: Cup in cups:
		cup.target_raised = true
	cups_raised.emit()


func update_alive_players() -> void:
	for player: LiarsDice.Player in LiarsDice.Player.COUNT:
		if player == LiarsDice.Player.SELF:
			if not player in LiarsDice.alive_players:
				player_shot.emit()
				
		else:
			if player in LiarsDice.alive_players:
				player_models[player].alive = true
				cups[player].visible = true and cups_and_dice_visible
			else:
				player_models[player].alive = false
				cups[player].visible = false
	
	GameMaster.ambience.ambience_level = 5 - LiarsDice.alive_players.size()


func pirate_shoot() -> void:
	GameMaster.shake_camera(0.4)
	navy_shot.emit()


func pan_camera_to_pirate_gun() -> void:
	pirate_gun.can_pickup = true
	player_camera.pan_to_point(pirate_gun.global_position)

func pan_camera_to_npc(npc: Dialogue.Actor) -> void:
	player_camera.pan_to_point(dialogue_points[npc].global_position)


func play_credits() -> void:
	ready_for_credits.emit()


func pan_camera_to_cup() -> void:
	player_camera.pan_to_point(cups[LiarsDice.Player.SELF].global_position)
