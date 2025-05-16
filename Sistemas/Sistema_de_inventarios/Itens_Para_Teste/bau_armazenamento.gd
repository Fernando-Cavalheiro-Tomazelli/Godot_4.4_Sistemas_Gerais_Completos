extends StaticBody3D

@export var inventario : InventarioBase
var inventario_externo :  CriarInventarioVisualExterno = null


func _ready() -> void:
	inventario.dono_do_inventario = str(self.name)
	inventario.iniciar_inventario()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not "inventario" in body or body == self:
		return
	inventario_externo = CriarInventarioVisualExterno.new()
	inventario_externo.criar_inventarios_visuais_externos(body, self)
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	inventario_externo.excluir_inventario_visual_externo() # Arrumar exclusão
	inventario_externo = null
	pass
