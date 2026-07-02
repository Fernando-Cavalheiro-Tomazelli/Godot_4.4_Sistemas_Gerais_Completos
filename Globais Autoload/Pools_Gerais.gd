extends Node

#Contém variáveis e códigos em autoload para uso geral global e testes.



#-------------------------------------------------------------------------------------------
#Pool de slots visuais vazios para reutilização e evitar criar e excluir sempre.
#Manter a média de slots necessária para maior parte dos inventários podendo criar mais depois.
var pool_slots_visuais: Array[Control] = []

@export var slot_scene: PackedScene = preload("res://Sistemas/Sistema_de_inventarios/slots_inventario_itens_recursos/slot_item_visual.tscn")
var pool_slots_inv_visuais: Array[Control] = []  # slots livres

func _ready():
	# Opcional: pré-cria alguns slots para evitar instanciação em tempo real
	_preload_slots(20)

func _preload_slots(amount: int):
	for i in range(amount):
		var slot = slot_scene.instantiate()
		#slot.visible = false
		# Adiciona em um lugar fora da árvore de UI (ex: este próprio nó)
		#add_child(slot) Colocar na árvore somente quando for algum item pesado na pool
		pool_slots_inv_visuais.append(slot)

func pegar_slots_pool() -> Control:
	if pool_slots_inv_visuais.is_empty():
		return slot_scene.instantiate()
	return pool_slots_inv_visuais.pop_back()

func devolver_slots_pool(slot: Control):
	# Reseta o slot (limpa ícone, texto, etc.)
	slot.reset()  # método que você deve implementar no SlotUI
	slot.visible = false
	pool_slots_inv_visuais.append(slot)
