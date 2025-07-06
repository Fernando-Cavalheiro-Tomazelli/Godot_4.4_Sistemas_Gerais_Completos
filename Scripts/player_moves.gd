extends CharacterBody3D

@export var nome : String = "CavalheiroFT"
@export var player_status : BaseStatus
@export var inventario : InventarioBase

@export var hud_inventarios: Control
@export var local_inventario_player = PanelContainer


@export var SPEED = 12.0
const JUMP_VELOCITY = 10.0

@onready var camera_pivot: Node3D = $"Player_Camera_Pivot"
@onready var player_camera: Camera3D = $Player_Camera_Pivot/PlayerSpringArm/PlayerCamera
@onready var gobot_skin: Node3D = $GobotSkin

#RayCast da camera para movimentar personagem no cursos
var RayOrigin = Vector3.ZERO
var RayEnd = Vector3.ZERO	

func _ready() -> void:
	
	inventario.set_local_inventario(local_inventario_player)
	player_status.inicializar_status()
	inventario.dono_do_inventario = str(self.name) #Define a variável com nome do dono do inventário.
	inventario.iniciar_inventario() # Inicia inventário lógico do player
	inventario.criar_inventario_visual() # Inicia inventário visual se for necessário.
	

func _process(delta: float) -> void:
	if player_status: #atualiza o tick dos efeitos de status.
		player_status.tick_interno(delta)
	
func _physics_process(delta: float) -> void:
	move_player_at_cursor() #Func para virar o personagem na direção do cursor.
	apply_movement() #Func aplica movimentação básica para os lados.
	just_jump() #Func para fazer pular.
	apply_gravity(delta) #Func que aplica gravidade.
	move_and_slide()
	
	
func move_player_at_cursor():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position() #Pegar posição do mouse na tela "viewport".
	var ray_origin = player_camera.project_ray_origin(mouse_position) #Criar um novo raio "RayTrace" na posição indicada.
	var ray_end = ray_origin + player_camera.project_ray_normal(mouse_position) * 300 #Faz o raio ser projetado até a posição final desejada.
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end) #Cria um objeto "query" com posição inicial e final do Ray.
	var intersection = space_state.intersect_ray(query)
	# Se colidir com algo, move o personagem
	if intersection:
		var pos_look_at = intersection.position #Posição onde o Ray colidiu no mundo 3D a partir do cursor.
		gobot_skin.look_at(Vector3(pos_look_at.x, global_position.y, pos_look_at.z), Vector3(0, 1, 0)) #Função Look_at faz olhar na direção do vecto3 indicado.
		# Corrige a rotação girando 180 graus no eixo Y caso persoangem esteja olhando para o lado contrário do cursor.
		gobot_skin.rotate_y(deg_to_rad(180))
		
func apply_movement():
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
