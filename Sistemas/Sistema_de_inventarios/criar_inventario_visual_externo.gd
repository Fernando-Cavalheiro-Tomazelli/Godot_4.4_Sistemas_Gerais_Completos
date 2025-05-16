extends Resource
class_name CriarInventarioVisualExterno

const tela_inventarios_externos = preload("res://Sistemas/Sistema_de_inventarios/inventarios_externos.tscn")
const slot_base = preload("res://Sistemas/Sistema_de_inventarios/slots_inventario_itens_recursos/slot_item_visual.tscn")
const inventario_visual = preload("res://Sistemas/Sistema_de_inventarios/inventario_visual.tscn")
var tela_inventario = null
var inventario_player = null
var inventario_externo = null

var referencia_player = null
var referencia_externo = null


# tentar criar o inventario externo usando somente o criar inventario visual normal para o bau e para o player, e fazendo alguma
# forma de abmos conseguirem se atualizar conforme são alterados fisicamente.


func criar_inventarios_visuais_externos(player, externo) -> void:
	if "inventario" in player and "inventario" in externo:
		print("Abrir bau")
		referencia_player = player
		referencia_externo = externo
		
		tela_inventario = tela_inventarios_externos.instantiate()
		var local_inventario_player = tela_inventario.find_child("Inventario_Player")
		var local_inventario_externo = tela_inventario.find_child("Inventario_Externo")
		player.add_child(tela_inventario)
		
		criar_inventario_player(player, local_inventario_player)
		criar_inventario_externo(externo, local_inventario_externo)
		
#
func criar_inventario_player(player, local_inventario):
	
	inventario_player = CriarInventarioVisual.new()
	player.inventario.set_referencia_inventario_visual_externo(inventario_player)
	inventario_player.set_referencia_inventario_logico(player.inventario)
	inventario_player.criar_inventario_visual(player.inventario.inventario_logico, local_inventario )
	
	
func criar_inventario_externo(externo, local_inventario):
	inventario_externo = CriarInventarioVisual.new()
	externo.inventario.set_referencia_inventario_visual_externo(inventario_externo)
	inventario_externo.set_referencia_inventario_logico(externo.inventario)
	inventario_externo.criar_inventario_visual(externo.inventario.inventario_logico, local_inventario )
	
func excluir_inventario_visual_externo():
	referencia_player.inventario.set_referencia_inventario_visual_externo(null)
	referencia_externo.inventario.set_referencia_inventario_visual_externo(null)
	tela_inventario.queue_free()
	
