extends Node2D
class_name PlantGardenSpeehBubble

@onready var plant_need_items_bubble={
	PlantGarden.NeedItem.Null:null,
	PlantGarden.NeedItem.WateringCan:$Plantspeechbubble/Waterdrop,		## 水壶
	PlantGarden.NeedItem.Fertilizer:$Plantspeechbubble/ZenNeedIcons,		## 肥料
	PlantGarden.NeedItem.BugSpray:$Plantspeechbubble/ZenNeedIcons2,			## 杀虫剂
	PlantGarden.NeedItem.Phonograph:$Plantspeechbubble/ZenNeedIcons3,		## 留声机
}
@onready var plantspeechbubble: Sprite2D = $Plantspeechbubble

@export var curr_plant_need_item :PlantGarden.NeedItem

func _ready() -> void:
	for plant_need_item_bubble in plant_need_items_bubble.values():
		if plant_need_item_bubble != null:
			plant_need_item_bubble.visible = false
	plantspeechbubble.visible = false

## 改变当前植物需求气泡
func change_plant_need_item(new_plant_need_item :PlantGarden.NeedItem):
	if plant_need_items_bubble[curr_plant_need_item] != null:
		plant_need_items_bubble[curr_plant_need_item].hide()
	
	curr_plant_need_item = new_plant_need_item
	
	if plant_need_items_bubble[new_plant_need_item] != null:
		plantspeechbubble.visible = true
		plant_need_items_bubble[new_plant_need_item].visible = true
	
		scale = Vector2(1,1)/get_parent().scale
		
	else:
		plantspeechbubble.visible = false
	
