extends Control

var cena_menu_jogar = preload("res://Menus/Menu Inicial/menu_inicial_jogar.tscn")



func _on_jogar_pressed() -> void:
	var cena = cena_menu_jogar.instantiate()
	get_tree().change_scene_to_packed(cena_menu_jogar)
