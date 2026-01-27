extends Control

@export var menu_options: MarginContainer
@export var menu_config_in_game: Control
@export var menu_select_mapas: Control



func _ready() -> void:
	menu_config_in_game.hide()
	
	
	
#func _unhandled_key_input(event: InputEvent) -> void:
			#if Input.is_action_just_pressed("ui_cancel") :
				#if self.visible == true and menu_options.visible == false and menu_config_in_game.visible == true:
					#menu_options.show()
					#menu_config_in_game.hide()
				#else:
					#self.visible = !self.visible


	


func _on_quit_game_button_pressed() -> void:
	get_tree().quit() #Sai do jogo


func _on_config_button_pressed() -> void:
	menu_config_in_game.show()
	menu_options.hide()


func _on_draw() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_tree_exited() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
