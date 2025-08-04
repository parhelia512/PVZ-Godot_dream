extends Node
class_name SoundManagerClass

enum Bus {MASTER, BGM, SFX} 

@onready var bgm_play: AudioStreamPlayer = $BGMPlay
@onready var sfx_all: Node = $SFXAll
@onready var crazy_dave_player: AudioStreamPlayer = $SFXAll/CrazyDavePlayer

func _ready() -> void:
	Global.load_config()
	Global.save_config()
	
	
#region 播放音乐和音效
func play_bgm(stream: AudioStream):
	bgm_play.stream = stream
	bgm_play.play()

#region 植物和僵尸有关音效(植物、僵尸、子弹、受击)
"""
 本身这部分代码是只有防具受击音效和子弹攻击音效的，
 后来又加了植物和僵尸音效，
 然后就懒得改了，干脆就这么用了
"""

## 僵尸防具受击音效种类
enum TypeZombieBeAttackSFX{
	Null,		## 无声音
	Plastic,	## 塑料
	Shield		## 铁器
}

## 僵尸受击音效资源字典
const SFXZombieBeAttackMap := {
	TypeZombieBeAttackSFX.Null: null,
	TypeZombieBeAttackSFX.Plastic: [
		preload("res://assets/audio/SFX/bullet/plastichit.ogg"),
		preload("res://assets/audio/SFX/bullet/plastichit2.ogg")
	],
	TypeZombieBeAttackSFX.Shield: [
		preload("res://assets/audio/SFX/bullet/shieldhit1.ogg"),
		preload("res://assets/audio/SFX/bullet/shieldhit2.ogg")
	],
}

## 子弹音效种类
enum TypeBulletSFX{
	Null,		## 无声音
	Pea,		## 豌豆
	PeaFire,	## 火焰豌豆
	
	Bowling = 51,		## 保龄球
}

## 子弹音效资源字典
const SFXBulletMap := {
	TypeBulletSFX.Null: null,
	TypeBulletSFX.Pea: [
		preload("res://assets/audio/SFX/bullet/splat1.ogg"),
		preload("res://assets/audio/SFX/bullet/splat2.ogg"),
		preload("res://assets/audio/SFX/bullet/splat3.ogg")
	],
	TypeBulletSFX.PeaFire: [
		preload("res://assets/audio/SFX/bullet/firepea.ogg"),
	],
	
	TypeBulletSFX.Bowling: [
		preload("res://assets/audio/SFX/bullet/bowlingimpact.ogg"),
		preload("res://assets/audio/SFX/bullet/bowlingimpact2.ogg"),
	],
	
}

## 植物音效字典
const SFXPlantMap := {
	Global.PlantType.PeaShooterSingle:{
		&"Throw":[
			preload("res://assets/audio/SFX/plant/throw1.ogg"),
			preload("res://assets/audio/SFX/plant/throw2.ogg")
		]
	},
	Global.PlantType.SunFlower:{
		&"Throw":preload("res://assets/audio/SFX/plant/throw1.ogg"),
		
	},
	Global.PlantType.CherryBomb:{
		&"CherryBomb":preload("res://assets/audio/SFX/plant/cherrybomb.ogg"),
		
	},
	Global.PlantType.WallNut:{
	},
	Global.PlantType.PotatoMine:{
		&"PotatoMine": preload("res://assets/audio/SFX/plant/potato_mine.ogg")
	},
	Global.PlantType.SnowPea:{
	},
	Global.PlantType.Chomper:{
		&"BigChomp": preload("res://assets/audio/SFX/plant/bigchomp.ogg")
	},
	Global.PlantType.PeaShooterDouble:{
	},
	Global.PlantType.PuffShroom:{
		&"Puff": preload("res://assets/audio/SFX/plant/puff.ogg")
	},
	Global.PlantType.SunShroom:{
		&"PlantGrow": preload("res://assets/audio/SFX/plant/plantgrow.ogg")
	},
	Global.PlantType.FumeShroom:{
		&"Fume": preload("res://assets/audio/SFX/plant/fume.ogg")
	},
	Global.PlantType.GraveBuster:{
		&"GraveBusterChomp":preload("res://assets/audio/SFX/plant/gravebusterchomp.ogg")
	},
	Global.PlantType.HypnoShroom:{
		&"MindControlled": preload("res://assets/audio/SFX/plant/mindcontrolled.ogg")
	},
	Global.PlantType.ScaredyShroom:{
	},
	Global.PlantType.IceShroom:{
		&"Frozen": preload("res://assets/audio/SFX/plant/frozen.ogg")
	},
	Global.PlantType.DoomShroom:{
		&"DoomShroom": preload("res://assets/audio/SFX/plant/doomshroom.ogg")
	},
	Global.PlantType.LilyPad:{
	},
	Global.PlantType.Squash:{
		&"SquashHmm":[
			preload("res://assets/audio/SFX/plant/squash_hmm2.ogg"),
			preload("res://assets/audio/SFX/plant/squash_hmm.ogg")
		]
	},
	Global.PlantType.ThreePeater:{
	},
	Global.PlantType.TangleKelp:{
	},
	Global.PlantType.Jalapeno:{
		&"Jalapeno": preload("res://assets/audio/SFX/plant/jalapeno.ogg")
	},
	Global.PlantType.Caltrop:{
	},
	Global.PlantType.TorchWood:{
	},
	
	Global.PlantType.SeaShroom:{
	},
	Global.PlantType.Plantern:{
	},
	Global.PlantType.Cactus:{
	},
	Global.PlantType.Blover:{
		&"blover": preload("res://assets/audio/SFX/plant/blover.ogg")
	},
	Global.PlantType.SplitPea:{
	},
	Global.PlantType.StarFruit:{
	},
	Global.PlantType.Pumpkin:{
	},
	Global.PlantType.MagnetShroom:{
	},
	
	Global.PlantType.CabbagePult:{
	},
	Global.PlantType.FlowerPot:{
	},
	Global.PlantType.CornPult:{
	},
	Global.PlantType.CoffeeBean:{
	},
	Global.PlantType.Garlic:{
	},
	Global.PlantType.UmbrellaLeaf:{
	},
	Global.PlantType.MariGold:{
	},
	Global.PlantType.MelonPult:{
	},
	
	Global.PlantType.GatlingPea:{
	},
	Global.PlantType.TwinSunFlower:{
	},
	Global.PlantType.GloomShroom:{
	},
	Global.PlantType.Cattail:{
	},
	Global.PlantType.WinterMelon:{
	},
	Global.PlantType.GoldMagnet:{
	},
	Global.PlantType.SpikeRock:{
	},
	Global.PlantType.CobCannon:{
	}
}

