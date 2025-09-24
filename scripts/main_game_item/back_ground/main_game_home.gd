extends Node2D
class_name MainGameHome


@onready var panel_zombie_go_home: Panel = %PanelZombieGoHome

@onready var door_downs: Array[Sprite2D] = [
	$Door/DoorDown/Background1GameoverInteriorOverlay,
	$Door/DoorDown/Background2GameoverInteriorOverlay,
	$Door/DoorDown/Background3GameoverInteriorOverlay,
	$Door/DoorDown/Background4GameoverInteriorOverlay,
	null,
]

@onready var door_masks: Array[Sprite2D] = [
	$Door/DoorMask/Background1GameoverMask,
	$Door/DoorMask/Background2GameoverMask,
	$Door/DoorMask/Background3GameoverMask,
	$Door/DoorMask/Background4GameoverMask,
	$Door/DoorMask/Background5GameoverMask
]

## 根据当前背景初始化房门
func init_home(game_BG:ResourceLevelData.GameBg):
	if is_instance_valid(door_downs[game_BG]):
		## 打开房门
		door_downs[game_BG].visible = true
	door_masks[game_BG].visible = true

## 僵尸进房
func _on_area_2d_home_area_entered(area: Area2D) -> void:
	print("僵尸进家")
	var zombie :Zombie000Base = area.owner
	EventBus.push_event("zombie_go_home", [zombie])
