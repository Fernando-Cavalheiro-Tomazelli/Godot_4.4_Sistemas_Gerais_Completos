extends Resource
class_name InventarioBase

@export var tamanho_inventario = 8
@export var dono_do_inventario = null

#Coração do inventário, uma array com os slots onde serão inseridos os itens.
var inventario_logico : Array[SlotItemBase]

#caches que auxiliam encontrar slots ou itens, evitando buscas e varreduras desnecessárias.
#Cache contendo slots totalmente vazios.
var cache_slots_vazios : PackedByteArray
#cache contendo slots já com itens que são estacáveis e possuem espaço.
var cache_slots_com_espaco : Dictionary
#Cache indicando quantos slots possuem o mesmo tipo de item, util para organização.
var cache_slots_por_item: Dictionary
#Cachê com quantidade total de cada item por ID.
var cache_quantia_por_item: Dictionary



#Simplesmente inicia o iventário a primeira vez com os slots e tamanho corretos.
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

#Aumenta a quantidade de slots no inventário, aumentada por itens ou missões.
func expandir_inventario(quantidade : int) -> void:
	tamanho_inventario = tamanho_inventario + quantidade
	inventario_logico.resize(tamanho_inventario)
	print("O tamanho do seu inventário agora é de: ", tamanho_inventario)
	
	var tamanho_atual = tamanho_inventario - quantidade  # Ajusta para o tamanho antes da expansão
	for index in range(tamanho_atual, tamanho_inventario):
		var slot_item = SlotItemBase.new()
		slot_item.index_do_slot = index
		inventario_logico[index] = slot_item
		cache_slots_vazios.append(index)
		#fazer alguma forma de iniciar os visuais também
	#self.find_parent("Player3D").find_child("InventarioVisual").iniciar_inventario_visual(inventario_logico)

#Apenas limpa todos os slots do inventário sem excluir o SlotBase.
func limpar_inventario_completo() -> void:
	for i in range(inventario_logico.size()):
		var slot = inventario_logico[i]
		if slot.item_atual_do_slot != null:
			remover_item_do_slot(i, slot.quantidade_atual_no_slot)


func organizar_inventario() -> void:
	# FASE 1: Compactar itens (usando primitivas, que já atualizam caches)
	compactar_itens()

	# FASE 2: Ordenar os slots e recriar o array
	ordenar_slots_por_nome()

	# FASE 3: Reconstruir todos os caches do zero
	reconstruir_caches()

#Adiciona item ao inventário se houve espaço, até o inventário encher e depois dropa o restante.		
func adicionar_item_ao_inventario(item: ItemBase, quantidade: int) -> bool:
	#verifica se o inventário lógico existe e se a quantidade passada é maior que 0.
	if inventario_logico.is_empty() or quantidade <= 0:
		return false
	
	#verifica se existe slots com algum espaço antes de continuar a função.	
	if cache_slots_vazios.is_empty() and cache_slots_com_espaco.is_empty():
		return false
	
	var restante = quantidade #Quantidade a ser acomodada nos slots.

	# 1. Tenta empilhar em slots com o mesmo item e com espaço sobrando (cache de slots com espaço)
	if item.estacavel and cache_slots_com_espaco.has(item.item_id):
		# Itera sobre cópia da lista de índices
		var indices = cache_slots_com_espaco[item.item_id].duplicate()
		for slot_idx in indices:
			if restante <= 0:
				break
			var adicionado = adicionar_item_ao_slot(slot_idx, item, restante)
			restante -= adicionado

	# 2. Tenta usar slots vazios
	if restante > 0 and not cache_slots_vazios.is_empty():
		# Ordena para preencher os menores índices primeiro (opcional)
		cache_slots_vazios.sort()
		for slot_idx in cache_slots_vazios.duplicate():
			if restante <= 0:
				break
			var adicionado = adicionar_item_ao_slot(slot_idx, item, restante)
			restante -= adicionado

	# 3. Se ainda restou, não há espaço suficiente
	if restante > 0: 
		dropar_item_no_chao(item, restante)
		return true

	return true