## 僵尸音效字典
const SFXZombieMap := {
	Global.ZombieType.ZombieNorm:{
		## 啃食
		&"Chomp":[
			preload("res://assets/audio/SFX/zombie/chomp.ogg"),
			preload("res://assets/audio/SFX/zombie/chomp2.ogg"),
			preload("res://assets/audio/SFX/zombie/chompsoft.ogg")
		],
		## 掉头
		&"Shoop":preload("res://assets/audio/SFX/zombie/shoop.ogg")
	},
	Global.ZombieType.ZombieFlag:{
	},
	Global.ZombieType.ZombieCone:{
	},
	Global.ZombieType.ZombiePoleVaulter:{
		&"Polevault":preload("res://assets/audio/SFX/zombie/polevault.ogg")
	},
	Global.ZombieType.ZombieBucket:{
	},
	Global.ZombieType.ZombiePaper:{
		&"Rarrgh":[
			preload("res://assets/audio/SFX/zombie/newspaper_rarrgh.ogg"),
			preload("res://assets/audio/SFX/zombie/newspaper_rarrgh2.ogg")
		],
		&"Rip":	preload("res://assets/audio/SFX/zombie/newspaper_rip.ogg")
	},
	Global.ZombieType.ZombieScreenDoor:{
	},
	Global.ZombieType.ZombieFootball:{
	},
	Global.ZombieType.ZombieJackson:{
		&"Dancer":preload("res://assets/audio/SFX/zombie/dancer.ogg")
	},
	Global.ZombieType.ZombieDancer:{
	},
	Global.ZombieType.ZombieDuckytube:{
	},
	Global.ZombieType.ZombieSnorkle:{
	},
	Global.ZombieType.ZombieZamboni:{
		&"zamboni":preload("res://assets/audio/SFX/zombie/zamboni.ogg"),
		&"explosion":preload("res://assets/audio/SFX/zombie/explosion.ogg")
	},
	Global.ZombieType.ZombieBobsled:{
	},
	Global.ZombieType.ZombieDolphinrider:{
		&"dolphin_appears":preload("res://assets/audio/SFX/zombie/dolphin_appears.ogg"),
		&"dolphin_before_jumping":preload("res://assets/audio/SFX/zombie/dolphin_before_jumping.ogg")
	},
}

