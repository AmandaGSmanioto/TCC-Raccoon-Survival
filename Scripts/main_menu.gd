extends Node

func _on_iniciar_pressed():
	get_tree().change_scene_to_file("res://Scenes/select_difficulty.tscn")

func _on_sair_pressed():
	get_tree().quit()

