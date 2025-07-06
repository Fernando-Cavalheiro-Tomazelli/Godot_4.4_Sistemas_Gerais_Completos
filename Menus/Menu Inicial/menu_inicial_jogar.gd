extends Control

var cena_de_jogo = preload("res://Scenes/main.tscn")
	
func _on_novo_jogo_pressed() -> void:
	get_tree().change_scene_to_packed(cena_de_jogo)
