extends Node2D
class_name LawnMovers

var all_lawn_movers:Array[LawnMover] = []
var all_lawn_movers_pos:Array[Vector2] = []
var all_lawn_movers_backup:Array[LawnMover] = []

func _ready() -> void:
	for lawn_mover in get_children():
		all_lawn_movers.append(lawn_mover)
		all_lawn_movers_pos.append(lawn_mover.position)
		all_lawn_movers_backup.append(lawn_mover.duplicate())

		lawn_mover_appear(lawn_mover)

	## 补充小推车
	EventBus.subscribe("replenish_lawn_mover", replenish_lawn_mover)

## 补充小推车
func replenish_lawn_mover():
	for i in range(all_lawn_movers.size()):
		if is_instance_valid(all_lawn_movers[i]) and not all_lawn_movers[i].is_moving:
			continue
		else:
			var new_lawn_mover = all_lawn_movers_backup[i].duplicate()
			add_child(new_lawn_mover)
			lawn_mover_appear(new_lawn_mover)
			all_lawn_movers[i] = new_lawn_mover

## 小推车出现动画
func lawn_mover_appear(lawn_mover:Node2D):
	var pos_x = lawn_mover.position.x
	lawn_mover.position.x -= 100
	var tween:Tween = create_tween()
	tween.tween_property(lawn_mover, "position:x", pos_x, 0.5)