#Remove o item do inventário somente na quantia exata definida, se houver menos  não remove.
func remover_quantia_exata(item: ItemBase, quantidade: int) -> bool:
	if quantidade <= 0:
		return true
	if not cache_slots_por_item.has(item.item_id):
		return false

	# Verifica disponibilidade total (sem modificar)
	var disponivel = 0
	for slot_idx in cache_slots_por_item[item.item_id]:
		var slot = inventario_logico[slot_idx]
		if slot.item_atual_do_slot and slot.item_atual_do_slot.item_id == item.item_id:
			disponivel += slot.quantidade_atual_no_slot
			if disponivel >= quantidade:
				break
	if disponivel < quantidade:
		return false

	# Remove a quantidade exata
	var restante = quantidade
	for slot_idx in cache_slots_por_item[item.item_id].duplicate():
		if restante <= 0:
			break
		var removido = remover_item_do_slot(slot_idx, restante)
		restante -= removido
	return restante == 0

# Remove o máximo possível (até 'quantidade'). Retorna quanto foi removido.
func remover_quantia_parcial(item: ItemBase, quantidade: int) -> int:
	if quantidade <= 0 or not cache_slots_por_item.has(item.item_id):
		return 0

	var restante = quantidade
	var total_removido = 0
	for slot_idx in cache_slots_por_item[item.item_id].duplicate():
		if restante <= 0:
			break
		var removido = remover_item_do_slot(slot_idx, restante)
		restante -= removido
		total_removido += removido
	return total_removido

#Adiciona o item específicamente ao slot.
func adicionar_item_ao_slot(slot_index: int, item: ItemBase, quantidade: int) -> int:
	if slot_index < 0 or slot_index >= inventario_logico.size() or quantidade <= 0:
		return 0
	var slot = inventario_logico[slot_index]
	var item_id = item.item_id

	# Slot vazio
	if slot.item_atual_do_slot == null:
		var adicionar = min(quantidade, item.maximo_por_pilha)
		slot.adicionar_item_ao_slot(item, adicionar)
		# Atualiza caches
		var pos = cache_slots_vazios.find(slot_index)
		if pos != -1:
			cache_slots_vazios.remove_at(pos)
		if not cache_slots_por_item.has(item_id):
			cache_slots_por_item[item_id] = []
		if not cache_slots_por_item[item_id].has(slot_index):
			cache_slots_por_item[item_id].append(slot_index)
			cache_slots_por_item[item_id].sort()
		if item.estacavel and slot.espaco_livre_na_pilha > 0:
			if not cache_slots_com_espaco.has(item_id):
				cache_slots_com_espaco[item_id] = []
			if not cache_slots_com_espaco[item_id].has(slot_index):
				cache_slots_com_espaco[item_id].append(slot_index)
				cache_slots_com_espaco[item_id].sort()
		return adicionar

	# Mesmo item e empilhável
	if slot.item_atual_do_slot.item_id == item_id and item.estacavel:
		var cabem = min(quantidade, slot.espaco_livre_na_pilha)
		if cabem > 0:
			slot.somar_quantia_na_pilha(item, cabem)
			# Atualiza caches
			var pos2 = cache_slots_vazios.find(slot_index)
			if pos2 != -1:
				cache_slots_vazios.remove_at(pos2)
			if not cache_slots_por_item.has(item_id):
				cache_slots_por_item[item_id] = []
			if not cache_slots_por_item[item_id].has(slot_index):
				cache_slots_por_item[item_id].append(slot_index)
				cache_slots_por_item[item_id].sort()
			var novo_espaco = slot.espaco_livre_na_pilha
			if novo_espaco > 0:
				if not cache_slots_com_espaco.has(item_id):
					cache_slots_com_espaco[item_id] = []
				if not cache_slots_com_espaco[item_id].has(slot_index):
					cache_slots_com_espaco[item_id].append(slot_index)
					cache_slots_com_espaco[item_id].sort()
			else:
				if cache_slots_com_espaco.has(item_id):
					cache_slots_com_espaco[item_id].erase(slot_index)
					if cache_slots_com_espaco[item_id].is_empty():
						cache_slots_com_espaco.erase(item_id)
			return cabem #se a quantia exceder o espaço do slot, retorna quantia que sobrou.
	return 0

