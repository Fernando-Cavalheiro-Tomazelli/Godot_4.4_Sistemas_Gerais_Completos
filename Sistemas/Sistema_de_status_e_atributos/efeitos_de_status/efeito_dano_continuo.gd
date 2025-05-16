extends StaticBody3D
@export var dano_continuo : DanoContinuoBase

func _on_area_3d_body_entered(alvo: Node3D) -> void:
	var dano = dano_continuo.duplicate()
	dano.aplicar_efeito(alvo)
	
func _process(delta: float) -> void:
	dano_continuo.tick(delta)
