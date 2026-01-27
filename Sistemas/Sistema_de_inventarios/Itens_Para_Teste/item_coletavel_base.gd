extends StaticBody3D

@export var item_slot : SlotItemBase



func _ready() -> void:
	if item_slot and item_slot.item_atual_do_slot and item_slot.item_atual_do_slot.caminho_cena_item_3d:
		
		var item3d = load(item_slot.item_atual_do_slot.caminho_cena_item_3d)
		var item = item3d.instantiate()
		self.add_child(item)
		
	else:
		print("Item coletável: ", item_slot.item_atual_do_slot.nome_item, " não tem caminho de cena 3D")

func adicionar_ao_inventario(alvo):
	var inventario = alvo.find_child("ComponentManager").Inventario
	if inventario.adicionar_item_ao_inventario(item_slot.item_atual_do_slot, item_slot.quantidade_atual_no_slot):
		self.queue_free()
	else:
		print("Inventário cheio, não é possível coletar o item ", item_slot.item_atual_do_slot.nome_item)


func _on_area_3d_area_entered(area: Area3D) -> void:
	adicionar_ao_inventario(area.get_parent())
