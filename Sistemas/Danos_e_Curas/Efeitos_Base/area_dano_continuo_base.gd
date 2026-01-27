extends Resource
class_name  AreaDanoContinuoBase


@export var intervalo_por_hit : float = 1.0

@export var aplicar_dano : AplicarDanoUnicoBase

var contador_intervalo_dano : float = 0.0
var intervalo_dano_continuo : float = 1.0


var alvos_na_area: Array[Node3D] = []

func iniciar_dano_continuo(area : Area3D):
	var alvo = area.get_parent()
	if not alvos_na_area.has(alvo) and alvo.find_child("ComponentManager").Status:
			alvos_na_area.append(alvo)
			print(alvo, " entrou na área de dano")
	
func tick_efeito(delta):
	for alvo in alvos_na_area:
		if alvo.find_child("ComponentManager").Status:
			contador_intervalo_dano -= delta
			if contador_intervalo_dano <= 0.0:
				var dano_final = aplicar_dano.duplicate()
				dano_final.aplicar_efeito(alvo)
				contador_intervalo_dano = intervalo_por_hit
				
func terminar_dano_continuo(area : Area3D):
	var alvo = area.get_parent()
	alvos_na_area.erase(alvo)
	print(alvo, " saiu da área")
