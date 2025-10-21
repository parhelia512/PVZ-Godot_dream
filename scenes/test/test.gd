extends Node2D

@onready var almanac_ground_pool: Sprite2D = $AlmanacGroundPool
@onready var almanac_ground_roof: Sprite2D = $AlmanacGroundRoof
@onready var control: Control = $Control


@onready var area_2d_2: Area2D = $AlmanacGroundRoof/Area2D2

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#print("移动前位置", almanac_ground_pool.position)
	#print("移动前全局位置", almanac_ground_pool.global_position)
	#remove_child(almanac_ground_pool)
	#control.add_child(almanac_ground_pool)
#
	#print("移动后位置", almanac_ground_pool.position)
	#print("移动后全局位置", almanac_ground_pool.global_position)
#

func _on_area_2d_area_entered(area: Area2D) -> void:
	prints("检测到区域2")
	print(area.get_parent().name)


func _on_area_2d_area_exited(area: Area2D) -> void:
	prints("检测到区域2离开")


func _on_button_pressed() -> void:
	area_2d_2.monitorable = not area_2d_2.monitorable
	area_2d_2.monitoring = not area_2d_2.monitoring
	area_2d_2.monitoring = not area_2d_2.monitoring



func _on_area_2d_2_area_entered(area: Area2D) -> void:
	print("区域2检测到区域一")
	pass # Replace with function body.
