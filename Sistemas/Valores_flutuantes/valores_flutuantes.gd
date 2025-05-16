extends Label3D

@export var tempo_de_vida: float = 1.0
@export var altura_salto: float = 1.5
@export var label_valor : Label3D

@export var cor_interior := Color.WHITE
@export var cor_bordas := Color.BLACK

var tempo_passado := 0.0

func set_valor_flutuante(valor : String): # Valor é uma string.
	label_valor.text = valor
		
func set_cores(interior, bordas):
	label_valor.modulate = interior
	label_valor.outline_modulate = bordas

func _process(delta):
	animacao_subir_e_desaparecer(delta)

func animacao_subir_e_desaparecer(delta : float):
	# Animação simples de subir e desaparecer com o tempo
	tempo_passado += delta
	translate(Vector3.UP * altura_salto * delta)

	if tempo_passado >= tempo_de_vida:
		queue_free()
