extends Area3D

@export var velocidade: float = 10.0
@export var distancia_maxima: float = 20.0

var direcao: Vector3
var distancia_percorrida: float = 0.0

@export var aplicar_cura : CuraContinuaBase

func set_direcao(dir: Vector3):
	direcao = dir.normalized()

func _process(delta):
	var movimento = direcao * velocidade * delta
	global_translate(movimento)
	
	distancia_percorrida += movimento.length()
	if distancia_percorrida >= distancia_maxima:
		queue_free()

func _on_body_entered(alvo: Node3D) -> void:
	var dano = aplicar_cura.duplicate()
	dano.aplicar_efeito(alvo)
	queue_free() # Destroi a bola de fogo ao colidir
