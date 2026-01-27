extends Resource
class_name AreaCuraContinuaBase



@export var valor_cura_minima : float = 3.0
@export var valor_cura_maxima : float = 5.0
@export var chance_critica : float = 0.5 # Chance de crítico (0.5 = 50%)
@export var valor_cura_critica : float = 1.0 # Porcentagem adicional do crítico (1.0 = +100%)
@export var intervalo_por_hit : float = 1.0

@export var valor_flutuante : MostrarDanoCuraFlutuante

var contador_intervalo_cura : float = 0.0
var intervalo_dano_continuo : float = 1.0
var alvo_global : Node3D = null	

var alvos_na_area: Array[Node3D] = []

func iniciar_dano_continuo(alvo : Node3D):
	if not alvos_na_area.has(alvo) and "player_status" in alvo:
		alvos_na_area.append(alvo)
		print(alvo, " entrou na área")
	
func tick_efeito(delta):
	for alvo in alvos_na_area:
		if "player_status" in alvo:
			contador_intervalo_cura -= delta
			if contador_intervalo_cura <= 0.0:
				var cura_final = randf_range(valor_cura_minima, valor_cura_maxima)
				var critou := false
				
				# Verifica crítico
				if randf() <= chance_critica:
					cura_final += cura_final * valor_cura_critica
					critou = true
					
				alvo.player_status.vida_atual = min(alvo.player_status.vida_atual + cura_final, alvo.player_status.vida_max)
				contador_intervalo_cura += intervalo_por_hit # ← usa o base, não um valor fixo hardcoded
				#faz aparecer o valor flutuante no jogo.
				var mostrar_valor = valor_flutuante.duplicate()
				mostrar_valor.criar_dano_cura_flutuante(alvo,cura_final,critou)
			
func terminar_dano_continuo(alvo : Node3D):
	alvos_na_area.erase(alvo)
	print(alvo, " saiu da área")
	
