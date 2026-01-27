extends Control

@export var hud_inventarios : Control #Menu de inventários
@export var player_hud_info : Control #Hud de info, barra vida etc.

var player = null

func _ready() -> void:
	
	hud_inventarios.visible = false
	player = self.get_parent()
	
	if self.get_parent().find_child("ComponentManager").Inventario:
		var inventario_visual = CriarSlotsVisuaisInventario.new()
		var inventario_logico = self.get_parent().find_child("ComponentManager").Inventario.inventario_logico
		var local_inventario = self.find_child("LocalInventarioPlayer")
		
		inventario_visual.iniciar_inventario_visual_(inventario_logico, local_inventario)
	

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventario"):
		hud_inventarios.visible = !hud_inventarios.visible
	
			
		#player_hud_info.visible = not player_hud_info.visible
	if Input.is_action_just_pressed("ui_cancel") and hud_inventarios.visible == true:
		hud_inventarios.visible = false
		
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Permite soltar apenas outro slot com item
	return data is Control and data.has_method("get_slot_data")
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	#Criar maçã 3D
	var cena_item_3d = load(data.get_slot_data().item_atual_do_slot.caminho_cena_item_3d)
	
	var item_3d = cena_item_3d.instantiate()
	get_tree().current_scene.add_child(item_3d)
	var player_pos = player.global_position
	var player_forward = -player.global_transform.basis.z.normalized()
	var spawn_position = player_pos + player_forward * 2.0
	spawn_position.y = player_pos.y + 0.5
	item_3d.global_position = spawn_position
	
	#Excluir maçã do inventário
	player.inventario.remover_item_inventario(data.get_slot_data())
	


func _on_draw() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player_hud_info.visible = false
	


func _on_hidden() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_hud_info.visible = true
