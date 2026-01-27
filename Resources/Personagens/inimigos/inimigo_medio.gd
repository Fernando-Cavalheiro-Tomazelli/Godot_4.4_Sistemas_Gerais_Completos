extends CharacterBody3D

@export var player_status : BaseStatus

func _ready() -> void:
	player_status.inicializar_status()

func _process(delta: float) -> void:
	player_status.tick_interno(delta)
	morrer()

func morrer():
	if player_status.vida_atual <= 0.0:
		self.queue_free()
