extends Resource
class_name CriarInformacaoVisualItem

const ref_tela_informacao_item = preload("res://Sistemas/Sistema_de_inventarios/informacao_visual_item.tscn")

var ref_viewport = null
var ref_mouse_position = null

var tela_informacao

func set_ref_viewport(viewport):
	ref_viewport = viewport

func set_mouse_position(posicao : Vector2):
	ref_mouse_position = posicao

func criar_informacao_item():
	tela_informacao = ref_tela_informacao_item.instantiate()
	ref_viewport.add_child(tela_informacao)
	tela_informacao.global_position = ref_mouse_position

func atualizar_posicao_tela(mouse_position):
	tela_informacao.global_position = mouse_position
	
func excluir_tela_informacao():
	tela_informacao.queue_free()
