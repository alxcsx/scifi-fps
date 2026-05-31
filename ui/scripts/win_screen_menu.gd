extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://maps/scenes/intro_scene_definitive_real.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/scenes/MainMenu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()