#Remove quantia específica do slot, se remover o total o slot fica vazio.
func remover_item_do_slot(slot_index: int, quantidade: int) -> int:
	if slot_index < 0 or slot_index >= inventario_logico.size():
		return 0
	var slot = inventario_logico[slot_index]
	if slot.item_atual_do_slot == null:
		return 0

	var item = slot.item_atual_do_slot
	var item_id = item.item_id
	var qtd_atual = slot.quantidade_atual_no_slot
	var removido = 0

	if quantidade >= qtd_atual:
		# Remoção total
		removido = qtd_atual
		slot.remover_item_do_slot()
		# Atualiza caches
		if not cache_slots_vazios.has(slot_index):
			cache_slots_vazios.append(slot_index)
			cache_slots_vazios.sort()
		if cache_slots_por_item.has(item_id):
			cache_slots_por_item[item_id].erase(slot_index)
			if cache_slots_por_item[item_id].is_empty():
				cache_slots_por_item.erase(item_id)
		if cache_slots_com_espaco.has(item_id):
			cache_slots_com_espaco[item_id].erase(slot_index)
			if cache_slots_com_espaco[item_id].is_empty():
				cache_slots_com_espaco.erase(item_id)
	else:
		# Remoção parcial
		removido = quantidade
		slot.subtrair_quantia_da_pilha(quantidade)
		#slot.espaco_livre_na_pilha = item.maximo_por_pilha - slot.quantidade_atual_no_slot
		var pos = cache_slots_vazios.find(slot_index)
		if pos != -1:
			cache_slots_vazios.remove_at(pos)
		if not cache_slots_por_item.has(item_id):
			cache_slots_por_item[item_id] = []
		if not cache_slots_por_item[item_id].has(slot_index):
			cache_slots_por_item[item_id].append(slot_index)
			cache_slots_por_item[item_id].sort()
		var novo_espaco = slot.espaco_livre_na_pilha
		if item.estacavel and novo_espaco > 0:
			if not cache_slots_com_espaco.has(item_id):
				cache_slots_com_espaco[item_id] = []
			if not cache_slots_com_espaco[item_id].has(slot_index):
				cache_slots_com_espaco[item_id].append(slot_index)
				cache_slots_com_espaco[item_id].sort()
		else:
			if cache_slots_com_espaco.has(item_id):
				cache_slots_com_espaco[item_id].erase(slot_index)
				if cache_slots_com_espaco[item_id].is_empty():
					cache_slots_com_espaco.erase(item_id)
	return removido
	

