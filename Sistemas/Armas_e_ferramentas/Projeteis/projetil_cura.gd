extends Area3D

@export var nome_projetil : String = "Projétil de Cura"
@export var icone_projetil : Texture2D

@export var velocidade: float = 10.0
@export var distancia_maxima: float = 20.0

@export var aplicar_cura : AplicarCuraUnicaBase

var atacante : Node3D = null

var direcao: Vector3
var distancia_percorrida: float = 0.0

func definir_atacante(atacante : Node3D):
	self.atacante = atacante

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
