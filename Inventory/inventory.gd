extends Control
class_name InventoryData

@onready var inventory_id : String = name
var data : Array[Item] = []

func _ready() -> void:
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)

func _on_mouse_entered() -> void:
	get_parent().curr_inventory = self

func _on_mouse_exited() -> void:
	get_parent().curr_inventory = null
