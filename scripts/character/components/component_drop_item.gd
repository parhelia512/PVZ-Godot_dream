extends ComponentBase
class_name DropItemComponent
## 掉落战利品组件,可以掉落金币\硬币\钻石\花园植物

@export_group("掉落相关")
## 掉落金币的概率
@export var drop_coin_rate := 0.3
## 掉落银币、金币、钻石的比例（要求和为1）
@export var drop_coin_silver_glod_diamond_rate := [0.5,0.4,0.1]
## 掉落花园植物概率
@export var drop_garden_plant_rate := 0.004


#region 僵尸掉落
## 掉落金银钻
func drop_coin():
	var r = randf()
	if r < drop_coin_rate:
		Global.create_coin(drop_coin_silver_glod_diamond_rate, global_position + Vector2(0, -100))

## 掉落花园植物
func drop_garden_plant():
	var r = randf()
	if r < drop_garden_plant_rate:
		Global.create_garden_plant(global_position + Vector2(0, -50))
#endregion

