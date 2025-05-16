extends Resource
class_name CriarInventarioVisual

var slot_base = preload("res://Sistemas/Sistema_de_inventarios/slots_inventario_itens_recursos/slot_item_visual.tscn")

var inventario_visual = null
var inventario_visual_externo = null

var ref_inventario_logico = null
#var local_inventario  =  null

func set_referencia_inventario_logico(inventario_logico):
	ref_inventario_logico = inventario_logico
	
func set_referencia_inventario_visual(invent_visu):
	inventario_visual = invent_visu
	

func criar_inventario_visual(inventario_logico: Array[SlotItemBase], local_inventario):
	var inventario = GridContainer.new() # Criar novo GridContainer
	inventario.columns = 8
	inventario.name = "Grade_de_itens"
	set_referencia_inventario_visual(inventario)
	print("Local que era pra ser o certo do visual = ", local_inventario)
	local_inventario.add_child(inventario)
	iniciar_slots_visuais(inventario_logico)
	
	
func iniciar_slots_visuais(slot_itens: Array[SlotItemBase]) -> void:
	
	# Limpa os slots antigos, se houver
	for slot in inventario_visual.get_children():
		slot.queue_free()

	# Cria novos slots visuais com base no array de dados
	for slot_data in slot_itens:
		var slot_visual = slot_base.instantiate()
		slot_visual.index_slot_visual = slot_data.index_slot # Define o index do slot visual igual do slot_base.
		slot_visual.set_referencia_inventario_logico(ref_inventario_logico)
		inventario_visual.add_child(slot_visual)
		slot_visual.set_slot_data(slot_data)
		#print("Index do slot visual adicionado com sucesso através do slot_base= ", slot_visual.index_slot_visual)

	
func atualizar_slots_visuais(slot_itens: Array[SlotItemBase]) -> void:
	var slots_visuais = inventario_visual.get_children()
	for i in range(min(slots_visuais.size(), slot_itens.size())):
		slots_visuais[i].set_slot_data(slot_itens[i])
