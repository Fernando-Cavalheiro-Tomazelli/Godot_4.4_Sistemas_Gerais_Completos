extends Camera3D

@export var camera_minimapa : Camera3D
@export var player : CharacterBody3D


func _process(_delta):
	if not player:
		print("não foi possível atribuir mini mapa ao player ", player)
		return

	global_transform.origin = player.global_transform.origin + Vector3(0, 20, 0)
	look_at(player.global_transform.origin, Vector3(1, 0, 0).normalized()) #inves de UP usa vetor custom pra não bugar.
	#look_at(player.global_transform.origin, Vector3.UP)
