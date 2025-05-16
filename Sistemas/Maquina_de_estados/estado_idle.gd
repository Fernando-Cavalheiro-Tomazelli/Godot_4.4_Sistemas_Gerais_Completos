extends EstadoBase
class_name EstadoIdle

func enter(owner: Node):
	owner.velocity = Vector3.ZERO
	print("Entrando em IDLE")

func update(owner: Node, delta: float):
	# Idle não faz nada por enquanto
	pass
