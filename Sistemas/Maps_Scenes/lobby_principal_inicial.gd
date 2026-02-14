extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerManager.criar_jogador(multiplayer.get_unique_id(), Vector3(3, 4, 3))
