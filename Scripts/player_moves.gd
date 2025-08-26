extends CharacterBody3D

@export var nome : String = "CavalheiroFT"

@export var hud_inventarios: Control
@export var local_inventario_player = PanelContainer


@export var SPEED = 12.0
const JUMP_VELOCITY = 10.0

var camera_pivot: Node3D = null


#RayCast da camera para movimentar personagem no cursos
var RayOrigin = Vector3.ZERO
var RayEnd = Vector3.ZERO	

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	apply_movement() #Func aplica movimentação básica para os lados.
	just_jump() #Func para fazer pular.
	apply_gravity(delta) #Func que aplica gravidade.
	move_and_slide()
	
		
func apply_movement():
	if camera_pivot == null:
		return
	# Obter a direção do input e lidar com o movimento/desaceleração.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
func just_jump():
		# Lidar com o pulo.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
func apply_gravity(delta):
	# Adicionar a gravidade.
	if not is_on_floor():
		velocity += get_gravity() * delta
