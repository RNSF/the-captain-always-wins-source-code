extends Node


var scene_id : int = MAIN_SCENE :
	set(new_value):
		scene_id = new_value % SCENE_COUNT



enum { # Define level enum here
	DITHER_TEST,
	MOVEMENT_TEST,
	DICE_GAME,
	GAME_ROOM,
	MAIN_SCENE,
	SCENE_COUNT, # not an actual scene
}

const SCENES = { # Add scene paths here
	DITHER_TEST: "res://scenes/test/dither_test.tscn",
	MOVEMENT_TEST: "res://scenes/test/movement_test.tscn",
	DICE_GAME: "res://scenes/dice_game.tscn",
	GAME_ROOM: "res://scenes/game_room.tscn",
	MAIN_SCENE: "res://scenes/main.tscn",
}

func _ready() -> void:
	for id: int in SCENE_COUNT:
		assert(SCENES.has(id), "Missing scene path for " + str(id))
		var scene_path : String = SCENES[id]
		assert(ResourceLoader.exists(scene_path), "Scene does not exist at path " + scene_path)


func goto_current_scene() -> void:
	goto_scene(scene_id)


func goto_next_scene() -> void:
	goto_scene(scene_id + 1)

func goto_previous_scene() -> void:
	goto_scene(scene_id - 1)


func goto_scene(new_scene_id: int) -> void:
	scene_id = new_scene_id
	execute_scene_change()


func execute_scene_change() -> void:
	var scene_path : String = SCENES[(scene_id + SCENE_COUNT) % SCENE_COUNT]
	var error := get_tree().change_scene_to_packed(load(scene_path))
	assert(not error, "Failed to load scene: " + str(error))


func goto_start_scene() -> void:
	goto_current_scene()
