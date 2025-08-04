extends BulletBase
class_name BulletStar


func _ready():
	super._ready()
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(bullet_body, "rotation", TAU, 1.0).as_relative()
