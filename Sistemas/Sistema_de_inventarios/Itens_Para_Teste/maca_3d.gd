extends StaticBody3D

@export var item : ItemBase




func _on_area_3d_body_entered(alvo: Node3D) -> void:
	if not "inventario" in alvo:
		return
	if alvo.inventario.adicionar_item_inventario(item):
		self.queue_free()
	else:
		print("Sem espaço no inventário")
