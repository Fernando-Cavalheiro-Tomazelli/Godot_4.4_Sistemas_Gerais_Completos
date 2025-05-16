extends EstadoBase
class_name EstadoPerseguir

@export var velocidade: float = 3.0

func iniciar(owner: Node):
	print("Entrando em PERSEGUIR")

func atualizar(owner: Node3D, _delta: float):
	if owner.alvo and owner.alvo.is_inside_tree():
		if not "player_status" in owner.alvo:
			return

		# Direção até o alvo (ignorando o eixo Y)
		var direcao = owner.alvo.global_transform.origin - owner.global_transform.origin
		direcao.y = 0  # Elimina a diferença vertical
		direcao = direcao.normalized()

		# Rotaciona apenas no eixo Y (horizontal)
		var target_rotation = Vector3(0, atan2(direcao.x, direcao.z), 0)
		owner.rotation.y = atan2(direcao.x, direcao.z) + PI


		# Movimento
		owner.velocity = direcao * velocidade
		owner.move_and_slide()
