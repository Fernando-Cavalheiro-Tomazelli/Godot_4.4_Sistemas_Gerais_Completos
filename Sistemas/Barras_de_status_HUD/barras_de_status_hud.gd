extends Control

@export var barra_vida_principal : ProgressBar
@export var barra_vida_fundo : ProgressBar
@export var barra_vida_valor : Label

@export var barra_energia_principal : ProgressBar
@export var barra_energia_fundo : ProgressBar
@export var barra_energia_valor : Label

@export var barra_fome_principal : ProgressBar
@export var barra_fome_fundo : ProgressBar
@export var barra_fome_valor : Label

var player_dono = null
var intervalo_atualizacao_barras = 0.1

func _ready() -> void:
	player_dono = self.get_parent().get_parent() # Pegar referência do nó pai que é o player.
	print("Nó pai das barras HUD é ", player_dono)

func _process(delta: float) -> void:
	atualizar_barras_do_hud(delta)
	
func atualizar_barras_do_hud(delta: float):
	intervalo_atualizacao_barras -= delta
	
	if intervalo_atualizacao_barras <= 0.0 :
		if not "player_status" in player_dono:
			return
		
		# Barra de vida.
		if barra_vida_principal.value != player_dono.player_status.get_vida_atual():
			barra_vida_principal.value = player_dono.player_status.get_vida_atual()
			barra_vida_valor.text = "%.2f / %.2f" % [player_dono.player_status.get_vida_atual(), player_dono.player_status.get_vida_max()]
		
		if barra_vida_principal.max_value != player_dono.player_status.get_vida_max():
			barra_vida_principal.max_value = player_dono.player_status.get_vida_max()
			barra_vida_valor.text = "%.2f / %.2f" % [player_dono.player_status.get_vida_atual(), player_dono.player_status.get_vida_max()]
			
		if barra_vida_fundo.value != player_dono.player_status.get_vida_atual():
			barra_vida_fundo.value = lerp(barra_vida_fundo.value, player_dono.player_status.get_vida_atual(), 10 * delta)
		
		if barra_vida_fundo.max_value != player_dono.player_status.get_vida_max():
			barra_vida_fundo.max_value = lerp(barra_vida_fundo.max_value, player_dono.player_status.get_vida_max(), 10 * delta)
			
		# Barra de energia.
		if barra_energia_principal.value != player_dono.player_status.get_energia_atual():
			barra_energia_principal.value = player_dono.player_status.get_energia_atual()
			barra_energia_valor.text = "%.2f / %.2f" % [player_dono.player_status.get_energia_atual(), player_dono.player_status.get_energia_max()]
		
		if barra_energia_principal.max_value != player_dono.player_status.get_energia_max():
			barra_energia_principal.max_value = player_dono.player_status.get_energia_max()
			barra_energia_valor.text = "%.2f / %.2f" % [player_dono.player_status.get_energia_atual(), player_dono.player_status.get_energia_max()]
			
		if barra_energia_fundo.value != player_dono.player_status.get_energia_atual():
			barra_energia_fundo.value = lerp(barra_energia_fundo.value, player_dono.player_status.get_energia_atual(), 10 * delta)
		
		if barra_energia_fundo.max_value != player_dono.player_status.get_energia_max():
			barra_energia_fundo.max_value = lerp(barra_vida_fundo.max_value, player_dono.player_status.get_energia_max(), 10 * delta)
			
		# Barra de fome.
		if barra_fome_principal.value != player_dono.player_status.get_fome_atual():
			barra_fome_principal.value = player_dono.player_status.get_fome_atual()
			barra_fome_valor.text = "%.2f / %.2f" % [player_dono.player_status.get_fome_atual(), player_dono.player_status.get_fome_max()]
		
		if barra_fome_principal.max_value != player_dono.player_status.get_fome_max():
			barra_fome_principal.max_value = player_dono.player_status.get_fome_max()
			barra_fome_valor.text = "%.2f / %.2f" % [player_dono.player_status.get_fome_atual(), player_dono.player_status.get_fome_max()]
			
		if barra_fome_fundo.value != player_dono.player_status.get_fome_atual():
			barra_fome_fundo.value = lerp(barra_fome_fundo.value, player_dono.player_status.get_fome_atual(), 10 * delta)
		
		if barra_fome_fundo.max_value != player_dono.player_status.get_fome_max():
			barra_fome_fundo.max_value = lerp(barra_fome_fundo.max_value, player_dono.player_status.get_fome_max(), 10 * delta)
			
		intervalo_atualizacao_barras = 0.1
