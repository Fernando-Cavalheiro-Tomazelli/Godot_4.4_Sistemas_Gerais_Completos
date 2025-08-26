extends Node
class_name InventarioBase

@export var tamanho_inventario = 8
@export var dono_do_inventario = "Desconhecido"

var inventario_logico : Array[SlotItemBase]


func _ready() -> void:
	iniciar_inventario()

func iniciar_inventario():
	if tamanho_inventario > 0:
		inventario_logico.resize(tamanho_inventario)
		for index in range(tamanho_inventario):
			var slot_item = SlotItemBase.new()
			slot_item.index_do_slot = index
			inventario_logico[index] = slot_item
		
	print("Foi iniciado inventario lógico de ", dono_do_inventario, " com ",tamanho_inventario, " slots." )

func expandir_inventario(quantidade : int) -> void:
	tamanho_inventario = tamanho_inventario + quantidade
	inventario_logico.resize(tamanho_inventario)
	print("O tamanho do seu inventário agora é de: ", tamanho_inventario)
	
	var tamanho_atual = tamanho_inventario - quantidade  # Ajusta para o tamanho antes da expansão
	for i in range(tamanho_atual, tamanho_inventario):
		var slot_item = SlotItemBase.new()
		slot_item.index_do_slot = i
		inventario_logico[i] = slot_item
	self.find_parent("Player3D").find_child("InventarioVisual").iniciar_inventario_visual(inventario_logico)
		
func adicionar_item_ao_inventario(item_recebido: ItemBase, quantidade: int) -> bool:
	if inventario_logico == null or inventario_logico.size() <= 0:
		return false
		
	var itens_sobrando = 0
	
	for index in range(inventario_logico.size()):
		var slot = inventario_logico[index]
		# Verifica se o slot tem o mesmo item e é empilhável
		if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item_recebido.item_id and slot.espaco_livre_na_pilha > 0:
			if quantidade <= slot.espaco_livre_na_pilha:
				slot.somar_quantia_na_pilha(item_recebido, quantidade)
				return true
			else:
				itens_sobrando = quantidade - slot.espaco_livre_na_pilha
				slot.somar_quantia_na_pilha(item_recebido, slot.espaco_livre_na_pilha)
				break
		elif slot.item_atual_do_slot == null:
			slot.espaco_livre_na_pilha = item_recebido.maximo_por_pilha
			if quantidade <= slot.espaco_livre_na_pilha:
				slot.adicionar_item_ao_slot(item_recebido, quantidade)
				return true
			else:
				itens_sobrando = quantidade - item_recebido.maximo_por_pilha
				slot.adicionar_item_ao_slot(item_recebido, item_recebido.maximo_por_pilha)
				break
				
	while itens_sobrando > 0:
		var espaço_encontrado = false
		for index in range(inventario_logico.size()):
			var slot = inventario_logico[index]
			# Verifica se o slot tem o mesmo item e é empilhável
			if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item_recebido.item_id and slot.espaco_livre_na_pilha > 0:
				if itens_sobrando <= slot.espaco_livre_na_pilha:
					slot.somar_item_na_pilha(item_recebido, itens_sobrando)
					itens_sobrando = 0  # Zera para sair do while
					return true
				else:
					itens_sobrando = itens_sobrando - slot.espaco_livre_na_pilha
					slot.somar_item_na_pilha(item_recebido, slot.espaco_livre_na_pilha)
					espaço_encontrado = true
			
			elif slot.item_atual_do_slot == null:
				slot.espaco_livre_na_pilha = item_recebido.maximo_por_pilha
				if itens_sobrando <= slot.espaco_livre_na_pilha:
					slot.adicionar_item_ao_slot(item_recebido, itens_sobrando)
					itens_sobrando = 0  # Zera para sair do while
					return true
				else:
					itens_sobrando = itens_sobrando - slot.espaco_livre_na_pilha
					slot.adicionar_item_ao_slot(item_recebido, slot.espaco_livre_na_pilha)
		
					espaço_encontrado = true
		
		if not espaço_encontrado:  # Se nenhum espaço foi encontrado, sai do while
			break
	
	if itens_sobrando > 0:
		dropar_item_no_chao(item_recebido, itens_sobrando)
		return true
	else:
		return false
	
	return true
	
func remover_item_inventario(item: ItemBase, quantidade: int) -> bool: #Tentar modificar aqui passar direto o index.
	if inventario_logico and inventario_logico.size() <= 0:
		return false

	var itens_faltando = 0
	
	for index in range(inventario_logico.size()):
		var slot = inventario_logico[index]
		# Verifica se o slot tem o mesmo item e é empilhável
		if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item.item_id:
			if quantidade == slot.quantidade_atual_no_slot:
				slot.remover_item_do_slot()
				return true
			elif quantidade < slot.quantidade_atual_no_slot:
				slot.subtrair_quantia_da_pilha(quantidade)
				return true
			else:
				itens_faltando = quantidade - slot.quantidade_atual_no_slot
				slot.remover_item_do_slot()
				break
				
			
	while itens_faltando > 0:
		var item_encontrado = false
		for index in range(inventario_logico.size()):
			var slot = inventario_logico[index]
			# Verifica se o slot tem o mesmo item e é empilhável
			if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item.item_id:
				if itens_faltando == slot.quantidade_atual_no_slot:
					slot.remover_item_do_slot()
					return true
				elif itens_faltando < slot.quantidade_atual_no_slot:
					slot.subtrair_quantia_da_pilha(itens_faltando)
					return true
				else:
					itens_faltando = itens_faltando - slot.item_atual_do_slot.maximo_por_pilha
					slot.remover_item_do_slot()
					item_encontrado = true
		
		if not item_encontrado:  # Se nenhum espaço foi encontrado, sai do while
			break
	
	return true
		
func dropar_item_no_chao(item: ItemBase, quantidade: int):
	print("Inventário cheio dropando ", quantidade, " de ", item.nome_item, " no chão.")
