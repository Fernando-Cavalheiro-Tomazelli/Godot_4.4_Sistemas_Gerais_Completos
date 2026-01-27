extends StaticBody3D
@export var dano_direto : AplicarDanoUnicoBase

#func _on_area_3d_body_entered(alvo: Node3D) -> void:
	#var dano = dano_direto.duplicate()
	#dano.aplicar_efeito(alvo)
	
	
func _on_area_3d_area_entered(area: Area3D) -> void:
	var player = area.get_parent()
	var dano = dano_direto.duplicate()
	dano.aplicar_efeito(player)
