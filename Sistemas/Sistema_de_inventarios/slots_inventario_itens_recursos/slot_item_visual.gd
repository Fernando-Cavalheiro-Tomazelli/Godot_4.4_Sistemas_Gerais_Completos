extends Control

@export var icone_slot : TextureRect = null
@export var label: Label
@export var efeito_selecionado: ColorRect
@export var icone_default : Texture2D

#variáveis internas
var quantidade_item : int
var textura_icone: TextureRect

var slot_logico : SlotItemBase
var slot_index : int
var inventario_dono = null

var selecionado : bool
 
func _ready() -> void:
	BusSignal.att_inventario_visual.connect(att_info_slot_visual)
	
	
func att_info_slot_visual(index, icone, quantia):
	if index != slot_index:
		return
	icone_slot.texture = icone if icone else icone_default
	label.text = str(quantia) if quantia > 1 else ""
			

func limpar_slot_visual() -> void:
	icone_slot.texture = null
	label.text = ""
	quantidade_item = 0
	
func _get_drag_data(_pos):
	# Verifica se o slot tem item
	if slot_logico == null or slot_logico.item_atual_do_slot == null:
		return null

	var preview = self.duplicate() #TextureRect.new()
	#preview.texture = icone_slot
	#preview.EXPAND_IGNORE_SIZE
	#preview.STRETCH_KEEP_ASPECT_CENTERED
	#preview.size.x = 32
	#preview.size.y = 32
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

	# Chamada única: a função já decide a melhor ação (empilhar, trocar, mover)
	origem_inv.trocar_mover_slots(origem_inv, origem_idx, destino_inv, destino_idx)
		
	
		


func _on_focus_entered() -> void:
	print("Estou clicando e está selecionando o slot")
	efeito_selecionado.visible = true


func _on_focus_exited() -> void:
	efeito_selecionado.visible = false
