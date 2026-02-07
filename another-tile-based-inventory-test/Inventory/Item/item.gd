extends Node2D
class_name Item


enum Rotation {
	_0,
	_90,
	_180,
	_270,
}


const GREY : Color = Color(0.251, 0.251, 0.251)

@onready var texture: TextureRect = $Texture
@onready var color_rect: ColorRect = $Texture/ColorRect
@onready var quantity_label: Label = $Texture/QuantityLabel

#
#var properties : Dictionary = {} fill with properties so
#duplicating items in the place_item() function is less cumbersome
#

var item_id : int = 0
var item_name : String
var slot_type : String = "N/A"
var max_stack_size : int = 111

var quantity : int = 1 : 
	set(value):
		quantity = value
		if quantity <= 0:
			queue_free()
		else:
			_refresh_quantity_label.call_deferred()
var selected : bool  = false : 
	set(val):
		selected = val
		if is_node_ready():
			fade_colour_rect(val)

var offset : Vector2 = Vector2.ZERO
var rect : Rect2 
var rotation_state : int = Rotation._0 :
	set(value):
		rotation_state = value
		_handle_rotation()
var inventory : Control 


func _ready() -> void:
	rect = Rect2(global_position, texture.size)
	
	await get_tree().create_timer(0.02).timeout
	quantity_label.rotation_degrees = -rotation_state * 90
	quantity_label.global_position = position - quantity_label.size
	if rotation_state % 2 == 0:
		quantity_label.global_position +=texture.size/2. 
	else:
		quantity_label.global_position += Vector2(texture.size.y,texture.size.x)/2. 


func _process(_delta: float) -> void:
	if selected:
		global_position = get_global_mouse_position() + offset


func fade_colour_rect(forward : bool) -> void:
	var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	if forward:
		color_rect.visible = true
		tween.tween_property(color_rect,"color",Color(GREY,0.45),0.1)
	else:
		tween.tween_property(color_rect,"color",Color(GREY,0.), 0.1)
		await tween.finished
		color_rect.visible = false


func load_item(_item_id : int, _quantity : int = 1) -> void:
	var d : Dictionary = ItemHandler.item_data[str(_item_id)]
	quantity = _quantity
	item_id = _item_id
	texture.texture = load(d["Texture Path"])
	item_name = d["Name"]
	max_stack_size =d["Max Stack Size"]
	slot_type = d["Slot"]
	

func get_rect() -> Rect2:
	var size : Vector2 
	if rotation_state % 2 == 1:
		size = Vector2(texture.size.y, texture.size.x)
	else:
		size = texture.size
	
	return Rect2(
		position - size/2.,
		size
	)


func rotate_item(cw : bool) -> void: 
	if not selected:
		return
	
	if cw:
		rotation_state = (rotation_state + 1) % 4
	else:
		rotation_state = (wrapi(rotation_state - 1,0,4)) % 4



func _handle_rotation() -> void:
	if not is_node_ready():
		return
	
	rotation_degrees = rotation_state * 90
	
	quantity_label.rotation_degrees = -rotation_state * 90
	quantity_label.global_position = position - quantity_label.size
	if rotation_state % 2 == 0:
		quantity_label.global_position +=texture.size/2. 
	else:
		quantity_label.global_position += Vector2(texture.size.y,texture.size.x)/2. 

func _refresh_quantity_label() -> void:
	if not is_node_ready():
		return
	
	if quantity < 2:
		quantity_label.hide()
	else:
		quantity_label.text = "%dx" % quantity
		quantity_label.show()
