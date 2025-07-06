extends Resource
class_name MostrarDanoCuraFlutuante

@export var cor_base : Color = Color.ORANGE
@export var cor_critico : Color = Color.RED
@export var cor_bordas : Color = Color.BLACK	

func criar_dano_cura_flutuante(alvo : Node3D, valor : float, critou : bool):
	if is_instance_valid(alvo):
		var valor_flutuante_scene = preload("res://Sistemas/Valores_flutuantes/valores_flutuantes.tscn")
		var instancia = valor_flutuante_scene.instantiate()
		if critou == true:
			instancia.set_cores(cor_critico, cor_bordas) #Acessa métodos do script da cena instanciada.
			instancia.set_valor_flutuante("%.2f CRIT" % valor) #Acessa métodos do script da cena instanciada.
		else:
			instancia.set_cores(cor_base, cor_bordas) #Acessa métodos do script da cena instanciada.
			instancia.set_valor_flutuante("%.2f" % valor) #Acessa métodos do script da cena instanciada.
		alvo.get_tree().current_scene.add_child(instancia)
		instancia.global_position = alvo.global_position + Vector3.UP * 2.0
		# Fazer esse script ficar genérico e receber qualquer valor em string.
