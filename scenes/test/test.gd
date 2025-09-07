extends Node2D

@onready var almanac_ground_pool: Sprite2D = $AlmanacGroundPool
@onready var almanac_ground_roof: Sprite2D = $AlmanacGroundRoof
@onready var control: Control = $Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("移动前位置", almanac_ground_pool.position)
	print("移动前全局位置", almanac_ground_pool.global_position)
	remove_child(almanac_ground_pool)
	control.add_child(almanac_ground_pool)
	
	print("移动后位置", almanac_ground_pool.position)
	print("移动后全局位置", almanac_ground_pool.global_position)
	
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	prints("检测到区域2")
