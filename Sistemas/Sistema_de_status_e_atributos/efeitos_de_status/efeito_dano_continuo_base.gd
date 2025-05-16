extends Resource
class_name DanoContinuoBase

@export_group("Informações do efeito")
@export var nome_do_efeito : String = "DanoContinuoBase"
@export var icone_do_efeito : Texture2D # Imagem do icone do efeito em formato texture2D.

@export_group("Valores do efeito")
@export var chance_de_aplicar_efeito : float = 1.0 # 1.0 = a 100% de chance , 0.5 = 50% de chance.
@export var duracao_do_efeito : float = 12.0 # Tempo de duração total do efeito.
@export var intervalo_por_hit : float = 3.0 # Intervalo em segundos de aplicação de cada hit.

@export_group("Recurso de aplicar dano")
@export var dano_por_hit : AplicarDanoUnicoBase # Importação do recurso que aplica a dano.

# Variáveis de uso interno.
var efeito_tempo_restante : float = 0.0
var contador_intervalo_dano : float = 0.0 # ← contador interno
var alvo_global = null

func aplicar_efeito(alvo):
	if not "player_status" in alvo:
		print("Alvo não possui player_status")
		return
		
	var status = alvo.player_status
	if not "vida_atual" in status:
		print("Alvo não possui status de vida_atual")
		return
	
	# Verifica chance de aplicar o efeito
	if randf() > chance_de_aplicar_efeito:
		print("O efeito de dano FALHOU. Chance não satisfeita.")
		return	
		
	alvo_global = alvo
	
	# Verifica se já está ativo
	for e in status.efeitos_ativos:
		if e.nome_do_efeito == nome_do_efeito:
			e.reiniciar_efeito()
			print("Buff já aplicado, apenas reiniciado.")
			return
	
	# Se chegou aqui, é novo, então aplica
	status.adicionar_efeito_na_lista(self)
	efeito_tempo_restante = duracao_do_efeito
	contador_intervalo_dano = intervalo_por_hit

func reiniciar_efeito():
	print("Efeito Reiniciado")
	efeito_tempo_restante = duracao_do_efeito
	contador_intervalo_dano = intervalo_por_hit
	
func tick(delta: float) -> bool:
	if alvo_global == null:
		return true
		
	efeito_tempo_restante -= delta
	contador_intervalo_dano -= delta
	
	if contador_intervalo_dano <= 0.0:
		var aplicar_dano = dano_por_hit.duplicate() #sempre instanciar ou duplicar o efeito aplicado.
		aplicar_dano.aplicar_efeito(alvo_global)
		contador_intervalo_dano += intervalo_por_hit

	if efeito_tempo_restante <= 0.0:
		print("Efeito de dano contínuo terminou.")
		return true

	return false
