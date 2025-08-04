extends BulletBase
class_name BulletCactus

## 是否为攻击空中气球的子弹
@export var is_sky := false
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	super._ready()
	if is_sky:
		area_2d.collision_mask = 2048


## 子弹击中僵尸
func _on_area_2d_area_entered(area: Area2D) -> void:
	## 如果是攻击气球的子弹
	if is_sky:
		pass
	else:
		super._on_area_2d_area_entered(area)
