extends Control
class_name Dialog


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func appear_dialog():
	await get_tree().create_timer(0.1).timeout
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP 

func _on_button_pressed() -> void:
	await get_tree().create_timer(0.1).timeout
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
