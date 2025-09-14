extends BulletLinear000Base
class_name Bullet008Star

func _ready() -> void:
	super()
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(body, "rotation", TAU, 1.0).as_relative()


func _process(delta: float) -> void:
	super(delta)
