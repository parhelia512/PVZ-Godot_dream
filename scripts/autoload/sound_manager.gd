extends Node
class_name SoundManagerClass

enum Bus {MASTER, BGM, SFX}

@onready var bgm_play: AudioStreamPlayer = $BGMPlay
@onready var sfx_all: Node = $SFXAll
@onready var crazy_dave_player: AudioStreamPlayer = $SFXAll/CrazyDavePlayer

## 当前帧播放的音效(每隔25物理帧清除一次)
## 即音效每25物理帧内不可以重复播放
var curr_frame_sfx:Array[AudioStream] = []
var frame_num:=0

func _ready() -> void:
	Global.load_config()
	Global.save_config()

func _physics_process(delta: float) -> void:
	frame_num = wrapi(frame_num + 1, 0, 25)
	if frame_num == 0:
		curr_frame_sfx.clear()

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

## 僵尸受击音效种类
enum TypeBeAttackSFX{
	Null,		## 无声音
	Plastic,	## 塑料
	Shield		## 铁器
}

## 僵尸受击音效资源字典
const SFXBeAttackMap := {
	TypeBeAttackSFX.Null: null,
	TypeBeAttackSFX.Plastic: [
		preload("res://assets/audio/SFX/bullet/plastichit.ogg"),
		preload("res://assets/audio/SFX/bullet/plastichit2.ogg")
	],
	TypeBeAttackSFX.Shield: [
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
	Global.PlantType.P001PeaShooterSingle:{
		&"Throw":[
			preload("res://assets/audio/SFX/plant/throw1.ogg"),
			preload("res://assets/audio/SFX/plant/throw2.ogg")
		]
	},
	Global.PlantType.P002SunFlower:{
		&"Throw":preload("res://assets/audio/SFX/plant/throw1.ogg"),

	},
	Global.PlantType.P003CherryBomb:{
		&"CherryBomb":preload("res://assets/audio/SFX/plant/cherrybomb.ogg"),

	},
	Global.PlantType.P004WallNut:{
	},
	Global.PlantType.P005PotatoMine:{
		&"PotatoMine": preload("res://assets/audio/SFX/plant/potato_mine.ogg")
	},
	Global.PlantType.P006SnowPea:{
	},
	Global.PlantType.P007Chomper:{
		&"BigChomp": preload("res://assets/audio/SFX/plant/bigchomp.ogg")
	},
	Global.PlantType.P008PeaShooterDouble:{
	},
	Global.PlantType.P009PuffShroom:{
		&"Puff": preload("res://assets/audio/SFX/plant/puff.ogg")
	},
	Global.PlantType.P010SunShroom:{
		&"PlantGrow": preload("res://assets/audio/SFX/plant/plantgrow.ogg")
	},
	Global.PlantType.P011FumeShroom:{
		&"Fume": preload("res://assets/audio/SFX/plant/fume.ogg")
	},
	Global.PlantType.P012GraveBuster:{
		&"GraveBusterChomp":preload("res://assets/audio/SFX/plant/gravebusterchomp.ogg")
	},
	Global.PlantType.P013HypnoShroom:{
		&"MindControlled": preload("res://assets/audio/SFX/plant/mindcontrolled.ogg")
	},
	Global.PlantType.P014ScaredyShroom:{
	},
	Global.PlantType.P015IceShroom:{
		&"Frozen": preload("res://assets/audio/SFX/plant/frozen.ogg")
	},
	Global.PlantType.P016DoomShroom:{
		&"DoomShroom": preload("res://assets/audio/SFX/plant/doomshroom.ogg")
	},
	Global.PlantType.P017LilyPad:{
	},
	Global.PlantType.P018Squash:{
		&"SquashHmm":[
			preload("res://assets/audio/SFX/plant/squash_hmm2.ogg"),
			preload("res://assets/audio/SFX/plant/squash_hmm.ogg")
		]
	},
	Global.PlantType.P019ThreePeater:{
	},
	Global.PlantType.P020TangleKelp:{
	},
	Global.PlantType.P021Jalapeno:{
		&"Jalapeno": preload("res://assets/audio/SFX/plant/jalapeno.ogg")
	},
	Global.PlantType.P022Caltrop:{
	},
	Global.PlantType.P023TorchWood:{
	},

	Global.PlantType.P025SeaShroom:{
	},
	Global.PlantType.P026Plantern:{
	},
	Global.PlantType.P027Cactus:{
	},
	Global.PlantType.P028Blover:{
		&"blover": preload("res://assets/audio/SFX/plant/blover.ogg")
	},
	Global.PlantType.P029SplitPea:{
	},
	Global.PlantType.P030StarFruit:{
	},
	Global.PlantType.P031Pumpkin:{
	},
	Global.PlantType.P032MagnetShroom:{
	},

	Global.PlantType.P033CabbagePult:{
	},
	Global.PlantType.P034FlowerPot:{
	},
	Global.PlantType.P035CornPult:{
	},
	Global.PlantType.P036CoffeeBean:{
	},
	Global.PlantType.P037Garlic:{
	},
	Global.PlantType.P038UmbrellaLeaf:{
	},
	Global.PlantType.P039MariGold:{
	},
	Global.PlantType.P040MelonPult:{
	},

	Global.PlantType.P041GatlingPea:{
	},
	Global.PlantType.P042TwinSunFlower:{
	},
	Global.PlantType.P043GloomShroom:{
	},
	Global.PlantType.P044Cattail:{
	},
	Global.PlantType.P045WinterMelon:{
	},
	Global.PlantType.P046GoldMagnet:{
	},
	Global.PlantType.P047SpikeRock:{
	},
	Global.PlantType.P048CobCannon:{
	}
}

## 僵尸音效字典
const SFXZombieMap := {
	## 通用音效
	Global.ZombieType.Null:{## 啃食
		&"Chomp":[
			preload("res://assets/audio/SFX/zombie/chomp.ogg"),
			preload("res://assets/audio/SFX/zombie/chomp2.ogg"),
			preload("res://assets/audio/SFX/zombie/chompsoft.ogg")
		],
		## 掉头
		&"Shoop":preload("res://assets/audio/SFX/zombie/shoop.ogg"),
		## 啃食大蒜
		&"yuck":[
			preload("res://assets/audio/SFX/zombie/yuck2.ogg"),
			preload("res://assets/audio/SFX/zombie/yuck.ogg")
		]
	},

	Global.ZombieType.Z001Norm:{
	},
	Global.ZombieType.Z002Flag:{
	},
	Global.ZombieType.Z003Cone:{
	},
	Global.ZombieType.Z004PoleVaulter:{
		&"Polevault":preload("res://assets/audio/SFX/zombie/polevault.ogg")
	},
	Global.ZombieType.Z005Bucket:{
	},
	Global.ZombieType.Z006Paper:{
		&"Rarrgh":[
			preload("res://assets/audio/SFX/zombie/newspaper_rarrgh.ogg"),
			preload("res://assets/audio/SFX/zombie/newspaper_rarrgh2.ogg")
		],
		&"Rip":	preload("res://assets/audio/SFX/zombie/newspaper_rip.ogg")
	},
	Global.ZombieType.Z007ScreenDoor:{
	},
	Global.ZombieType.Z008Football:{
	},
	Global.ZombieType.Z009Jackson:{
		&"Dancer":preload("res://assets/audio/SFX/zombie/dancer.ogg")
	},
	Global.ZombieType.Z010Dancer:{
	},
	Global.ZombieType.Z011Duckytube:{
	},
	Global.ZombieType.Z012Snorkle:{
	},
	Global.ZombieType.Z013Zamboni:{
		&"zamboni":preload("res://assets/audio/SFX/zombie/zamboni.ogg"),
		&"explosion":preload("res://assets/audio/SFX/zombie/explosion.ogg")
	},
	Global.ZombieType.Z014Bobsled:{
	},
	Global.ZombieType.Z015Dolphinrider:{
		&"dolphin_appears":preload("res://assets/audio/SFX/zombie/dolphin_appears.ogg"),
		&"dolphin_before_jumping":preload("res://assets/audio/SFX/zombie/dolphin_before_jumping.ogg")
	},
	Global.ZombieType.Z016Jackbox:{
		&"jackinthebox":preload("res://assets/audio/SFX/zombie/jackinthebox.ogg"),
		&"jack_suprise":[
			preload("res://assets/audio/SFX/zombie/jack_surprise.ogg"),
			preload("res://assets/audio/SFX/zombie/jack_surprise2.ogg"),
		],
		&"boing":preload("res://assets/audio/SFX/zombie/boing.ogg"),
		&"explosion":preload("res://assets/audio/SFX/zombie/explosion.ogg"),
	},
	Global.ZombieType.Z017Ballon:{
		&"ballooninflate":preload("res://assets/audio/SFX/zombie/ballooninflate.ogg"),
		&"balloon_pop":preload("res://assets/audio/SFX/zombie/balloon_pop.ogg")
	},
	Global.ZombieType.Z018Digger:{
		&"digger_zombie": preload("res://assets/audio/SFX/Zombie/digger_zombie.ogg")
	},
	Global.ZombieType.Z019Pogo:{
		&"pogo_zombie": preload("res://assets/audio/SFX/Zombie/pogo_zombie.ogg")
	},
	Global.ZombieType.Z020Yeti:{
	},
	Global.ZombieType.Z021Bungee:{
	},
	Global.ZombieType.Z022Ladder:{
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

## 音效对象池实现
var sfx_bullet_pool = []

func play_sfx_with_pool(sfx_resource: AudioStream) -> AudioStreamPlayer:
	if sfx_resource in curr_frame_sfx:
		return
	curr_frame_sfx.append(sfx_resource)

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

	## 配置播放器
	player.stream = sfx_resource
	player.play()
	return player

func _on_sfx_finished(player: AudioStreamPlayer):
	# 播放完成后自动停止，保留在池中
	player.stop()

## 播放僵尸受击音效
func play_be_attack_SFX(type_bullet_zombie_sfx:TypeBeAttackSFX):
	var sfx_array: Array = SFXBeAttackMap[type_bullet_zombie_sfx]

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
	var player: AudioStreamPlayer = play_sfx_with_pool(sfx_resource)
	return player

## 播放僵尸相关音效
func play_zombie_SFX(zombie_type:Global.ZombieType, option:StringName):
	var sfx_resource: AudioStream
	if SFXZombieMap[zombie_type][option] is Array:
		sfx_resource = SFXZombieMap[zombie_type][option].pick_random()
	else:
		sfx_resource = SFXZombieMap[zombie_type][option]
	var player: AudioStreamPlayer = play_sfx_with_pool(sfx_resource)
	return player

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
	## 掉落花园植物
	&"chime":preload("res://assets/audio/SFX/item/chime.ogg"),
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
	## -------- 僵尸出土 ------------
	&"dirt_rise": preload("res://assets/audio/SFX/zombie/dirt_rise.ogg"),

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