# Função principal de arrastar/soltar entre dois slots.
# Decide entre mover, empilhar ou trocar com base no estado dos slots.
func trocar_mover_slots(inv_origem: InventarioBase, idx_origem: int, inv_destino: InventarioBase, idx_destino: int) -> void:
	if inv_origem == inv_destino and idx_origem == idx_destino:
		return

	var slot_origem = inv_origem.inventario_logico[idx_origem]
	var slot_destino = inv_destino.inventario_logico[idx_destino]

	# 1. Origem vazia → nada a fazer
	if slot_origem.item_atual_do_slot == null:
		return

	# 2. Destino vazio → mover tudo
	if slot_destino.item_atual_do_slot == null:
		inv_destino.adicionar_item_ao_slot(idx_destino, slot_origem.item_atual_do_slot, slot_origem.quantidade_atual_no_slot)
		inv_origem.remover_item_do_slot(idx_origem, slot_origem.quantidade_atual_no_slot)
		return

	# 3. Ambos ocupados
	var item_origem = slot_origem.item_atual_do_slot
	var item_destino = slot_destino.item_atual_do_slot

	# 3a. Itens iguais e empilháveis → tentar empilhar
	if item_origem.item_id == item_destino.item_id and item_origem.estacavel:
		# Verifica se há espaço no destino (evita chamar empilhar à toa)
		var espaco_destino = item_destino.maximo_por_pilha - slot_destino.quantidade_atual_no_slot
		if espaco_destino > 0:
			# Empilha (transfere o máximo possível)
			empilhar_slots(inv_origem, idx_origem, inv_destino, idx_destino)
			
			return
		# Se não há espaço, cai no else abaixo para trocar completamente

	# 3b. Itens diferentes, não empilháveis, ou destino cheio → troca completa
	trocar_slots_completamente(inv_origem, idx_origem, inv_destino, idx_destino)



# Empilha o máximo possível do slot origem para o slot destino (mesmo item empilhável).
# Retorna a quantidade efetivamente transferida.
func empilhar_slots(inv_origem: InventarioBase, idx_origem: int, inv_destino: InventarioBase, idx_destino: int) -> int:
	var slot_origem = inv_origem.inventario_logico[idx_origem]
	var slot_destino = inv_destino.inventario_logico[idx_destino]

	if slot_origem.item_atual_do_slot == null or slot_destino.item_atual_do_slot == null:
		return 0

	var item_origem = slot_origem.item_atual_do_slot
	var item_destino = slot_destino.item_atual_do_slot

	if item_origem.item_id != item_destino.item_id or not item_origem.estacavel:
		return 0

	var qtd_origem = slot_origem.quantidade_atual_no_slot
	var qtd_destino = slot_destino.quantidade_atual_no_slot
	var espaco_destino = item_destino.maximo_por_pilha - qtd_destino
	if espaco_destino <= 0:
		return 0  # destino cheio, não empilha

	var transferir = min(qtd_origem, espaco_destino)
	if transferir <= 0:
		return 0

	# Adiciona no destino
	var adicionado = inv_destino.adicionar_item_ao_slot(idx_destino, item_origem, transferir)
	if adicionado <= 0:
		return 0

	# Remove da origem apenas o que foi adicionado
	inv_origem.remover_item_do_slot(idx_origem, adicionado)
	return adicionado


# Troca completamente o conteúdo de dois slots (origem e destino).
# Usado quando os itens são diferentes, não empilháveis, ou quando o destino está cheio.
func trocar_slots_completamente(inv_origem: InventarioBase, idx_origem: int, inv_destino: InventarioBase, idx_destino: int) -> void:
	if inv_origem == inv_destino and idx_origem == idx_destino:
		return

	var slot_origem = inv_origem.inventario_logico[idx_origem]
	var slot_destino = inv_destino.inventario_logico[idx_destino]

	var item_origem = slot_origem.item_atual_do_slot
	var qtd_origem = slot_origem.quantidade_atual_no_slot if item_origem else 0
	var item_destino = slot_destino.item_atual_do_slot
	var qtd_destino = slot_destino.quantidade_atual_no_slot if item_destino else 0

	# Remove ambos (as primitivas já atualizam caches)
	if item_origem:
		inv_origem.remover_item_do_slot(idx_origem, qtd_origem)
	if item_destino:
		inv_destino.remover_item_do_slot(idx_destino, qtd_destino)

	# Adiciona os itens trocados
	if item_destino:
		inv_origem.adicionar_item_ao_slot(idx_origem, item_destino, qtd_destino)
	if item_origem:
		inv_destino.adicionar_item_ao_slot(idx_destino, item_origem, qtd_origem)

