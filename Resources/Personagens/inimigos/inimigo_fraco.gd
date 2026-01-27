extends CharacterBody3D

@export var player_status : BaseStatus
@export var Estado : ListaDeEstados


@export var raycast : RayCast3D
var alvo = null
func _ready() -> void:
	player_status.inicializar_status()

func _process(delta: float) -> void:
	player_status.tick_interno(delta)
	if alvo == null:
		return
	if alvo.is_in_group("Jogadores"):
		Estado.perseguindo.atualizar(self, delta)
		
	morrer()


func morrer():
	if player_status.vida_atual <= 0.0:
		self.queue_free()
		


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not "player_status" in body:
		return
	alvo = body
	Estado.perseguindo.iniciar(self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	alvo = null
