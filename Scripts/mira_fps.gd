extends CenterContainer

@export var Tamanho_Ponto : float = 2.0
@export var Tamanho_Linha : float = 1.5
@export var Cor_Mira : Color = Color.GREEN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	draw_circle(Vector2(0,0), Tamanho_Ponto, Cor_Mira) #Desenha um círculo que seria o ponto
	#Desenha as 4 linhas nos eixos corretos para a mira.
	draw_line(Vector2(0, -5), Vector2(0, -15), Cor_Mira, Tamanho_Linha)
	draw_line(Vector2(0, 5), Vector2(0, 15), Cor_Mira, Tamanho_Linha)
	draw_line(Vector2(-5,0), Vector2(-15,0), Cor_Mira, Tamanho_Linha)
	draw_line(Vector2(5,0), Vector2(15,0), Cor_Mira, Tamanho_Linha)
