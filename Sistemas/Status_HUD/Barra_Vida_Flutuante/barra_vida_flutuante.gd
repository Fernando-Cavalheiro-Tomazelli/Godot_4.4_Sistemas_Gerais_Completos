extends Node3D

var dono_da_barra
@export var barra_vida : ProgressBar
var contador = 3.0

func _ready() -> void:
	dono_da_barra = self.get_parent()
	
func _process(delta: float) -> void:
	pass
	atualizar_barra_vida()
	#esconder_barra_vida(delta)

func atualizar_barra_vida():
	if not dono_da_barra:
		return
	if not dono_da_barra.find_child("ComponentManager").Status:
		print("Alvo nao possui vida para mostrar na barra flutuante")
		return
	barra_vida.value = dono_da_barra.find_child("ComponentManager").Status.vida_atual
	barra_vida.max_value = dono_da_barra.find_child("ComponentManager").Status.vida_max

func esconder_barra_vida(delta):
	if barra_vida.value == barra_vida.max_value:
		contador -= delta
		if contador <= 0.0:
			self.hide()
	else:
		self.show()
		contador = 3.0
		
		