## 戴夫音效字典
const SFXCarzyDaveMap := {
	## 一秒左右
	&"crazydaveshort" : [
		preload("res://assets/audio/SFX/carzy/crazydaveshort1.ogg"), 
		preload("res://assets/audio/SFX/carzy/crazydaveshort2.ogg"), 
		preload("res://assets/audio/SFX/carzy/crazydaveshort3.ogg")
	],
	## 两秒左右
	&"crazydavelong" : [
		preload("res://assets/audio/SFX/carzy/crazydavelong1.ogg"),
		preload("res://assets/audio/SFX/carzy/crazydavelong2.ogg"),
		preload("res://assets/audio/SFX/carzy/crazydavelong3.ogg")
	],
	## 三秒左右
	&"crazydaveextralong" : [
		preload("res://assets/audio/SFX/carzy/crazydaveextralong1.ogg"),
		preload("res://assets/audio/SFX/carzy/crazydaveextralong2.ogg"),
		preload("res://assets/audio/SFX/carzy/crazydaveextralong3.ogg")
	],
	&"crazydavecrazy" : [
		preload("res://assets/audio/SFX/carzy/crazydavecrazy.ogg")
	],
	&"crazydavescream" : [
		preload("res://assets/audio/SFX/carzy/crazydavescream2.ogg"), 
		preload("res://assets/audio/SFX/carzy/crazydavescream.ogg")
	],
}

# 音效对象池实现
var sfx_bullet_pool = []

func play_sfx_with_pool(sfx_resource: AudioStream) -> AudioStreamPlayer:
	var player: AudioStreamPlayer
	# 从池中获取可用播放器
	for p in sfx_bullet_pool:
		if not p.playing:
			player = p
			break

	
	# 如果没有可用播放器，创建新的
	if not player:
		player = AudioStreamPlayer.new()
		player.bus = AudioServer.get_bus_name(Bus.SFX)
		player.finished.connect(_on_sfx_finished.bind(player))
		sfx_all.add_child(player)
		sfx_bullet_pool.append(player)

	# 配置播放器
	player.stream = sfx_resource
	player.play()
	return player

func _on_sfx_finished(player: AudioStreamPlayer):
	# 播放完成后自动停止，保留在池中
	player.stop()

## 播放僵尸受击音效
func play_be_attack_SFX(type_bullet_zombie_sfx:TypeZombieBeAttackSFX):
	var sfx_array: Array = SFXZombieBeAttackMap[type_bullet_zombie_sfx] 

	var sfx_selected = sfx_array.pick_random()
	play_sfx_with_pool(sfx_selected)

## 播放子弹攻击音效
func play_bullet_attack_SFX(type_bullet_sfx:TypeBulletSFX):
	var sfx_array: Array = SFXBulletMap[type_bullet_sfx] 

	var sfx_selected = sfx_array.pick_random()
	play_sfx_with_pool(sfx_selected)

## 播放植物相关音效
func play_plant_SFX(plant_type:Global.PlantType, option:StringName):
	var sfx_resource:AudioStream
	if SFXPlantMap[plant_type][option] is Array:
		sfx_resource = SFXPlantMap[plant_type][option].pick_random()
	else:
		sfx_resource = SFXPlantMap[plant_type][option]
	play_sfx_with_pool(sfx_resource)
	
## 播放僵尸相关音效
func play_zombie_SFX(zombie_type:Global.ZombieType, option:StringName):
	var sfx_resource: AudioStream
	if SFXZombieMap[zombie_type][option] is Array:
		sfx_resource = SFXZombieMap[zombie_type][option].pick_random()
	else:
		sfx_resource = SFXZombieMap[zombie_type][option]
	play_sfx_with_pool(sfx_resource)

## 播放戴夫音效
func play_crazy_dave_SFX(option:StringName):
	var sfx_array: Array = SFXCarzyDaveMap[option] 

	var sfx_selected = sfx_array.pick_random()
	crazy_dave_player.stream = sfx_selected
	crazy_dave_player.play()

#endregion

