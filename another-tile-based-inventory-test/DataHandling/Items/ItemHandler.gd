extends Node

const ITEM_DATA : String = "res://DataHandling/Items/Item_data.json"

var item_data : Dictionary = {}

func _ready() -> void:
	load_data()


func load_data() -> void:
	if not FileAccess.file_exists(ITEM_DATA):
		print("Item Data file not found")
	var item_data_file : FileAccess = FileAccess.open(ITEM_DATA, FileAccess.READ)
	item_data = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
