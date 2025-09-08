extends Node

## 图层顺序种类
#0,		## 世界背景
#100,	## 鼠标未移入UI时，在最下面
#395,	## 植物： 395	 每行隔10个图层
	#395+5,	## 磁力菇吸的铁具
	#395-2,		## 墓碑: 当前植物格子图层-2
#400,	## 僵尸： 400	 每行僵尸隔10图层
	#0,		## 保龄球根据行更新图层，在僵尸行之间
#405,	## 小推车： 每行比僵尸行+5，
#600,	## 子弹： 600
#650,	## 爆炸： 650
#700,	## 展示僵尸： 700
#800,	## 泳池迷雾:800
#910,	## 阳光： 910
#900,	## Ui2 : 900 鼠标移入UI时，在植物和僵尸上面
#950,	## 真实铲子 : 950
#950,	## 锤子： 950
#951,	## 锤击僵尸特效： 951
#0,		## 血量显示： 对应角色+1
#1000,	## UI3： 1000 进度条、准备放置植物
#1100,	## UI4： 1100 卡槽默认 （+50 卡片选择移动时临时位置）
#2000,	## 奖杯： 2000
#0,		## 商店： 使用canvasLayer
#3100,	## 戴夫: 3100
#3200,	## 金币显示：3200


## 花园图层顺序
#TODO:忘记写了，也不重要，有空写

#region 用户游戏存档相关
#region 全局游戏数据
## 金币数量
##
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
var coin_value_label:CoinBankLabel

## 生产金币,按概率生产，概率和为1, 将金币生产在coin_bank_bank（Global.coin_value_label）节点下
## 概率顺序为 银币金币和钻石
func create_coin(probability:Array=[0.5, 0.5, 0], global_position_new_coin:Vector2=Vector2()):
	coin_value_label.update_label()
	## 如果当前场景有金币值的label,将金币生产在coin_bank_bank（Global.coin_value_label）节点下
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

# TODO:暂时先写global，后面要改?
# 也可能不改 -- 20250907
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

	##PlantType.CabbagePult,
	#PlantType.FlowerPot,
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

	#PlantType.WallNutBowling,
	#PlantType.WallNutBowlingBomb,
	#PlantType.WallNutBowlingBig,

]


var curr_zombie = [
	ZombieType.ZombieNorm,
	ZombieType.ZombieFlag,
	ZombieType.ZombieCone,
	ZombieType.ZombiePoleVaulter,
	ZombieType.ZombieBucket,

	ZombieType.ZombiePaper,
	ZombieType.ZombieScreenDoor,
	ZombieType.ZombieFootball,
	ZombieType.ZombieJackson,
	ZombieType.ZombieDancer,

	#ZombieDuckytube,
	ZombieType.ZombieSnorkle,
	ZombieType.ZombieZamboni,
	ZombieType.ZombieBobsled,
	ZombieType.ZombieDolphinrider,


	### 单人雪橇车小队僵尸
	#ZombieType.ZombieBobsledSingle,
]

#region 保存数据
#region 存档全局数据
const SAVE_GAME_PATH = "user://SaveGame.json"
## 保存存档数据到 JSON 文件
func save_game_data() -> void:
	var data = {
		"coin_value": coin_value,
		"garden_data": garden_data,
		"curr_num_new_garden_plant": curr_num_new_garden_plant,
	}
	save_json(data, SAVE_GAME_PATH)

## 加载存档数据
func load_game_data() -> void:
	var data = load_json(SAVE_GAME_PATH) as Dictionary
	coin_value = data.get("coin_value", coin_value)
	curr_num_new_garden_plant = data.get("curr_num_new_garden_plant", curr_num_new_garden_plant)
	garden_data = data.get("garden_data", garden_data)
#endregion

#region 保存上次选卡信息
var selected_cards := {}
const SelectedCardsPath =  "user://selected_cards.json"
func save_selected_cards():
	var data:Dictionary = {
		"selected_cards" : selected_cards,
	}
	save_json(data, SelectedCardsPath)

func load_selected_cards():

	var data = load_json(SelectedCardsPath) as Dictionary
		# 加载数据
	selected_cards = data.get("selected_cards", {})

#endregion

#region 图鉴信息
var data_almanac:Dictionary
const PathDataPlant := "res://data/almanac_plant.json"
#endregion

#region 保存数据方法
## 保存数据到json
func save_json(data:Dictionary, path:String):
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("❌ 无法打开文件进行写入: %s" % path)
		return false

	var json_text := JSON.stringify(data, "\t")  # 可读性更强
	file.store_string(json_text)
	file.close()
	print("✅ 存档已保存到", path)

