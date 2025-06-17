extends Node

func _on_botao_facil_pressed():
	Globals.dificuldade = "facil"
	get_tree().change_scene_to_file("res://Scenes/tilemap.tscn")

func _on_botao_medio_pressed():
	Globals.dificuldade = "medio"
	get_tree().change_scene_to_file("res://Scenes/tilemap.tscn")

func _on_botao_dificil_pressed():
	Globals.dificuldade = "dificil"
	get_tree().change_scene_to_file("res://Scenes/tilemap.tscn")

func _on_botao_voltar_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
