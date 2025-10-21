extends Node

## 图层顺序种类
#0,		## 世界背景
#100,	## 鼠标未移入UI时，在最下面
#395,	## 植物： 395	 代码更新每行图层 每行隔10个图层
	#395+5,		## 磁力菇吸的铁具
	#395-4,		## 墓碑: 当前植物格子图层-4
#400,	## 僵尸： 400	 代码更新每行图层 每行僵尸隔10图层
	#0,		## 保龄球根据行更新图层，在僵尸行之间
	#400-7 蹦极僵尸
	#400-7 +7+2 蹦极僵尸靶子
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
	SoundManager.play_other_SFX("chime")

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
	_create_save_game_timer()

#region 自动保存存档
func _create_save_game_timer():
	var save_game_timer = Timer.new()

	save_game_timer.wait_time = 60
	save_game_timer.one_shot = false
	save_game_timer.autostart = true
	add_child(save_game_timer)
	# 连接超时信号
	save_game_timer.timeout.connect(_on_save_game_timer_timeout)

func _on_save_game_timer_timeout():
	print("自动保存存档")
	save_game_data()
#endregion

var curr_plant = [
	PlantType.P001PeaShooterSingle,
	PlantType.P002SunFlower,
	PlantType.P003CherryBomb,
	PlantType.P004WallNut,
	PlantType.P005PotatoMine,
	PlantType.P006SnowPea,
	PlantType.P007Chomper,
	PlantType.P008PeaShooterDouble,

	PlantType.P009PuffShroom,
	PlantType.P010SunShroom,
	PlantType.P011FumeShroom,
	PlantType.P012GraveBuster,
	PlantType.P013HypnoShroom,
	PlantType.P014ScaredyShroom,
	PlantType.P015IceShroom,
	PlantType.P016DoomShroom,

	PlantType.P017LilyPad,
	PlantType.P018Squash,
	PlantType.P019ThreePeater,
	PlantType.P020TangleKelp,
	PlantType.P021Jalapeno,
	PlantType.P022Caltrop,
	PlantType.P023TorchWood,
	PlantType.P024TallNut,

	PlantType.P025SeaShroom,
	PlantType.P026Plantern,
	PlantType.P027Cactus,
	PlantType.P028Blover,
	PlantType.P029SplitPea,
	PlantType.P030StarFruit,
	PlantType.P031Pumpkin,
	PlantType.P032MagnetShroom,

	PlantType.P033CabbagePult,
	PlantType.P034FlowerPot,
	PlantType.P035CornPult,
	PlantType.P036CoffeeBean,
	PlantType.P037Garlic,
	PlantType.P038UmbrellaLeaf,
	PlantType.P039MariGold,
	PlantType.P040MelonPult,
#
	#PlantType.P041GatlingPea,
	#PlantType.P042TwinSunFlower,
	#PlantType.P043GloomShroom,
	#PlantType.P044Cattail,
	#PlantType.P045WinterMelon,
	#PlantType.P046GoldMagnet,
	#PlantType.P047SpikeRock,
	#PlantType.P048CobCannon,
#
	#PlantType.P1001WallNutBowling,
	#PlantType.P1002WallNutBowlingBomb,
	#PlantType.P1003WallNutBowlingBig,

]