# Lida com arrastar/soltar entre dois slots (mesmo inventário ou diferentes).
# Comportamento:
# - Se destino vazio: move tudo (origem fica vazia).
# - Se itens iguais e empilháveis: transfere o máximo possível (empilha parcialmente, se couber).
# - Se itens diferentes ou não empilháveis: troca completamente.
#func trocar_slots(inv_origem: InventarioBase, idx_origem: int, inv_destino: InventarioBase, idx_destino: int) -> void:
	#if inv_origem == inv_destino and idx_origem == idx_destino:
		#return
#
	#var slot_origem = inv_origem.inventario_logico[idx_origem]
	#var slot_destino = inv_destino.inventario_logico[idx_destino]
#
	## Se origem vazia, não faz nada
	#if slot_origem.item_atual_do_slot == null:
		#return
#
	#var item_origem = slot_origem.item_atual_do_slot
	#var qtd_origem = slot_origem.quantidade_atual_no_slot
#
	## Caso 1: Destino vazio -> mover tudo
	#if slot_destino.item_atual_do_slot == null:
		#var adicionado = inv_destino.adicionar_item_ao_slot(idx_destino, item_origem, qtd_origem)
		#if adicionado > 0:
			#inv_origem.remover_item_do_slot(idx_origem, adicionado)
		## Se adicionado == 0 (não deveria acontecer, mas por segurança), não remove nada
		#return
#
	#var item_destino = slot_destino.item_atual_do_slot
	#var qtd_destino = slot_destino.quantidade_atual_no_slot
#
	## Caso 2: Mesmo item e empilhável -> transferir o máximo possível
	#if item_origem.item_id == item_destino.item_id and item_origem.estacavel:
		#var espaco_destino = slot_destino.espaco_livre_na_pilha
		#var transferir = min(qtd_origem, espaco_destino)
##arrumar aqui pra baixo a lógica do comportamento dos slots que eu quero arrumar.......S
		#if transferir > 0:
			## Adiciona no destino
			#inv_destino.adicionar_item_ao_slot(idx_destino, item_origem, transferir)
			## Remove da origem (pode ser parcial ou total)
			#inv_origem.remover_item_do_slot(idx_origem, transferir)
		## Se transferir == 0 (destino cheio), não faz nada (não troca)
		#return
#
	## Caso 3: Itens diferentes ou não empilháveis -> troca completa
	## Guarda dados do destino
	#var item_dest = item_destino
	#var qtd_dest = qtd_destino
#
	## Remove ambos (usando as primitivas)
	#inv_origem.remover_item_do_slot(idx_origem, qtd_origem)
	#inv_destino.remover_item_do_slot(idx_destino, qtd_dest)
#
	## Adiciona os itens trocados
	#if item_dest:
		#inv_origem.adicionar_item_ao_slot(idx_origem, item_dest, qtd_dest)
	#if item_origem:
		#inv_destino.adicionar_item_ao_slot(idx_destino, item_origem, qtd_origem)

#func trocar_mover_slots(inv_origem: InventarioBase, idx_origem: int, inv_destino: InventarioBase, idx_destino: int) -> void:
	#if inv_origem == inv_destino and idx_origem == idx_destino:
		#return
	#var slot_origem = inv_origem.inventario_logico[idx_origem]
	#var slot_destino = inv_destino.inventario_logico[idx_destino]
#
	## Origem vazia? não faz nada
	#if slot_origem.item_atual_do_slot == null:
		#return
#
	## Destino vazio? move tudo (usando empilhar com transferência total)
	#if slot_destino.item_atual_do_slot == null:
		## move tudo (equivale a empilhar com qtd_origem)
		#inv_destino.adicionar_item_ao_slot(idx_destino, slot_origem.item_atual_do_slot, slot_origem.quantidade_atual_no_slot)
		#inv_origem.remover_item_do_slot(idx_origem, slot_origem.quantidade_atual_no_slot)
		#return
