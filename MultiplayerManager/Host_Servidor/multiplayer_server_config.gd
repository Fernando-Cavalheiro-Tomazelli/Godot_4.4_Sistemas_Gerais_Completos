extends Node

var porta_servidor = 2828
var max_clientes = 4

var servidor_principal = null

var lista_jogadores_servidor = {} # {id: {"name_jogador": string, "ref_char": Node3D}}}) 

func criar_servidor(nome_jogador):
	
	var peer = ENetMultiplayerPeer.new() #Novo peer criado
	var server_on = peer.create_server(porta_servidor, max_clientes) #Criando servidor com o peer criado
	
	if server_on != OK:
		print("Erro ao criar o servidor!")
		return
		
	print("Servidor criado com sucesso na porta: ", porta_servidor, " !")

	multiplayer.multiplayer_peer = peer #Peer adicionado na API(rede).
	
	add_peer_na_lista_do_servidor(multiplayer.get_unique_id(), nome_jogador)
	multiplayer.peer_connected.connect(jogador_conectado)
	multiplayer.peer_disconnected.connect(jogador_desconectado)

	# O host se adiciona corretamente para todos
	#_spawn_player(multiplayer.get_unique_id())
	
func jogador_conectado(peer_id):
	print("Sinal quando jogador conecta")
	get_tree().find_child("GerenciadorDeJogo").quando_jogador_conecta(peer_id)


func jogador_desconectado(peer_id):
	pass
	
#Adiciona todos os players na lista somente do servidor, junto com ID e nome	
func add_peer_na_lista_do_servidor(peer_id, nome_jogador):
	if peer_id in lista_jogadores_servidor: #Se o peer já estiver na lista, retorna.
		return 
	lista_jogadores_servidor[peer_id] = nome_jogador #Adiciona ID do peer como índice e nome como atributo.
	print("players na lista", lista_jogadores_servidor)
