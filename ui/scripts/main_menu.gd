extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://maps/scenes/intro_scene_definitive_real.tscn")


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()














