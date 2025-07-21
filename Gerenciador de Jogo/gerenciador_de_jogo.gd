extends Node

#Depois adicionar um recurso com lista de todos mapas!!!
var mapa_inicial = preload("res://Scenes/main.tscn")
var personagem = preload("res://Scenes/Player3D.tscn")

@export var tela_loading : Control
@export var local_instanciar_jogador : Node



func quando_jogador_conecta(peer_id):
	rpc("criar_adicionar_player", peer_id)



func _ready() -> void:
	tela_loading.show()
	iniciar_mapa_principal(mapa_inicial)
	if multiplayer.is_server():
		criar_adicionar_player(1)

#Carrega o mapa principal inicial do jogo.
func iniciar_mapa_principal(mapa : PackedScene):
	var iniciar_mapa = mapa.instantiate()
	
	self.find_child("Mapas").add_child(iniciar_mapa)
	
	tela_loading.hide() #tirar depoi ssomente testes!!!!
	
	
	
#Adiciona mapas extras, instancias, dugeons etc. ativas em paralelo.
func adicionar_mapa_paralelo(mapa : PackedScene):
	pass
	
#Troca o mapa deletando o atual e adicionando um novo.
func trocar_mapa_atual(mapa : PackedScene):
	pass

@rpc("any_peer", "call_remote")	
func criar_adicionar_player(peer_id):
	var player = personagem.instantiate() #Criando uma instancia do player.
	player.name = str(peer_id) #Nomeando o objeto personagem com o ID de multipalyer.
	player.set_multiplayer_authority(peer_id) #Definindo autoridade do player com o ID dele.
	local_instanciar_jogador.add_child(player)
	player.global_transform.origin = Vector3(randf_range(-5, 5), randf_range(1, 5), randf_range(-5, 5))
