extends Resource
class_name ListaDeEstados

@export var idle : EstadoBase
@export var perseguindo : EstadoBase
@export var atacando : EstadoBase

var estado_atual: EstadoBase = null

func iniciar(dono):
	estado_atual = idle
	estado_atual.enter(dono)

func atualizar(dono, delta):
	if estado_atual:
		estado_atual.update(dono, delta)

func trocar_para(novo_estado: EstadoBase, dono):
	if estado_atual != null:
		estado_atual.exit(dono)
	estado_atual = novo_estado
	estado_atual.enter(dono)
