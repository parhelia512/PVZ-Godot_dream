extends Node2D
class_name MainGameSlope
## 主游戏斜面(屋顶)

## 第一个斜面coll,用于计算夹角单位方向和法向量
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
## 所有斜面的区域
var all_slope_area:Array[Area2D] = []
## 与地面的夹角方向
var dir_ground : Vector2
## 斜面法向量,地面上方向
var normal_vector_slope :Vector2
## 斜面起始全局坐标
var global_pos_slope_start:Vector2
## 斜面结束全局坐标
var global_pos_slope_end:Vector2

func _ready() -> void:
	MainGameDate.slope = self
	## 斜面形状
	var slope_shape:SegmentShape2D = collision_shape_2d.shape
	dir_ground = get_unit_direction(slope_shape.a, slope_shape.b)
	global_pos_slope_start = collision_shape_2d.global_position
	global_pos_slope_end = global_pos_slope_start + slope_shape.b
	#print("斜面起始全局位置")
	print("屋顶斜面单位方向为:", dir_ground)
	## 逆时针旋转90度
	normal_vector_slope = Vector2(dir_ground.y, -dir_ground.x)
	print("屋顶斜面法向量方向(地面上方向)为:", normal_vector_slope)

	for area_node:Area2D in get_children():
		area_node.area_entered.connect(_on_area_2d_area_entered)
		area_node.area_exited.connect(_on_area_2d_area_exited)
		all_slope_area.append(area_node)

## 计算线段的单位方向向量
func get_unit_direction(p1: Vector2, p2: Vector2) -> Vector2:
	var direction = p2 - p1  # 计算线段的方向向量
	var length = direction.length()  # 计算向量的模长（长度）
	if length != 0:
		return direction.normalized()  # 返回单位向量（方向相同，但长度为1）
	else:
		return Vector2.ZERO  # 如果线段的两个端点重合，返回零向量

## 僵尸\小推车进入
##TODO:小推车
func _on_area_2d_area_entered(area: Area2D) -> void:
	## 如果检测到僵尸
	if area.owner is Zombie000Base:
		#print("检测到僵尸")
		area.owner.update_move_dir(dir_ground)

## 僵尸\小推车离开
##TODO:小推车
func _on_area_2d_area_exited(area: Area2D) -> void:
	## 如果检测到僵尸
	if area.owner is Zombie000Base:
		area.owner.update_move_dir(Vector2.ZERO)

## 获取当前行斜坡与第一行斜坡的偏移量
func get_offest_first_slope(lane:int)->float:
	return all_slope_area[lane].position.y - all_slope_area[0].position.y

