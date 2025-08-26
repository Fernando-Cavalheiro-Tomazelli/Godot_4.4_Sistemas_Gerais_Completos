extends Node
class_name  ColetavelInventario

@export var item_slot : SlotItemBase


func adicionar_ao_inventario(alvo):
	var inventario = alvo.find_child("InventarioBase")
	if inventario.adicionar_item_ao_inventario(item_slot.item_atual_do_slot, item_slot.quantidade_atual_no_slot):
		self.get_parent().queue_free()
	else:
		print("Inventário cheio, não é possível coletar o item ", item_slot.item_atual_do_slot.nome_item)
