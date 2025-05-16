extends Node3D

@onready var dono_da_barra = self.get_parent()
@export var barra_vida : ProgressBar
var contador = 3.0

func _ready() -> void:
	print("Dono da barra = ", dono_da_barra)
	if dono_da_barra.get("player_status") != null:
		barra_vida.value = dono_da_barra.player_status.vida_max
	
func _process(delta: float) -> void:
	atualizar_barra_vida()
	esconder_barra_vida(delta)

func atualizar_barra_vida():
	if dono_da_barra.get("player_status") == null:
		print("Alvo nao possui vida para mostrar na barra flutuante")
		return
	barra_vida.value = dono_da_barra.player_status.vida_atual
	barra_vida.max_value = dono_da_barra.player_status.vida_max

func esconder_barra_vida(delta):
	if barra_vida.value == barra_vida.max_value:
		contador -= delta
		if contador <= 0.0:
			self.hide()
	else:
		self.show()
		contador = 3.0
		
		
