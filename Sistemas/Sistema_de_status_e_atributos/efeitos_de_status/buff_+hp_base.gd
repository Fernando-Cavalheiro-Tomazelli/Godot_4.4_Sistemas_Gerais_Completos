extends Resource
class_name BuffHpBase

@export var nome_do_efeito : String = "Desconhecido"
@export var icone_do_efeito : Texture2D
@export var efeito_porcentagem : float = 0.2
@export var efeito_duracao_total : float = 10.0
var efeito_tempo_restante : float = efeito_duracao_total
var alvo_global
var quantia_vida_aumentada

func aplicar_efeito(alvo):
	if not "player_status" in alvo:
		print("Alvo não possui player_status")
		return
		
	var status = alvo.player_status
	if not "vida_max" in status:
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
	quantia_vida_aumentada = status.vida_max * efeito_porcentagem
	status.vida_max += quantia_vida_aumentada

	print("Vida máxima do alvo ", status.nome, " foi aumentada em ", efeito_porcentagem, ".")
	print("Vida máxima atual é ", status.vida_max)

		
	
func reiniciar_efeito():
	print("Efeito Reiniciado")
	efeito_tempo_restante = efeito_duracao_total
	
func tick(delta: float) -> bool:
	if alvo_global == null:
		return true
		
	efeito_tempo_restante -= delta
	if efeito_tempo_restante <= 0:
		#remover efeito
		alvo_global.player_status.vida_max -= quantia_vida_aumentada
		print("Efeito Removido")
		return true
	return false
