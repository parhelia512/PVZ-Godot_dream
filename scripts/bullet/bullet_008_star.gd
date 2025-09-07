extends BulletLinear000Base
class_name Bullet008Star


func _process(delta: float) -> void:
	super(delta)

	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(body, "rotation", TAU, 1.0).as_relative()
