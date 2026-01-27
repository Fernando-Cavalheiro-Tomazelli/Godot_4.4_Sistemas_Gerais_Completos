extends StaticBody3D

@export var causar_dano_continuo_base : AreaDanoContinuoBase
var causar_dano_continuo : AreaDanoContinuoBase

func _ready():
	# Duplicar uma vez só, garantindo que cada fogueira tenha sua própria lógica
	causar_dano_continuo = causar_dano_continuo_base.duplicate()

func _process(delta):
	causar_dano_continuo.tick_efeito(delta)




func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area, "Colidiu com o dano")
	causar_dano_continuo.iniciar_dano_continuo(area)


func _on_area_3d_area_exited(area: Area3D) -> void:
	causar_dano_continuo.terminar_dano_continuo(area)
