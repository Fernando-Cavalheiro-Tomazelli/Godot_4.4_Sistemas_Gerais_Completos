extends StaticBody3D

@export var causar_dano_continuo_base : AreaDanoContinuoBase
var causar_dano_continuo : AreaDanoContinuoBase

func _ready():
	# Duplicar uma vez só, garantindo que cada fogueira tenha sua própria lógica
	causar_dano_continuo = causar_dano_continuo_base.duplicate()

func _process(delta):
	causar_dano_continuo.tick_efeito(delta)

func _on_area_3d_body_entered(alvo: Node3D) -> void:
	causar_dano_continuo.iniciar_dano_continuo(alvo)

func _on_area_3d_body_exited(alvo: Node3D) -> void:
	causar_dano_continuo.terminar_dano_continuo(alvo)
