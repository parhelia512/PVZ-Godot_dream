extends Plant000Base
class_name Plant022Caltrop

@onready var attack_ray_component: AttackRayComponent = $AttackRayComponent

@export var attack_value:=20
@export_group("动画状态")
@export var is_attack:=false
var is_flattened := false


## 初始化正常出战角色信号连接
func init_norm_signal_connect():
	super()
	attack_ray_component.signal_can_attack.connect(func():is_attack = true)
	attack_ray_component.signal_not_can_attack.connect(func():is_attack = false)

## 攻击一次
func _attack_once():
	SoundManager.play_plant_SFX(Global.PlantType.PeaShooterSingle, "Throw")
	for enemy:Character000Base in attack_ray_component.all_ray_area_enenies_can_be_attacked[0]:
		if enemy is Zombie000Base:
			var zombie = enemy as Zombie000Base
			zombie.be_attacked_bullet(attack_value, Global.AttackMode.Real, false, true)

## 被压扁
## [character:Character000Base] 发动攻击的角色
func be_flattened(character:Character000Base):
	if not is_flattened:
		is_flattened = true
		character.be_caltrop()
		character_death()
		super(character)
