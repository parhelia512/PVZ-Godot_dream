extends Node
class_name SoundManagerClass

enum Bus {MASTER, BGM, SFX} 

@onready var sfx: Node = $SFX
@onready var bgm_play: AudioStreamPlayer = $BGMPlay
@onready var bullet_sfx: Node = $BulletSFX

func _ready() -> void:
	Global.load_config()
	Global.save_config()
	
	
	
#region 播放音乐和音效
func play_bgm(stream: AudioStream):
	bgm_play.stream = stream
	bgm_play.play()

func play_sfx(name:String):
	var player := sfx.get_node(name) as AudioStreamPlayer
	#player.bus = AudioServer.get_bus_name(Bus.BGM)
	if not player:
		return
		
	# 如果音效正在播放，则跳过
	if player.playing:
		return
		
	player.play()
	
#region 子弹攻击音效
## 子弹音效种类
enum TypeZombieBeAttackSFX{
	Null,		## 无声音
	Plastic,	## 塑料
	Shield		## 铁器
}

## 子弹音效资源字典
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
	
	TypeBulletSFX.Bowling: [
		preload("res://assets/audio/SFX/bullet/bowlingimpact.ogg"),
		preload("res://assets/audio/SFX/bullet/bowlingimpact2.ogg"),
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
		bullet_sfx.add_child(player)
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

#endregion

#endregion

#region 按钮信号连接辅助函数
## 更新开始菜单的UI音效
func setup_ui_start_menu_sound(node:Node, is_menu_button:=false):
	if node is BaseButton:
		var button := node
		button.mouse_entered.connect(play_sfx.bind("StartMenu/ButtonMouseEntered"))
		
		if is_menu_button:
			button.button_down.connect(play_sfx.bind("StartMenu/MenuButtonDown"))
		else:
			if not button.button_down.is_connected(play_sfx):
				button.button_down.connect(play_sfx.bind("StartMenu/OtherButtonDown"))

				
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
			node.pressed.connect(play_sfx.bind("MainGameUI/CheckButton"))
		else:
			node.button_down.connect(play_sfx.bind("MainGameUI/ButtonDown"))
			
			if node.name == "Return":
				node.pressed.connect(play_sfx.bind("MainGameUI/CheckButton"))
		
		
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
