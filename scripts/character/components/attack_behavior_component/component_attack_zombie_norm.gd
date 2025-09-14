extends AttackComponentBase
class_name AttackComponentZombieNorm
## 普通僵尸攻击组件

@export_group("每秒伤害值")
@export var init_attack_value_per_min :int = 100

## 每分钟攻击值
var curr_attack_value_per_min :int = 100
enum E_AttackValueFactor{
	Death,			## 死亡，攻击力置为0
	Speed,			## 攻击速度，
	PaperDrop,		## 报纸掉落，攻击力翻倍
	JacksonEnter,	## 舞王入场时,攻击值为0
}

var attack_value_factor:Dictionary[E_AttackValueFactor, float] = {}
## 间隔帧数
var frame_counter := 0


func _ready() -> void:
	super()
	curr_attack_value_per_min = init_attack_value_per_min

## 修改攻击速度,通过修改攻击值实现
func owner_update_speed(speed_product:float):
	update_attack_value(speed_product, E_AttackValueFactor.Speed)

## 修改攻击值
func update_attack_value(value:float, influence_factor:E_AttackValueFactor):
	attack_value_factor[influence_factor] = value
	var res_product = GlobalUtils.get_dic_product(attack_value_factor)
	curr_attack_value_per_min = init_attack_value_per_min * res_product

func _physics_process(delta: float) -> void:
	if is_attack_res:
		frame_counter += 1
		if not is_instance_valid(attack_ray_component.enemy_can_be_attacked):
			return
		if frame_counter % 8 == 7 and is_instance_valid(attack_ray_component.enemy_can_be_attacked):
			attack_ray_component.enemy_can_be_attacked.be_zombie_eat(curr_attack_value_per_min * delta * 8, owner)
			frame_counter = 0

## 攻击一次发亮，动画调用
func attack_once():
	if is_instance_valid(attack_ray_component.enemy_can_be_attacked) and not owner.is_death:
		attack_ray_component.enemy_can_be_attacked.be_zombie_eat_once(owner)
		SoundManager.play_zombie_SFX(Global.ZombieType.Z001Norm, "Chomp")
