extends Resource
class_name InventarioBase

@export var tamanho_inventario = 8
@export var dono_do_inventario = "Desconhecido"

var inventario_logico : Array[SlotItemBase]
#caches

#Cache contendo slots totalmente vazios.
var cache_slots_vazios : PackedByteArray

#cache contendo slots já com itens que são estacáveis e possuem espaço.
var cache_slots_com_espaco : Dictionary

var slots_por_item_id: Dictionary

func iniciar_inventario():
	if tamanho_inventario > 0:
		inventario_logico.clear()
		inventario_logico.resize(tamanho_inventario)
		for index in range(tamanho_inventario):
			var slot_item = SlotItemBase.new()
			slot_item.index_do_slot = index
			inventario_logico[index] = slot_item
			cache_slots_vazios.append(index)#Inicia com todos os slots vazios no cache
		
	print("Foi iniciado inventario lógico de ", dono_do_inventario, " com ",tamanho_inventario, " slots." )
	print("O cache de slots vazios do inventario de ", dono_do_inventario, " é de ", cache_slots_vazios.size())

func expandir_inventario(quantidade : int) -> void:
	tamanho_inventario = tamanho_inventario + quantidade
	inventario_logico.resize(tamanho_inventario)
	print("O tamanho do seu inventário agora é de: ", tamanho_inventario)
	
	var tamanho_atual = tamanho_inventario - quantidade  # Ajusta para o tamanho antes da expansão
	for i in range(tamanho_atual, tamanho_inventario):
		var slot_item = SlotItemBase.new()
		slot_item.index_do_slot = i
		inventario_logico[i] = slot_item
	#self.find_parent("Player3D").find_child("InventarioVisual").iniciar_inventario_visual(inventario_logico)
		
func adicionar_item_ao_inventario(item_recebido: ItemBase, quantidade: int) -> bool:
	#se o inventário lógico não existir ou tamanho foi 0 ou menor retorna falso.	
	if inventario_logico == null or inventario_logico.size() <= 0:
		return false
	#se o cache de slots vazios e de slots com espaços estiverem vazios, não existem espaço, retorna falso.	
	if cache_slots_vazios.is_empty() and cache_slots_com_espaco.is_empty():
		print("O cache diz que o inventário está cheio")
		return false

	#Quantidade que resta a cada vez que adiciona em algum slot
	var quantidade_restante = quantidade

	# 1. Tenta empilhar em slots existentes do mesmo item (somente se empilhável)
	if item_recebido.estacavel and cache_slots_com_espaco.has(item_recebido.item_id):
		var lista = cache_slots_com_espaco[item_recebido.item_id]
		lista.sort()   # ordena para preencher os menores índices primeiro
		var indices = lista.duplicate()
		for slot_index in indices:
			if quantidade_restante <= 0:
				break
			var slot = inventario_logico[slot_index]
			if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item_recebido.item_id:
				var cabem = min(quantidade_restante, slot.espaco_livre_na_pilha)
				if cabem > 0:
					slot.somar_quantia_na_pilha(item_recebido, cabem)
					quantidade_restante -= cabem
					if slot.espaco_livre_na_pilha == 0:
						lista.erase(slot_index)   # remove da lista (ainda ordenada)
			else:
				lista.erase(slot_index)
		if lista.is_empty():
			cache_slots_com_espaco.erase(item_recebido.item_id)

	# 2. Se ainda restam itens, usa slots vazios (ou para itens não empilháveis)
	if quantidade_restante > 0 and not cache_slots_vazios.is_empty():
		#coloca os slots em ordem crescente.
		cache_slots_vazios.sort()
		# Itera sobre cópia do cache de vazios
		for slot_index in cache_slots_vazios.duplicate():
			if quantidade_restante <= 0:
				break
			var slot = inventario_logico[slot_index]
			
			if not item_recebido.estacavel:
				# Item não empilhável: adiciona 1 por slot
				slot.adicionar_item_ao_slot(item_recebido, 1)
				quantidade_restante -= 1
				cache_slots_vazios.erase(slot_index)
				# Não adiciona ao cache de espaço (item não empilhável não tem espaço)
			else:
				# Item empilhável: adiciona o máximo que cabe no slot
				var colocar = min(quantidade_restante, item_recebido.maximo_por_pilha)
				slot.adicionar_item_ao_slot(item_recebido, colocar)
				quantidade_restante -= colocar
				cache_slots_vazios.erase(slot_index)
				
				# Se o slot não ficou cheio, adiciona ao cache de espaço
				if slot.espaco_livre_na_pilha > 0:
					if not cache_slots_com_espaco.has(item_recebido.item_id):
						cache_slots_com_espaco[item_recebido.item_id] = []
					cache_slots_com_espaco[item_recebido.item_id].append(slot_index)

	# 3. Se ainda sobrou, tenta expandir ou dropar
	if quantidade_restante > 0:
		# Política: expandir inventário (se desejar)
		#var slots_necessarios = ceil(float(quantidade_restante) / item_recebido.maximo_por_pilha) if item_recebido.estacavel else quantidade_restante
		#expandir_inventario(slots_necessarios)
		# Chama recursivamente para tentar nos novos slots
		print("Inventário cheio, não foi possível adicionar o item")
		dropar_item_no_chao(item_recebido, quantidade_restante)
		return adicionar_item_ao_inventario(item_recebido, quantidade_restante)
		
	
	return true		
		
	
func remover_item_inventario(item: ItemBase, quantidade: int) -> bool:
	if inventario_logico.is_empty():
		return false
	
	var quantidade_restante = quantidade
	var item_id = item.item_id
	
	# Verifica se existe algum slot com este item
	if not slots_por_item_id.has(item_id):
		return false
	
	# Itera sobre uma cópia da lista (pois podemos modificar a lista original durante a remoção)
	var indices = slots_por_item_id[item_id].duplicate()
	for slot_index in indices:
		if quantidade_restante <= 0:
			break
		var slot = inventario_logico[slot_index]
		# Segurança: verifica se o slot ainda tem o mesmo item (pode ter mudado)
		if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item_id:
			if quantidade_restante >= slot.quantidade_atual_no_slot:
				# Remove todo o slot
				quantidade_restante -= slot.quantidade_atual_no_slot
				slot.remover_item_do_slot()   # isso emite sinais e atualiza caches
			else:
				# Remove parcialmente
				slot.subtrair_quantia_da_pilha(quantidade_restante)
				quantidade_restante = 0
				# O sinal de quantidade_alterada será emitido, atualizando o cache de espaço
		else:
			# Slot não contém mais o item (inconsistência) - remove do cache
			slots_por_item_id[item_id].erase(slot_index)
	
	# Após o loop, se a lista ficou vazia, remove a chave
	if slots_por_item_id.has(item_id) and slots_por_item_id[item_id].is_empty():
		slots_por_item_id.erase(item_id)
	
	# Se ainda restou quantidade, significa que não havia itens suficientes no inventário
	if quantidade_restante > 0:
		print("Não havia quantidade suficiente de ", item.nome_item, " para remover. Faltaram ", quantidade_restante)
		return false
	
	return true
		
func dropar_item_no_chao(item: ItemBase, quantidade: int):
	remover_item_inventario(item, quantidade)
	print("Inventário cheio dropando ", quantidade, " de ", item.nome_item, " no chão.")
	
	
