extends Resource
class_name InventarioBase

@export var tamanho_inventario : int = 8
@export var dono_do_inventario : String = ""
var inventario_logico : Array[SlotItemBase] #inventário real, uma array com os itens.

var inventario_visual : CriarInventarioVisual = null #Usado para criar o inventario próprio do player
var inventario_visual_externo: CriarInventarioVisual = null #Referencia usada para atualizar o inv externo.
var local_inventario : Control = null

func set_referencia_inventario_visual_externo(ref_inventario : CriarInventarioVisual):
	inventario_visual_externo = ref_inventario

func set_local_inventario(local):
	local_inventario = local
	print("Local do inventário principal do player = ", local)

func set_tamanho_inventario(tamanho : int):
	tamanho_inventario = tamanho

func iniciar_inventario():
	inventario_logico.resize(tamanho_inventario)
	for i in range(tamanho_inventario):
		var slot_item = SlotItemBase.new()
		slot_item.index_slot = i
		inventario_logico[i] = slot_item	
	print("Foi iniciado inventario lógico de ", dono_do_inventario, " com ",tamanho_inventario, " slots." )
		
func criar_inventario_visual():
	inventario_visual = CriarInventarioVisual.new()
	inventario_visual.set_referencia_inventario_logico(self)
	inventario_visual.criar_inventario_visual(inventario_logico, local_inventario)

func expandir_inventario(quantidade : int) -> void:
	tamanho_inventario += quantidade
	var tamanho_atual = inventario_logico.size()
	inventario_logico.resize(tamanho_inventario)
	for i in range(tamanho_atual, tamanho_inventario):
		inventario_logico[i] = SlotItemBase.new()
		if inventario_visual:
			inventario_visual.atualizar_slots_visuais(inventario_logico)
			
		if inventario_visual_externo:
			inventario_visual_externo.atualizar_slots_visuais(inventario_logico)

func adicionar_item_inventario(item: ItemBase, index_slot := -1) -> bool:
	if index_slot >= 0 and index_slot < inventario_logico.size():
		if inventario_logico[index_slot].item_atual_do_slot == null:
			inventario_logico[index_slot].item_atual_do_slot = item
			
			if inventario_visual:
				inventario_visual.atualizar_slots_visuais(inventario_logico)
			if inventario_visual_externo:
				inventario_visual_externo.atualizar_slots_visuais(inventario_logico)
			print(" Adicionado ao inventário lógico de ", dono_do_inventario, " o item: ", item,  " no slot número ", index_slot, ".")
			return true
		return false

	for i in range(inventario_logico.size()):
		
		
		var slot = inventario_logico[i]
		if slot.item_atual_do_slot == null:
			slot.item_atual_do_slot = item
			if inventario_visual:
				inventario_visual.atualizar_slots_visuais(inventario_logico)
			if inventario_visual_externo:
				inventario_visual_externo.atualizar_slots_visuais(inventario_logico)
			print(" Adicionado ao inventário lógico de ", dono_do_inventario, " o item: ", item.nome,  " no slot número ", i , ".")
			return true
			
	return false
	
func remover_item_inventario(slot_item : SlotItemBase) -> bool:
	var index_slot = slot_item.index_slot
	for i in range(inventario_logico.size()):
		if i == index_slot:
			slot_item.item_atual_do_slot = null
			if inventario_visual:
				inventario_visual.atualizar_slots_visuais(inventario_logico)
			if inventario_visual_externo:
				inventario_visual_externo.atualizar_slots_visuais(inventario_logico)
			return true
		
	return false
	
# Troca itens de lugar entre o mesmo inventario
func trocar_itens_de_lugar(index_1: int, index_2: int) -> void:
	if index_1 >= inventario_logico.size() or index_2 >= inventario_logico.size():
		return
	
	var temp = inventario_logico[index_1].item_atual_do_slot
	inventario_logico[index_1].item_atual_do_slot = inventario_logico[index_2].item_atual_do_slot
	inventario_logico[index_2].item_atual_do_slot = temp
	print("Trocando o item: ", inventario_logico[index_2].item_atual_do_slot.nome, " do slot: ",index_1, " para o slot: ", index_2)

	if inventario_visual:
		inventario_visual.atualizar_slots_visuais(inventario_logico)
	if inventario_visual_externo:
		inventario_visual_externo.atualizar_slots_visuais(inventario_logico)


func trocar_ou_mover_itens_entre_inventarios(index_origem: int, inventario_destino: InventarioBase, index_destino: int) -> void:
	var item_origem = inventario_logico[index_origem].item_atual_do_slot
	var item_destino = inventario_destino.inventario_logico[index_destino].item_atual_do_slot

	# Remove os itens diretamente dos slots
	inventario_logico[index_origem].item_atual_do_slot = null
	inventario_destino.inventario_logico[index_destino].item_atual_do_slot = null

	# Tenta adicionar os itens nos slots opostos
	var sucesso_destino = inventario_destino.adicionar_item_inventario(item_origem, index_destino)
	var sucesso_origem = adicionar_item_inventario(item_destino, index_origem)

	# Se a troca falhar, desfaz as alterações (rollback simples)
	if not sucesso_destino:
		inventario_logico[index_origem].item_atual_do_slot = item_origem
	if not sucesso_origem:
		inventario_destino.inventario_logico[index_destino].item_atual_do_slot = item_destino

	print("Trocando ou movendo itens de inventários diferentes com encapsulamento respeitado")

	# Atualiza os visuais de ambos os inventários
	if inventario_visual:
		inventario_visual.atualizar_slots_visuais(inventario_logico)
	if inventario_visual_externo:
		inventario_visual_externo.atualizar_slots_visuais(inventario_logico)
	if inventario_destino.inventario_visual:
		inventario_destino.inventario_visual.atualizar_slots_visuais(inventario_destino.inventario_logico)
	if inventario_destino.inventario_visual_externo:
		inventario_destino.inventario_visual_externo.atualizar_slots_visuais(inventario_destino.inventario_logico)
	
	
	
