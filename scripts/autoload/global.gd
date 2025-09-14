extends Node

func _ready() -> void:
	save_game()

#region 游戏相关

# 图层顺序：
#世界背景： 0
#Ui1: 100	鼠标未移入UI时，在最下面
#墓碑: 150
#植物： 200
#僵尸： 400	每行僵尸隔10图层
#保龄球： 根据行更新图层，在僵尸行之间
#小推车： 每行比僵尸行+5，
#起跳窝瓜： 每行比僵尸行+5，
#子弹： 600
#爆炸： 650
#阳光： 800
#Ui2 : 900 鼠标移入UI时，在植物和僵尸下面
#真实铲子 : 950
# 锤子： 950
# 锤击僵尸特效： 951
#血量显示： 980
#UI3： 1000 进度条、准备放置植物
#UI4： 1100 所有备选植物卡槽
#UI5:  1150 卡片选择移动时临时位置

#奖杯： 2000



#region 角色
# 定义枚举
enum CharacterType {Plant, Zombie}


#region 植物

enum PlantInfoAttribute{
	PlantName,
	CoolTime,		## 植物种植冷却时间
	SunCost,		## 阳光消耗
	PlantScenes,	## 植物场景预加载
	PlantStaticScenes,	## 静态植物预加载
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
	}


