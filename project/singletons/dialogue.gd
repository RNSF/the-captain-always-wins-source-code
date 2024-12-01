extends Node

signal display_changed

const MAX_OPTIONS = 3

var display : DialogueDisplay :
	set(new_value):
		if new_value == display: return
		var old_value = display
		display = new_value
		display.clear_options()
		display.clear_speach()
		if LiarsDice.physical: LiarsDice.physical.update_betting_lock()

enum Actor {
	CAPTAIN,
	PIRATE_LEFT,
	PIRATE_RIGHT,
	COUNT,
}
var is_betting_locked := false : 
	set(new_value):
		if is_betting_locked == new_value: return
		is_betting_locked = new_value
		if LiarsDice.physical: LiarsDice.physical.update_betting_lock()


var timeline_dialogue_tracker : Array = ArrayUtils.filled(DialogueInstance.Id.size(), false) # only in this timeline


func can_bet() -> bool:
	return not is_betting_locked and (not display or not display.is_someone_speaking)


func is_completed(id: DialogueInstance.Id) -> bool:
	return timeline_dialogue_tracker[id]

func mark_completed(id: DialogueInstance.Id) -> void:
	timeline_dialogue_tracker[id] = true

func reset() -> void:
	timeline_dialogue_tracker.fill(false)


func _process(delta: float) -> void:
	if Debug.is_just_pressed(&"test_0"):
		var instance : DialogueInstance
		instance = play(DialogueInstance.Id.CAPTAIN_NOW)
		await instance.finished
		instance = play(DialogueInstance.Id.TEST_2)
		await instance.finished


func play(dialogue_id: DialogueInstance.Id, args := {}) -> DialogueInstance:
	var instance := DialogueInstance.new(dialogue_id, display, args)
	instance.play()
	return instance


func get_actor_name(actor : Actor) -> String:
	assert(actor < Actor.COUNT)
	match actor:
		Actor.CAPTAIN: 			return "Captain"
		Actor.PIRATE_LEFT: 		return "Roberts" if Progress.know_pirate_name else "???"
		Actor.PIRATE_RIGHT: 	return "Shaw" if Progress.know_navy_name else "???"
	
	return "Unknown"


func get_die_face_string(face: int, plural := false) -> String:
	assert(face >= 1 and face <= 6)
	match face:
		1:	return "ones" if plural else "one"
		2:	return "twos" if plural else "two"
		3:	return "threes" if plural else "three"
		4:	return "fours" if plural else "four"
		5:	return "fives" if plural else "five"
		6:	return "sixes" if plural else "six"
	return ""


func get_bet_string(bet: LiarsDice.Round.Bet) -> String:
	return str(bet.amount) + " " + Dialogue.get_die_face_string(bet.value, bet.amount != 1)


func get_actor(player: LiarsDice.Player) -> Actor:
	match player:
		LiarsDice.Player.CAPTAIN: return Actor.CAPTAIN
		LiarsDice.Player.PIRATE_RIGHT: return Actor.PIRATE_RIGHT
		LiarsDice.Player.PIRATE_LEFT: return Actor.PIRATE_LEFT
	assert(false)
	return Actor.CAPTAIN


func get_liars_dice_player(actor: Actor) -> LiarsDice.Player:
	match actor:
		Actor.CAPTAIN: return LiarsDice.Player.CAPTAIN
		Actor.PIRATE_RIGHT: return LiarsDice.Player.PIRATE_RIGHT
		Actor.PIRATE_LEFT: return LiarsDice.Player.PIRATE_LEFT
	assert(false)
	return LiarsDice.Player.CAPTAIN
