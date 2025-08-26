extends Resource
class_name ItemBase

@export var item_id : String
@export_multiline var nome_item : String
@export_multiline var descricao_item : String
@export var icone_item = Texture2D
@export var estacavel : bool = false
@export var maximo_por_pilha : int = 2
@export var caminho_cena_item_3d : String # Referencia da Cena do objeto 3D do item.
