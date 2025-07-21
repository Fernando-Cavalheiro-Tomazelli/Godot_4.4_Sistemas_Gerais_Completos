extends Node




func criar_cliente_multiplayer(ip, porta : int):
	var peer = ENetMultiplayerPeer.new() #Cria o peer
	var peer_on = peer.create_client(ip, porta) #Cria um cliente multiplayer usando o peer.
	if peer_on != OK: #Verifica se o cliente foi criado com sucesso
		print("Erro ao criar cliente!")
		return
	print("Cliente conectado ao servidor:", ip)
	
	multiplayer.multiplayer_peer = peer #Adiciona o peer na rede padrão multiplayer.
	multiplayer.connection_failed.connect(falha_na_conexao)
	
func falha_na_conexao():
	print("Conexão com o servidor falhou!")
