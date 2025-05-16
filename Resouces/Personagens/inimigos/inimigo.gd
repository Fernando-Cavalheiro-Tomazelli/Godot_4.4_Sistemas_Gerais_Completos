extends CharacterBody3D

@export var player_status : BaseStatus

@export var barra_vida_flutuante : Node3D

func _ready() -> void:
	player_status.inicializar_status()

func _process(delta: float) -> void:
	player_status.tick_efeitos(delta)
	atualizar_barra_vida_flutuante(delta)



func atualizar_barra_vida_flutuante(delta):
	barra_vida_flutuante.get_node("SubViewport/MarginContainer/ProgressBar").value = player_status.vida_atual
	barra_vida_flutuante.get_node("SubViewport/MarginContainer/ProgressBar").max_value = player_status.vida_max
