extends AttackComponentBase
## 发射子弹攻击行为基础组件
class_name AttackComponentBulletBase

@onready var animation_tree: AnimationTree = $"../AnimationTree"
## 冷却时间计时器
@onready var bullet_attack_cd_timer: Timer = $BulletAttackCdTimer

## 是否使用行属性进行攻击判断
@export var is_lane:=true

## 子弹攻击伤害
@export var attack_value_bullet:int = 20
@export var attack_cd:float = 2.0
## 攻击子弹场景
@export var attack_bullet_type:Global.BulletType = Global.BulletType.BulletPea
## 子弹生产位置
@export var markers_2d_bullet: Array[Marker2D]
@export_group("发射子弹音效")
## 攻击音效所属植物
@export var attack_sfx_plant_type:Global.PlantType = Global.PlantType.PeaShooterSingle
## 攻击音效名字（发射子弹）
@export var attack_sfx:StringName = &"Throw"

## 主游戏场景子弹父节点
var bullets: Node2D
func _ready() -> void:
	super()
	bullet_attack_cd_timer.wait_time = attack_cd
	attack_ray_component.is_lane = is_lane
	if is_instance_valid(MainGameDate.bullets):
		bullets = MainGameDate.bullets


## 角色速度修改
func owner_update_speed(speed_product:float):
	if not bullet_attack_cd_timer.is_stopped():
		if speed_product == 0:
			bullet_attack_cd_timer.paused = true
		else:
			bullet_attack_cd_timer.paused = false

			bullet_attack_cd_timer.start(bullet_attack_cd_timer.time_left / speed_product)

	bullet_attack_cd_timer.wait_time = attack_cd / speed_product

## 开始攻击
func attack_start():
	super()
	## 先随机等待一段时间调用一次攻击
	await get_tree().create_timer(randf_range(0, bullet_attack_cd_timer.wait_time/3)).timeout
	if is_attack and bullet_attack_cd_timer.is_stopped():
		_on_bullet_attack_cd_timer_timeout()
		bullet_attack_cd_timer.start()
	## 等待一段时间后可能为非攻击状态
	if not is_attack:
		attack_end()

## 结束攻击
func attack_end():
	super()
	bullet_attack_cd_timer.stop()

## 攻击间隔后触发执行攻击
func _on_bullet_attack_cd_timer_timeout() -> void:
	# 在这里调用实际攻击逻辑
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

## 发射子弹（动画调用）
func _shoot_bullet():
	for i in range(markers_2d_bullet.size()):
		var marker_2d_bullet = markers_2d_bullet[i]
		var ray_direction = attack_ray_component.ray_area_direction[i]
		var bullet:Bullet000Base = Global.get_bullet_scenes(attack_bullet_type).instantiate()
		## 子弹初始位置
		var bullet_pos_ori = marker_2d_bullet.global_position
		bullet.init_bullet(owner.lane, bullets.to_local(bullet_pos_ori), ray_direction, is_lane)
		bullets.add_child(bullet)
		play_throw_sfx()


func play_throw_sfx():
	## 播放音效
	SoundManager.play_plant_SFX(attack_sfx_plant_type, attack_sfx)
