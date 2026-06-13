extends Node

var menu_in_game : PackedScene = preload("res://Sistemas/Menus/Menu in Game/menu_in_game.tscn")
var menu_ativo_in_game
var menu_inicial_ativo = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and menu_ativo_in_game == null and menu_inicial_ativo == false:
		var menu = menu_in_game.instantiate()
		menu_ativo_in_game = menu
		get_tree().root.add_child(menu)
	elif Input.is_action_just_pressed("ui_cancel") and menu_ativo_in_game != null:
		menu_ativo_in_game.queue_free()
		menu_ativo_in_game = null
	
	#função somente para testes.
