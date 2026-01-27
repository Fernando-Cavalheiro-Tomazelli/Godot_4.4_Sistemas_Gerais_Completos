extends Control

@export var player : CharacterBody3D
var player_morreu : bool = false
@export var life_bar: ProgressBar
@export var display_valor_vida : Label
const slot_efeito_scene = preload("res://Sistemas/Status_HUD/efect_slot.tscn")
@export var display_effects: PanelContainer

var cronometro_forcar_sincronizacao : float = 0.0

func  _unhandled_key_input(event: InputEvent) -> void:
	pass

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass




func att_icone_efeitos(efeito : Resource):
	var novo_slot = slot_efeito_scene.instantiate()
	novo_slot.name = str(efeito.get_instance_id()) # ID único baseado no efeito
	# Supondo que dentro do slot o TextureRect seja acessível
	var icone = novo_slot.get_node("MarginContainer/icone_efeito")
	icone.texture = efeito.icone_do_efeito

	display_effects.get_node("MarginContainer/Grade_Efeitos").add_child(novo_slot)
	
func remover_icone_efeitos(efeito : Resource):
	var id = str(efeito.get_instance_id())
	var slot = display_effects.get_node("MarginContainer/Grade_Efeitos").get_node_or_null(id)
	if slot:
		slot.queue_free()
	

		
