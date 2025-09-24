extends Bullet000Base
class_name Bullet000ParabolaBase

## 抛物线运行的最大误差, 敌人从瞄准时移动超过该值, 子弹不会进行修正
@export var max_diff_x: float = 200
## 控制抛物线的顶点高度 (调节上下弯曲的程度)
@export var parabola_height: float = -300
## 抛物线(贝塞尔曲线)子弹需要根据敌人位置每帧更新(_ready之前赋值)
var enemy: Character000Base
## 敌人最终位置，敌人死亡时位置不变
var enemy_last_global_pos: Vector2
## 敌人移动距离(大于最大距离后,子弹不进行修正)
var curr_diff_x: float
## 贝塞尔曲线当前时间
var current_time = 0.0
## 贝塞尔曲线的控制点1
var start_control_point: Vector2
## 开始时全局位置
var start_global_pos:Vector2
## 子弹移动的总时间(控制点到起点和终点距离和/速度)
var all_time:float

#region 影子相关
## 当前场景是否有斜坡,有斜坡的场景每帧检测斜面位置
var is_have_slope:=false
## 影子全局位置默认值y,影子不跟随斜坡移动时的全局位置y
var global_pos_y_shadow_default:float
## 影子与第一行斜面的偏移量
var offset_shadow_first_slope:float

#endregion

func _ready() -> void:
	super()
	if is_instance_valid(enemy):
		enemy_last_global_pos = enemy.global_position
	curr_diff_x = 0
	start_global_pos = global_position
	# 计算贝塞尔曲线的控制点，确保曲线的最高点位于中间
	start_control_point = Vector2(
		(global_position.x + enemy_last_global_pos.x) / 2,
		# 确保最高点在路径的中间，调节 y 坐标来控制弯曲程度
		min(global_position.y, enemy_last_global_pos.y) + parabola_height
	)
	all_time = (start_control_point.distance_to(global_position) + start_control_point.distance_to(enemy_last_global_pos)) / speed

	## 如果有斜坡
	if is_instance_valid(MainGameDate.slope):
		is_have_slope = true
		offset_shadow_first_slope = 10 + MainGameDate.slope.get_offest_first_slope(bullet_lane)
	else:
		is_have_slope = false
		global_pos_y_shadow_default = MainGameDate.all_zombie_rows[bullet_lane].zombie_create_position.global_position.y

	update_shadow_global_pos()


## 抛物线子弹初始化(子弹初始化之后)
## [enemy: Character000Base]: 敌人
## [enemy_global_position:Vector2]:敌人位置,发射单位赋值,若发射时敌人死亡,使用该位置
## TODO: 敌人死亡时, 敌人位置赋值为发射子弹的位置,修改为敌人死亡位置
func init_bullet_parabola(enemy: Character000Base, enemy_global_position:Vector2):
	self.enemy = enemy
	self.enemy_last_global_pos = enemy_global_position

func _process(delta: float) -> void:
	## 若敌人存在且敌人还未死亡,更新其位置
	if is_instance_valid(enemy) and not enemy.is_death:
		##$ 计算敌人移动的水平差距
		curr_diff_x += abs(enemy.global_position.x - enemy_last_global_pos.x)
		if curr_diff_x < max_diff_x:
			enemy_last_global_pos = enemy.global_position + Vector2(0, -20)

	current_time += delta
	var t :float= min(current_time / all_time, 1)
	## 使用缓动函数来调整时间 t (最后时移动变快)
	var eased_t = eased_time(t)
	## 如果到达最终落点时未命中敌人,攻击空气销毁子弹
	if eased_t >= 1:
		attack_once(null)
	## 子弹根据贝塞尔曲线的路径更新位置
	global_position = start_global_pos.bezier_interpolate(start_control_point, enemy_last_global_pos, enemy_last_global_pos, eased_t)
	update_shadow_global_pos()

## 控制影子位置
func update_shadow_global_pos():
	if is_have_slope:
		update_global_pos_y_shadow_default_on_have_slope()

	bullet_shadow.global_position.y = global_pos_y_shadow_default

## 场景有斜坡时更新默认影子y值
func update_global_pos_y_shadow_default_on_have_slope():
	## 在斜坡左边
	if global_position.x < MainGameDate.slope.global_pos_slope_start.x:
		global_pos_y_shadow_default = MainGameDate.slope.global_pos_slope_start.y + 10 + offset_shadow_first_slope
	## 在斜坡右边
	elif global_position.x > MainGameDate.slope.global_pos_slope_end.x:
		global_pos_y_shadow_default = MainGameDate.slope.global_pos_slope_end.y + 10 + offset_shadow_first_slope
	## 在斜坡中
	else:
		# 计算斜坡上的y值
		var slope_start = MainGameDate.slope.global_pos_slope_start
		var slope_end = MainGameDate.slope.global_pos_slope_end
		var t = (global_position.x - slope_start.x) / (slope_end.x - slope_start.x)  # 计算相对位置

		# 基于斜坡起始和结束点计算中间位置的y值
		var slope_y = slope_start.y + (slope_end.y - slope_start.y) * t
		global_pos_y_shadow_default = slope_y + 10 + offset_shadow_first_slope

## 自定义的缓动函数，分段加速,抛物线移动到最后时加速
func eased_time(t: float) -> float:
	if t > 0.5:
		if (t-0.5) * 1.2 + 0.5 > 0.6:
			if ((t-0.5) * 1.2 + 0.5 - 0.6) * 1.3 + 0.6 > 0.9:
				return (((t-0.5) * 1.2 + 0.5 - 0.6) * 1.3 + 0.6 - 0.9) * 2 + 0.9
			return ((t-0.5) * 1.2 + 0.5 - 0.6) * 1.3 + 0.6
		return (t-0.5) * 1.2 + 0.5
	else:
		return t

