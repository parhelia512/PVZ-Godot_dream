extends PanelContainer
class_name CardSlotConveyorBelt

@onready var conveyor_belt_gear: ConveyorBeltGear = $ConveyorBeltGear
@onready var new_card_area: Panel = $NewCardArea
@onready var create_new_card_timer: Timer = $CreateNewCardTimer

var curr_cards :Array[Card] = []

@export_group("传送带参数")
## 最大卡片数量，固定10个
@export var num_card_max :int = 10
## 每张卡片最终目标位置x,从0开始隔50像素个，ready函数中自动生成
var all_card_pos_x_target :Array[float] = []
## 卡片移动速度
@export var conveyor_velocity :float = 30
## 卡片生成时间
@export var create_new_card_cd :float = 5

@export_group("出现卡片相关")
## 可能出现的植物卡片,及其概率
@export var all_card_plant_type_probability :Dictionary[Global.PlantType, int] = {}
## 可能出现的僵尸卡片,及其概率
@export var all_card_zombie_type_probability :Dictionary[Global.ZombieType, int] = {}
## 游戏开始时按顺序出现的卡片
@export var start_list_card_plant_type :Array[Global.PlantType] = []
## 游戏开始时按顺序出现的卡片
@export var start_list_card_zombie_type :Array[Global.ZombieType] = []
## 当前生成的卡片总数量
@export var all_num_card :int = 0

## 总概率之和
var total_prob = 0
## 每种卡片的概率上限，从小到大遍历随机值不大于该上限时选择对应的卡牌
var prob_every_card :Array[int] = []

## 是否正在运行中
var is_working:= false
## 创建新卡片倍率
var create_new_card_speed:float
## 卡片种植完成后信号，计时器判断是否重启
signal signal_card_end
## 传送带创建新card发射信号给hand_manager连接点击种植函数
signal signal_create_new_card(card:Card)


#region 初始化

func _ready() -> void:
	_init_card_position_x()

## 初始化传送带卡片最终位置
func _init_card_position_x():
	for i in range(num_card_max):
		all_card_pos_x_target.append(0 + i * 50)
	print("传送带每张卡片的位置：",all_card_pos_x_target)

## 管理器初始化调用
func init_card_slot_conveyor_belt(game_para:ResourceLevelData):
	self.all_card_plant_type_probability = game_para.all_card_plant_type_probability
	self.all_card_zombie_type_probability = game_para.all_card_zombie_type_probability
	self.start_list_card_plant_type = game_para.start_list_card_plant_type
	self.start_list_card_zombie_type = game_para.start_list_card_zombie_type
	self.create_new_card_speed = game_para.create_new_card_speed
	## 修改倍率
	create_new_card_cd = create_new_card_cd / create_new_card_speed
	create_new_card_timer.wait_time = create_new_card_cd

	## 计算总概率值
	for prob in all_card_plant_type_probability.values():
		total_prob += prob
		prob_every_card.append(total_prob)

	for prob in all_card_zombie_type_probability.values():
		total_prob += prob
		prob_every_card.append(total_prob)

	await get_tree().process_frame
	## 初始化后生成一个卡片
	_create_new_card()

#endregion

func _process(delta: float) -> void:
	if is_working:
		## 更新卡片位置
		for i in curr_cards.size():
			if curr_cards[i].position.x > all_card_pos_x_target[i]:
				curr_cards[i].position.x-= delta * conveyor_velocity
			elif curr_cards[i].position.x == all_card_pos_x_target[i]:
				continue
			else:
				curr_cards[i].position.x = all_card_pos_x_target[i]

#region 卡片生成相关
## 卡片种植完成后
func card_use_end(card:Card):
	curr_cards.erase(card)
	card.queue_free()
	signal_card_end.emit()

func _on_create_new_card_timer_timeout() -> void:
	_create_new_card() # Replace with function body.

## 生成一张新卡片
func _create_new_card():
	if curr_cards.size() >= num_card_max:
		create_new_card_timer.stop()
		await signal_card_end
		create_new_card_timer.start()
	var new_card_prefabs:Card
	if all_num_card < start_list_card_plant_type.size():
		new_card_prefabs = AllCards.all_plant_card_prefabs[start_list_card_plant_type[all_num_card]]
	elif all_num_card < start_list_card_plant_type.size() + start_list_card_zombie_type.size():
		new_card_prefabs = AllCards.all_zombie_card_prefabs[start_list_card_zombie_type[all_num_card]]
	else:
		new_card_prefabs = _get_random_card_by_probability()
	var new_card = new_card_prefabs.duplicate()
	new_card_area.add_child(new_card)
	new_card.card_init_conveyor_belt()
	new_card.position = Vector2(new_card_area.size.x, 0)
	#print(new_card_area.size)
	curr_cards.append(new_card)
	signal_create_new_card.emit(new_card)
	new_card.signal_card_use_end.connect(card_use_end.bind(new_card))
	var card_bg:TextureRect = new_card.get_node("CardBg")
	card_bg.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED

	all_num_card += 1

## 按概率随机获取可生成卡片索引
func _get_random_card_by_probability() -> Card:
	var rand_val = randi_range(1, total_prob)

	for i in range(prob_every_card.size()):
		if rand_val <= prob_every_card[i]:
			## 如果是植物
			if i < all_card_plant_type_probability.size():
				var card_plant_type = all_card_plant_type_probability.keys()[i]
				return AllCards.all_plant_card_prefabs[card_plant_type]
			else:
				i = i - all_card_plant_type_probability.size()
				var card_zombie_type = all_card_zombie_type_probability.keys()[i]
				return AllCards.all_zombie_card_prefabs[card_zombie_type]

	push_error("传送带未随机到卡片？")
	# （理论上不会执行到这里）
	return null
#endregion

#region 传送带开始与结束
## 开始传送带
func start_conveyor_belt():
	is_working = true
	conveyor_belt_gear.start_gear()
	create_new_card_timer.start()

## 停止传送带
func stop_conveyor_belt():
	is_working = false
	conveyor_belt_gear.stop_gear()
	create_new_card_timer.stop()

## 移动卡槽（出现或隐藏）
func move_card_slot_conveyor_belt(is_appeal:bool):
	var tween = create_tween()
	if is_appeal:
		tween.tween_property(self, "position:y", 0, 0.2)

	else:
		tween.tween_property(self, "position:y", -100, 0.2)
	await tween.finished

#endregion