#
	## Ambos ocupados: verificar se são iguais e empilháveis
	#if slot_origem.item_atual_do_slot.item_id == slot_destino.item_atual_do_slot.item_id and slot_origem.item_atual_do_slot.estacavel:
		## Tenta empilhar (chama a função específica)
		#empilhar_slots(inv_origem, idx_origem, inv_destino, idx_destino)
	#else:
		## Senão, troca completa
		#trocar_slots_completamente(inv_origem, idx_origem, inv_destino, idx_destino)
#
#
## Função auxiliar: transferir o máximo possível (empilhar)
#func empilhar_slots(inv_origem: InventarioBase, idx_origem: int, inv_destino: InventarioBase, idx_destino: int) -> void:
	#var slot_origem = inv_origem.inventario_logico[idx_origem]
	#var slot_destino = inv_destino.inventario_logico[idx_destino]
	#
	#if slot_origem.item_atual_do_slot == null or slot_destino.item_atual_do_slot == null:
		#return
	#var item_origem = slot_origem.item_atual_do_slot
	#var item_destino = slot_destino.item_atual_do_slot
	#
	#if item_origem.item_id != item_destino.item_id or not item_origem.estacavel:
		#return
	#var qtd_destino = slot_destino.quantidade_atual_no_slot
	#var espaco_destino = item_destino.maximo_por_pilha - qtd_destino
	#var transferir = min(slot_origem.quantidade_atual_no_slot, espaco_destino)
	#if transferir <= 0:
		#return
	## Adiciona no destino
	#inv_destino.adicionar_item_ao_slot(idx_destino, item_origem, transferir)
	## Remove da origem
	#inv_origem.remover_item_do_slot(idx_origem, transferir)
#
## Função auxiliar: troca completa de conteúdo entre dois slots
#func trocar_slots_completamente(inv_origem: InventarioBase, idx_origem: int, inv_destino: InventarioBase, idx_destino: int) -> void:
	#if inv_origem == inv_destino and idx_origem == idx_destino:
		#return
	#var slot_origem = inv_origem.inventario_logico[idx_origem]
	#var slot_destino = inv_destino.inventario_logico[idx_destino]
	#var item_origem = slot_origem.item_atual_do_slot
	#var qtd_origem = slot_origem.quantidade_atual_no_slot if item_origem else 0
	#var item_destino = slot_destino.item_atual_do_slot
	#var qtd_destino = slot_destino.quantidade_atual_no_slot if item_destino else 0
#
	## Remove ambos
	#if item_origem:
		#inv_origem.remover_item_do_slot(idx_origem, qtd_origem)
	#if item_destino:
		#inv_destino.remover_item_do_slot(idx_destino, qtd_destino)
#
	## Adiciona os itens trocados
	#if item_destino:
		#inv_origem.adicionar_item_ao_slot(idx_origem, item_destino, qtd_destino)
	#if item_origem:
		#inv_destino.adicionar_item_ao_slot(idx_destino, item_origem, qtd_origem)



