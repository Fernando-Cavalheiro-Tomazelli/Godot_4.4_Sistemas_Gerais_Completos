extends StaticBody3D
@export var dano_direto : AplicarDanoUnicoBase

func _on_area_3d_body_entered(alvo: Node3D) -> void:
	var dano = dano_direto.duplicate()
	dano.aplicar_efeito(alvo)
	
	

	
	