#region 其余音效
const SFXOtherMap := {
	##-------------------------- 按钮相关 --------------------------
	## 开始菜单点击
	&"gravebutton": preload("res://assets/audio/SFX/button/gravebutton.ogg"),
	## 鼠标进入开始菜单
	&"bleep":preload("res://assets/audio/SFX/button/bleep.ogg"),
	## 
	&"tap":preload("res://assets/audio/SFX/button/tap.ogg"),
	## 选项按钮
	&"buttonclick":preload("res://assets/audio/SFX/button/buttonclick.ogg"),
	## 暂停
	&"pause": preload("res://assets/audio/SFX/button/pause.ogg"),
	## 点击阳光
	&"points": preload("res://assets/audio/SFX/button/points.ogg"),
	## 点击金币
	&"coin":preload("res://assets/audio/SFX/item/coin.ogg"),
	
	##-------------------------- 卡片相关 --------------------------
	&"buzzer":preload("res://assets/audio/SFX/card_and_shovel/buzzer.ogg"),
	&"seedlift":preload("res://assets/audio/SFX/card_and_shovel/seedlift.ogg"),
	&"shovel":preload("res://assets/audio/SFX/card_and_shovel/shovel.ogg"),
	&"tap2":preload("res://assets/audio/SFX/card_and_shovel/tap2.ogg"),
	
	##-------------------------- 进度相关 --------------------------
	## 汽笛音效
	&"siren": preload("res://assets/audio/SFX/progress/siren.ogg"),
	## TODO :这个也是汽笛音效？
	&"awooga":preload("res://assets/audio/SFX/progress/awooga.ogg"),
	## 最后一波
	&"finalwave":preload("res://assets/audio/SFX/progress/finalwave.ogg"),
	## 大波僵尸
	&"hugewave":preload("res://assets/audio/SFX/progress/hugewave.ogg"),
	## 失败
	&"losemusic":preload("res://assets/audio/SFX/progress/losemusic.ogg"),
	## 准备安放植物
	&"readysetplant":preload("res://assets/audio/SFX/progress/readysetplant.ogg"),
	## 戴夫尖叫
	&"scream":preload("res://assets/audio/SFX/progress/scream.ogg"),
	## 获胜音效
	&"winmusic":preload("res://assets/audio/SFX/progress/winmusic.ogg"),
	
	
	##-------------------------- 主游戏场景物品相关 --------------------------
	## 墓碑生成
	&"gravestone_rumble":preload("res://assets/audio/SFX/zombie/gravestone_rumble.ogg"),
	## 植物种植音效
	&"plant1": preload("res://assets/audio/SFX/plant_create/plant.ogg"),
	## 植物铲除音效
	&"plant2":preload("res://assets/audio/SFX/plant_create/plant2.ogg"),
	## 植物种植在水上
	&"plant_water": preload("res://assets/audio/SFX/plant_create/plant_water.ogg"),
	## 僵尸入水音效、水花音效
	&"zombie_entering_water": preload("res://assets/audio/SFX/zombie/zombie_entering_water.ogg"),
	## -------- 小推车 --------
	&"lawnmower": preload("res://assets/audio/SFX/item/lawnmower.ogg"),
	&"pool_cleaner": preload("res://assets/audio/SFX/item/pool_cleaner.ogg"),
	## -------- 锤子 --------
	&"swing": preload("res://assets/audio/SFX/item/swing.ogg"),
	&"bonk": preload("res://assets/audio/SFX/item/bonk.ogg"),
	## -------- 花园 -----------
	&"prize": preload("res://assets/audio/SFX/garden/prize.ogg"),
	
	##-------------------------- 花园相关 --------------------------
	&"watering":preload("res://assets/audio/SFX/garden/watering.ogg"),
	&"fertilizer":preload("res://assets/audio/SFX/garden/fertilizer.ogg"),
	&"bugspray":preload("res://assets/audio/SFX/garden/bugspray.ogg"),
	&"phonograph":preload("res://assets/audio/SFX/garden/phonograph.ogg"),
	&"wakeup": preload("res://assets/audio/SFX/garden/wakeup.ogg"),
	
}
## 播放其它相关音效
func play_other_SFX(option:StringName):
	var sfx_resource: AudioStream
	if SFXOtherMap[option] is Array:
		sfx_resource = SFXOtherMap[option].pick_random()
	else:
		sfx_resource = SFXOtherMap[option]
	play_sfx_with_pool(sfx_resource)


#endregion

#endregion

#region 按钮信号连接辅助函数
## 更新开始菜单的UI音效
func setup_ui_start_menu_sound(node:Node, is_menu_button:=false):
	if node is BaseButton:
		var button := node
		button.mouse_entered.connect(play_other_SFX.bind("bleep"))
		
		if is_menu_button:
			button.button_down.connect(play_other_SFX.bind("gravebutton"))
		else:
			if not button.button_down.is_connected(play_other_SFX):
				button.button_down.connect(play_other_SFX.bind("tap"))

				
	for child in node.get_children():
		## 如果是Menu或者其上面的节点为Menu
		if child.name == "Menu" or is_menu_button:
			setup_ui_start_menu_sound(child, true)
		else:
			setup_ui_start_menu_sound(child, false)


## 更新主游戏按钮的UI音效
func setup_ui_main_game_sound(node:Node):
	if node is BaseButton:
		if node is CheckButton:
			node.pressed.connect(play_other_SFX.bind("buttonclick"))
		else:
			node.button_down.connect(play_other_SFX.bind("gravebutton"))
			
			if node.name == "Return":
				node.pressed.connect(play_other_SFX.bind("buttonclick"))
		
		
	for child in node.get_children():
		setup_ui_main_game_sound(child)
#endregion

#region 音量大小调整
func get_volum(bus_index:int):
	var db := AudioServer.get_bus_volume_db(bus_index)
	
	return db_to_linear(db)
	
func set_volume(bus_index:int, v:float) ->void:
	var db := linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index, db)

#endregion