# Transfere o máximo possível de itens do inventário origem para o destino, bom para baús rápidos.
# Retorna a quantidade total de itens movidos.
func transferir_tudo_para_inventario(destino: InventarioBase) -> int:
	if destino == self:
		return 0  # não faz sentido transferir para si mesmo

	var total_movido = 0
	var slots_para_remover = []  # armazena índices para remover após a transferência

	# 1. Primeiro, tenta empilhar itens que já existem no destino (prioridade)
	# Itera sobre todos os slots da origem que têm item
	for idx_origem in range(inventario_logico.size()):
		var slot_origem = inventario_logico[idx_origem]
		if slot_origem.item_atual_do_slot == null:
			continue

		var item = slot_origem.item_atual_do_slot
		var qtd = slot_origem.quantidade_atual_no_slot

		# Tenta adicionar no destino usando a função de adição (já lida com empilhamento)
		var adicionado = destino.adicionar_item_ao_inventario(item, qtd)
		if adicionado > 0:
			# Remove da origem (parcial ou total)
			var removido = remover_item_do_slot(idx_origem, adicionado)
			total_movido += removido
			# Se o slot ficou vazio, marca para remover depois (opcional)
			if slot_origem.item_atual_do_slot == null:
				slots_para_remover.append(idx_origem)

	# 2. Depois, tenta mover itens que não caberam na primeira passagem
	# (ou itens novos que não existiam no destino)
	# Itera novamente sobre os slots que ainda têm item
	for idx_origem in range(inventario_logico.size()):
		if idx_origem in slots_para_remover:
			continue
		var slot_origem = inventario_logico[idx_origem]
		if slot_origem.item_atual_do_slot == null:
			continue

		var item = slot_origem.item_atual_do_slot
		var qtd = slot_origem.quantidade_atual_no_slot

		# Tenta adicionar no destino
		var adicionado = destino.adicionar_item_ao_inventario(item, qtd)
		if adicionado > 0:
			var removido = remover_item_do_slot(idx_origem, adicionado)
			total_movido += removido
			if slot_origem.item_atual_do_slot == null:
				slots_para_remover.append(idx_origem)

	# 3. Opcional: reorganizar a origem para compactar slots vazios (se desejar)
	# (isso pode ser feito chamando uma função de compactação)
	# organizar_inventario()  # se você tiver essa função

	return total_movido


#Copia o inventário atual para o destino, serve para dropar mochila, clonar mochila entre outros.
func copiar_inventario_para(destino: InventarioBase) -> void:
	# Assumindo que destino tem pelo menos o mesmo número de slots
	for i in range(inventario_logico.size()):
		var slot_origem = inventario_logico[i]
		if slot_origem.item_atual_do_slot != null:
			var slot_destino = destino.inventario_logico[i]
			slot_destino.adicionar_item_ao_slot(slot_origem.item_atual_do_slot, slot_origem.quantidade_atual_no_slot)
			# Atualiza caches do destino manualmente (ou chama a primitiva)
			destino._atualizar_caches_slot(i)
	# Depois de copiar, limpa a origem
	limpar_inventario_completo()

	
 #Empilha itens do inventário origem que já existem no destino.
# Retorna a quantidade total de itens empilhados.
func empilhar_itens_existentes(destino: InventarioBase) -> int:
	if destino == self:
		return 0

	var total_movido = 0

	# Itera sobre todos os slots da origem
	for idx_origem in range(inventario_logico.size()):
		var slot_origem = inventario_logico[idx_origem]
		if slot_origem.item_atual_do_slot == null:
			continue

		var item = slot_origem.item_atual_do_slot
		var qtd = slot_origem.quantidade_atual_no_slot
		var item_id = item.item_id

		# Verifica se o destino já possui este item (usando o cache de itens)
		if destino.slots_por_item_id.has(item_id):
			# Tenta adicionar no destino
			var adicionado = destino.adicionar_item_ao_inventario(item, qtd)
			if adicionado > 0:
				var removido = remover_item_do_slot(idx_origem, adicionado)
				total_movido += removido
		# Se não existir no destino, mantém na origem (não faz nada)

	return total_movido	

