extends Control
class_name CoinBankLabel

## 是否自动隐藏
@export var auto_hide := true
@onready var label_coin_value: Label = $TextureRect/LabelCoinValue
@onready var timer_auto_hide: Timer = $TimerAutoHide
@onready var marker_2d_coin_target: Marker2D = $Marker2DCoinTarget

func _ready() -> void:
	update_label()


func update_label():
	visible = true
	label_coin_value.text = "$" + Global.format_number_with_commas(Global.coin_value)
	if auto_hide:
		timer_auto_hide.start()


func _on_timer_auto_hide_timeout() -> void:
	visible = false
