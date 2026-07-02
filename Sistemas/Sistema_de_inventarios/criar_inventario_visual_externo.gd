extends Resource
class_name CriarInventarioVisualExterno

var tela_inv_duplo : PackedScene = preload("res://Sistemas/Sistema_de_inventarios/inventarios_externos.tscn")

func criar_inventarios_visuais_externos(externo, player):
	var tela_inventarios = tela_inv_duplo.instantiate()
	externo.ref_tela_inv_ativa = tela_inventarios
	player.add_child(tela_inventarios)
	
	print("Criar código para criar inventário visual duplo")
	pass
	
