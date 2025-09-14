extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scene = preload("res://scenes/manager/dancer_manager.tscn")
	print(scene is PackedScene)  # 应该是 true
	var inst = scene.instantiate()
	print(inst)  # 应该是 Node2D（或 DancerManager 实例）
