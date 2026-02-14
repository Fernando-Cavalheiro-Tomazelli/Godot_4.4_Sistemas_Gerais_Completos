extends Node

var personagem : String = "res://Sistemas/Players/Player3D.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func criar_jogador(peer_id : int, local : Vector3):
	var cena_player = load(personagem)
	var player = cena_player.instantiate()
	 #Criando uma instancia do player.
	player.name = str(peer_id) #Nomeando o objeto personagem com o ID de multipalyer.
	player.set_multiplayer_authority(peer_id) #Definindo autoridade do player com o ID dele.
	get_tree().root.add_child(player)
	player.global_transform.origin = local  #Vector3(randf_range(-5, 5), randf_range(1, 5), randf_range(-5, 5))
