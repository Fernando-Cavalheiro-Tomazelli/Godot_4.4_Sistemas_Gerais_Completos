extends Resource
class_name InventarioBase

@export var tamanho_inventario = 8
@export var dono_do_inventario = null

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

	# 1. Tenta empilhar em slots existentes (se empilhável)
	if item_recebido.estacavel and cache_slots_com_espaco.has(item_recebido.item_id):
		# Itera sobre cópia da lista de índices (segurança)
		var indices = cache_slots_com_espaco[item_recebido.item_id].duplicate()
		for slot_index in indices:
			if quantidade_restante <= 0:
				break
			var slot = inventario_logico[slot_index]
			# Verifica se o slot ainda contém o mesmo item
			if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item_recebido.item_id:
				var cabem = min(quantidade_restante, slot.espaco_livre_na_pilha)
				if cabem > 0:
					slot.somar_quantia_na_pilha(item_recebido, cabem)
					quantidade_restante -= cabem
					# Atualiza caches para este slot (quantidade mudou)
					_atualizar_caches_slot(slot_index)
			else:
				# Inconsistência: remove do cache de espaço manualmente
				cache_slots_com_espaco[item_recebido.item_id].erase(slot_index)

	# 2. Usa slots vazios
	if quantidade_restante > 0 and not cache_slots_vazios.is_empty():
		cache_slots_vazios.sort()  # garante ordem crescente
		for slot_index in cache_slots_vazios.duplicate():
			if quantidade_restante <= 0:
				break
			var slot = inventario_logico[slot_index]
			if not item_recebido.estacavel:
				# Não empilhável: adiciona 1 unidade
				slot.adicionar_item_ao_slot(item_recebido, 1)
				quantidade_restante -= 1
				_atualizar_caches_slot(slot_index)
				# Remove o slot do cache de vazios (já será removido pela atualização)
			else:
				var colocar = min(quantidade_restante, item_recebido.maximo_por_pilha)
				slot.adicionar_item_ao_slot(item_recebido, colocar)
				quantidade_restante -= colocar
				_atualizar_caches_slot(slot_index)

	# 3. Se ainda sobrou quantidade, não há espaço suficiente → dropar
	if quantidade_restante > 0:
		dropar_item_no_chao(item_recebido, quantidade_restante)
		return true   # ou true dependendo da semântica

	return true
			

#Remove item do inventário em quantidade parcial, drop parcial, guardar em bau etc.		
func remover_item_parcial(item: ItemBase, quantidade: int) -> int:
	var quantidade_removida = 0
	var quantidade_restante = quantidade

	if not slots_por_item_id.has(item.item_id):
		return 0

	var indices = slots_por_item_id[item.item_id].duplicate()
	for slot_index in indices:
		if quantidade_restante <= 0:
			break
		var slot = inventario_logico[slot_index]
		if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item.item_id:
			var remover_aqui = min(quantidade_restante, slot.quantidade_atual_no_slot)
			if remover_aqui >= slot.quantidade_atual_no_slot:
				slot.remover_item_do_slot()
			else:
				slot.subtrair_quantia_da_pilha(remover_aqui)
			quantidade_restante -= remover_aqui
			quantidade_removida += remover_aqui
			_atualizar_caches_slot(slot_index)

	return quantidade_removida	

#Remove a quantidade exata do item somente se existir, sem parcial, para craft, missões etc.		
func remover_item_quantia_exata(item: ItemBase, quantidade: int) -> bool:
	if quantidade <= 0:
		return false

	# Verifica quantidade disponível (sem modificar)
	var disponivel = 0
	if slots_por_item_id.has(item.item_id):
		for slot_index in slots_por_item_id[item.item_id]:
			var slot = inventario_logico[slot_index]
			if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item.item_id:
				disponivel += slot.quantidade_atual_no_slot
				if disponivel >= quantidade:
					break

	if disponivel < quantidade:
		return false

	# Remove a quantidade exata
	var quantidade_restante = quantidade
	var indices = slots_por_item_id[item.item_id].duplicate()
	for slot_index in indices:
		if quantidade_restante <= 0:
			break
		var slot = inventario_logico[slot_index]
		if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item.item_id:
			if quantidade_restante >= slot.quantidade_atual_no_slot:
				quantidade_restante -= slot.quantidade_atual_no_slot
				slot.remover_item_do_slot()
			else:
				slot.subtrair_quantia_da_pilha(quantidade_restante)
				quantidade_restante = 0
			_atualizar_caches_slot(slot_index)

	return true

#Remove completamente o slot específico do inventário, exemplo para drag and drop.		
func remover_item_slot_completo(slot_index : int):
	if slot_index < 0 or slot_index >= inventario_logico.size():
		return false
	var slot = inventario_logico[slot_index]
	if slot.item_atual_do_slot == null:
		return false
	slot.remover_item_do_slot()
	_atualizar_caches_slot(slot_index)
	return true
	
	
	
