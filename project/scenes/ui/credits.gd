extends Control




func play() -> void:
	GameMaster.ambience.is_enabled = false
	$AnimationPlayer.play("credits")


func _on_liars_dice_physical_ready_for_credits() -> void:
	play()




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().quit()
