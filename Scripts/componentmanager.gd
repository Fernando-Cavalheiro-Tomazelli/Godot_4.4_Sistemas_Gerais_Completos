extends Node
class_name ComponentManager

@export var Status : BaseStatus
@export var Inventario : InventarioBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Inventario:
		Inventario.iniciar_inventario()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Status:
		Status.tick_interno(delta)