var curr_zombie = [
	ZombieType.Z001Norm,
	ZombieType.Z002Flag,
	ZombieType.Z003Cone,
	ZombieType.Z004PoleVaulter,
	ZombieType.Z005Bucket,

	ZombieType.Z006Paper,
	ZombieType.Z007ScreenDoor,
	ZombieType.Z008Football,
	ZombieType.Z009Jackson,
	ZombieType.Z010Dancer,

	#ZombieDuckytube,
	ZombieType.Z012Snorkle,
	ZombieType.Z013Zamboni,
	ZombieType.Z014Bobsled,
	ZombieType.Z015Dolphinrider,

	ZombieType.Z016Jackbox,
	ZombieType.Z017Ballon,
	ZombieType.Z018Digger,
	ZombieType.Z019Pogo,
	ZombieType.Z020Yeti,

	ZombieType.Z021Bungi,
	ZombieType.Z022Ladder,
	ZombieType.Z023Catapult,
	ZombieType.Z024Gargantuar,
	ZombieType.Z025Imp,
	### 单人雪橇车小队僵尸
	#ZombieType.Z1001BobsledSingle,
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
## 植物选卡和僵尸选卡
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
enum CharacterType {Null, Plant, Zombie}


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
	P001PeaShooterSingle = 1,
	P002SunFlower,
	P003CherryBomb,
	P004WallNut,
	P005PotatoMine,
	P006SnowPea,
	P007Chomper,
	P008PeaShooterDouble,

	P009PuffShroom,
	P010SunShroom,
	P011FumeShroom,
	P012GraveBuster,
	P013HypnoShroom,
	P014ScaredyShroom,
	P015IceShroom,
	P016DoomShroom,

	P017LilyPad,
	P018Squash,
	P019ThreePeater,
	P020TangleKelp,
	P021Jalapeno,
	P022Caltrop,
	P023TorchWood,
	P024TallNut,

	P025SeaShroom,
	P026Plantern,
	P027Cactus,
	P028Blover,
	P029SplitPea,
	P030StarFruit,
	P031Pumpkin,
	P032MagnetShroom,

	P033CabbagePult,
	P034FlowerPot,
	P035CornPult,
	P036CoffeeBean,
	P037Garlic,
	P038UmbrellaLeaf,
	P039MariGold,
	P040MelonPult,

	P041GatlingPea,
	P042TwinSunFlower,
	P043GloomShroom,
	P044Cattail,
	P045WinterMelon,
	P046GoldMagnet,
	P047SpikeRock,
	P048CobCannon,

	## 发芽
	P1000Sprout = 1000,
	## 保龄球
	P1001WallNutBowling = 1001,
	P1002WallNutBowlingBomb,
	P1003WallNutBowlingBig,
	}


