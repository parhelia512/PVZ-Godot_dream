extends CardBase
class_name Card

@onready var character_static: Node2D = $CardBg/CharacterStatic
@onready var short_cut: Label = $ShortCut
@onready var button: Button = $Button

var _is_cooling : bool = false		# 是否正在冷却
var is_sun_enough: bool = true		# 阳光是否足够
var _cool_timer : float				# 冷却计时器

#region 开局选卡相关
## 开局选择卡片时 是否被选中
var is_choosed_pre_card := false
var card_candidate_container:CardCandidateContainer
#endregion

## 点击信号,选卡时使用该信号(种植点击使用时间总线)
signal signal_card_click(card:Card)
## 卡片种植完成后信号，生成卡片所在卡槽连接该信号
signal signal_card_use_end(card:Card)


## 卡片出战时初始化
func card_init():
	_cool_mask.value = 0

## 改变卡片的冷却时间（测试时使用）
func card_change_cool_time(cool_time:float):
	self.cool_time = cool_time
	_cool_mask.value = 0

## 传送带卡槽初始化卡片
func card_init_conveyor_belt():
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

## 卡片可以点击
func card_ready():
	_cool_mask.visible = false

## 卡片开始冷却
func card_cool():
	_is_cooling = true
	_cool_mask.visible = true
	_cool_timer = cool_time
	_cool_mask.value = cool_time

## 点击卡片时
func _on_button_pressed() -> void:
	if MainGameDate.main_game_progress != MainGameManager.E_MainGameProgress.MAIN_GAME:
			signal_card_click.emit()
	else:
		## 卡片冷却完成并且阳光充足
		if not _is_cooling and is_sun_enough:
			EventBus.push_event("main_game_click_card", [self])
		else:
			SoundManager.play_other_SFX("buzzer")

## 快捷键设置
func set_shortcut(i:int):
	short_cut.text = str(i)
	short_cut.visible = true