var PlantInfo = {
	PlantType.PeaShooterSingle: {
		PlantInfoAttribute.PlantName: "PeaShooterSingle",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 100,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/001_pea_shooter_single.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/001_pea_shooter_single_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
		
	PlantType.SunFlower: {
		PlantInfoAttribute.PlantName: "SunFlower",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/002_sun_flower.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/002_sun_flower_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		
		},
	PlantType.CherryBomb: {
		PlantInfoAttribute.PlantName: "CherryBomb",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 150,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/003_cherry_bomb.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/003_cherry_bomb_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		
		},
	PlantType.WallNut: {
		PlantInfoAttribute.PlantName: "WallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/004_wall_nut.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/004_wall_nut_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.PotatoMine: {
		PlantInfoAttribute.PlantName: "PotatoMine",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/005_potato_mine.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/005_potato_mine_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/005_potato_mine.tres")
		},
	PlantType.SnowPea: {
		PlantInfoAttribute.PlantName: "SnowPea",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/006_snow_pea.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/006_snow_pea_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.Chomper: {
		PlantInfoAttribute.PlantName: "Chomper",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 150,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/007_chomper.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/007_chomper_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.PeaShooterDouble: {
		PlantInfoAttribute.PlantName: "PeaShooterDouble",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 200,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/008_pea_shooter_double.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/008_pea_shooter_double_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.PuffShroom: {
		PlantInfoAttribute.PlantName: "PuffShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 0,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/009_puff_shroom.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/009_puff_shroom_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.SunShroom: {
		PlantInfoAttribute.PlantName: "SunShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/010_sun_shroom.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/010_sun_shroom_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.FumeShroom: {
		PlantInfoAttribute.PlantName: "FumeShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/011_fume_shroom.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/011_fume_shroom_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.GraveBuster: {
		PlantInfoAttribute.PlantName: "GraveBuster",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/012_grave_buster.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/012_grave_buster_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/012_grave_buster.tres")
		},
	PlantType.HypnoShroom: {
		PlantInfoAttribute.PlantName: "HypnoShroom",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/013_hypno_shroom.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/013_hypno_shroom_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.ScaredyShroom: {
		PlantInfoAttribute.PlantName: "ScaredyShroom",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/014_scaredy_shroom.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/014_scaredy_shroom_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.IceShroom: {
		PlantInfoAttribute.PlantName: "IceShroom",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 75,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/015_ice_shroom.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/015_ice_shroom_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.DoomShroom: {
		PlantInfoAttribute.PlantName: "DoomShroom",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/016_doom_shroom.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/016_doom_shroom_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.LilyPad: {
		PlantInfoAttribute.PlantName: "LilyPad",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/017_lily_pad.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/017_lily_pad_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/017_lily_pad.tres")
		},
	PlantType.Squash: {
		PlantInfoAttribute.PlantName: "Squash",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/018_squash.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/018_squash_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.ThreePeater: {
		PlantInfoAttribute.PlantName: "ThreePeater",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 325,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/019_three_peater.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/019_three_peater_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.TangleKelp: {
		PlantInfoAttribute.PlantName: "TangleKelp",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 25,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/020_tanglekelp.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/020_tanglekelp_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/020_tanglekelp.tres")
		},
	PlantType.Jalapeno: {
		PlantInfoAttribute.PlantName: "Jalapeno",
		PlantInfoAttribute.CoolTime: 50.0,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/021_jalapeno.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/021_jalapeno_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.Caltrop: {
		PlantInfoAttribute.PlantName: "Caltrop",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 125,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/022_caltrop.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/022_caltrop_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/022_caltrop.tres")
		},
	PlantType.TorchWood: {
		PlantInfoAttribute.PlantName: "TorchWood",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/023_torch_wood.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/023_torch_wood_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.TallNut: {
		PlantInfoAttribute.PlantName: "TallNut",
		PlantInfoAttribute.CoolTime: 30.0,
		PlantInfoAttribute.SunCost: 175,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/024_tall_nut.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/024_tall_nut_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
		
		
	## 保龄球
	PlantType.WallNutBowling: {
		PlantInfoAttribute.PlantName: "WallNutBowling",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/051_wall_nut_bowling.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/051_wall_nut_bowling_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.WallNutBowlingBomb: {
		PlantInfoAttribute.PlantName: "WallNutBowlingBomb",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/052_wall_nut_bowling_bomb.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/052_wall_nut_bowling_bomb_static.tscn"),
		PlantInfoAttribute.PlantConditionResource :  preload("res://resources/plant_resource/plant_condition/000_common_plant_land.tres")
		},
	PlantType.WallNutBowlingBig: {
		PlantInfoAttribute.PlantName: "WallNutBowlingBig",
		PlantInfoAttribute.CoolTime: 7.5,
		PlantInfoAttribute.SunCost: 50,
		PlantInfoAttribute.PlantScenes : preload("res://scenes/character/plant/053_wall_nut_bowlingBig.tscn"),
		PlantInfoAttribute.PlantStaticScenes : preload("res://scenes/character/plant/053_wall_nut_bowlingBig_static.tscn"),
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

	
#endregion

#region 用户游戏存档相关
const SAVE_GAME_PATH = "user://SaveGame.save"

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
]


const card_in_seed_chooser = preload("res://scenes/ui/card_in_seed_chooser.tscn")
const card = preload("res://scenes/ui/card.tscn")


func save_game():
	var save_file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"curr_plant" : curr_plant,
	}
	var json_string = JSON.stringify(data)

	save_file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists(SAVE_GAME_PATH):
		curr_plant = []
		return # Error! We don't have a save to load.
	
	# 打开文件
	var save_file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	# 读取全部内容
	while save_file.get_position() < save_file.get_length():
		var data = JSON.parse_string(save_file.get_line())
		# 加载数据
		curr_plant = data["curr_plant"]
	return
	
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

#endregion


#endregion

#region 关卡相关

## 加载场景
enum MainScenes{
	StartMenu,
	ChooseLevel,
	MainGameFront,
	MainGameBack,
	
	Almanac
}

var MainScenesMap = {
	MainScenes.StartMenu: "res://scenes/main/01StartMenu.tscn",
	MainScenes.ChooseLevel: "res://scenes/main/02ChooesLevel.tscn",
	MainScenes.MainGameFront: "res://scenes/main/MainGameFront.tscn",
	MainScenes.MainGameBack: "res://scenes/main/MainGameBack.tscn",
	MainScenes.Almanac: "res://scenes/main/11Almanac.tscn",
}


var game_para:ResourceLevelData = load("res://resources/level_date_resource/mode_adventure/adventure_01_day.tres")
#endregion
