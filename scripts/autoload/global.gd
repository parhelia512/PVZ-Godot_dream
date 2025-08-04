extends Node

# 图层顺序：
#世界背景： 0
#Ui1: 100	鼠标未移入UI时，在最下面
#墓碑: 当前植物格子图层-2
#植物： 395	每行隔10个图层
#僵尸： 400	每行僵尸隔10图层
#保龄球： 根据行更新图层，在僵尸行之间
#小推车： 每行比僵尸行+5，
#起跳窝瓜： 每行比僵尸行+5，
#子弹： 600
#爆炸： 650
# 泳池迷雾:700
#阳光： 910
#Ui2 : 900 鼠标移入UI时，在植物和僵尸下面
#真实铲子 : 950
# 锤子： 950
# 锤击僵尸特效： 951
#血量显示： 980
#UI3： 1000 进度条、准备放置植物
#UI4： 1100 所有备选植物卡槽
#UI5:  1150 卡片选择移动时临时位置
#奖杯： 2000
#商店： 使用canvasLayer
#戴夫: 3100
# 金币显示：3200

## 花园图层顺序
#TODO:忘记写了，也不重要，有空写

#region 用户游戏存档相关
#region 全局游戏数据
## 金币数量
var coin_value : int = 0:
	set(value):
		coin_value_change.emit()
		## 若存在金币显示ui 更新金币
		coin_value = value
		if coin_value_label:
			coin_value_label.update_label()

## 金币改变信号
signal coin_value_change
## 显示金币的label
var coin_value_label:CoinBank

## 生产金币,按概率生产，概率和为1, 将金币生产在coin_bank（Global.coin_value_label）节点下
## 概率顺序为 银币金币和钻石
func create_coin(probability:Array=[0.5, 0.5, 0], global_position_new_coin:Vector2=Vector2()):
	coin_value_label.update_label()
	## 如果当前场景有金币值的label,将金币生产在coin_bank（Global.coin_value_label）节点下
	if Global.coin_value_label and is_instance_valid(Global.coin_value_label):
		assert(probability[0] + probability[1] + probability[2], "概率和不为1")
		var r = randf()
		var new_coin:Coin
		if r < probability[0]:
			new_coin = SceneRegistry.COIN_SILVER.instantiate()
		elif r < probability[0] + probability[1]: 
			new_coin = SceneRegistry.COIN_GOLD.instantiate()
		else:
			new_coin = SceneRegistry.COIN_DIAMOND.instantiate()
		Global.coin_value_label.add_child(new_coin)
		new_coin.global_position = global_position_new_coin
		## 抛物线发射金币
		new_coin.launch(Vector2(randf_range(-50, 50), randf_range(80, 90)))

# TODO:暂时先写global，后面要改
## 掉落花园植物
func create_garden_plant(global_position_new_garden_plant:Vector2):
	coin_value_label.update_label()
	
	var new_garden_plant:Present = SceneRegistry.PRESENT.instantiate()

	Global.coin_value_label.add_child(new_garden_plant)
	new_garden_plant.global_position = global_position_new_garden_plant



## 当前花园的新增植物数量，进入花园时处理
var curr_num_new_garden_plant :int = 3

## 花园数据
var garden_data:Dictionary = {
	"num_bg_page_0":1,
	"num_bg_page_1":1,
	"num_bg_page_2":1,
}

