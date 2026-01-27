extends StaticBody3D

@export var item_coletavel : ColetavelInventario

func _on_area_3d_area_entered(area: Area3D) -> void:
	item_coletavel.adicionar_ao_inventario(area.get_parent())
