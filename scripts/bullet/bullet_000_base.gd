extends Node2D
class_name Bullet000Base

@onready var bullet_shadow: Sprite2D = $BulletShadow
@onready var area_2d_attack: Area2D = $Area2DAttack

## 子弹击中特效
@onready var bullet_effect: BulletEffect000Base = $BulletEffect
## 子弹本体节点
@onready var body: Node2D = $Body
## 子弹基类
@export_group("子弹基础属性")
## 子弹阵营
@export var bullet_camp:Global.CharacterType = Global.CharacterType.Plant
## 子弹是否旋转
@export var is_rotate := false
## 最大攻击次数(-1表示可以无限攻击)
@export var max_attack_num:=1
## 当前攻击次数
var curr_attack_num:=0
## 子弹伤害
@export var attack_value := 20
## 子弹默认移动速度
@export var speed: float = 300.0
## 子弹默认移动方向
@export var direction: Vector2 = Vector2.RIGHT
## 子弹伤害模式：普通，穿透，真实
@export var bullet_mode : Global.AttackMode
## 子弹移动离出生点最大距离，超过自动销毁
@export var max_distance := 2000.0
## 子弹初始位置
var start_pos: Vector2
## 默认是否激活行属性，激活后只能攻击本行的僵尸
@export var default_bullet_lane_activate:=true
var bullet_lane_activate:bool
## 子弹行属性
var bullet_lane :int = -1
@export_subgroup("子弹音效相关")
## 是否触发受击音效(火焰豌豆就不触发)
@export var trigger_be_attack_sfx := true
## 子弹本身音效
@export var type_bullet_SFX :SoundManagerClass.TypeBulletSFX =  SoundManagerClass.TypeBulletSFX.Pea


@export_group("子弹攻击相关")
## 可以攻击的敌人状态
@export_flags("1 正常", "2 悬浮", "4 地刺") var can_attack_plant_status:int = 1
@export_flags("1 正常", "2 跳跃", "4 水下", "8 空中", "16 地下") var can_attack_zombie_status:int = 1

@export_group("子弹升级相关")
## 是否可以升级子弹
@export var is_can_up:=false
## 子弹升级需要的植物种类（升级子弹的植物需要有对应的area区域）
@export var bullet_up_plant_type : Global.PlantType
## 子弹升级种类（子弹升级后的子弹种类）
@export var bullet_up_type:Global.BulletType

func _ready() -> void:
	body.rotation = direction.angle()

	if is_rotate:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(body, "rotation", TAU, 1.0).as_relative()


## 初始化子弹属性
func init_bullet(lane:int, start_pos:Vector2, direction:= Vector2.RIGHT, \
	bullet_lane_activate:bool=default_bullet_lane_activate, \
	can_attack_plant_status:int= can_attack_plant_status, \
	can_attack_zombie_status:int= can_attack_zombie_status
	):

	self.bullet_lane_activate = bullet_lane_activate
	## 子弹行
	if bullet_lane_activate:
		self.bullet_lane = lane
	self.start_pos = start_pos
	self.direction = direction
	position = start_pos
	self.can_attack_plant_status = can_attack_plant_status
	self.can_attack_zombie_status = can_attack_zombie_status


## 子弹与敌人碰撞
func _on_area_2d_attack_area_entered(area: Area2D) -> void:
	var enemy:Character000Base = area.owner
	## TODO:攻击植物子弹
	if enemy is Plant000Base:
		if not enemy.curr_be_attack_status & can_attack_plant_status:
			return
	elif enemy is Zombie000Base:
		## 如果不是可攻击状态敌人
		if not enemy.curr_be_attack_status & can_attack_zombie_status:
			return
	else:
		push_error("敌人不是植物,不是僵尸")
	## 子弹还有攻击次数
	if max_attack_num != -1 and curr_attack_num < max_attack_num:
		## 如果子弹有行属性
		if bullet_lane_activate:
			if bullet_lane == enemy.lane:
				attack_once(enemy)
		else:
			attack_once(enemy)
	## 子弹无限穿透
	if max_attack_num == -1:
		attack_once(enemy)


## 对敌人造成伤害
func _attack_enemy(enemy:Character000Base):
	if enemy is Zombie000Base:
		## 攻击敌人
		enemy.be_attacked_bullet(attack_value, bullet_mode, true, trigger_be_attack_sfx)
	elif enemy is Plant000Base:
		enemy = get_first_be_hit_plant_in_cell(enemy)
		## 攻击敌人
		enemy.be_attacked_bullet(attack_value, bullet_mode, true, trigger_be_attack_sfx)

## 直线子弹先对壳类进行攻击
## 抛物线子弹先对Norm进行攻击
func get_first_be_hit_plant_in_cell(plant:Plant000Base)->Plant000Base:
	return plant

## 攻击一次
func attack_once(enemy:Character000Base):
	curr_attack_num += 1
	if max_attack_num != -1 and curr_attack_num > max_attack_num:
		return
	## 对敌人造成伤害
	if enemy != null:
		_attack_enemy(enemy)
		## 是否有音效
		if type_bullet_SFX != SoundManagerClass.TypeBulletSFX.Null:
			SoundManager.play_bullet_attack_SFX(type_bullet_SFX)
	## 如果有子弹特效
	if bullet_effect.is_bullet_effect:
		bullet_effect.activate_bullet_effect()

	## 判断是否进入删除队列
	if max_attack_num != -1 and curr_attack_num >= max_attack_num:
		queue_free()


#region 子弹升级相关
## 创建升级后的子弹
func create_new_bullet_up():
	var new_bullet_up_scenes = Global.get_bullet_scenes(bullet_up_type)
	## 子弹升级后更新行属性，上次升级的火炬树桩
	var bullet_up :Bullet000Base = new_bullet_up_scenes.instantiate()
	bullet_up.init_bullet(bullet_lane, position, direction, bullet_lane_activate)

	return bullet_up
#endregion