## 从json中读取数据
func load_json(path:String):
	if not FileAccess.file_exists(path):
		print("⚠️ 存档文件不存在: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("❌ 无法打开文件进行读取: %s" % path)
		return {}
	var json_text := file.get_as_text()
	file.close()
	var result = JSON.parse_string(json_text)
	if result == null:
		push_error("❌ JSON 解析失败")
		return {}

	print("✅ 成功读取json文件:", path)
	return result
#endregion
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
	PlantScenes,	## 植物场景预加载
	PlantConditionResource,	## 植物种植条件资源预加载
}

enum PlantType {
	Null = 0,
	PeaShooterSingle = 1,
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

	## 发芽
	Sprout = 1000,
	## 保龄球
	WallNutBowling = 1001,
	WallNutBowlingBomb,
	WallNutBowlingBig,
	}


const  PlantInfo = {
	PlantType.PeaShooterSingle: {
		PlantInfoAttribute.PlantName: "PeaShooterSingle",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantConditionResource:preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_001_pea_shooter_single.tscn")
		},
	PlantType.SunFlower: {
		PlantInfoAttribute.PlantName: "SunFlower",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource:preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_002_sun_flower.tscn")
		},
	PlantType.CherryBomb: {
		PlantInfoAttribute.PlantName: "CherryBomb",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 150,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_003_cherry_bomb.tscn")
		},
	PlantType.WallNut: {
		PlantInfoAttribute.PlantName: "WallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_004_wall_nut.tscn")
		},
	PlantType.PotatoMine: {
		PlantInfoAttribute.PlantName: "PotatoMine",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/005_potato_mine.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_005_potato_mine.tscn")
		},
	PlantType.SnowPea: {
		PlantInfoAttribute.PlantName: "SnowPea",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_006_snow_pea.tscn")
		},
	PlantType.Chomper: {
		PlantInfoAttribute.PlantName: "Chomper",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 150,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_007_chomper.tscn")
		},
	PlantType.PeaShooterDouble: {
		PlantInfoAttribute.PlantName: "PeaShooterDouble",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 200,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_008_pea_shooter_double.tscn")
		},
		#
	PlantType.PuffShroom: {
		PlantInfoAttribute.PlantName: "PuffShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 0,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_009_puff.tscn")
		},
	PlantType.SunShroom: {
		PlantInfoAttribute.PlantName: "SunShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_010_sun_shroom.tscn")
		},
	PlantType.FumeShroom: {
		PlantInfoAttribute.PlantName: "FumeShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_011_fume_shroom.tscn")
		},
	PlantType.GraveBuster: {
		PlantInfoAttribute.PlantName: "GraveBuster",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/012_grave_buster.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_012_grave_buster.tscn")
		},
	PlantType.HypnoShroom: {
		PlantInfoAttribute.PlantName: "HypnoShroom",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_013_hypno_shroom.tscn")
		},
	PlantType.ScaredyShroom: {
		PlantInfoAttribute.PlantName: "ScaredyShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_014_scaredy_shroom.tscn")
		},
	PlantType.IceShroom: {
		PlantInfoAttribute.PlantName: "IceShroom",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_015_ice_shroom.tscn")
		},
	PlantType.DoomShroom: {
		PlantInfoAttribute.PlantName: "DoomShroom",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_016_doom_shroom.tscn")
		},
	PlantType.LilyPad: {
		PlantInfoAttribute.PlantName: "LilyPad",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/017_lily_pad.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_017_lily_pad.tscn")
		},
	PlantType.Squash: {
		PlantInfoAttribute.PlantName: "Squash",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_018_squash.tscn")
		},
	PlantType.ThreePeater: {
		PlantInfoAttribute.PlantName: "ThreePeater",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 325,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_019_three_peater.tscn")
		},
	PlantType.TangleKelp: {
		PlantInfoAttribute.PlantName: "TangleKelp",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/020_tanglekelp.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_020_tanglekelp.tscn")
		},
	PlantType.Jalapeno: {
		PlantInfoAttribute.PlantName: "Jalapeno",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_021_jalapeno.tscn")
		},
	PlantType.Caltrop: {
		PlantInfoAttribute.PlantName: "Caltrop",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/022_caltrop.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_022_caltrop.tscn")
		},
	PlantType.TorchWood: {
		PlantInfoAttribute.PlantName: "TorchWood",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_023_torch_wood.tscn")
		},
	PlantType.TallNut: {
		PlantInfoAttribute.PlantName: "TallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_024_tall_nut.tscn")
		},

	PlantType.SeaShroom: {
		PlantInfoAttribute.PlantName: "SeaShroom",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 0,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/020_tanglekelp.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_025_sea_shroom.tscn")
		},
	PlantType.Plantern: {
		PlantInfoAttribute.PlantName: "Plantern",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_026_plantern.tscn")
		},
	PlantType.Cactus: {
		PlantInfoAttribute.PlantName: "Cactus",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_027_cactus.tscn")
		},
	PlantType.Blover: {
		PlantInfoAttribute.PlantName: "Blover",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_028_blover.tscn")
		},
	PlantType.SplitPea: {
		PlantInfoAttribute.PlantName: "SplitPea",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_029_split_pea.tscn")
		},
	PlantType.StarFruit: {
		PlantInfoAttribute.PlantName: "StarFruit",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_030_star_fruit.tscn")
		},
	PlantType.Pumpkin: {
		PlantInfoAttribute.PlantName: "Pumpkin",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/031_Pumpkin.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_031_pumpkin.tscn")
		},
	PlantType.MagnetShroom: {
		PlantInfoAttribute.PlantName: "MagnetShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_032_magnet_shroom.tscn")
		},

	#PlantType.CabbagePult: {
		#PlantInfoAttribute.PlantName: "CabbagePult",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.FlowerPot: {
		#PlantInfoAttribute.PlantName: "FlowerPot",
		#PlantInfoAttribute.CoolTime: 7.5,
		#PlantInfoAttribute.SunCost: 25,
		#PlantInfoAttribute.PlantScenesName: "034_flower_pot",
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/034_flower_pot.tres")
		#},
	#PlantType.CornPult: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.CoffeeBean: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.Garlic: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.UmbrellaLeaf: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.MariGold: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.MelonPult: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.GatlingPea: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.TwinSunFlower: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.GloomShroom: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.Cattail: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.WinterMelon: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.GoldMagnet: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
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

	## 发芽
	PlantType.Sprout:{
		PlantInfoAttribute.PlantName: "Sprout",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes :  preload("res://scenes/character/plant/plant_1000_sprout.tscn")
		},

	## 保龄球
	PlantType.WallNutBowling: {
		PlantInfoAttribute.PlantName: "WallNutBowling",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes :  preload("res://scenes/character/plant/plant_1001_wall_nut_bowling.tscn")
		},
	PlantType.WallNutBowlingBomb: {
		PlantInfoAttribute.PlantName: "WallNutBowlingBomb",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes :  preload("res://scenes/character/plant/plant_1002_wall_nut_bowling.tscn")
		},
	PlantType.WallNutBowlingBig: {
		PlantInfoAttribute.PlantName: "WallNutBowlingBig",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_1003_wall_nut_bowling.tscn")
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
	var curr_plant_info = PlantInfo[plant_type]
	return curr_plant_info[info_attribute]

#endregion

#region 僵尸
#TODO：改成和植物差不多的
enum ZombieType {
	Null = 0,
	ZombieNorm = 1,
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

	ZombieBobsledSingle=1001,	## 单个雪橇车僵尸
	}

## 僵尸行类型
enum ZombieRowType{
	Land,
	Pool,
	Both,
}

## 僵尸信息属性
enum ZombieInfoAttribute{
	ZombieName,
	CoolTime,		## 僵尸冷却时间
	SunCost,		## 阳光消耗
	ZombieScenes,	## 植物场景预加载
	ZombieRowType,	## 僵尸行类型
}

## 僵尸信息
const ZombieInfo = {
	ZombieType.ZombieNorm:{
		ZombieInfoAttribute.ZombieName: "ZombieNorm",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_001_norm.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},
	ZombieType.ZombieFlag:{
		ZombieInfoAttribute.ZombieName: "ZombieFlag",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_002_flag.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},
	ZombieType.ZombieCone:{
		ZombieInfoAttribute.ZombieName: "ZombieCone",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_003_cone.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},
	ZombieType.ZombiePoleVaulter:{
		ZombieInfoAttribute.ZombieName: "ZombiePoleVaulter",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_004_pole_vaulter.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.ZombieBucket:{
		ZombieInfoAttribute.ZombieName: "ZombieBucket",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_005_bucket.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},

	ZombieType.ZombiePaper:{
		ZombieInfoAttribute.ZombieName: "ZombiePaper",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_006_paper.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.ZombieScreenDoor:{
		ZombieInfoAttribute.ZombieName: "ZombieScreenDoor",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_007_screendoor.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.ZombieFootball:{
		ZombieInfoAttribute.ZombieName: "ZombieFootball",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes: preload("res://scenes/character/zombie/zombie_008_football.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.ZombieJackson:{
		ZombieInfoAttribute.ZombieName: "ZombieJackson",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_009_jackson.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.ZombieDancer:{
		ZombieInfoAttribute.ZombieName: "ZombieDancer",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_010_dancer.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},

	ZombieType.ZombieSnorkle:{
		ZombieInfoAttribute.ZombieName: "ZombieSnorkle",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_012_snorkle.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Pool
	},
	ZombieType.ZombieZamboni:{
		ZombieInfoAttribute.ZombieName: "ZombieZamboni",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_013_zamboni.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.ZombieBobsled:{
		ZombieInfoAttribute.ZombieName: "ZombieBobsled",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_014_bobsled.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.ZombieDolphinrider:{
		ZombieInfoAttribute.ZombieName: "ZombieDolphinrider",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_015_dolphinrider.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Pool
	},


	## 单独雪橇僵尸
	ZombieType.ZombieBobsledSingle:{
		ZombieInfoAttribute.ZombieName: "ZombieBobsledSingle",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_1001_bobsled_signle.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
}


## 获取僵尸属性方法
func get_zombie_info(zombie_type:ZombieType, info_attribute:ZombieInfoAttribute):
	var curr_zombie_info = ZombieInfo[zombie_type]
	return curr_zombie_info[info_attribute]


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
	Null = 0,

	BulletPea = 1,			## 豌豆
	BulletPeaSnow,		## 寒冰豌豆
	BulletPuff,			## 小喷孢子
	BulletFume,			## 大喷孢子
	BulletPuffLongTime,	## 胆小菇孢子（和小喷孢子一样，不过修改存在持续距离）
	BulletPeaFire,		## 火焰豌豆
	BulletCactus,		## 仙人掌尖刺
	BulletStar,			## 星星子弹
}

const BulletTypeMap := {
	BulletType.BulletPea : preload("res://scenes/bullet/bullet_linear/bullet_001_pea.tscn"),
	BulletType.BulletPeaSnow : preload("res://scenes/bullet/bullet_linear/bullet_002_pea_snow.tscn"),
	BulletType.BulletPuff : preload("res://scenes/bullet/bullet_linear/bullet_003_puff.tscn"),
	BulletType.BulletFume : preload("res://scenes/bullet/bullet_linear/bullet_004_fume.tscn"),
	BulletType.BulletPuffLongTime : preload("res://scenes/bullet/bullet_linear/bullet_005_puff_long_time.tscn"),
	BulletType.BulletPeaFire : preload("res://scenes/bullet/bullet_linear/bullet_006_pea_fire.tscn"),
	BulletType.BulletCactus : preload("res://scenes/bullet/bullet_linear/bullet_007_cactus.tscn"),
	BulletType.BulletStar : preload("res://scenes/bullet/bullet_linear/bullet_008_star.tscn"),

}

## 获取子弹场景方法
func get_bullet_scenes(bullet_type:BulletType) -> PackedScene:
	return BulletTypeMap.get(bullet_type)

#endregion

#region 铁器种类、磁力菇与铁器僵尸交互使用

## 铁器种类
enum IronType{
	Null,		## 没有铁器
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
var disappear_spare_card_Placeholder := false:
	set(value):
		disappear_spare_card_Placeholder = value
		signal_change_disappear_spare_card_placeholder.emit()
## 卡槽显示改变
signal signal_change_disappear_spare_card_placeholder

## 需要区分植物和僵尸，因此将值作为参数发射
var display_plant_HP_label := false:
	set(value):
		display_plant_HP_label = value
		signal_change_display_plant_HP_label.emit(display_plant_HP_label)
## 血量显示改变信号
signal signal_change_display_plant_HP_label(value:bool)

var display_zombie_HP_label := false:
	set(value):
		display_zombie_HP_label = value
		signal_change_display_zombie_HP_label.emit(display_zombie_HP_label)

## 血量显示改变信号
signal signal_change_display_zombie_HP_label(value:bool)

var card_slot_top_mouse_focus := false:
	set(value):
		card_slot_top_mouse_focus = value

## 静态迷雾
var fog_is_static := false:
	set(value):
		fog_is_static = value
		signal_fog_is_static.emit()

signal signal_fog_is_static


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
	config.set_value("user_control", "card_slot_top_mouse_focus", card_slot_top_mouse_focus)
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
	card_slot_top_mouse_focus = config.get_value("user_control", "card_slot_top_mouse_focus", false)
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
	## 商店场景添加为子节点
	store_node = preload("res://scenes/main/12Store.tscn").instantiate()
	get_tree().current_scene.add_child(store_node)


# 在新场景的脚本中（例如点击返回按钮）
func exit_store():
	Global.save_game_data()
	signal_store_leave.emit()
	store_node.queue_free()  # 删除当前商店场景

#endregion
