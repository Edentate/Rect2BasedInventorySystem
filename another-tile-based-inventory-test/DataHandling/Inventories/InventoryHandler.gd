extends Node


const PATH : String = "user://test/%s.json" 
var thread : Thread = Thread.new()

func _ready() -> void:
	var dir : DirAccess = DirAccess.open("user://")
	dir.make_dir("test")

func save_inventory(inventory : InventoryData, data : Array[Dictionary]) -> void:
	var path : String = PATH % inventory.inventory_id
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file")
		return
	
	var payload : Dictionary[String, Variant] = {
		"version": 1,
		"items": data
	}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()


func load_inventory(inventory : InventoryData) -> Array[Dictionary]:
	var path : String =  PATH % inventory.inventory_id
	
	if not FileAccess.file_exists(path):
		return [{"Failed to load inventory from path " : path}]
	
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	var parsed : Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	var result : Array[Dictionary] = []
	for entry in parsed.get("items"):
		result.append(entry as Dictionary[String, Variant])
	return result
	#return parsed["items"]
	#return parsed.get("items", [{"DEFAULT ARRAY" : "parsed items not present"}])

func save_equip_inventory(data : Dictionary[String,Array]) -> void:
	var path : String = PATH % "EquipInventory"
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file")
		return
	
	var payload : Dictionary[String, Variant] = {
		"version": 1,
		"data": data
	}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()

func load_equip_inventory() -> Dictionary:
	var path : String = PATH % "EquipInventory"
	
	if not FileAccess.file_exists(path):
		push_error("Failed to load inventory from path %s" % path)
		return {null : []}# {null : ["Failed to load inventory from path %s" % path]}
	
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	var parsed : Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	var result : Dictionary = parsed.get("data")
	#for entry in parsed.get("data").keys():
		#result.append(entry )
	return result
