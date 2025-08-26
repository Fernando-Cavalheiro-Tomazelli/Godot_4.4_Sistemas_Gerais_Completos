extends StaticBody3D

@export var nome = "Baú de Armazenamento"
#@export var inventario : InventarioBase
var inventario_externo :  CriarInventarioVisualExterno = null
var ref_player = null


func _ready() -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not "inventario" in body or body == self:
		return
		
	ref_player = body
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	ref_player = null
	if inventario_externo == null:
		return
	inventario_externo.excluir_inventario_visual_externo() # Arrumar
	inventario_externo = null
	pass
	
func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interagir"):
		print("apertando botão interagir, referência player = ", ref_player)
		if ref_player == null or inventario_externo != null:
			return
			
		inventario_externo = CriarInventarioVisualExterno.new()
		inventario_externo.criar_inventarios_visuais_externos(ref_player, self)
