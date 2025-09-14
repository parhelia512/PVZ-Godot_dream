extends Resource
class_name ResourceLevelData

#region 游戏参数枚举以及对应map
#region 游戏背景
## 游戏场景
enum GameBg{
	FrontDay,
	FrontNight,
	Pool,
}

## 背景图
var GameBgTextureMap = {
	GameBg.FrontDay: preload("res://assets/image/background/background1.jpg"),
	GameBg.FrontNight: preload("res://assets/image/background/background2.jpg"),
	GameBg.Pool: preload("res://assets/image/background/background3.jpg"),
}
#endregion

#region 游戏模式
enum GameMode{
	Adventure,	# 主游戏冒险模式
	MiniGame,	# 小游戏
}

## 游戏关卡枚举值
enum AdventureLevel{
	FrontDay,
	FrontNight,
	Pool
}

## 小游戏模式
enum MiniGameLevel{
	Bowling,		# 保龄球
	HammerZombie,	# 锤僵尸
}

enum GameBGM {
	FrontDay,
	FrontNight,
	Pool,
	
	MiniGame,
	
}

## bgm
var  GameBGMMap = {
	GameBGM.FrontDay: "res://assets/audio/BGM/front_day.mp3",
	GameBGM.FrontNight: "res://assets/audio/BGM/front_night.mp3",
	GameBGM.Pool: "res://assets/audio/BGM/pool.mp3",
	
	GameBGM.MiniGame: "res://assets/audio/BGM/mini_game.mp3"
}



#endregion

#region 卡槽
## 卡槽模式
enum CardMode{
	Norm,
	ConveyorBelt
}

#endregion

#endregion

#region 关卡参数
@export_group("关卡参数")
#region 关卡
@export_subgroup("关卡")
## 游戏模式  
@export var  game_mode:GameMode = GameMode.Adventure
## 冒险关卡
@export var adventure_game_level :AdventureLevel = AdventureLevel.FrontDay
## 迷你游戏关卡
@export var mini_game_level :MiniGameLevel = MiniGameLevel.Bowling
#endregion

#region 关卡背景
@export_subgroup("关卡背景参数")
## 游戏场景
@export var game_sences:Global.MainScenes = Global.MainScenes.MainGameFront
## 游戏背景
@export var game_BG:GameBg = GameBg.FrontDay
## 游戏背景音乐
@export var game_BGM:GameBGM = GameBGM.FrontDay
#endregion

#region 关卡流程
@export_subgroup("关卡流程参数")
## 开局查看展示僵尸
@export var look_show_zombie:bool = true
## 卡槽模式，只有Norm可以选卡
@export var card_mode : CardMode = CardMode.Norm
## 是否有卡槽,传送带要出现
@export var have_card_bar := true
## 是否可以选择卡片,传送带不可选择
@export var can_choosed_card :bool = true
#endregion


#region 出怪参数
@export_subgroup("出怪参数")
## 游戏是否出怪
@export var is_zombie_spawn := true
## 游戏出怪波次，每10波生成1旗帜
@export var max_wave := 30
## 僵尸种类刷新列表
@export var zombie_refresh_types : Array[Global.ZombieType] = [
	Global.ZombieType.ZombieNorm,			# 普通僵尸
	#Global.ZombieType.ZombieFlag,			# 旗帜僵尸
	Global.ZombieType.ZombieCone,			# 路障僵尸
	Global.ZombieType.ZombiePoleVaulter,	# 撑杆僵尸
	Global.ZombieType.ZombieBucket,			# 铁桶僵尸
]
## 出怪倍率
@export var zombie_multy := 1
## 初始生成的墓碑数量
@export var init_tombstone_num := 0
## 大波是否生成墓碑的墓碑数量
@export var create_tombston_in_flag_wave := false
#endregion

#region 卡片参数
## 当前已有的植物卡片在Global文件中
@export_subgroup("卡片参数")
## 最大卡槽数量
@export_range(1,10) var max_choosed_card_num :int = 10
## 开始阳光数量
@export var start_sun : int = 50

## 是否天降阳光,传送带没有
@export var is_day_sun:bool = true
## 预选卡片列表、预选卡片不能取消,传送带模式为开局时出现的卡片
@export var pre_choosed_card_list:Array[Global.PlantType] = []

#var card_type_list:Array[Global.PlantType] = [Global.PlantType.PotatoMine, Global.PlantType.GraveBuster, Global.PlantType.IceShroom]
@export_subgroup("传送带卡片参数")
## 可能出现的卡片
@export var card_type :Array[Global.PlantType] = []
## 每张卡片出现对应的概率
@export var card_type_probability :Array[int] = []
## 游戏开始时按顺序出现的卡片
@export var card_type_start_list :Array[Global.PlantType] = []
#endregion


## 游戏开始会根据参数初始化一些硬性的参数
func init_para():
	match card_mode:
		CardMode.Norm:
			pass
		CardMode.ConveyorBelt:
			have_card_bar = true
			can_choosed_card = false
			is_day_sun = false
			assert(card_type.size() == card_type_probability.size(), "传送带卡片和其出现的概率需要一一对应")
			
			
