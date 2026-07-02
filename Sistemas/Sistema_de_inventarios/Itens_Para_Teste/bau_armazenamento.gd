extends StaticBody3D

@export var nome = "Baú de Armazenamento"

var inventario_externo :  CriarInventarioVisualExterno = null
var ref_tela_inv_ativa = null


func _ready() -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_node("ComponentManager") and body.is_in_group("Jogadores"):
		inventario_externo = CriarInventarioVisualExterno.new()
		inventario_externo.criar_inventarios_visuais_externos(self, body)
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	if ref_tela_inv_ativa:
		ref_tela_inv_ativa.queue_free()
	
	
func _unhandled_key_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("interagir"):
		#print("apertando botão interagir, referência player = ", ref_player)
		#if ref_player == null or inventario_externo != null:
			#return
			#
		#inventario_externo = CriarInventarioVisualExterno.new()
		#inventario_externo.criar_inventarios_visuais_externos(ref_player, self)
	pass
