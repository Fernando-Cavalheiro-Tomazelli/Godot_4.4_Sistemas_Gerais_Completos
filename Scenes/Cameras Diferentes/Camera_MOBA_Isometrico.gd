extends Node3D #Nó onde o script atual foi herdado

#Exportar grupro faz as variáveis abaixo aparecerem dentro do grupo indicado "indicado".
@export_group("Properties") 
var target : CharacterBody3D

#Exportar grupro faz as variáveis abaixo aparecerem dentro do grupo indicado "indicado".
@export_group("Zoom") 
@export var zoom_sensitivity = 0.1 #velocidade/sensibilidade do zoom.
@export var min_zoom_distance = 10.0
@export var max_zoom_distance = 5.0
@export var horizontal_sensitivity = 0.05 #Sensibilidade do movimento horizontal da câmera.
@export var vertical_sensitivity = 0.05 #Sensibilidade do movimento vertical da câmera.
@export var min_pitch = -60.0 #Ângulo mínimo de rotação vertical da câmera.
@export var max_pitch = -40.0 #Ângulo máximo de rotação horizontal da câmera.

#Ativas quando o nó estiver totalmente pronto, pode ser colocado dentro da func _ready().
@export var spring_arm: SpringArm3D #Especifica o nó do braço da câmera.
@export var camera: Camera3D #Especifica o nó da câmera em sí.

var _yaw = 0.0
var _pitch = 0.0
var _target_yaw = 0.0
var _target_pitch = -45.0 #Ângulo inicial do pivô da câmera.
var _initial_zoom = 10.0 #Distância inicial do braço da câmera.
var _target_zoom = _initial_zoom #Aplica o zoom inicia na câmera, que depois é alterado pelo player.
var last_mouse_position := Vector2.ZERO  # Armazena a última posição do mouse antes de capturar

func _ready() -> void:
	spring_arm.spring_length = _target_zoom #zoom inicial da camera.
	if self.get_parent() is CharacterBody3D:
		target = self.get_parent()
	self.get_parent().camera_pivot = self

func _process(_delta: float) -> void:
	soft_camera_movement()
	

	
#função _unhandled_input pega todos os inputs e processa assim que são recebidos independente do frame ou delta.
#tipo movimento do mouse, assim que é clicado ou movido, ao contário do handled_input que processa por frame.	
func _unhandled_input(event: InputEvent) -> void:
	change_camera_movement(event)	
	change_camera_zoom(event)

#Codigos da camera
func move_player_at_cursor():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position() #Pegar posição do mouse na tela "viewport".
	var ray_origin = camera.project_ray_origin(mouse_position) #Criar um novo raio "RayTrace" na posição indicada.
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * 300 #Faz o raio ser projetado até a posição final desejada.
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end) #Cria um objeto "query" com posição inicial e final do Ray.
	var intersection = space_state.intersect_ray(query)
	# Se colidir com algo, move o personagem
	if intersection:
		var pos_look_at = intersection.position #Posição onde o Ray colidiu no mundo 3D a partir do cursor.
		self.get_parent().look_at(Vector3(pos_look_at.x, global_position.y, pos_look_at.z), Vector3(0, 1, 0)) #Função Look_at faz olhar na direção do vecto3 indicado.
		# Corrige a rotação girando 180 graus no eixo Y caso persoangem esteja olhando para o lado contrário do cursor.
		self.get_parent().rotate_y(deg_to_rad(180))

func change_camera_movement(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		var mouse_event := evento as InputEventMouseButton
		
		# Se o botão direito for pressionado
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
			last_mouse_position = get_viewport().get_mouse_position()  # Salva posição do mouse
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		# Se o botão direito for solto
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT and not mouse_event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			# Retorna o mouse para a posição onde ele estava antes de ser capturado
			DisplayServer.warp_mouse(last_mouse_position)

	# Se estiver movendo o mouse enquanto o botão direito está pressionado
	elif evento is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mouse_motion: InputEventMouseMotion = evento as InputEventMouseMotion
		
		_target_yaw -= mouse_motion.relative.x * horizontal_sensitivity
		_target_pitch -= mouse_motion.relative.y * vertical_sensitivity
		_target_pitch = clamp(_target_pitch, min_pitch, max_pitch)

		
		
func change_camera_zoom(evento : InputEvent) -> void:
	if evento is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = evento as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom -= zoom_sensitivity
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom += zoom_sensitivity	
			
		# função "clamp" Limita o zoom entre os valores mínimo e máximo
		_target_zoom = clamp(_target_zoom, max_zoom_distance, min_zoom_distance)

func soft_camera_movement() -> void:
	#suavizar a rotação usando lerp
	_yaw = lerp(_yaw, _target_yaw, 0.1)
	_pitch = lerp(_pitch, _target_pitch, 0.1)
	#aplicar a rotação do pivo no eixo Y
	self.rotation_degrees.y = _yaw
	self.rotation_degrees.x = _pitch
	
	#adiconand lerp para suavisar o zoom da camera
	spring_arm.spring_length = lerp(spring_arm.spring_length, _target_zoom, 0.1)
	
	
	

	