#Compacta itens que são empilháveis e estão espalhados talvez com espaço sobrando na pilha.	
func compactar_itens() -> void:
	# Itera sobre cada tipo de item presente no inventário (usando o cache)
	for item_id in cache_slots_por_item.keys():
		var item = inventario_logico[cache_slots_por_item[item_id][0]].item_atual_do_slot
		if not item or not item.estacavel:
			continue  # ignora não empilháveis

		# Coleta todos os slots com este item e calcula a quantidade total
		var slots_com_item = cache_slots_por_item[item_id].duplicate()
		var quantidade_total = 0
		for idx in slots_com_item:
			quantidade_total += inventario_logico[idx].quantidade_atual_no_slot

		# Se a quantidade total cabe em menos slots que os atuais, redistribui
		if quantidade_total > 0:
			# Limpa todos os slots deste item (remove tudo)
			for idx in slots_com_item:
				remover_item_do_slot(idx, inventario_logico[idx].quantidade_atual_no_slot)

			# Agora readiciona em novos slots (usando slots vazios)
			var restante = quantidade_total
			while restante > 0:
				# Pega o primeiro slot vazio disponível
				if cache_slots_vazios.is_empty():
					# Sem slots vazios, expandir? Nesse caso, não deve acontecer
					# porque removemos os slots que estavam ocupados, então eles
					# já foram adicionados ao cache de vazios.
					break
				var slot_idx = cache_slots_vazios[0]  # primeiro vazio
				var colocar = min(restante, item.maximo_por_pilha)
				adicionar_item_ao_slot(slot_idx, item, colocar)
				restante -= colocar

#Ordena os itens do inventário por ordem alfabética em consideração ao ID.
func ordenar_slots_por_nome() -> void:
	# Coleta todos os slots ocupados (com item)
	var slots_ocupados = []
	for i in range(inventario_logico.size()):
		var slot = inventario_logico[i]
		if slot.item_atual_do_slot != null:
			slots_ocupados.append(slot)

	# Ordena os slots ocupados por nome do item (alfabeticamente)
	slots_ocupados.sort_custom(func(a, b):
		return a.item_atual_do_slot.nome_item < b.item_atual_do_slot.nome_item
	)

	# Preenche os primeiros slots com os itens ordenados, o restante fica vazio
	var novo_array : Array[SlotItemBase] = []
	var idx = 0
	# Primeiro, adiciona os itens ordenados
	for slot in slots_ocupados:
		novo_array.append(slot)
		slot.index_do_slot = idx
		idx += 1

	# Depois, preenche o restante com slots vazios (existentes ou novos)
	var total_slots = inventario_logico.size()
	while novo_array.size() < total_slots:
		# Cria um slot vazio (ou reutiliza um existente)
		var slot_vazio = SlotItemBase.new()
		slot_vazio.index_do_slot = novo_array.size()
		novo_array.append(slot_vazio)

	# Substitui o array antigo pelo novo
	inventario_logico = novo_array

	# Reconstroi todos os caches do zero (mais seguro que tentar atualizar incrementalmente)
	reconstruir_caches()

	
	
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

#Limpa e reconstrói todos os cachês, necessário após organizar inventári por exemplo.
func reconstruir_caches() -> void:
	# Limpa todos os caches
	cache_slots_vazios.clear()
	cache_slots_com_espaco.clear()
	cache_slots_por_item.clear()

	# Percorre todos os slots e preenche os caches
	for i in range(inventario_logico.size()):
		var slot = inventario_logico[i]
		slot.index_do_slot = i  # garante que o índice esteja correto

		var item = slot.item_atual_do_slot
		if item == null:
			# Slot vazio
			cache_slots_vazios.append(i)
			continue

		var item_id = item.item_id

		# 1. Adiciona ao cache de slots por item
		if not cache_slots_por_item.has(item_id):
			cache_slots_por_item[item_id] = []
		cache_slots_por_item[item_id].append(i)

		# 2. Adiciona ao cache de slots com espaço (se empilhável e com espaço)
		if item.estacavel and slot.espaco_livre_na_pilha > 0:
			if not cache_slots_com_espaco.has(item_id):
				cache_slots_com_espaco[item_id] = []
			cache_slots_com_espaco[item_id].append(i)

	# Ordena os caches para manter consistência (opcional)
	cache_slots_vazios.sort()
	for item_id in cache_slots_por_item:
		cache_slots_por_item[item_id].sort()
	for item_id in cache_slots_com_espaco:
		cache_slots_com_espaco[item_id].sort()
