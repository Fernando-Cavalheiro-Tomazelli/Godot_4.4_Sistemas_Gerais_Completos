extends StaticBody3D

@export var buff_hp : BuffHpBase

func _on_area_3d_body_entered(alvo: Node3D) -> void:
	var buff = buff_hp.duplicate()
	buff.aplicar_efeito(alvo)
	
