extends Control


@onready var slots : Array[EquipSlot] = [$Head, $Chest, $Hands, $Legs, $Feet]
@onready var inv_manager : Control = get_parent()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var clicked_slot : EquipSlot = get_clicked_slot()
		
		if not clicked_slot:
			return
		
		if inv_manager.held_item:
			if inv_manager.held_item.slot_type != clicked_slot.slot_type:
				return
			if clicked_slot.data.size() >= clicked_slot.max_items:
				return
			
			clicked_slot.data.append(get_item_data(inv_manager.held_item))
			inv_manager.held_item.queue_free() #equipable items shouldn't be stackable, hence we dont need to account for stacked items
			
		else:
			if clicked_slot.data:
				var item_data : Dictionary = clicked_slot.data.pop_back()
				inv_manager.build_item_from_data(item_data)
		
		update_texture(clicked_slot)


func _draw() -> void: #just here until we implement textures
	draw_rect(Rect2(Vector2.ZERO,get_rect().size),Color(0.35, 0.373, 0.38, 0.6))


func get_clicked_slot() -> EquipSlot:
	for slot : EquipSlot in slots:
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			print("%s has been clicked" % slot)
			return slot
	
	return


func update_texture(slot : EquipSlot) -> void:
	if slot.data.size() > 0:
		var texture_path : String = ItemHandler.item_data[str(int(slot.data[-1].item_id))]["Texture Path"] 
		#converts to int first as json doesnt have int type, only floats (or number type). Hence the formatting is wrong
		#might be better to save item_id as a string anyway however
		
		slot.texture = load(texture_path) as Texture2D
	else:
		slot.texture = null


func get_item_data(item : Item) -> Dictionary:
	return {
		"item_id": item.item_id,
		"quantity": item.quantity,
	} #right now I'm passing through quantity just as a test
	#it should be removed, and other persistant properties of the item should replace it


func create_save_data() -> Dictionary[String,Array]:
	var out : Dictionary[String,Array] #Dictionary[String,Array[Dictionary[String,Variant]]]
	
	for slot : EquipSlot in slots:
		var item_arr : Array[Dictionary]
		
		for item_data : Dictionary in slot.data:
			item_arr.append(item_data)
		
		out[slot.name] = item_arr
	
	return out


func rebuild_from_data(d : Dictionary) -> void:
	for slot in slots:
		slot.data = d.get(slot.name)
		update_texture(slot)
	


func _on_mouse_entered() -> void:
	inv_manager.hovering_over_equip = true
	print("Im hovering over equip here")


func _on_mouse_exited() -> void:
	inv_manager.hovering_over_equip = false
	print("left equip inv rect")
