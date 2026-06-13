extends Resource
class_name SlotItemBase

var index_do_slot : int
@export var item_atual_do_slot : ItemBase = null
@export var quantidade_atual_no_slot : int
var espaco_livre_na_pilha = 1


func adicionar_item_ao_slot(item_base : ItemBase, quantidade : int):
	item_atual_do_slot = item_base
	quantidade_atual_no_slot = clamp(quantidade_atual_no_slot + quantidade, 0, item_atual_do_slot.maximo_por_pilha)
	espaco_livre_na_pilha = item_atual_do_slot.maximo_por_pilha - quantidade_atual_no_slot
	print("Adicionando item ", item_base.nome_item, " ao slot: ", index_do_slot, " na quantia de : ", quantidade)
	print("Quantidade atual do slot ", index_do_slot, " é de ", quantidade_atual_no_slot)
	print("Quantidade restante da pilha no slot ", index_do_slot, " é de ", espaco_livre_na_pilha)
	
func somar_quantia_na_pilha(item_base : ItemBase, quantidade : int):
	
	quantidade_atual_no_slot = quantidade_atual_no_slot + quantidade 
	espaco_livre_na_pilha = item_atual_do_slot.maximo_por_pilha - quantidade_atual_no_slot
	print("acrescentou a quantia de ", quantidade, " de ", item_base.nome_item, " na pilha do slot ", index_do_slot, ".")
	print("Quantidade atual do slot ", index_do_slot, " é de ", quantidade_atual_no_slot)
	print("Quantidade restante da pilha no slot ", index_do_slot, " é de ", espaco_livre_na_pilha)	

func remover_item_do_slot():
	item_atual_do_slot =  null
	quantidade_atual_no_slot = 0
	espaco_livre_na_pilha = 1
	
func subtrair_quantia_da_pilha(quantidade : int):
	if quantidade >= quantidade_atual_no_slot:
		item_atual_do_slot = null
		quantidade_atual_no_slot = 0
		espaco_livre_na_pilha = 1
	else:
		quantidade_atual_no_slot = quantidade_atual_no_slot - quantidade
		
		
