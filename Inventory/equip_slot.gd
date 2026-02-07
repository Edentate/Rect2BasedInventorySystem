extends TextureRect
class_name EquipSlot

var data : Array = []
@export var max_items : int = 4
@export_enum("N/A", "Head", 
			"Torso", "Hands", 
			"Legs", "Feet") var slot_type : String = "N/A"

func is_slot_full() -> bool:
	return false
	"""
	Might want to include some logic to make sure that inner layers
	can not put on top of outer layers and that you cant have multiple
	shoes on the same foot (for example)
	"""
