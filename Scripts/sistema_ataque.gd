extends Node

@export var cena_projetil : PackedScene
@export var raycast_projetil : RayCast3D

@export var cena_projetil_dano : PackedScene
@export var cena_projetil_cura : PackedScene

@export var display_skill : TextureRect

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ataque"):
		atirar()
		
	if Input.is_action_just_pressed("1"):
		var cena_instanciada = cena_projetil_dano.instantiate()
		cena_projetil = cena_projetil_dano
		display_skill.texture = cena_instanciada.icone_projetil
		cena_instanciada.queue_free()
		print("Apertou 1")
	if Input.is_action_just_pressed("2"):
		var cena_instanciada = cena_projetil_cura.instantiate()
		cena_projetil = cena_projetil_cura
		display_skill.texture = cena_instanciada.icone_projetil
		cena_instanciada.queue_free()
		print("Apertou 2")
	if Input.is_action_just_pressed("3"):
		print("Apertou 3")
	if Input.is_action_just_pressed("4"):
		print("Apertou 4")

func atirar():
	if not cena_projetil:
		print("Cena de projétil não está atribuída.")
		return

	var projetil = cena_projetil.instantiate()
	projetil.atacante = self.get_parent() #garantir que o alvo tenha a variável atacante......
	get_tree().current_scene.add_child(projetil)

	var origem = raycast_projetil.global_position
	var direcao = raycast_projetil.global_transform.basis.z.normalized() 
	

	projetil.global_position = origem

	if projetil.has_method("set_direcao"):
		projetil.set_direcao(direcao)