const  PlantInfo = {
	PlantType.P001PeaShooterSingle: {
		PlantInfoAttribute.PlantName: "PeaShooterSingle",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantConditionResource:preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_001_pea_shooter_single.tscn")
		},
	PlantType.P002SunFlower: {
		PlantInfoAttribute.PlantName: "SunFlower",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource:preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_002_sun_flower.tscn")
		},
	PlantType.P003CherryBomb: {
		PlantInfoAttribute.PlantName: "CherryBomb",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 150,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_003_cherry_bomb.tscn")
		},
	PlantType.P004WallNut: {
		PlantInfoAttribute.PlantName: "WallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_004_wall_nut.tscn")
		},
	PlantType.P005PotatoMine: {
		PlantInfoAttribute.PlantName: "PotatoMine",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/005_potato_mine.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_005_potato_mine.tscn")
		},
	PlantType.P006SnowPea: {
		PlantInfoAttribute.PlantName: "SnowPea",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_006_snow_pea.tscn")
		},
	PlantType.P007Chomper: {
		PlantInfoAttribute.PlantName: "Chomper",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 150,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_007_chomper.tscn")
		},
	PlantType.P008PeaShooterDouble: {
		PlantInfoAttribute.PlantName: "PeaShooterDouble",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 200,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_008_pea_shooter_double.tscn")
		},
		#
	PlantType.P009PuffShroom: {
		PlantInfoAttribute.PlantName: "PuffShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 0,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_009_puff.tscn")
		},
	PlantType.P010SunShroom: {
		PlantInfoAttribute.PlantName: "SunShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_010_sun_shroom.tscn")
		},
	PlantType.P011FumeShroom: {
		PlantInfoAttribute.PlantName: "FumeShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_011_fume_shroom.tscn")
		},
	PlantType.P012GraveBuster: {
		PlantInfoAttribute.PlantName: "GraveBuster",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/012_grave_buster.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_012_grave_buster.tscn")
		},
	PlantType.P013HypnoShroom: {
		PlantInfoAttribute.PlantName: "HypnoShroom",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_013_hypno_shroom.tscn")
		},
	PlantType.P014ScaredyShroom: {
		PlantInfoAttribute.PlantName: "ScaredyShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_014_scaredy_shroom.tscn")
		},
	PlantType.P015IceShroom: {
		PlantInfoAttribute.PlantName: "IceShroom",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_015_ice_shroom.tscn")
		},
	PlantType.P016DoomShroom: {
		PlantInfoAttribute.PlantName: "DoomShroom",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_016_doom_shroom.tscn")
		},
	PlantType.P017LilyPad: {
		PlantInfoAttribute.PlantName: "LilyPad",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/017_lily_pad.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_017_lily_pad.tscn")
		},
	PlantType.P018Squash: {
		PlantInfoAttribute.PlantName: "Squash",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_018_squash.tscn")
		},
	PlantType.P019ThreePeater: {
		PlantInfoAttribute.PlantName: "ThreePeater",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 325,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_019_three_peater.tscn")
		},
	PlantType.P020TangleKelp: {
		PlantInfoAttribute.PlantName: "TangleKelp",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/020_tanglekelp.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_020_tanglekelp.tscn")
		},
	PlantType.P021Jalapeno: {
		PlantInfoAttribute.PlantName: "Jalapeno",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_021_jalapeno.tscn")
		},
	PlantType.P022Caltrop: {
		PlantInfoAttribute.PlantName: "Caltrop",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/022_caltrop.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_022_caltrop.tscn")
		},
	PlantType.P023TorchWood: {
		PlantInfoAttribute.PlantName: "TorchWood",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_023_torch_wood.tscn")
		},
	PlantType.P024TallNut: {
		PlantInfoAttribute.PlantName: "TallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_024_tall_nut.tscn")
		},

	PlantType.P025SeaShroom: {
		PlantInfoAttribute.PlantName: "SeaShroom",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 0,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/020_tanglekelp.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_025_sea_shroom.tscn")
		},
	PlantType.P026Plantern: {
		PlantInfoAttribute.PlantName: "Plantern",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource : preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_026_plantern.tscn")
		},
	PlantType.P027Cactus: {
		PlantInfoAttribute.PlantName: "Cactus",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_027_cactus.tscn")
		},
	PlantType.P028Blover: {
		PlantInfoAttribute.PlantName: "Blover",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_028_blover.tscn")
		},
	PlantType.P029SplitPea: {
		PlantInfoAttribute.PlantName: "SplitPea",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_029_split_pea.tscn")
		},
	PlantType.P030StarFruit: {
		PlantInfoAttribute.PlantName: "StarFruit",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_030_star_fruit.tscn")
		},
	PlantType.P031Pumpkin: {
		PlantInfoAttribute.PlantName: "Pumpkin",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/031_Pumpkin.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_031_pumpkin.tscn")
		},
	PlantType.P032MagnetShroom: {
		PlantInfoAttribute.PlantName: "MagnetShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_032_magnet_shroom.tscn")
		},

	PlantType.P033CabbagePult: {
		PlantInfoAttribute.PlantName: "CabbagePult",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_033_cabbage_pult.tscn")
		},
	PlantType.P034FlowerPot: {
		PlantInfoAttribute.PlantName: "FlowerPot",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/034_flower_pot.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_034_flower_pot.tscn")
		},
	PlantType.P035CornPult: {
		PlantInfoAttribute.PlantName: "CornPult",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_035_corn_pult.tscn")
		},
	PlantType.P036CoffeeBean: {
		PlantInfoAttribute.PlantName: "CoffeeBean",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/036_coffee_bean.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_036_coffee_bean.tscn")
		},
	PlantType.P037Garlic: {
		PlantInfoAttribute.PlantName: "TallNut",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_037_garlic.tscn")
		},
	PlantType.P038UmbrellaLeaf: {
		PlantInfoAttribute.PlantName: "TallNut",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_038_umbrella_leaf.tscn")
		},
	PlantType.P039MariGold: {
		PlantInfoAttribute.PlantName: "TallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_039_mari_gold.tscn")
		},
	PlantType.P040MelonPult: {
		PlantInfoAttribute.PlantName: "TallNut",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 300,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/plant_040_melon_pult.tscn")
		},
	#PlantType.P041GatlingPea: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.P042TwinSunFlower: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.P043GloomShroom: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.P044Cattail: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.P045WinterMelon: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.P046GoldMagnet: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.P047SpikeRock: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/024_tall_nut.tscn"),
		#PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/024_tall_nut_static.tscn"),
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},
	#PlantType.P048CobCannon: {
		#PlantInfoAttribute.PlantName: "TallNut",
		#PlantInfoAttribute.CoolTime: 30.0,
		#PlantInfoAttribute.SunCost: 175,
		#PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/024_tall_nut.tscn"),
		#PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/024_tall_nut_static.tscn"),
		#PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		#},

	## 发芽
	PlantType.P1000Sprout:{
		PlantInfoAttribute.PlantName: "Sprout",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes :  preload("res://scenes/character/plant/plant_1000_sprout.tscn")
		},

	## 保龄球
	PlantType.P1001WallNutBowling: {
		PlantInfoAttribute.PlantName: "WallNutBowling",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes :  preload("res://scenes/character/plant/plant_1001_wall_nut_bowling.tscn")
		},
	PlantType.P1002WallNutBowlingBomb: {
		PlantInfoAttribute.PlantName: "WallNutBowlingBomb",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/character_resource/plant_condition/000_common_plant_land.tres"),
		PlantInfoAttribute.PlantScenes :  preload("res://scenes/character/plant/plant_1002_wall_nut_bowling.tscn")
		},
	PlantType.P1003WallNutBowlingBig: {
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
	Shell,	## 保护壳位置
	Down,	## 花盆（睡莲）位置
	Float,	## 漂浮位置
}

