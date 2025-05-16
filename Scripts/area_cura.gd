extends StaticBody3D
@export var curar : AplicarCuraUnicaBase


func _on_area_3d_body_entered(alvo: Node3D) -> void:
	var cura = curar.duplicate()
	cura.aplicar_efeito(alvo)
	
