extends Control
class_name PlantCell

signal click_cell
signal cell_mouse_enter
signal cell_mouse_exit

@onready var plant_position: Control = $PlantPosition
@export var is_plant := false
@export var plant:PlantBase
@export var col:int


func _ready() -> void:
	var new_stylebox_normal = $Button.get_theme_stylebox("pressed").duplicate()
	$Button.add_theme_stylebox_override("normal", new_stylebox_normal)
	

func _on_button_pressed() -> void:

	click_cell.emit(self)


func _on_button_mouse_entered() -> void:

	cell_mouse_enter.emit(self)


func _on_button_mouse_exited() -> void:

	cell_mouse_exit.emit(self)
