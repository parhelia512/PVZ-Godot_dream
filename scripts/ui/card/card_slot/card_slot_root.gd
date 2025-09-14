extends Control
class_name CardSlotRoot

## 阳光收集位置
@onready var marker_2d_sun_target: Marker2D = $Marker2DSunTarget

## 卡片
var curr_cards:Array[Card]
## 铲子
@onready var ui_shovel: UIShovel = %UIShovel


func _ready() -> void:
	MainGameDate.marker_2d_sun_target = marker_2d_sun_target

	Global.signal_change_card_slot_top_mouse_focus.connect(card_slot_z_index_100)
	mouse_entered.connect(_on_bg_mouse_entered)
	mouse_exited.connect(_on_bg_mouse_exited)

## 快捷键
func _input(event):
	## 铲子快捷键
	if Input.is_action_just_pressed("ShortcutKeys_Shovel"):
		ui_shovel._on_button_pressed()
		return
	## 卡片快捷键
	for i in range(1,11):
		## 卡片快捷键
		if Input.is_action_just_pressed("ShortcutKeys_Card" + str(int(i))):
			## 0-9
			var card_i = i - 1
			if card_i < curr_cards.size():
				curr_cards[card_i]._on_button_pressed()
			else:
				return

#region 卡槽处于焦点时置顶
func _on_bg_mouse_entered() -> void:
	if Global.card_slot_top_mouse_focus and MainGameDate.main_game_progress == MainGameManager.E_MainGameProgress.MAIN_GAME:
		# 鼠标进入时，提高z_index，保证在前面显示
		z_index = 900

func _on_bg_mouse_exited() -> void:
	if Global.card_slot_top_mouse_focus and MainGameDate.main_game_progress == MainGameManager.E_MainGameProgress.MAIN_GAME:
		# 鼠标离开时，恢复原始z_index
		z_index = 100

## 修改控制台按钮时
## 植物卡槽取消置顶,取消鼠标焦点卡槽置顶时
func card_slot_z_index_100():
	if not Global.card_slot_top_mouse_focus:
		z_index = 100
#endregion
