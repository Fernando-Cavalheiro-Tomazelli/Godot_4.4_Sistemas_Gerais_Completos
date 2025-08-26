extends Control

var icone_slot : Texture2D
var quantidade_item : int
@export var texture_rect: TextureRect
@export var label: Label

var slot_logico : SlotItemBase
 
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

	var preview = TextureRect.new()
	preview.texture = icone_slot
	preview.EXPAND_IGNORE_SIZE
	preview.STRETCH_KEEP_ASPECT_CENTERED
	preview.size.x = 32
	preview.size.y = 32
	set_drag_preview(preview)

	return slot_logico #quando clica ele pega esse return com a informaçao
	
func _can_drop_data(at_position: Vector2, data: Variant):
	if data == slot_logico:
		return
		
	if data.item_atual_do_slot:
		#if data.item_atual_do_slot == slot_logico.item_atual_do_slot:
			#return
			
		return data
		
func _drop_data(at_position: Vector2, data: Variant) -> void:
		
	if slot_logico.item_atual_do_slot == null:
		slot_logico.item_atual_do_slot = data.item_atual_do_slot
		slot_logico.quantidade_atual_no_slot = data.quantidade_atual_no_slot
		data.remover_item_do_slot()
		
	else:
		
		var item_recebido = data.item_atual_do_slot
		var quantidade_recebida = data.quantidade_atual_no_slot
		data.remover_item_do_slot()
		data.adicionar_item_ao_slot(slot_logico.item_atual_do_slot, slot_logico.quantidade_atual_no_slot)
		slot_logico.remover_item_do_slot()
		slot_logico.adicionar_item_ao_slot(item_recebido,quantidade_recebida)
		
