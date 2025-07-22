extends CharacterBase
class_name PlantBase

var be_shovel_look_color := Color(1, 1, 1)

var curr_scene:Node
var bullets: Node2D
var bombs: Node2D

@onready var area_2d: Area2D = $Area2D
@export_group("植物种植")
@export var plant_condition : ResourcePlantCondition
## 行和列
@export var row_col:Vector2i

@export_group("植物眨眼相关， no_blink表示没有眨眼功能")
## 植物没有眨眼功能
@export var no_blink := false
@export var blink_sprite:Sprite2D				## 控制idle状态下植物眨眼
@export var blink_sprite_texture:Array[Texture]	## 控制植物眨眼纹理图片

var blink_timer :Timer	## 眨眼计时器
## 动画状态是否可以眨眼,is_blink才会眨眼
@export var is_blink := true


@export_group("植物是否为idle状态，默认为否")
@export var is_idle := false

signal plant_free_signal


func _ready() -> void:
	super._ready()

	get_main_game_node()
	if is_idle:
		keep_idle()
		
	label_hp.get_node('Label').text = str(curr_Hp)
	
	if Global.display_plant_HP_label:
		label_hp.visible = true
	else:
		label_hp.visible = false

	## 植物有眨眼功能
	if not no_blink:
		if blink_timer == null:
			# 创建 Timer 节点
			blink_timer = Timer.new()
			blink_timer.name = "BlinkTimer"
			blink_timer.wait_time = 5.0
			blink_timer.one_shot = false
			blink_timer.autostart = true
			add_child(blink_timer)
			# 连接 timeout 信号到函数
			blink_timer.timeout.connect(_on_blink_timer_timeout)

func get_main_game_node():
	curr_scene = get_tree().current_scene
	if curr_scene is MainGameManager:
		bullets = get_tree().current_scene.get_node("Bullets")
		bombs = get_tree().current_scene.get_node("Bombs")
	
## 植物初始化相关
func init_plant(row_col:Vector2i) -> void:
	self.row_col = row_col
	
	
#region 眨眼相关
func _on_blink_timer_timeout() -> void:
	## is_blink状态下眨眼
	if is_blink:
		do_blink(blink_sprite)
	
	
func do_blink(blink_sprite) -> void:
	blink_sprite.visible = true
	blink_sprite.texture = blink_sprite_texture[0]
	if is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		blink_sprite.texture = blink_sprite_texture[1]
	if is_inside_tree():
		await get_tree().create_timer(0.1).timeout
		blink_sprite.texture = blink_sprite_texture[0]
	if is_inside_tree():
		await get_tree().create_timer(0.1).timeout
	
		blink_sprite.visible = false
#endregion

#region 被铲子威胁
# 重写父类改变颜色方法
func _update_modulate():
	var final_color = base_color * _hit_color * debuff_color * be_shovel_look_color
	body.modulate = final_color

# 被铲子威胁
func be_shovel_look():
	be_shovel_look_color = Color(2, 2, 2)
	_update_modulate()
	
# 被铲子威胁结束
func be_shovel_look_end():
	be_shovel_look_color = Color(1, 1, 1)
	_update_modulate()
#endregion

#region 被攻击

func judge_status():
	if curr_Hp <= 0:
		_plant_free()

## 代替受伤，同一个格子内，有保护壳，保护壳代替掉血,睡莲重写
func replace_attack(attack_value:int,zombie:ZombieBase) -> bool:
	## 如果不是保护壳
	if plant_condition.place_plant_in_cell != Global.PlacePlantInCell.Shell:
		var plant_cell:PlantCell = get_parent()
		if plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell]:
			plant_cell.plant_in_cell[Global.PlacePlantInCell.Shell].be_eated(attack_value, zombie)
			return true
	return false
	
# 重写父类被僵尸啃咬攻击
func be_eated(attack_value:int, zombie:ZombieBase):
	## 如果没有能替其掉血的
	if not replace_attack(attack_value, zombie):
		# 被僵尸啃咬子弹属性为真实伤害（略过2类防具，直接对1类防具和血量攻击）
		Hp_loss(attack_value, Global.AttackMode.Real)
	


#重写父类血量变化
func Hp_loss(attack_value:int, bullet_mode : Global.AttackMode = Global.AttackMode.Norm, trigger_be_attack_SFX:=true, no_drop:=false):

	curr_Hp -= attack_value
	label_hp.get_node('Label').text = str(curr_Hp)

	judge_status()
	
	
#endregion

#region 植物死亡相关
# 植物死亡
func _plant_free():
	plant_free_signal.emit(self)
	
	self.queue_free()
	
# 铲掉植物
func be_shovel_kill():
	_plant_free()
	
## 被压扁
func be_flattened(zombie:ZombieBase):
	## 被压扁改变形状和位置
	var global_position_shaodw:Vector2 = shadow.global_position
	body.scale.y = 0.5
	var now_global_position_shaodw:Vector2 = shadow.global_position
	body.position.y -= now_global_position_shaodw.y - global_position_shaodw.y
	## 停止每帧处理
	set_process(false)
	set_physics_process(false)
	## 被压扁后删除所有除body节点外的所有节点（不再动画，没有交互）
	for child in get_children():
		if child != body:
			child.queue_free()
	## 发射死亡信号
	plant_free_signal.emit(self)
	## 两秒后删除
	await get_tree().create_timer(2).timeout
	self.queue_free()

## 如果被冰车压扁(地刺重写)
func be_flattened_zomboni(zombie:ZombieBase):
	be_flattened(zombie)
#endregion


#region 爆炸特效更换父节点
#使用父类方法	child_node_change_parent(bomb_effect, bullets)
## 更换节点父节点
#func bomb_effect_change_parent(bomb_effect:Node2D):
	## 保存全局变换
	#var global_transform = bomb_effect.global_transform
#
	## 移除并添加到bullet节点
	#bomb_effect.get_parent().remove_child(bomb_effect)
	#bullets.add_child(bomb_effect)
#
	## 恢复全局变换，保持位置不变
	#bomb_effect.global_transform = global_transform
#endregion

#region idle展示状态(图鉴展示)
func keep_idle():
	label_hp.visible = false
	area_2d.queue_free()
#endregion
