extends Node2D
class_name LawnMover
## 小推车

var lane: int = -1  ## 推车行，从0开始, 创建小推车的脚本赋值
@export var move_speed: float = 200.0  ## 推车移动速度（像素/秒）
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_moving: bool = false
## 超出屏幕500像素删除
var screen_rect: Rect2  # 延后初始化

func _ready() -> void:
	# 必须在 ready 后才能安全获取视口尺寸
	screen_rect = get_viewport_rect().grow(500)


func _process(delta: float) -> void:
	if is_moving:
		position.x += move_speed * delta

		if not screen_rect.has_point(global_position):
			queue_free()


func _on_area_entered(area: Area2D) -> void:
	var area_owner = area.owner
	if area_owner is Zombie000Base:
		var zombie :Zombie000Base = area_owner
		if lane == zombie.lane:
			if not is_moving:
				is_moving = true
				animation_player.play("LawnMower_normal")
				SoundManager.play_other_SFX("lawnmower")

			zombie.be_mowered_run()