func trocar_mover_empilhar_item(origem_idx: int, destino_idx: int) -> void:
	if origem_idx == destino_idx:
		return

	var slot_origem = inventario_logico[origem_idx]
	var slot_destino = inventario_logico[destino_idx]

	# Origem vazia? nada a fazer
	if slot_origem.item_atual_do_slot == null:
		return

	# Caso 1: Destino vazio → mover tudo
	if slot_destino.item_atual_do_slot == null:
		var item = slot_origem.item_atual_do_slot
		var qtd = slot_origem.quantidade_atual_no_slot
		slot_destino.adicionar_item_ao_slot(item, qtd)
		slot_origem.remover_item_do_slot()
		_atualizar_caches_slot(origem_idx)
		_atualizar_caches_slot(destino_idx)
		return

	# Caso 2: Ambos ocupados
	var item_origem = slot_origem.item_atual_do_slot
	var item_destino = slot_destino.item_atual_do_slot
	var qtd_origem = slot_origem.quantidade_atual_no_slot
	var qtd_destino = slot_destino.quantidade_atual_no_slot

	# 2a: Mesmo item e empilhável → transferir o máximo possível
	if item_origem.item_id == item_destino.item_id and item_origem.estacavel:
		var espaco_destino = slot_destino.espaco_livre_na_pilha
		var transferir = min(qtd_origem, espaco_destino)

		if transferir > 0:
			slot_destino.somar_quantia_na_pilha(item_origem, transferir)
			slot_origem.subtrair_quantia_da_pilha(transferir)
			_atualizar_caches_slot(origem_idx)
			_atualizar_caches_slot(destino_idx)
		# se transferir == 0 (destino cheio), não faz nada
		else:
			var item_dest = item_destino
			var qtd_dest = qtd_destino

			# Limpa destino e coloca item da origem
			slot_destino.remover_item_do_slot()
			slot_destino.adicionar_item_ao_slot(item_origem, qtd_origem)
			# Limpa origem e coloca antigo item do destino
			slot_origem.remover_item_do_slot()
			slot_origem.adicionar_item_ao_slot(item_dest, qtd_dest)

			_atualizar_caches_slot(origem_idx)
			_atualizar_caches_slot(destino_idx)
			
		return

	# 2b: Itens diferentes ou não empilháveis → troca completa
	# Guarda conteúdo do destino
	var item_dest = item_destino
	var qtd_dest = qtd_destino

	# Limpa destino e coloca item da origem
	slot_destino.remover_item_do_slot()
	slot_destino.adicionar_item_ao_slot(item_origem, qtd_origem)
	# Limpa origem e coloca antigo item do destino
	slot_origem.remover_item_do_slot()
	slot_origem.adicionar_item_ao_slot(item_dest, qtd_dest)

	_atualizar_caches_slot(origem_idx)
	_atualizar_caches_slot(destino_idx)
	
	
# Transfere uma quantidade de itens do slot origem (deste inventário) para o slot destino do outro inventário.
# Se a quantidade for igual ao total do slot origem, o slot fica vazio.
# Se o slot destino já tiver o mesmo item empilhável, tenta empilhar o máximo possível.
# Se sobrar itens após empilhar, eles permanecem no slot origem (ou são devolvidos, dependendo da lógica).
# Em caso de itens diferentes ou não empilháveis, ocorre troca completa (movimenta todo o stack).
# Retorna true se a operação foi bem-sucedida (parcialmente ou totalmente).
func transferir_entre_inventarios(destino_inventario: InventarioBase, origem_idx: int, destino_idx: int, quantidade: int = -1) -> bool:
	# Se quantidade for -1, usa toda a quantidade do slot origem
	var slot_origem = inventario_logico[origem_idx]
	if slot_origem.item_atual_do_slot == null:
		return false
	
	var item_origem = slot_origem.item_atual_do_slot
	var qtd_origem = slot_origem.quantidade_atual_no_slot
	if quantidade <= 0 or quantidade > qtd_origem:
		quantidade = qtd_origem
	
	var slot_destino = destino_inventario.inventario_logico[destino_idx]
	
	# CASO 1: Slot destino vazio -> mover todos os itens
	if slot_destino.item_atual_do_slot == null:
		# Adiciona no destino
		slot_destino.adicionar_item_ao_slot(item_origem, quantidade)
		# Remove da origem
		if quantidade >= qtd_origem:
			slot_origem.remover_item_do_slot()
		else:
			slot_origem.subtrair_quantia_da_pilha(quantidade)
		# Atualiza caches
		_atualizar_caches_slot(origem_idx)
		destino_inventario._atualizar_caches_slot(destino_idx)
		return true
	
	# CASO 2: Ambos ocupados
	var item_destino = slot_destino.item_atual_do_slot
	var qtd_destino = slot_destino.quantidade_atual_no_slot
	
	# 2a: Mesmo item e empilhável -> tentar empilhar no destino
	if item_origem.item_id == item_destino.item_id and item_origem.estacavel:
		var espaco_destino = slot_destino.espaco_livre_na_pilha
		var transferir = min(quantidade, espaco_destino)
		if transferir > 0:
			# Adiciona no destino
			slot_destino.somar_quantia_na_pilha(item_origem, transferir)
			# Remove da origem
			if transferir >= quantidade:
				if quantidade >= qtd_origem:
					slot_origem.remover_item_do_slot()
				else:
					slot_origem.subtrair_quantia_da_pilha(transferir)
			else:
				# Remove apenas a quantidade transferida
				slot_origem.subtrair_quantia_da_pilha(transferir)
			# Atualiza caches
			_atualizar_caches_slot(origem_idx)
			destino_inventario._atualizar_caches_slot(destino_idx)
			return true
		else:
			# Não cabe nada, não faz transferência
			return false
	
	# 2b: Itens diferentes ou não empilháveis -> troca completa
	# Guarda conteúdo do destino
	var item_dest = item_destino
	var qtd_dest = qtd_destino
	
	# Limpa destino e coloca item da origem (com a quantidade solicitada)
	slot_destino.remover_item_do_slot()
	slot_destino.adicionar_item_ao_slot(item_origem, quantidade)
	# Limpa origem e coloca o antigo item do destino
	slot_origem.remover_item_do_slot()
	slot_origem.adicionar_item_ao_slot(item_dest, qtd_dest)
	
	# Atualiza caches em ambos os inventários
	_atualizar_caches_slot(origem_idx)
	destino_inventario._atualizar_caches_slot(destino_idx)
	return true

