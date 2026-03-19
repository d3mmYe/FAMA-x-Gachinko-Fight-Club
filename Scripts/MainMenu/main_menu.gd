extends Control

func _onStartPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _onDeckEditorPressed() -> void:
	pass

func _onOptionsPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _onQuitPressed() -> void:
	get_tree().quit()
