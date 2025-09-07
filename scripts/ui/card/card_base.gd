extends Control
class_name CardBase

@onready var card_bg: TextureRect = $CardBg
@onready var cost: Label = $CardBg/Cost
@onready var _cool_mask: ProgressBar = $ProgressBar


## 卡片索引位置
@export var card_id :int = -1
## 植物卡片类型，植物卡片类型为Global.PlantType.Null时为僵尸卡片
@export var card_plant_type: Global.PlantType
## 僵尸卡片类型
@export var card_zombie_type: Global.ZombieType

## 卡片冷却时间
@export var cool_time: float = 7.5:
	set(value):
		cool_time = value
		if _cool_mask:
			_cool_mask.max_value = value

## 卡片阳光消耗
@export var sun_cost: int = 100:
	set(value):
		sun_cost = value
		if cost:
			cost.text = str(int(value))


