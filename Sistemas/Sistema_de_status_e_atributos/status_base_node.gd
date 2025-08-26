extends Node
class_name BaseStatusNode

#sinais que enviam os efeitos para o HUD atualizar no display de efeitos ativos.
signal adicionar_icone_efeito(icone : Resource)
signal remover_icone_efeito(icone : Resource)
signal alvo_morreu # Emite quando a vida chegar a 0.
signal barra_de_vida_alterada(atual : float, maxima : float) # Emite quando a vida é alterada.

@export_multiline var nome : String # Nome do player ou inimigo.

@export var vida_max : float : set = set_vida_max, get = get_vida_max
@export var vida_atual: float : set = set_vida_atual, get = get_vida_atual
@export var energia_max : float : set = set_energia_max, get = get_energia_max
@export var energia_atual : float : set = set_energia_atual, get = get_energia_atual
@export var fome_max : float : set = set_fome_max, get = get_fome_max
@export var fome_atual : float : set = set_fome_atual, get = get_fome_atual
@export var sede_max : float
@export var velocidade : float
@export var defesa : float
@export var ataque_minimo : float
@export var ataque_maximo : float



@export var percentual_reducao_dano : float # Redução de dano recebido em porcentagem.
@export var percentual_penetracao_armadura : float # Porcentagem que reduz a redução de dano do alvo.


@export var chance_critica : float
@export var dano_critico : float

# Passivas 
var tempo_corrido_intervalo_passiva : float = tempo_intervalo_recuperar_passiva
@export var tempo_intervalo_recuperar_passiva : float = 1.0

@export var valor_recuperar_vida_passiva : float = 1.0
@export var valor_recuperar_energia_passiva : float = 1.0
@export var valor_diminuir_fome_passiva : float = 1.0

# Array da lista onde fica todos os efeitos de status enquanto estiverem ativos.
var efeitos_ativos : Array[Resource] = []


# Funções Get and Set para mudar atributos com segurança em usar direto a variável.
# Vida getters and setters
func get_vida_atual() -> float:
	return vida_atual
	
func set_vida_atual(valor : float) -> void:
	valor = clamp(valor, 0.0, vida_max) # Limita o valor entre esses intervalos.
	if valor != vida_atual: # Verifica se o valor for alterado, evita atualizar sem precisar.
		vida_atual = valor
		emit_signal("barra_de_vida_alterada", vida_atual, vida_max)
		if vida_atual <= 0.0:
			emit_signal("alvo_morreu")
			
func get_vida_max() -> float:
	return vida_max
	
func set_vida_max(valor) -> void:
	valor = max(valor, 0.0)
	if valor != get_vida_max():
		vida_max = valor
		emit_signal("barra_de_vida_alterada", get_vida_atual(), get_vida_max())
		
# Energia getters and setters		
func get_energia_atual() -> float:
	return energia_atual
	
func set_energia_atual(valor : float) -> void:
	valor = clamp(valor, 0.0, energia_max) # Limita o valor entre esses intervalos.
	if valor != get_energia_atual(): # Verifica se o valor for alterado, evita atualizar sem precisar.
		energia_atual = valor
		
func get_energia_max() -> float:
	return energia_max
	
func set_energia_max(valor : float) -> void:
	valor = max(valor, 0.0)
	if valor != get_energia_max():
		energia_max = valor
		
# Fome getters and setters		
func get_fome_atual() -> float:
	return fome_atual
	
func set_fome_atual(valor : float) -> void:
	valor = clamp(valor, 0.0, fome_max)
	if valor != get_fome_atual():
		fome_atual = valor
		
func get_fome_max() -> float:
	return fome_max
	
func set_fome_max(valor : float) -> void:
	valor = max(valor, 0.0)
	if valor != get_fome_max():
		fome_max = valor
	


# Função para adicionar no process() de algum nó para atualizar a lógica interna.
func tick_interno(delta: float):
	att_efeitos_passivos(delta) #atualiza efeitos passivos tipo recuperação de vida ou queda de fome
	att_efeitos_e_excluir_da_lista(delta)

func adicionar_efeito_na_lista(efeito: Resource):
	efeitos_ativos.append(efeito)
	emit_signal("adicionar_icone_efeito", efeito)
	print("Efeito ", efeito.nome_do_efeito, " adicionado à lista de efeitos.")
	
func att_efeitos_e_excluir_da_lista(delta):
	for efeito in efeitos_ativos.duplicate():
		if efeito.tick(delta):
			efeitos_ativos.erase(efeito)
			emit_signal("remover_icone_efeito", efeito)
			print("Efeito ", efeito.nome_do_efeito, " removido do status")
	
func att_efeitos_passivos(delta):
	tempo_corrido_intervalo_passiva -= delta
	
	if tempo_corrido_intervalo_passiva <= 0.0:
		set_vida_atual(get_vida_atual() + valor_recuperar_vida_passiva)
		set_energia_atual(get_energia_atual() + valor_recuperar_energia_passiva)
		set_fome_atual(get_fome_atual() - valor_diminuir_fome_passiva)
		
		tempo_corrido_intervalo_passiva = tempo_intervalo_recuperar_passiva 

# Função colocada dentro de ready() de algum nó para inicializar lógica interna.		
func inicializar_status() -> void:
	set_vida_atual(get_vida_max())
	set_energia_atual(get_energia_max())
	set_fome_atual(get_fome_max())
	
