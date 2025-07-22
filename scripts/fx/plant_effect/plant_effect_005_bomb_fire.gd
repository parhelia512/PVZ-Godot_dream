extends Node2D
class_name Fire

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate_bomb_effect(exist_time:float = 1.0):
	animation_player.play("fire_flame")
	await get_tree().create_timer(exist_time + randf() / 5).timeout
	animation_player.play("fire_done")

func _fire_end():
	queue_free()
