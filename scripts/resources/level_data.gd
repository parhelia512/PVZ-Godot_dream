extends Resource
class_name ResourceLevelData

#region 游戏参数枚举以及对应map
#region 游戏背景
## 游戏场景
enum GameBg{
	FrontDay,
	FrontNight,
	Pool,
	Fog,
}

## 背景图
var GameBgTextureMap = {
	GameBg.FrontDay: preload("res://assets/image/background/background1.jpg"),
	GameBg.FrontNight: preload("res://assets/image/background/background2.jpg"),
	GameBg.Pool: preload("res://assets/image/background/background3.jpg"),
	GameBg.Fog: preload("res://assets/image/background/background4.jpg"),

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
	Fog,
	Roof,

	MiniGame,
}

## 出怪模式
enum E_MonsterMode{
	Null,	## 不出怪，测试使用
	Norm,	## 正常出怪模式
	HammerZombie,	## 锤僵尸出怪模式
}

## bgm
const  GameBGMMap = {
	GameBGM.FrontDay: "res://assets/audio/BGM/front_day.mp3",
	GameBGM.FrontNight: "res://assets/audio/BGM/front_night.mp3",
	GameBGM.Pool: "res://assets/audio/BGM/pool.mp3",
	GameBGM.Fog: "res://assets/audio/BGM/fog.mp3",
	GameBGM.Roof: "res://assets/audio/BGM/roof.mp3",

	GameBGM.MiniGame: "res://assets/audio/BGM/mini_game.mp3"
}



#endregion

#region 卡槽
## 卡槽模式
enum E_CardMode{
	Norm,
	ConveyorBelt
}

#endregion

#endregion

#region 关卡参数
#region 关卡
@export_group("关卡")
## 游戏模式
@export var  game_mode:GameMode = GameMode.Adventure
## 冒险关卡
@export var adventure_game_level :AdventureLevel = AdventureLevel.FrontDay
## 迷你游戏关卡
@export var mini_game_level :MiniGameLevel = MiniGameLevel.Bowling
#endregion

#region 关卡背景
@export_group("关卡背景参数")
## 游戏场景
@export var game_sences:Global.MainScenes = Global.MainScenes.MainGameFront
## 游戏背景
@export var game_BG:GameBg = GameBg.FrontDay
## 游戏背景音乐
@export var game_BGM:GameBGM = GameBGM.FrontDay

## 是否有雾
@export var is_fog:bool = false
## 是否为白天,控制蘑菇睡觉
@export var is_day:bool = true
## 是否天降阳光,传送带没有
@export var is_day_sun:bool = true

#endregion

#region 关卡流程
@export_group("关卡流程参数")
## 开局查看展示僵尸
@export var look_show_zombie:bool = true
## 是否可以选择卡片,传送带不可选择
@export var can_choosed_card :bool = true
## 戴夫对话资源
@export var crazy_dave_dialog:CrazyDaveDialogResource

#endregion


#region 出怪参数
@export_group("出怪参数")
## 出怪模式
@export var monster_mode :E_MonsterMode = E_MonsterMode.Norm
@export_subgroup("正常出怪模式")
## 出怪倍率
@export var zombie_multy := 1
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
@export_subgroup("锤僵尸出怪模式（需调整对应墓碑参数）")
## 墓碑出怪倍率
@export var zombie_multy_hammer := 1
## 锤僵尸出怪波数
@export var max_wave_hammer_zombie := 10
## 初始化僵尸速度
@export var speed_zombie_init := 1.0
## 每波僵尸速度提升
@export var speed_zombie_add := 0.15
## 僵尸速度提升最大值
@export var speed_zombie_max := 2.0

@export_subgroup("墓碑参数")
## 是否有墓碑
@export var is_have_tombston:= false
## 初始生成的墓碑数量
@export var init_tombstone_num := 0

#endregion

#region 卡片参数
## 当前已有的植物卡片在Global文件中
@export_group("卡片参数")
## 卡槽模式，只有Norm可以选卡
@export var card_mode : E_CardMode = E_CardMode.Norm
## 是否有卡槽,传送带要出现
@export var have_card_bar := true
@export_subgroup("正常卡槽参数")
## 最大卡槽数量
@export_range(1,10) var max_choosed_card_num :int = 10
## 开始阳光数量
@export var start_sun : int = 50
## 预选卡片列表、预选卡片不能取消,传送带模式为开局时出现的卡片
@export var pre_choosed_card_list:Array[Global.PlantType] = []
@export var pre_choosed_card_list_zombie:Array[Global.ZombieType] = []

#var card_type_list:Array[Global.PlantType] = [Global.PlantType.PotatoMine, Global.PlantType.GraveBuster, Global.PlantType.IceShroom]
@export_subgroup("传送带卡片参数")
## 可能出现的卡片和概率
@export var all_card_plant_type_probability :Dictionary[Global.PlantType, int]
@export var all_card_zombie_type_probability :Dictionary[Global.ZombieType, int]
## 游戏开始时按顺序出现的卡片
@export var start_list_card_plant_type :Array[Global.PlantType]
@export var start_list_card_zombie_type :Array[Global.ZombieType]
## 创建卡片的倍率
@export var create_new_card_speed:float = 1

@export_subgroup("种植参数")
## 柱子模式
@export var is_mode_column := false
#endregion

#region 迷你游戏物品参数
@export_group("游戏物品参数")
@export_subgroup("保龄球红线")
@export var is_bowling_stripe := false
## 第几列植物格子之后(0开始)
@export var plant_cell_col_j:int = 2
## 左手可以种植
@export var is_left_can_plant := true
@export_subgroup("锤子")
@export var is_hammer := false
#endregion

## 游戏开始会根据参数初始化一些硬性的参数
func init_para():
	match card_mode:
		E_CardMode.Norm:
			pass
		E_CardMode.ConveyorBelt:
			have_card_bar = true
			can_choosed_card = false
			is_day_sun = false


