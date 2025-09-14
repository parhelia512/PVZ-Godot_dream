extends CardBase
class_name Card

@onready var _cool_mask: ProgressBar = $ProgressBar			# 冷却进度条
@onready var _button: Button = $Button				# 卡片点击按钮

var _is_cooling : bool = false					# 是否正在冷却
var _cool_timer : float				# 冷却计时器

var is_sun_enough: bool				# 阳光是否足够

## 开局选择卡片时 是否被选中
@export var is_choosed := false
@export var card_in_seed_chooser:CardInSeedChooser
## 种植植物时发送点击信号,使用这个信号控制种植植物
signal card_click		#点击信号
signal card_plant_end		#卡片种植完成后信号，生成卡片的地方连接


## 备选卡槽时卡片初始化
func card_init_in_seed_chooser(card_type: Global.PlantType):
	super.card_init(card_type)
	## 获取其父节点，取消选择卡片时会重新回来
	card_in_seed_chooser = get_parent()
	_cool_mask.max_value = cool_time
	#_cool_mask.value = 0
	
## 卡片出战时初始化
func card_init(card_type: Global.PlantType):
	super.card_init(card_type)
	_cool_mask.max_value = cool_time
	_cool_mask.value = 0
	
func card_change_cool_time(cool_time):
	self.cool_time = cool_time
	_cool_mask.max_value = cool_time
	_cool_mask.value = 0

## 传送带卡槽初始化卡片
func card_init_conveyor_belt(card_type: Global.PlantType):
	super.card_init(card_type)
	_cool_mask.max_value = cool_time
	_cool_mask.value = 0
	sun_cost = 0
	get_node("CardBg/Cost").text = str(sun_cost)


## 卡片冷卻
func _process(delta: float) -> void:
	if _is_cooling:
		_cool_timer -= delta
		_cool_mask.value = _cool_timer
		# 卡片冷却完成
		if _cool_timer <= 0:
			_is_cooling = false
			#卡片阳光充足
			if is_sun_enough:
				card_ready()

## 修改阳光时会调用
func judge_sun_enough(curr_sun_value):
	# 判断阳光是否足够
	is_sun_enough = curr_sun_value >= sun_cost
	# 阳光充足
	if is_sun_enough:
		# 卡片冷却完成
		if not _is_cooling:
			card_ready()
			
	# 阳光不充足
	else:
		# 卡片冷却完成
		if not _is_cooling:
			_cool_mask.value = 0
			_cool_mask.visible = true
			_button.disabled = true
		

## 卡片可以点击    
func card_ready():
	_cool_mask.visible = false
	_button.disabled = false


## 卡片开始冷却
func card_cool():
	_is_cooling = true
	_cool_mask.visible = true
	_button.disabled = true
	_cool_timer = cool_time
	_cool_mask.value = cool_time


## 点击卡片时
func _on_button_pressed() -> void:
	card_click.emit(self)
	
