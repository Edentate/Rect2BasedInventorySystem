extends Control

@onready var par : Control = get_parent()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		queue_redraw()


#func _draw() -> void:
	#if par.held_item: 
		##draw_rect(held_item.get_rect().grow(2),Color(0.0, 1.0, 0.0, 0.733))
		#draw_rect(par.snap_to_grid(par.held_item,par.curr_inventory).grow(1),Color(0.348, 0.348, 0.348, 0.3))

#func _process(delta: float) -> void:
	#queue_redraw()
