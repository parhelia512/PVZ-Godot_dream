extends Goods
class_name GoodsGardenBg


## 当前商品的背景
@export var curr_goods_garden_bg :GardenManager.GardenBgType

## 对应的数据路径
const data_string_path_from_bg_map = {
	GardenManager.GardenBgType.GreenHouse : "num_bg_page_0",
	GardenManager.GardenBgType.MushroomGraden : "num_bg_page_1",
	GardenManager.GardenBgType.Aquarium : "num_bg_page_2",
}

## 获得该商品的作用，子类重写
func get_one_goods():
	Global.garden_data[data_string_path_from_bg_map[curr_goods_garden_bg]] += 1
	Global.save_game_data()
