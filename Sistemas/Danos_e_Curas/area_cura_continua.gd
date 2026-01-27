extends StaticBody3D

@export var aplicar_cura_continua_base : AreaCuraContinuaBase
var aplicar_cura_continua: AreaCuraContinuaBase

func _ready():
	# Duplicar uma vez só, garantindo que cada fogueira tenha sua própria lógica
	aplicar_cura_continua = aplicar_cura_continua_base.duplicate()


func _process(delta):
	aplicar_cura_continua.tick_efeito(delta)


func _on_area_3d_body_entered(alvo: Node3D) -> void:
	aplicar_cura_continua.iniciar_dano_continuo(alvo)


func _on_area_3d_body_exited(alvo: Node3D) -> void:
	aplicar_cura_continua.terminar_dano_continuo(alvo)