## 获取植物属性方法
func get_plant_info(plant_type:PlantType, info_attribute:PlantInfoAttribute):
	var curr_plant_info = PlantInfo[plant_type]
	return curr_plant_info[info_attribute]

#endregion

#region 僵尸
enum ZombieType {
	Null = 0,

	Z001Norm = 1,
	Z002Flag,
	Z003Cone,
	Z004PoleVaulter,
	Z005Bucket,

	Z006Paper,
	Z007ScreenDoor,
	Z008Football,
	Z009Jackson,
	Z010Dancer,

	Z011Duckytube,
	Z012Snorkle,
	Z013Zamboni,
	Z014Bobsled,
	Z015Dolphinrider,

	Z016Jackbox,
	Z017Ballon,
	Z018Digger,
	Z019Pogo,
	Z020Yeti,

	Z021Bungi,
	Z022Ladder,
	Z023Catapult,
	Z024Gargantuar,
	Z025Imp,

	Z1001BobsledSingle=1001,	## 单个雪橇车僵尸
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
	ZombieType.Z001Norm:{
		ZombieInfoAttribute.ZombieName: "ZombieNorm",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_001_norm.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},
	ZombieType.Z002Flag:{
		ZombieInfoAttribute.ZombieName: "ZombieFlag",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_002_flag.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},
	ZombieType.Z003Cone:{
		ZombieInfoAttribute.ZombieName: "ZombieCone",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_003_cone.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},
	ZombieType.Z004PoleVaulter:{
		ZombieInfoAttribute.ZombieName: "ZombiePoleVaulter",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_004_pole_vaulter.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z005Bucket:{
		ZombieInfoAttribute.ZombieName: "ZombieBucket",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_005_bucket.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},

	ZombieType.Z006Paper:{
		ZombieInfoAttribute.ZombieName: "ZombiePaper",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_006_paper.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z007ScreenDoor:{
		ZombieInfoAttribute.ZombieName: "ZombieScreenDoor",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_007_screendoor.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z008Football:{
		ZombieInfoAttribute.ZombieName: "ZombieFootball",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes: preload("res://scenes/character/zombie/zombie_008_football.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z009Jackson:{
		ZombieInfoAttribute.ZombieName: "ZombieJackson",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_009_jackson.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z010Dancer:{
		ZombieInfoAttribute.ZombieName: "ZombieDancer",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_010_dancer.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},

	ZombieType.Z012Snorkle:{
		ZombieInfoAttribute.ZombieName: "ZombieSnorkle",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_012_snorkle.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Pool
	},
	ZombieType.Z013Zamboni:{
		ZombieInfoAttribute.ZombieName: "ZombieZamboni",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_013_zamboni.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z014Bobsled:{
		ZombieInfoAttribute.ZombieName: "ZombieBobsled",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_014_bobsled.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z015Dolphinrider:{
		ZombieInfoAttribute.ZombieName: "ZombieDolphinrider",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_015_dolphinrider.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Pool
	},
	ZombieType.Z016Jackbox:{
		ZombieInfoAttribute.ZombieName: "ZombieJackbox",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_016_jackbox.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z017Ballon:{
		ZombieInfoAttribute.ZombieName: "ZombieBallon",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_017_balloon.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},
	ZombieType.Z018Digger:{
		ZombieInfoAttribute.ZombieName: "ZombieDigger",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_018_digger.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z019Pogo:{
		ZombieInfoAttribute.ZombieName: "ZombiePogo",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_019_pogo.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z020Yeti:{
		ZombieInfoAttribute.ZombieName: "ZombieYeti",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 100,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_020_yeti.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z021Bungi:{
		ZombieInfoAttribute.ZombieName: "ZombieBungi",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 100,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_021_bungi.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Both
	},
	ZombieType.Z022Ladder:{
		ZombieInfoAttribute.ZombieName: "ZombieLadder",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 100,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_022_ladder.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z023Catapult:{
		ZombieInfoAttribute.ZombieName: "ZombieCatapult",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 100,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_023_catapult.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z024Gargantuar:{
		ZombieInfoAttribute.ZombieName: "ZombieGargantuar",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 100,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_024_gargantuar.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
	ZombieType.Z025Imp:{
		ZombieInfoAttribute.ZombieName: "ZombieImp",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 100,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_025_imp.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},

	## 单独雪橇僵尸
	ZombieType.Z1001BobsledSingle:{
		ZombieInfoAttribute.ZombieName: "ZombieBobsledSingle",
		ZombieInfoAttribute.CoolTime: 0.0,
		ZombieInfoAttribute.SunCost: 50,
		ZombieInfoAttribute.ZombieScenes:preload("res://scenes/character/zombie/zombie_1001_bobsled_signle.tscn"),
		ZombieInfoAttribute.ZombieRowType:ZombieRowType.Land
	},
}

## 获取僵尸属性方法
func get_zombie_info(zombie_type:ZombieType, info_attribute:ZombieInfoAttribute):
	if zombie_type == 0:
		printerr("空僵尸")
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

	Bullet001Pea = 1,			## 豌豆
	Bullet002PeaSnow,		## 寒冰豌豆
	Bullet003Puff,			## 小喷孢子
	Bullet004Fume,			## 大喷孢子
	Bullet005PuffLongTime,	## 胆小菇孢子（和小喷孢子一样，不过修改存在持续距离）
	Bullet006PeaFire,		## 火焰豌豆
	Bullet007Cactus,		## 仙人掌尖刺
	Bullet008Star,			## 星星子弹

	Bullet009Cabbage,		## 卷心菜
	Bullet010Corn,			## 玉米
	Bullet011Butter,		## 黄油
	Bullet012Melon,			## 西瓜

	Bullet013Basketball,	## 篮球

}

const BulletTypeMap := {
	BulletType.Bullet001Pea : preload("res://scenes/bullet/bullet_001_pea.tscn"),
	BulletType.Bullet002PeaSnow : preload("res://scenes/bullet/bullet_002_pea_snow.tscn"),
	BulletType.Bullet003Puff : preload("res://scenes/bullet/bullet_003_puff.tscn"),
	BulletType.Bullet004Fume : preload("res://scenes/bullet/bullet_004_fume.tscn"),
	BulletType.Bullet005PuffLongTime : preload("res://scenes/bullet/bullet_005_puff_long_time.tscn"),
	BulletType.Bullet006PeaFire : preload("res://scenes/bullet/bullet_006_pea_fire.tscn"),
	BulletType.Bullet007Cactus : preload("res://scenes/bullet/bullet_007_cactus.tscn"),
	BulletType.Bullet008Star : preload("res://scenes/bullet/bullet_008_star.tscn"),

	BulletType.Bullet009Cabbage :preload("res://scenes/bullet/bullet_009_cabbage.tscn"),
	BulletType.Bullet010Corn :preload("res://scenes/bullet/bullet_010_corn.tscn"),
	BulletType.Bullet011Butter :preload("res://scenes/bullet/bullet_011_butter.tscn"),
	BulletType.Bullet012Melon :preload("res://scenes/bullet/bullet_012_melon.tscn"),

	BulletType.Bullet013Basketball :preload("res://scenes/bullet/bullet_013_basketball.tscn"),

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
## 卡槽显示改变,隐藏多余卡槽
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

signal signal_change_card_slot_top_mouse_focus

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
	MainGameFront,
	MainGameBack,
	MainGameRoof,

	StartMenu,
	ChooseLevel,
	ChooseLevelMiniGame,

	Garden,
	Almanac,
	Store,
}

var MainScenesMap = {
	MainScenes.MainGameFront: "res://scenes/main/MainGame01Front.tscn",
	MainScenes.MainGameBack: "res://scenes/main/MainGame02Back.tscn",
	MainScenes.MainGameRoof: "res://scenes/main/MainGame03Roof.tscn",

	MainScenes.StartMenu: "res://scenes/main/01StartMenu.tscn",
	MainScenes.ChooseLevel: "res://scenes/main/02ChooesLevel.tscn",
	MainScenes.ChooseLevelMiniGame: "res://scenes/main/03MiniGameChooesLevel.tscn",

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
