extends Node3D

@export_group("Properties")
@export var target : CharacterBody3D

@export_group("Zoom")
@export var zoom_sensitivity = 0.1
@export var min_zoom_distance = 10.0
@export var max_zoom_distance = 5.0


@export var horizontal_sensitivity = 0.05
@export var vertical_sensitivity = 0.05

@export var min_pitch = -50.0
@export var max_pitch = 0.0


@onready var spring_arm: SpringArm3D = $PlayerSpringArm
@onready var camera: Camera3D = $PlayerSpringArm/PlayerCamera

var _yaw = 0.0
var _pitch = 0.0
var _target_yaw = 0.0
#começa com a rotação pitch em um ângulo -45 graus acima do personagem
var _target_pitch = -30.0
#começa com o lenght do springarm em 10 metros
var _initial_zoom = 5.0
var _target_zoom = _initial_zoom

func _ready() -> void:
	#iniciar o modo de captura de movimento do mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#iniciar o zoom da camera em um valor específico
	spring_arm.spring_length = _target_zoom

func _process(delta: float) -> void:
	soft_camera_movement()

	
#função _unhandled_input pega todos os inputs e processa assim que são recebidos
#tipo movimento do mouse, assim que é clicado, ao contário do handled_input que processa por quadro	
func _unhandled_input(event: InputEvent) -> void:
	change_camera_zoom(event)
	#esse if verifica se verdade que o mouse está se movendo, e se o botão direito está sendo segurado
	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		
		_target_yaw -= mouse_motion.relative.x * horizontal_sensitivity
		_target_pitch -= mouse_motion.relative.y * vertical_sensitivity
		#utiliza o "clamp" para limitar o intervalo de um ângulo para limitar a camera vertical
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
	target.rotation_degrees.y = _yaw
	self.rotation_degrees.x = _pitch
	
	#adiconand lerp para suavisar o zoom da camera
	spring_arm.spring_length = lerp(spring_arm.spring_length, _target_zoom, 0.1)
