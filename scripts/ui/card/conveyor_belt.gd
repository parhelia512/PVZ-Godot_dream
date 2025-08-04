extends Control
class_name ConveyorBelt


@onready var main_game: MainGameManager = $"../../.."

@export_group("传送带齿轮")
## 传送带齿轮,每移动502像素值生成新齿轮
@export var CB_list : Array[TextureRect]
## 传送带移动速度
@export var CB_velocity :float = 25.0
## 传送带齿轮父节点
@onready var conveyor_belt_gear: Panel = $BG/ConveyorBeltGear
## 当前最前面的齿轮索引位置
var curr_first:int = 0

@export_group("传送带卡片")
@onready var card_area: Panel = $BG/CardArea
@onready var card_position: Card = $BG/CardArea/CardPosition
var card_list :Array[Card] = []
## 卡片生成时间管理器
@onready var timer: Timer = $Timer
## 卡片生成时间
@export var time_create_cd :float = 3
## 最大卡片数量，固定10个
@export var num_card_max :int = 10
## 每张卡片的位置x,从0开始隔50像素个，ready函数中自动生成
@export var card_position_x :Array[float] = []

@export_group("出现卡片相关")
## 可能出现的卡片
@export var card_type :Array[Global.PlantType] = []
## 每张卡片出现对应的概率
@export var card_type_probability :Array[int] = []
## 游戏开始时按顺序出现的卡片
@export var card_type_start_list :Array[Global.PlantType] = []
## 当前生成的卡片数量
@export var curr_num_card :int = 0

var _rng := RandomNumberGenerator.new()
var total_prob = 0

## 植物种植完成后重新开始计时器信号
signal restart_timer_card_plant_end
const card = preload("res://scenes/ui/card.tscn")
#region 初始化
## main_game调用
func init_conveyor_belt_card_bar(card_type :Array[Global.PlantType], card_type_probability :Array[int], card_type_start_list :Array[Global.PlantType]):
	init_card_position_x()
	_init_card_sth(card_type, card_type_probability, card_type_start_list)
	

func _init_card_sth(card_type :Array[Global.PlantType], card_type_probability :Array[int], card_type_start_list :Array[Global.PlantType]):
	self.card_type = card_type
	self.card_type_probability = card_type_probability
	self.card_type_start_list = card_type_start_list

func start_plant():
	assert(card_type.size() == card_type_probability.size(), 
	"卡片类型和概率数组长度必须相同")
	for prob in card_type_probability:
		total_prob += prob
		
	init_timer()
	create_new_card()

func init_card_position_x():
	for i in range(num_card_max):
		card_position_x.append(0 + i * 50)
	print(card_position_x)

func init_timer():
	timer.one_shot = false
	timer.wait_time = time_create_cd
	timer.timeout.connect(create_new_card)
	timer.start()
#endregion

func _process(delta: float) -> void:
	## 更新齿轮位置
	for CB_i in CB_list:
		CB_i.position.x -= delta * CB_velocity
	## 如果第二个齿轮已经到最开始，更新第一个齿轮的位置
	if CB_list[(curr_first+1)%3].position.x <= 0:
		update_first_CB_position_x()
	
	## 更新卡片位置
	for i in card_list.size():
		if card_list[i].position.x > card_position_x[i]:
			card_list[i].position.x-= delta * CB_velocity
		elif card_list[i].position.x == card_position_x[i]:
			continue
		else:
			card_list[i].position.x = card_position_x[i]
		
		
## 更新旧齿轮位置，同时更新新旧齿轮索引
func update_first_CB_position_x():
	CB_list[curr_first%3].position.x = CB_list[(curr_first+2)%3].position.x + 300
	conveyor_belt_gear.move_child(CB_list[curr_first%3], 0)
	
	curr_first += 1
	if curr_first >= 1000:
		curr_first = 0

## 按概率随机获取卡片
func _get_random_card_by_probability() -> Global.PlantType:
	var rand_val = _rng.randi_range(1, total_prob)
	var cumulative_prob = 0
	
	for i in range(card_type.size()):
		cumulative_prob += card_type_probability[i]
		if rand_val <= cumulative_prob:
			return card_type[i]

	# 默认返回第一个卡片（理论上不会执行到这里）
	return card_type[0]

func create_new_card():
	if card_list.size() >= num_card_max:
		timer.stop()
		await restart_timer_card_plant_end
		timer.start()
	var new_card_type
	if curr_num_card < card_type_start_list.size():
		new_card_type = card_type_start_list[curr_num_card]
	else:
		new_card_type = _get_random_card_by_probability()
	
	var new_card:Card = card.instantiate()
	card_area.add_child(new_card)
	new_card.card_init_conveyor_belt(new_card_type)
	new_card.position = card_position.position
	card_list.append(new_card)
	main_game.hand_manager.one_card_game_signal_connect(new_card)
	new_card.card_plant_end.connect(card_plant_end)
	
	curr_num_card += 1

## 卡片种植完成后
func card_plant_end(card:Card):
	card_list.erase(card)
	card.queue_free()
	
	restart_timer_card_plant_end.emit()

#region 卡槽处于焦点时置顶
func _on_bg_mouse_exited() -> void:
	if Global.display_plant_card_bar_follow_mouse:
		# 鼠标离开时，恢复原始z_index
		z_index = 100
		
	## 如果有锤子
	if main_game.hammer:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_bg_mouse_entered() -> void:
	if Global.display_plant_card_bar_follow_mouse:
		# 鼠标进入时，提高z_index，保证在前面显示
		z_index = 900
		
	## 如果有锤子
	if main_game.hammer:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

#endregion


## 移动卡槽（出现或隐藏）
func move_card_chooser():
	var tween = create_tween()
	tween.tween_property(self, "position",Vector2(0, 0), 0.2) # 时间可以改短点

	await tween.finished
