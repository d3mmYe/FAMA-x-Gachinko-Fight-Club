extends Control

func _onBackPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