#Dropar item somente após o inventário cheio.
func dropar_item_no_chao(item: ItemBase, quantidade: int):
	print("Dropando item e criando 3D mas falta arrumar o código")
	#Criar item 3D
	var cena_item_3d = load(item.caminho_cena_item_3d)
	
	var item_3d = cena_item_3d.instantiate()
	dono_do_inventario.get_tree().current_scene.add_child(item_3d)
	var player_pos = dono_do_inventario.global_position
	var player_forward = -dono_do_inventario.global_transform.basis.z.normalized()
	var spawn_position = player_pos + player_forward * 2.0
	spawn_position.y = player_pos.y + 0.5
	item_3d.global_position = spawn_position
	#Fazer código para definir layer e mask correto para poder pegar o item novamente.
	#Excluir maçã do inventário
	#dono_do_inventario.find_child("ComponentManager").Inventario.remover_item_inventario(data.item_atual_do_slot,data.quantidade_atual_no_slot)
	#print("Inventário cheio dropando ", quantidade, " de ", item.nome_item, " no chão.")

func _atualizar_caches_slot(slot_index: int) -> void:
	var slot = inventario_logico[slot_index]
	var item = slot.item_atual_do_slot
	var item_id = item.item_id if item else ""
	var estacavel = item.estacavel if item else false
	var espaco = slot.espaco_livre_na_pilha if item else 0

	# 1. Cache de slots vazios
	if item == null:
		if not cache_slots_vazios.has(slot_index):
			cache_slots_vazios.append(slot_index)
			cache_slots_vazios.sort()
	else:
		# Remove do cache de vazios (se presente)
		var pos = cache_slots_vazios.find(slot_index)
		if pos != -1:
			cache_slots_vazios.remove_at(pos)

	# 2. Cache de slots por item
	if item:
		if not slots_por_item_id.has(item_id):
			slots_por_item_id[item_id] = PackedInt32Array()
		if not slots_por_item_id[item_id].has(slot_index):
			slots_por_item_id[item_id].append(slot_index)
			# Ordenar: como adicionamos em ordem crescente, não precisa, mas garantimos:
			slots_por_item_id[item_id].sort()
	else:
		# Slot vazio: remover de qualquer lista de itens
		for key in slots_por_item_id.keys():
			if slots_por_item_id[key].has(slot_index):
				slots_por_item_id[key].erase(slot_index)
				if slots_por_item_id[key].is_empty():
					slots_por_item_id.erase(key)
				break

	# 3. Cache de slots com espaço
	if item and estacavel and espaco > 0:
		if not cache_slots_com_espaco.has(item_id):
			cache_slots_com_espaco[item_id] = PackedInt32Array()
		if not cache_slots_com_espaco[item_id].has(slot_index):
			cache_slots_com_espaco[item_id].append(slot_index)
			cache_slots_com_espaco[item_id].sort()
	else:
		for key in cache_slots_com_espaco.keys():
			if cache_slots_com_espaco[key].has(slot_index):
				cache_slots_com_espaco[key].erase(slot_index)
				if cache_slots_com_espaco[key].is_empty():
					cache_slots_com_espaco.erase(key)
				break
