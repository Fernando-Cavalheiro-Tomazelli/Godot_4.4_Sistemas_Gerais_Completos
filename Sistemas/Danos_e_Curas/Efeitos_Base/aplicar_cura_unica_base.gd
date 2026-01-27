extends Resource
class_name AplicarCuraUnicaBase

@export var chance_aplicar_efeito : float = 0.8
@export var cura_minima : float = 25.0 
@export var cura_maxima : float = 35.0

@export var chance_critica : float = 0.5 # Chance de crítico (0.5 = 50%)
@export var valor_cura_critica : float = 1.0 # Porcentagem adicional do crítico (1.0 = +100%)

@export var valor_flutuante : MostrarDanoCuraFlutuante

#var alvo_global : Node3D = null

func aplicar_efeito(alvo: Node3D):
	if not "player_status" in alvo and not "vida_atual" in alvo.player_status:
		print("Alvo ", alvo, " não possui status_base ou atributo vida")
		return

	# Verifica chance de aplicar o efeito
	if randf() > chance_aplicar_efeito:
		print("O efeito de cura falhou.")
		return
		
	#alvo_global = alvo
	
	var status = alvo.player_status	
	var cura_final = randf_range(cura_minima, cura_maxima)
	var critou := false

	# Verifica chance para critar.
	if randf() <= chance_critica:
		cura_final += cura_final * valor_cura_critica
		critou = true
		
	status.vida_atual = status.vida_atual + cura_final
	print("Curou ", cura_final, " de vida de : ", alvo.nome,". Vida atual: ", status.vida_atual)
	#mostra o valor de dano flutuante na tela.
	var mostrar_valor = valor_flutuante.duplicate()
	mostrar_valor.criar_dano_cura_flutuante(alvo,cura_final,critou)
	
