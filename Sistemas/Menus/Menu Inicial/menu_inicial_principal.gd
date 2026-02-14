extends Control


@export var opcoes_menu_principal : PanelContainer
@export var menu_inicial_jogar : Control
@export var menu_lista_opcoes : PanelContainer
@export var menu_selecionar_jogo : MarginContainer
@export var nome_jogador : LineEdit
@export var ip_server : LineEdit
@export var porta_server : LineEdit	




func _ready() -> void:
	GameManager.menu_inicial_ativo = true
	opcoes_menu_principal.show()
	menu_inicial_jogar.hide()
	menu_lista_opcoes.hide()
	menu_selecionar_jogo.hide()
	


func _on_jogar_button_down() -> void:
	opcoes_menu_principal.hide()
	menu_inicial_jogar.show()
	menu_lista_opcoes.show()
	
func _on_quit_button_down() -> void:
	get_tree().quit()


func _on_novo_jogo_button_down() -> void:
	menu_lista_opcoes.hide()
	menu_selecionar_jogo.show()


func _on_iniciar_jogo_solo_button_down() -> void:
	MultiplayerServerConfig.criar_servidor(nome_jogador.text)
	GameManager.menu_inicial_ativo = false
	SceneManager.carregar_cena("lobby_principal")
	#get_tree().change_scene_to_packed(gerenciador_de_jogo)


func _on_multiplayer_button_down() -> void:
	MultiplayerClientConfig.criar_cliente_multiplayer(ip_server.text, int(porta_server.text))


func _on_draw() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_hidden() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_jogar_mouse_entered() -> void:
	pass # Replace with function body