## 数字转str,每三位加逗号
func format_number_with_commas(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
	return result



#endregion

const SAVE_GAME_PATH = "user://SaveGame.json"

func _ready() -> void:
	load_game_data()

var curr_plant = [
	PlantType.PeaShooterSingle,
	PlantType.SunFlower, 
	PlantType.CherryBomb,
	PlantType.WallNut,
	PlantType.PotatoMine,
	PlantType.SnowPea,
	PlantType.Chomper,
	PlantType.PeaShooterDouble,
	
	PlantType.PuffShroom,
	PlantType.SunShroom,
	PlantType.FumeShroom,
	PlantType.GraveBuster,
	PlantType.HypnoShroom,
	PlantType.ScaredyShroom,
	PlantType.IceShroom,
	PlantType.DoomShroom,
	
	PlantType.LilyPad,
	PlantType.Squash,
	PlantType.ThreePeater,
	PlantType.TangleKelp,
	PlantType.Jalapeno,
	PlantType.Caltrop,
	PlantType.TorchWood,
	PlantType.TallNut,
	
	PlantType.SeaShroom,
	PlantType.Plantern,
	PlantType.Cactus,
	PlantType.Blover,
	PlantType.SplitPea,
	PlantType.StarFruit,
	PlantType.Pumpkin,
	PlantType.MagnetShroom,
	
	#PlantType.CabbagePult,
	PlantType.FlowerPot,
	#PlantType.CornPult,
	#PlantType.CoffeeBean,
	#PlantType.Garlic,
	#PlantType.UmbrellaLeaf,
	#PlantType.MariGold,
	#PlantType.MelonPult,
	#
	#PlantType.GatlingPea,
	#PlantType.TwinSunFlower,
	#PlantType.GloomShroom,
	#PlantType.Cattail,
	#PlantType.WinterMelon,
	#PlantType.GoldMagnet,
	#PlantType.SpikeRock,
	#PlantType.CobCannon,
]

#region 存档方法
## 保存数据到 JSON 文件
func save_game_data() -> bool:
	var path = SAVE_GAME_PATH
	var data = {
		"coin_value": coin_value,
		"garden_data": garden_data,
		"curr_num_new_garden_plant": curr_num_new_garden_plant,
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("❌ 无法打开文件进行写入: %s" % path)
		return false

	var json_text := JSON.stringify(data, "\t")  # 可读性更强
	file.store_string(json_text)
	file.close()
	print("✅ 存档已保存到", path)
	return true


## 从 JSON 文件加载数据
func load_game_data() -> void:
	var path = SAVE_GAME_PATH
	if not FileAccess.file_exists(path):
		print("⚠️ 存档文件不存在: %s" % path)
		return 

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("❌ 无法打开文件进行读取: %s" % path)
		return 

	var json_text := file.get_as_text()
	file.close()

	var result = JSON.parse_string(json_text)
	if result == null:
		push_error("❌ JSON 解析失败")
		return 

	print("✅ 成功读取存档文件:", path)
	
	var data = result as Dictionary
	coin_value = data.get("coin_value", coin_value)
	curr_num_new_garden_plant = data.get("curr_num_new_garden_plant", curr_num_new_garden_plant)
	garden_data = data.get("garden_data", garden_data)

	
#endregion


#region 保存上次选卡信息
var selected_cards = []

func save_selected_cards():
	var save_file = FileAccess.open("user://selected_cards.save", FileAccess.WRITE)
	var data:Dictionary = {
		"selected_cards" : selected_cards,
	}
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)

func load_selected_cards():
	
	if not FileAccess.file_exists("user://selected_cards.save"):
		selected_cards = []
		return # Error! We don't have a save to load.
	
	# 打开文件
	var save_file = FileAccess.open("user://selected_cards.save", FileAccess.READ)
	# 读取全部内容
	while save_file.get_position() < save_file.get_length():
		var data = JSON.parse_string(save_file.get_line())
		# 加载数据
		selected_cards = data["selected_cards"]
	return

#endregion


#region 游戏相关



#region 角色
# 定义枚举
enum CharacterType {Plant, Zombie}


#region 植物

enum PlantInfoAttribute{
	PlantName,
	CoolTime,		## 植物种植冷却时间
	SunCost,		## 阳光消耗
	PlantScenesName,## 场景文件名字
	PlantScenes,	## 植物场景预加载
	PlantStaticScenes,	## 静态植物预加载
	PlantShowScenes,	## 展示植物预加载（花园，图鉴）
	PlantConditionResource,	## 植物种植条件资源预加载
}

enum PlantType {	
	PeaShooterSingle, 
	SunFlower, 
	CherryBomb,
	WallNut,
	PotatoMine,
	SnowPea,
	Chomper,
	PeaShooterDouble,
	
	PuffShroom,
	SunShroom,
	FumeShroom,
	GraveBuster,
	HypnoShroom,
	ScaredyShroom,
	IceShroom,
	DoomShroom,
	
	LilyPad,
	Squash,
	ThreePeater,
	TangleKelp,
	Jalapeno,
	Caltrop,
	TorchWood,
	TallNut,
	
	SeaShroom,
	Plantern,
	Cactus,
	Blover,
	SplitPea,
	StarFruit,
	Pumpkin,
	MagnetShroom,
	
	CabbagePult,
	FlowerPot,
	CornPult,
	CoffeeBean,
	Garlic,
	UmbrellaLeaf,
	MariGold,
	MelonPult,
	
	GatlingPea,
	TwinSunFlower,
	GloomShroom,
	Cattail,
	WinterMelon,
	GoldMagnet,
	SpikeRock,
	CobCannon,
	
	
	WallNutBowling = 51,
	WallNutBowlingBomb,
	WallNutBowlingBig,
	
	Null = 100,
	}


	## 目前已经写完的植物，
var curr_complete_plant = [
	PlantType.PeaShooterSingle, 
	PlantType.SunFlower, 
	PlantType.CherryBomb,
	PlantType.WallNut,
	PlantType.PotatoMine,
	PlantType.SnowPea,
	PlantType.Chomper,
	PlantType.PeaShooterDouble,
	
	PlantType.PuffShroom,
	PlantType.SunShroom,
	PlantType.FumeShroom,
	PlantType.GraveBuster,
	PlantType.HypnoShroom,
	PlantType.ScaredyShroom,
	PlantType.IceShroom,
	PlantType.DoomShroom,
	
	PlantType.LilyPad,
	PlantType.Squash,
	PlantType.ThreePeater,
	PlantType.TangleKelp,
	PlantType.Jalapeno,
	PlantType.Caltrop,
	PlantType.TorchWood,
	PlantType.TallNut,
	
	PlantType.SeaShroom,
	PlantType.Plantern,
	PlantType.Cactus,
	PlantType.Blover,
	PlantType.SplitPea,
	PlantType.StarFruit,
	PlantType.Pumpkin,
	PlantType.MagnetShroom,
	
	#PlantType.CabbagePult,
	PlantType.FlowerPot,
	#PlantType.CornPult,
	#PlantType.CoffeeBean,
	#PlantType.Garlic,
	#PlantType.UmbrellaLeaf,
	#PlantType.MariGold,
	#PlantType.MelonPult,
	#
	#PlantType.GatlingPea,
	#PlantType.TwinSunFlower,
	#PlantType.GloomShroom,
	#PlantType.Cattail,
	#PlantType.WinterMelon,
	#PlantType.GoldMagnet,
	#PlantType.SpikeRock,
	#PlantType.CobCannon,
	#
	
	PlantType.WallNutBowling,
	PlantType.WallNutBowlingBomb,
	PlantType.WallNutBowlingBig,
]
	
## 加载植物场景
func _init() -> void:
	for plant_type in curr_complete_plant:
		var plant_scenes_name:String = PlantInfo[plant_type][PlantInfoAttribute.PlantScenesName]
		PlantInfo[plant_type][PlantInfoAttribute.PlantScenes] = load("res://scenes/character/plant/" + plant_scenes_name + ".tscn")
		PlantInfo[plant_type][PlantInfoAttribute.PlantStaticScenes] = load("res://scenes/character/plant/" + plant_scenes_name + "_static.tscn")
		var plant_show_path = "res://scenes/character/plant/" + plant_scenes_name + "_show.tscn"
		## 如果存在该场景，就加载，不存在就置null
		if FileAccess.file_exists(plant_show_path):
			PlantInfo[plant_type][PlantInfoAttribute.PlantShowScenes] = load(plant_show_path)
		else:
			print(plant_scenes_name, "无show场景")
			PlantInfo[plant_type][PlantInfoAttribute.PlantShowScenes] = null
		

var PlantInfo = {
	PlantType.PeaShooterSingle: {
		PlantInfoAttribute.PlantName: "PeaShooterSingle",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantScenesName: "001_pea_shooter_single",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
		
	PlantType.SunFlower: {
		PlantInfoAttribute.PlantName: "SunFlower",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenesName: "002_sun_flower",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		
		},
	PlantType.CherryBomb: {
		PlantInfoAttribute.PlantName: "CherryBomb",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 150,
		PlantInfoAttribute.PlantScenesName: "003_cherry_bomb",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		
		},
	PlantType.WallNut: {
		PlantInfoAttribute.PlantName: "WallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenesName: "004_wall_nut",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.PotatoMine: {
		PlantInfoAttribute.PlantName: "PotatoMine",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenesName: "005_potato_mine",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/005_potato_mine.tres")
		},
	PlantType.SnowPea: {
		PlantInfoAttribute.PlantName: "SnowPea",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantScenesName: "006_snow_pea",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.Chomper: {
		PlantInfoAttribute.PlantName: "Chomper",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 150,
		PlantInfoAttribute.PlantScenesName: "007_chomper",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.PeaShooterDouble: {
		PlantInfoAttribute.PlantName: "PeaShooterDouble",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 200,
		PlantInfoAttribute.PlantScenesName: "008_pea_shooter_double",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.PuffShroom: {
		PlantInfoAttribute.PlantName: "PuffShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 0,
		PlantInfoAttribute.PlantScenesName: "009_puff_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.SunShroom: {
		PlantInfoAttribute.PlantName: "SunShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenesName: "010_sun_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.FumeShroom: {
		PlantInfoAttribute.PlantName: "FumeShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantScenesName: "011_fume_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.GraveBuster: {
		PlantInfoAttribute.PlantName: "GraveBuster",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantScenesName: "012_grave_buster",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/012_grave_buster.tres")
		},
	PlantType.HypnoShroom: {
		PlantInfoAttribute.PlantName: "HypnoShroom",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantScenesName: "013_hypno_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.ScaredyShroom: {
		PlantInfoAttribute.PlantName: "ScaredyShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenesName: "014_scaredy_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.IceShroom: {
		PlantInfoAttribute.PlantName: "IceShroom",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantScenesName: "015_ice_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.DoomShroom: {
		PlantInfoAttribute.PlantName: "DoomShroom",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenesName: "016_doom_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.LilyPad: {
		PlantInfoAttribute.PlantName: "LilyPad",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenesName: "017_lily_pad",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/017_lily_pad.tres")
		},
	PlantType.Squash: {
		PlantInfoAttribute.PlantName: "Squash",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenesName: "018_squash",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.ThreePeater: {
		PlantInfoAttribute.PlantName: "ThreePeater",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 325,
		PlantInfoAttribute.PlantScenesName: "019_three_peater",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.TangleKelp: {
		PlantInfoAttribute.PlantName: "TangleKelp",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenesName: "020_tanglekelp",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/020_tanglekelp.tres")
		},
	PlantType.Jalapeno: {
		PlantInfoAttribute.PlantName: "Jalapeno",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenesName: "021_jalapeno",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.Caltrop: {
		PlantInfoAttribute.PlantName: "Caltrop",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenesName: "022_caltrop",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/022_caltrop.tres")
		},
	PlantType.TorchWood: {
		PlantInfoAttribute.PlantName: "TorchWood",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantScenesName: "023_torch_wood",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.TallNut: {
		PlantInfoAttribute.PlantName: "TallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantScenesName: "024_tall_nut",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.SeaShroom: {
		PlantInfoAttribute.PlantName: "SeaShroom",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 0,
		PlantInfoAttribute.PlantScenesName: "025_sea_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/020_tanglekelp.tres")
		},
	PlantType.Plantern: {
		PlantInfoAttribute.PlantName: "Plantern",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenesName: "026_plantern",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.Cactus: {
		PlantInfoAttribute.PlantName: "Cactus",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenesName: "027_cactus",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.Blover: {
		PlantInfoAttribute.PlantName: "Blover",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantScenesName: "028_blover",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.SplitPea: {
		PlantInfoAttribute.PlantName: "SplitPea",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenesName: "029_split_pea",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.StarFruit: {
		PlantInfoAttribute.PlantName: "StarFruit",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenesName: "030_star_fruit",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.Pumpkin: {
		PlantInfoAttribute.PlantName: "Pumpkin",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenesName: "031_pumpkin",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/031_Pumpkin.tres")
		},
	PlantType.MagnetShroom: {
		PlantInfoAttribute.PlantName: "MagnetShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantScenesName: "032_magnet_shroom",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	#PlantType.CabbagePult: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	PlantType.FlowerPot: {
		PlantInfoAttribute.PlantName: "FlowerPot",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenesName: "034_flower_pot",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/034_flower_pot.tres")
		},
	#PlantType.CornPult: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.CoffeeBean: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.Garlic: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.UmbrellaLeaf: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.MariGold: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.MelonPult: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.GatlingPea: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.TwinSunFlower: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.GloomShroom: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.Cattail: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.WinterMelon: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.GoldMagnet: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.SpikeRock: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/024_tall_nut.tscn"),
		#PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/024_tall_nut_static.tscn"),
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.CobCannon: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/024_tall_nut.tscn"),
		#PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/024_tall_nut_static.tscn"),
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
		
		
	## 保龄球
	PlantType.WallNutBowling: {
		PlantInfoAttribute.PlantName: "WallNutBowling",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50, 
		PlantInfoAttribute.PlantScenesName: "051_wall_nut_bowling",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.WallNutBowlingBomb: {
		PlantInfoAttribute.PlantName: "WallNutBowlingBomb",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenesName: "052_wall_nut_bowling_bomb",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.WallNutBowlingBig: {
		PlantInfoAttribute.PlantName: "WallNutBowlingBig",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenesName: "053_wall_nut_bowlingBig",
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},

}

## 植物在格子中的位置
enum PlacePlantInCell{
	Norm,	## 普通位置
	Float,	## 漂浮位置
	Down,	## 花盆（睡莲）位置
	Shell,	## 保护壳位置
}

## 获取植物属性方法
func get_plant_info(plant_type:PlantType, info_attribute:PlantInfoAttribute):
	return PlantInfo.get(plant_type)[info_attribute]
	
#endregion

#region 僵尸
#TODO：改成和植物差不多的
enum ZombieType {
	ZombieNorm, 
	ZombieFlag, 
	ZombieCone, 
	ZombiePoleVaulter,
	ZombieBucket,
	ZombiePaper,
	ZombieScreenDoor,
	ZombieFootball,
	ZombieJackson,
	ZombieDancer,
	ZombieDuckytube,
	ZombieSnorkle,
	ZombieZamboni,
	ZombieBobsled,
	ZombieDolphinrider,
	
	}

var ZombieTypeSceneMap = {
	ZombieType.ZombieNorm: preload("res://scenes/character/zombie/001_zombie_norm.tscn"),
	ZombieType.ZombieFlag: preload("res://scenes/character/zombie/002_zombie_flag.tscn"),
	ZombieType.ZombieCone: preload("res://scenes/character/zombie/003_zombie_cone.tscn"),
	ZombieType.ZombiePoleVaulter: preload("res://scenes/character/zombie/004_zombie_pole_vaulter.tscn"),
	ZombieType.ZombieBucket: preload("res://scenes/character/zombie/005_zombie_bucket.tscn"),
	ZombieType.ZombiePaper: preload("res://scenes/character/zombie/006_zombie_paper.tscn"),
	ZombieType.ZombieScreenDoor: preload("res://scenes/character/zombie/007_zombie_screendoor.tscn"),
	ZombieType.ZombieFootball: preload("res://scenes/character/zombie/008_zombie_football.tscn"),
	ZombieType.ZombieJackson: preload("res://scenes/character/zombie/009_zombie_jackson.tscn"),
	ZombieType.ZombieDancer: preload("res://scenes/character/zombie/010_zombie_dancer.tscn"),
	ZombieType.ZombieSnorkle: preload("res://scenes/character/zombie/012_zombie_snorkle.tscn"),
	ZombieType.ZombieZamboni: preload("res://scenes/character/zombie/013_zombie_zamboni.tscn"),
	ZombieType.ZombieBobsled: preload("res://scenes/character/zombie/014_zombie_bobsled.tscn"),
	ZombieType.ZombieDolphinrider: preload("res://scenes/character/zombie/015_zombie_dolphinrider.tscn"),
	}


## 泳池水花场景
var splash_pool_scenes = preload("res://scenes/item/game_scenes_item/splash.tscn")

#endregion

#endregion

#region 子弹种类
## 伤害种类
## 普通，穿透，真实
enum AttackMode {
	Norm, 			# 按顺序对二类防具、一类防具、本体造成伤害
	Penetration, 	# 对二类防具造成伤害同时对一类防具造成伤害
	Real,			# 不对二类防具造成伤害，直接对一类防具造成伤害
	BowlingFront,		## 保龄球正面
	BowlingSide,		## 保龄球侧面
	Hammer,			## 锤子
	
	} 
	
enum BulletType{
	BulletPea,			## 豌豆
	BulletPeaSnow,		## 寒冰豌豆
	BulletPuff,			## 小喷孢子
	BulletFume,			## 大喷孢子
	BulletPuffLongTime,	## 胆小菇孢子（和小喷孢子一样，不过修改存在持续距离）
	BulletPeaFire,		## 火焰豌豆
}

const BulletTypeMap := {
	BulletType.BulletPea : preload("res://scenes/bullet/001_bullet_pea.tscn"),
	BulletType.BulletPeaSnow : preload("res://scenes/bullet/002_bullet_pea_snow.tscn"),
	BulletType.BulletPuff : preload("res://scenes/bullet/003_bullet_puff.tscn"),
	BulletType.BulletFume : preload("res://scenes/bullet/004_bullet_fume.tscn"),
	BulletType.BulletPuffLongTime : preload("res://scenes/bullet/005_bullet_puff_long_time.tscn"),
	BulletType.BulletPeaFire : preload("res://scenes/bullet/006_bullet_pea_fire.tscn"),
}

## 获取子弹场景方法
func get_bullet_scenes(bullet_type:BulletType):
	return BulletTypeMap.get(bullet_type)
	
#endregion

#region 铁器种类、磁力菇与铁器僵尸交互使用

## 铁器种类
enum IronType{
	IronArmor1,	## 一类铁器防具
	IronArmor2,	## 二类铁器防具
	IronItem,	## 铁器道具
}
#endregion

#endregion

#region 用户相关


#region 用户配置相关
const CONGIF_PATH := "user://config.ini"

## 用户选项控制台
var auto_collect_sun := false
var auto_collect_coin := false
var disappear_spare_card_Placeholder := false
var display_plant_HP_label := false
var display_zombie_HP_label := false
var display_plant_card_bar_follow_mouse := false
var fog_is_static := false			## 静态迷雾
var plant_be_shovel_front := true	## 预铲除植物本格置顶

var time_scale := 1.0

func save_config():
	var config := ConfigFile.new()
	## 音乐相关
	config.set_value("audio", "master", SoundManager.get_volum(SoundManager.Bus.MASTER)) 
	config.set_value("audio", "bgm", SoundManager.get_volum(SoundManager.Bus.BGM)) 
	config.set_value("audio", "sfx", SoundManager.get_volum(SoundManager.Bus.SFX)) 
	# 用户选项控制台相关
	config.set_value("user_control", "auto_collect_sun", auto_collect_sun) 
	config.set_value("user_control", "auto_collect_coin", auto_collect_coin) 
	config.set_value("user_control", "disappear_spare_card_Placeholder", disappear_spare_card_Placeholder) 
	config.set_value("user_control", "display_plant_HP_label", display_plant_HP_label) 
	config.set_value("user_control", "display_zombie_HP_label", display_zombie_HP_label) 
	config.set_value("user_control", "display_plant_card_bar_follow_mouse", display_plant_card_bar_follow_mouse) 
	config.set_value("user_control", "fog_is_static", fog_is_static) 
	config.set_value("user_control", "plant_be_shovel_front", plant_be_shovel_front) 

	config.save(CONGIF_PATH)
	
	
	
func load_config():
	var config := ConfigFile.new()
	config.load(CONGIF_PATH)
	
	SoundManager.set_volume(
		SoundManager.Bus.MASTER,
		config.get_value("audio", "master", 1)
	)
	
	SoundManager.set_volume(
		SoundManager.Bus.BGM,
		config.get_value("audio", "bgm", 0.5)
	)
	
	SoundManager.set_volume(
		SoundManager.Bus.SFX,
		config.get_value("audio", "sfx", 0.5)
	)
	
	auto_collect_sun = config.get_value("user_control", "auto_collect_sun", false) 
	auto_collect_coin = config.get_value("user_control", "auto_collect_coin", false) 
	disappear_spare_card_Placeholder = config.get_value("user_control", "disappear_spare_card_Placeholder", false) 
	display_plant_HP_label = config.get_value("user_control", "display_plant_HP_label", false) 
	display_zombie_HP_label = config.get_value("user_control", "display_zombie_HP_label", false) 
	display_plant_card_bar_follow_mouse = config.get_value("user_control", "display_plant_card_bar_follow_mouse", false) 
	fog_is_static = config.get_value("user_control", "fog_is_static", false) 
	plant_be_shovel_front = config.get_value("user_control", "plant_be_shovel_front", true) 

#endregion



#endregion


#endregion


#region 关卡相关

## 加载场景
enum MainScenes{
	StartMenu,
	ChooseLevel,
	MainGameFront,
	MainGameBack,
	
	Garden,
	Almanac,
	Store,
}

var MainScenesMap = {
	MainScenes.StartMenu: "res://scenes/main/01StartMenu.tscn",
	MainScenes.ChooseLevel: "res://scenes/main/02ChooesLevel.tscn",
	MainScenes.MainGameFront: "res://scenes/main/MainGame01Front.tscn",
	MainScenes.MainGameBack: "res://scenes/main/MainGame02Back.tscn",
	
	MainScenes.Garden: "res://scenes/main/10Garden.tscn",
	MainScenes.Almanac: "res://scenes/main/11Almanac.tscn",
	MainScenes.Store: "res://scenes/main/12Store.tscn",
}


var game_para:ResourceLevelData = load("res://resources/level_date_resource/mode_adventure/adventure_01_day.tres")
## 离开商店信号
signal signal_store_leave
var store_node :Node
## 打开商店和删除相关
# 当前场景中
func enter_store(curr_scene:Node):
	save_game_data()
	# 加载新场景并添加为子节点
	store_node = preload("res://scenes/main/12Store.tscn").instantiate()
	get_tree().root.add_child(store_node)



# 在新场景的脚本中（例如点击返回按钮）
func exit_store():
	Global.save_game_data()
	signal_store_leave.emit()
	store_node.queue_free()  # 删除当前商店场景

#endregion
