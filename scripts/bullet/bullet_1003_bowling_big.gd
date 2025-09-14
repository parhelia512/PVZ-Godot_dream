extends BulletLinear000Base
class_name Bullet1003BowlingBig

@onready var body_correct: Node2D = $Body/BodyCorrect

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

## 对敌人造成伤害
func _attack_enemy(enemy:Character000Base):
	## 攻击敌人
	enemy.be_attack_to_death(trigger_be_attack_sfx)
