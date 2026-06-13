extends Node
class_name ComponentManager

@export var Status : BaseStatus
@export var Inventario : InventarioBase

#variáveis internas.
var dono_dos_componentes = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Inventario:
		Inventario.iniciar_inventario()
		Inventario.dono_do_inventario = self.get_parent()
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Status:
		Status.tick_interno(delta)
		
		
		
func definir_dono(dono)->void:
	if not dono:
		print("Não foi possível definir dono do ResourceManager")
		return
	Inventario.dono_do_inventario = dono
