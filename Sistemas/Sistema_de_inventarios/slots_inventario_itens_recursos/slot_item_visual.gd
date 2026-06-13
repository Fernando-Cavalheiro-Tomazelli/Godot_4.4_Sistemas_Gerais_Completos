extends Control

var icone_slot : Texture2D
var quantidade_item : int
@export var texture_rect: TextureRect
@export var label: Label

var slot_logico : SlotItemBase

var inventario_dono = null
 
func _ready() -> void:
	texture_rect.texture = icone_slot
	
	
func _process(delta: float) -> void:
	if slot_logico.item_atual_do_slot:
		att_info_slot_visual()
	else:
		texture_rect.texture = null
		label.text = ""
		icone_slot = null
		quantidade_item = 0
	
func att_info_slot_visual():
	if slot_logico.item_atual_do_slot.icone_item != icone_slot or slot_logico.quantidade_atual_no_slot != quantidade_item:
		print("Atualizando info dos slots visuais")
		texture_rect.texture = slot_logico.item_atual_do_slot.icone_item
		icone_slot = slot_logico.item_atual_do_slot.icone_item
		if slot_logico.quantidade_atual_no_slot == 1:
			label.text = ""
		else:
			label.text = str(slot_logico.quantidade_atual_no_slot)
		quantidade_item = slot_logico.quantidade_atual_no_slot
	
	
func _get_drag_data(_pos):
	# Verifica se o slot tem item
	if slot_logico == null or slot_logico.item_atual_do_slot == null:
		return null

	var preview = TextureRect.new()
	preview.texture = icone_slot
	preview.EXPAND_IGNORE_SIZE
	preview.STRETCH_KEEP_ASPECT_CENTERED
	preview.size.x = 32
	preview.size.y = 32
	set_drag_preview(preview)

	# Dados a serem carregados no drag
	var drag_data = {
		"inventario_origem": inventario_dono,      # referência ao InventarioBase dono
		"slot_origem_idx": slot_logico.index_do_slot,
		"item": slot_logico.item_atual_do_slot,
		"quantidade": slot_logico.quantidade_atual_no_slot,
		"caminho_cena_3d": slot_logico.item_atual_do_slot.caminho_cena_item_3d
	}
	return drag_data
	
func _can_drop_data(at_position: Vector2, data: Variant):
	# Verifica se os dados são do tipo esperado (dicionário com as chaves)
	if not data is Dictionary or not data.has("inventario_origem") or not data.has("slot_origem_idx"):
		return false

	# Impede soltar no mesmo slot
	var origem_inv = data["inventario_origem"]
	var origem_idx = data["slot_origem_idx"]
	if origem_inv == inventario_dono and origem_idx == slot_logico.index_do_slot:
		return false

	# Se o slot destino está vazio, sempre pode soltar
	if slot_logico.item_atual_do_slot == null:
		return true

	# Se o slot destino está ocupado
	var item_origem = data["item"]
	var item_destino = slot_logico.item_atual_do_slot
	var qtd_origem = data["quantidade"]

	# Mesmo inventário: usa a lógica de troca/empilhamento (sempre permite)
	if origem_inv == inventario_dono:
		return true

	# Inventários diferentes: permite soltar se:
	# - Itens iguais e empilháveis E cabe pelo menos 1 unidade no destino
	# - Itens diferentes (vai trocar, então permite)
	if item_origem.item_id == item_destino.item_id and item_origem.estacavel:
		return slot_logico.espaco_livre_na_pilha > 0
	else:
		# Itens diferentes -> troca, sempre permite (mas vai trocar todo o stack)
		return true
		
func _drop_data(at_position: Vector2, data: Variant) -> void:
	
	var origem_inv = data["inventario_origem"]
	var origem_idx = data["slot_origem_idx"]
	var destino_idx = slot_logico.index_do_slot
	var destino_inv = inventario_dono

	# Se for o mesmo inventário -> usa função interna
	if origem_inv == destino_inv:
		origem_inv.trocar_mover_empilhar_item(origem_idx, destino_idx)
	else:
		# Inventários diferentes -> usa transferência
		# Quantidade: pode vir do data["quantidade"] ou usar -1 (tudo)
		var quantidade = data.get("quantidade", -1)
		origem_inv.transferir_entre_inventarios(destino_inv, origem_idx, destino_idx, quantidade)
		
		
		
	#var drag_data = data
	#var origem_idx = drag_data.index_do_slot
	#var destino_idx = slot_logico.index_do_slot   # método que retorna o índice deste slot
	#if origem_idx != destino_idx:
		#if not inventario_dono:
			#print("Slots visuais não possuem um inventário dono")
			#return
		## Chama a função de troca/empilhamento
		#inventario_dono.trocar_mover_empilhar_item(origem_idx, destino_idx)	
	
		
