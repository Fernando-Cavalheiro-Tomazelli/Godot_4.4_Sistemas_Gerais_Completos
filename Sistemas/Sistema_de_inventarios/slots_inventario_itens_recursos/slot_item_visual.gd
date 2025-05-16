extends Control

@export var icone_slot: TextureRect
@export var label_quantidade: Label
@export var efeito_mouse_on: ColorRect

@export var slot_item_visual: SlotItemBase
@export var cor_original: Color

# Referência ao inventário lógico dono deste slot
@export var ref_inventario_logico: InventarioBase # depois trocar para tipo certo

var tela_info_item_ativa = null # Guarda a tela de informacao visual do item do slot.

# Índice do slot no inventário lógico
var index_slot_visual: int

func set_referencia_inventario_logico(inventario_logico):
	ref_inventario_logico = inventario_logico

func set_slot_data(data: SlotItemBase):
	slot_item_visual = data
	atualizar_visual()

func atualizar_visual():
	if slot_item_visual and slot_item_visual.item_atual_do_slot:
		icone_slot.texture = slot_item_visual.item_atual_do_slot.icone
		label_quantidade.text = str(slot_item_visual.quantidade)
	else:
		icone_slot.texture = null
		label_quantidade.text = ""

# Getter auxiliar para drag and drop
func get_slot_data():
	return slot_item_visual

func get_inventario_logico():
	return ref_inventario_logico

# --- Drag and Drop ---

func _get_drag_data(_pos):
	if not slot_item_visual or not slot_item_visual.item_atual_do_slot:
		return null

	var preview = TextureRect.new()
	preview.texture = slot_item_visual.item_atual_do_slot.icone
	set_drag_preview(preview)
	preview.size = Vector2(32, 32)

	return self

func _can_drop_data(_pos, data):
	return data is Control and data.has_method("get_slot_data") and data.has_method("get_inventario_logico")

func _drop_data(_pos, data):
	if data == self:
		return  # Evita soltar sobre si mesmo

	if not _can_drop_data(_pos, data):
		return

	var other_slot_data = data.get_slot_data()
	var other_inventory = data.get_inventario_logico()

	#if not slot_item_visual or not other_slot_data or not ref_inventario_logico or not other_inventory:
		#return

	var index_origem = data.index_slot_visual
	var index_destino = self.index_slot_visual

	if ref_inventario_logico == other_inventory:
		# Troca dentro do mesmo inventário
		ref_inventario_logico.trocar_itens_de_lugar(index_origem, index_destino)
	else:
		# Troca entre inventários diferentes (player <-> baú)
		other_inventory.trocar_ou_mover_itens_entre_inventarios(index_origem, ref_inventario_logico, index_destino)

# Feedback visual
func _on_mouse_entered() -> void:
	efeito_mouse_on.show()
	if self.slot_item_visual.item_atual_do_slot:	
		tooltip_text = self.slot_item_visual.item_atual_do_slot.nome
	

func _on_mouse_exited() -> void:
	efeito_mouse_on.hide()
		


func _on_focus_entered() -> void:
	print("Está focado")
	if tela_info_item_ativa == null:
		var tela_info = CriarInformacaoVisualItem.new()
		tela_info_item_ativa = tela_info
		tela_info.set_ref_viewport(get_viewport())
		tela_info.set_mouse_position(get_viewport().get_mouse_position())
		tela_info.criar_informacao_item()

func _on_focus_exited() -> void:
	print("Está desfocado")
	tela_info_item_ativa.excluir_tela_informacao()
	tela_info_item_ativa = null
