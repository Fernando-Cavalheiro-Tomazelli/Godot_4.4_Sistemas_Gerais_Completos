extends StaticBody3D
@export var curar : AplicarCuraUnicaBase


#func _on_area_3d_body_entered(alvo: Node3D) -> void:
	#var cura = curar.duplicate()
	#cura.aplicar_efeito(alvo)
	


func _on_area_3d_area_entered(alvo: Area3D) -> void:
	var alvo_final = alvo.get_parent()
	print("Entrando na área3d, OBJETO = ", alvo_final)
	var cura = curar.duplicate()
	cura.aplicar_efeito(alvo_final)
