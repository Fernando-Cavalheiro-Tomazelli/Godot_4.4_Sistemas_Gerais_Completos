extends Resource
class_name  AreaDanoContinuoBase


@export var intervalo_por_hit : float = 1.0

@export var aplicar_dano : AplicarDanoUnicoBase

var contador_intervalo_dano : float = 0.0
var intervalo_dano_continuo : float = 1.0


var alvos_na_area: Array[Node3D] = []

func iniciar_dano_continuo(alvo : Node3D):
	if not alvos_na_area.has(alvo) and "player_status" in alvo:
			alvos_na_area.append(alvo)
			print(alvo, " entrou na área")
	
func tick_efeito(delta):
	for alvo in alvos_na_area:
		if "player_status" in alvo:
			contador_intervalo_dano -= delta
			if contador_intervalo_dano <= 0.0:
				var dano_final = aplicar_dano.duplicate()
				dano_final.aplicar_efeito(alvo)
				contador_intervalo_dano = intervalo_por_hit
				
func terminar_dano_continuo(alvo : Node3D):
	alvos_na_area.erase(alvo)
	print(alvo, " saiu da área")
