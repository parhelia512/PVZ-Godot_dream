extends BulletLinear000Base
class_name Bullet1002BowlingBomb

@onready var body_correct: Node2D = $Body/BodyCorrect
@onready var bomb_component: BombComponentNorm = %BombComponent

## 旋转速度
var rotation_speed = 5.0

## 初始化子弹属性
## 初始化子弹属性
func init_bullet(lane:int, start_pos:Vector2, direction:= Vector2.RIGHT, \
	bullet_lane_activate:bool=default_bullet_lane_activate, \
	can_attack_plant_status:int = can_attack_plant_status, \
	can_attack_zombie_status:int=can_attack_zombie_status
	):
	super(lane, start_pos, direction, bullet_lane_activate, can_attack_plant_status, can_attack_zombie_status)

	z_as_relative = false
	z_index = 415 + lane * 10


func _process(delta: float) -> void:
	super._process(delta)
	body_correct.rotation += rotation_speed * delta


## 攻击一次
func attack_once(enemy:Character000Base):
	bomb_component.bomb_once()
	queue_free()
