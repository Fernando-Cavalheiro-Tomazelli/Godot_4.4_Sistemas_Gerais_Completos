extends Resource
class_name CriarSlotsVisuaisInventario

var slot_visual = preload("res://Sistemas/Sistema_de_inventarios/slots_inventario_itens_recursos/slot_item_visual.tscn")
	

func iniciar_inventario_visual_(inventario_logico : Array[SlotItemBase], local_inventario : Control):
	#limpar slots visuais caso existam
	for slot in local_inventario.get_children():
		slot.queue_free()
	
	#adicionando novos slots
	for index in range(inventario_logico.size()):
		var slot_atual = inventario_logico[index]
		var novo_slot = slot_visual.instantiate()
		
		novo_slot.slot_logico = slot_atual #adiciona o numero de index da array logica para o slot visual
		local_inventario.add_child(novo_slot)
	print("foi iniciado inventario visual de : ")
	
