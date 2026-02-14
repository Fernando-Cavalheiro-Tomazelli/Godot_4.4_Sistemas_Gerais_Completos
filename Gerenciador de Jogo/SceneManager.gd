extends Node

var tela_load = preload("res://Gerenciador de Jogo/tela_loading.tscn")
var loading_ativo = null

var lista_de_cenas = { "lobby_principal" : "res://Sistemas/Maps_Scenes/lobby_principal_inicial.tscn",
"inventario_teste" : "res://Sistemas/Maps_Scenes/cena_inventario_teste.tscn" }

	
func start_loading():
	var loading = tela_load.instantiate()
	loading_ativo = loading
	get_tree().root.add_child(loading)
	pass
	
func stop_loading():
	await get_tree().create_timer(2.0).timeout
	loading_ativo.queue_free()
	loading_ativo = null
	pass

		
func carregar_cena(cena_id: String) -> PackedScene:
	if cena_id in lista_de_cenas:
		var caminho = lista_de_cenas[cena_id]
		var cena = load(caminho)
		print("Cena ", cena_id, " Carregada com sucesso!")
		get_tree().change_scene_to_packed(cena)
		return cena
	else:
		push_error("Cena não encontrada: " + cena_id)
		return null
