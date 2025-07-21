extends Resource
class_name AplicarDanoUnicoBase

@export var chance_aplicar_efeito : float = 0.8 # Chance de aplicar o efeito (0.5 = 50%)
@export var dano_minimo : float = 25.0 
@export var dano_maximo : float = 35.0

@export var chance_critica : float = 0.1 # Chance de crítico (0.5 = 50%)
@export var dano_critico : float = 1.0 # Porcentagem adicional do crítico (1.0 = +100%)

@export var valor_flutuante : MostrarDanoCuraFlutuante

var alvo_global : Node3D = null
var atacante_global : Node3D = null
var herdar_status_do_atacante : bool = false #Define se o dano vai ser herdado dos atributos do atacante, ou definidos manualmente

func aplicar_efeito(alvo: Node3D):
	if not "player_status" in alvo and not "vida_atual" in alvo.player_status:
		print("Alvo não possui status_base")
		return

	# Verifica chance de aplicar o efeito
	if randf() > chance_aplicar_efeito:
		print("O efeito de dano FALHOU. Chance não satisfeita.")
		return
		
	alvo_global = alvo	
		
	definir_status_atacante()


	var status = alvo.player_status	
	var dano_final = randf_range(dano_minimo, dano_maximo)
	var critou := false

	# Verifica crítico
	if randf() <= chance_critica:
		dano_final += dano_final * dano_critico
		critou = true
	

	if not "defesa" in status:
		print("Alvo não possui status de defesa")
	# Calcula redução por defesa
	var defesa = status.defesa
	print("Defesa do alvo é de ", defesa)
	var reducao = 100.0 / (100.0 + defesa)
	#reducao = clamp(reducao, 0.2, 1.0) # Nunca menos que 20% do dano original
	var dano_final_real = dano_final * reducao
	# Aplica o dano
	status.set_vida_atual(status.get_vida_atual() - dano_final_real)
	#mostra o valor de dano flutuante na tela.
	var mostrar_valor = valor_flutuante.duplicate()
	mostrar_valor.criar_dano_cura_flutuante(alvo,dano_final_real,critou)
	

	# Mensagens de debug
	if critou:
		print("⚔️ CRÍTICO! Recebeu", dano_final, "de dano. Vida atual:", status.vida_atual)
	else:
		print("Recebeu", dano_final, "de dano. Vida atual:", status.vida_atual)
		
func definir_status_atacante(): # Define os atributos do dano levando em conta atributos do atacante do dano.
	if atacante_global == null:
		print("Não possui atacante manter status base do dano")
		return
	if "player_status" in atacante_global:
		print("Alterando status do dano com base no status de atacante")
		var status_atacante = atacante_global.player_status
		chance_critica = status_atacante.chance_critica
		dano_minimo = status_atacante.ataque_minimo
		dano_maximo = status_atacante.ataque_maximo
		
		# Adicionar demais atributos a serem herdados
		
