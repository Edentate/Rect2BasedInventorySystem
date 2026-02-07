extends Control

#BUG
#have a stacked item in the equip inventory, when removed and a single one is placed
#it will have an incorrect zindex
#this is kinda a non-issue, as the equip inventory should only have unstacked items

const ITEM : PackedScene = preload("uid://rljltodcmbxq")
const GRID_SIZE : int = 16

@onready var player_inventory: InventoryData = $PlayerInventory
@onready var object_inventory: InventoryData = $ObjectInventory
@onready var equip_inventory: VBoxContainer = $EquipInventory

var curr_inventory : InventoryData
var hovering_over_equip : bool = false
var held_item : Item


func _input(event: InputEvent) -> void:
	if not curr_inventory :
		return
	#if curr_inventory is EquipInventoryData:
		#return
	
	if event.is_action_pressed("left_click"):
		var clicked_item : Item = get_item_under_mouse()
		
		if not clicked_item:
			if held_item:
				place_item(false)
		else:
			if held_item:
				if clicked_item.max_stack_size > 1:
					stack_item(clicked_item, false)
			else:
				print("attempted pick up of ", clicked_item)
				pick_item(clicked_item)
				
	elif event.is_action_pressed("right_click"):
		if held_item:
			var clicked_item : Item = get_item_under_mouse()
			if not clicked_item:
				place_item(true)
			else:
				stack_item(clicked_item, true)


func _unhandled_input(event: InputEvent) -> void:
	if held_item:
		if event.is_action_pressed("CW_item_rotate"):
			held_item.rotate_item(true)
		elif event.is_action_pressed("ACW_item_rotate"):
			held_item.rotate_item(false)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_spawn_item"):
		print("attempt spawn")
		spawn_item(randi_range(1,4))
		return
	#if curr_inventory:
	if event.is_action_pressed("DEBUG_clear_inv"):
		#var data : Array[Dictionary] = export_save_data(curr_inventory)
		#InventoryHandler.save_inventory(curr_inventory,data)
		var data = equip_inventory.create_save_data()
		InventoryHandler.save_equip_inventory(data)
	elif event.is_action_pressed("DEBUG_load_inv"):
		#var data : Array[Dictionary] = InventoryHandler.load_inventory(curr_inventory)
		#rebuild_from_save(curr_inventory,data)
		var data = InventoryHandler.load_equip_inventory()
		equip_inventory.rebuild_from_data(data)



func get_item_under_mouse() -> Item:
	for item : Item in curr_inventory.data:
		if item.get_rect().has_point(get_global_mouse_position()):
			print(item)
			return item
	return null


func spawn_item(item_id : int, quantity : int = 1) -> void:
	if held_item:
		return
	
	var new_item : Item = ITEM.instantiate()
	add_child(new_item)
	
	new_item.selected = true
	new_item.z_index = 1
	
	new_item.load_item(item_id, quantity)
	
	held_item = new_item


func pick_item(item : Item) -> void:
	item.offset = item.global_position - get_global_mouse_position()
	item.z_index = 1
	curr_inventory.data.erase(item)
	
	item.selected = true
	held_item = item


func stack_item(clicked_item : Item, place_single : bool) -> void:
	if clicked_item.item_id != held_item.item_id:
		return
	
	if place_single:
		if clicked_item.quantity < clicked_item.max_stack_size:
			clicked_item.quantity += 1
			held_item.quantity -= 1
	else:
		var space : int = clicked_item.max_stack_size - clicked_item.quantity
		var amount : int = min(space, held_item.quantity)
	
		clicked_item.quantity += amount
		held_item.quantity -= amount
	
	if held_item.quantity <= 0:
		held_item.queue_free()
		held_item = null


func place_item(place_single : bool) -> void:
	var snapped_rect : Rect2 = snap_to_grid(curr_inventory,held_item)
	
	if not can_place(curr_inventory, snapped_rect):
		return
	
	var placing_item : Item = held_item
	
	if place_single:
		placing_item = clone_item(held_item)
		placing_item.quantity = 1
		held_item.quantity -= 1
	
	if placing_item.get_parent() != self:
		add_child(placing_item)
	
	placing_item.global_position = snapped_rect.get_center()
	placing_item.selected = false
	placing_item.z_index = 0
	
	curr_inventory.data.append(placing_item)
	
	if place_single:
		if held_item.quantity <= 0:
			held_item.queue_free()
			held_item = null
	else:
		held_item = null


func can_place(inventory : InventoryData, rect : Rect2) -> bool:
	if not inventory.get_global_rect().encloses(rect):
		return false
	
	for item : Item in curr_inventory.data:
		if rect.intersects(item.get_rect()):
			return false
	
	return true


func snap_to_grid(inventory : InventoryData, item : Item) -> Rect2:
	var inv_rect : Rect2 = inventory.get_global_rect()
	var item_rect : Rect2 = item.get_rect()
	
	var local_pos : Vector2 = item_rect.position - inv_rect.position
	
	return Rect2(
		Vector2(
			round(local_pos.x / GRID_SIZE) * GRID_SIZE,
			round(local_pos.y / GRID_SIZE) * GRID_SIZE
		) + inv_rect.position,
		item_rect.size
	)


func clone_item(item : Item) -> Item:
	var new_item : Item = ITEM.instantiate()
	add_child(new_item)
	
	new_item.load_item(item.item_id, item.quantity)
	new_item.rotation_state = item.rotation_state
	
	return new_item



func export_save_data(inventory : InventoryData = player_inventory) -> Array[Dictionary]:
	var out : Array[Dictionary] = []
	
	for item : Item in inventory.data:
		out.append({
			"item_id": item.item_id,
			"quantity": item.quantity,
			"rotation_state": item.rotation_state,
			"local_position": {
				"x" : item.position.x - inventory.position.x,
				"y" : item.position.y- inventory.position.y
				}
		})
	
	return out


func rebuild_from_save(inventory : InventoryData, data : Array[Dictionary]) -> void:
	clear_inventory(inventory)
	
	for d : Dictionary in data:
		var item : Item = ITEM.instantiate()
		add_child(item)
		
		item.load_item(d["item_id"], d["quantity"])
		item.rotation_state = d["rotation_state"]
		item.position = inventory.position + Vector2(
			d["local_position"]["x"],
			d["local_position"]["y"]
			)
		
		inventory.data.append(item)


func build_item_from_data(d : Dictionary) -> void:
	if held_item:
		print("Attempted to build item from data, but an item was already held")
		return 
	
	var item : Item = ITEM.instantiate()
	add_child(item)
	
	item.load_item(d["item_id"], d["quantity"])
	item.selected = true
	held_item = item


func clear_inventory(inventory : InventoryData) -> void:
	for item : Item in inventory.data:
		item.queue_free()
	inventory.data.clear()
