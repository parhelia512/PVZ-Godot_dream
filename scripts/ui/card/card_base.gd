extends Control
class_name CardBase

## 卡片类型
@export var card_type: Global.PlantType
## 卡片冷却时间
@export var cool_time: float
## 卡片阳光消耗
@export var sun_cost: int


func card_init(card_type: Global.PlantType):
	self.card_type = card_type
	cool_time = Global.CardInfo[card_type][Global.CardInfoAttribute.CoolTime]
	sun_cost = Global.CardInfo[card_type][Global.CardInfoAttribute.SunCost]
	
	get_node("CardBg/Cost").text = str(sun_cost)
	var static_plant = Global.StaticPlantTypeSceneMap.get(card_type).instantiate()
	get_node("CardBg").add_child(static_plant)
	static_plant.position = Vector2(25,33)
