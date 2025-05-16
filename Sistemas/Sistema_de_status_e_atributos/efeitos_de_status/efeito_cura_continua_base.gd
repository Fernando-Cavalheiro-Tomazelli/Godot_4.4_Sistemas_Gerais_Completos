extends Resource
class_name CuraContinuaBase

@export_group("Informações do efeito")
@export var nome_do_efeito : String = "Efeito de cura continua base" 
@export var icone_do_efeito : Texture2D # Imagem do icone do efeito em formato texture2D.

@export_group("Valores do efeito")
@export var chance_aplicar_efeito : float = 1.0 # 1.0 = a 100% de chance , 0.5 = 50% de chance.
@export var duracao_do_efeito : float = 5.0 # Tempo de duração total do efeito.
@export var intervalo_por_hit : float = 1.0 # Intervalo em segundos de aplicação de cada hit.

@export_group("Recurso de aplicar cura")
@export var cura_por_hit : AplicarCuraUnicaBase # Importação do recurso que aplica a cura.

#Variáveis de uso interno.
var tempo_restante_do_efeito : float = 0.0
var contador_de_intervalo_do_hit : float = 0.0
var alvo_global : Node3D = null	

func aplicar_efeito(alvo):
	#Verifica se o alvo possui a varíavel de status.
	if not "player_status" in alvo:
		print("Alvo não possui recurso de status")
		return
		
	var status = alvo.player_status
	
	#verifica se existe vida_atual dentro de status.
	if not "vida_atual" in status:
		print("Alvo não possui o atributo de vida_atual")
		return
		
	# Verifica chance de aplicar o efeito
	if randf() > chance_aplicar_efeito:
		print("O efeito de dano FALHOU. Chance não satisfeita.")
		return	

	alvo_global = alvo #Define a variável alvo_global como o alvo recebido.
	
	# Verifica se o efeito já está ativo no alvo.
	for e in status.efeitos_ativos:
		if e.nome_do_efeito == nome_do_efeito:
			e.reiniciar_efeito()
			print("Buff já aplicado, apenas reiniciado.")
			return
	
	# Aplicao o efeito caso não tenha sido aplicado ou reinicializado.
	status.adicionar_efeito_na_lista(self)
	tempo_restante_do_efeito = duracao_do_efeito
	contador_de_intervalo_do_hit = intervalo_por_hit

func reiniciar_efeito():
	print("Efeito Reiniciado")
	tempo_restante_do_efeito = duracao_do_efeito
	contador_de_intervalo_do_hit = intervalo_por_hit
	
func tick(delta: float) -> bool:
	if alvo_global == null:
		return true
			
	tempo_restante_do_efeito -= delta
	contador_de_intervalo_do_hit -= delta
	
	# Executa o trecho quando o intervalo do hit chega a 0.
	if contador_de_intervalo_do_hit <= 0.0:
		
		# Duplica a variável do recurso de alicar dano e aplica o efeito.
		var aplicar_cura = cura_por_hit.duplicate()
		aplicar_cura.aplicar_efeito(alvo_global)
		
		# Reinicia o contador de intervalo de cada hit.
		contador_de_intervalo_do_hit += intervalo_por_hit

	# Quando o tempo restante do efeito chega em 0.	
	if tempo_restante_do_efeito <= 0.0:
		print("Efeito de dano cura continua terminou.")
		return true

	return false

	
