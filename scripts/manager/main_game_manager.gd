extends Node2D
class_name MainGameManager


#region 游戏管理器
@onready var manager: Node2D = $Manager
@onready var hand_manager: HandManager = $Manager/HandManager
@onready var zombie_manager: ZombieManager = $Manager/ZombieManager
@onready var card_manager: CardManager = $Camera2D/CardManager
## 传送带卡槽
@onready var conveyor_belt: ConveyorBelt = $Camera2D/CardManager/ConveyorBelt
## 控制台
@onready var control_panel: ControlCanvasLayer = $CanvasLayer/All_UI/MainGameMenuOptionDialog/Option/Button4/CanvasLayer
#endregion

#region UI元素、相机
@onready var camera_2d: MainGameCamera = $Camera2D
@onready var ui_remind_word: UIRemindWord = $CanvasLayer/UIRemindWord
#endregion

#region 游戏主元素
@onready var background: Sprite2D = $Background
@onready var plant_cells: Node2D = $PlantCells
@onready var temporary_plants: Node2D = $TemporaryPlants
@onready var zombies: Node2D = $Zombies
@onready var temporary_zombies: Node2D = $TemporaryZombies
@onready var bullets: Node2D = $Bullets
@onready var day_suns: DaySuns = $DaySuns
var fog_node:Fog
@onready var coin_bank: CoinBank = $CanvasLayer/CoinBank


#endregion

#region bgm
@export var bgm_choose_card: AudioStream
@export var bgm_main_game: AudioStream
#endregion

#region 设置
@export_group("游戏设置")
## 柱子模式
@export var mode_column := true
#endregion

#region 主游戏运行阶段
enum MainGameProgress{
	NONE,			## 无
	CHOOSE_CARD,	## 选卡界面
	MAIN_GAME,		## 游戏阶段
	GAME_OVER		## 游戏结束阶段
}

var main_game_progress:MainGameProgress
#endregion

#region 游戏参数
@export_group("本局游戏参数")
@export var game_para : ResourceLevelData
@export var is_test : bool = false

#endregion

@export_group("不同关卡相关物品(保龄球红线、锤子)")
var wallnut_bowlingstripe: Sprite2D
var hammer: Hammer
## 锤子场景路径
var hammer_scenes_path = "res://scenes/item/game_scenes_item/hammer.tscn"
#endregion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.coin_value_label = coin_bank
	coin_bank.visible = false
	## 初始化游戏，游戏背景，游戏卡槽
	_init_main_game()
	
	## 主游戏进程
	main_game_progress = MainGameProgress.CHOOSE_CARD
	## 如果有戴夫对话
	if game_para.crazy_dave_dialog:
		var crazy_dave:CrazyDave = SceneRegistry.CRAZY_DAVE.instantiate()
		crazy_dave.init_dave(game_para.crazy_dave_dialog)
		add_child(crazy_dave)
		await crazy_dave.dave_leave_end_signal
		crazy_dave.queue_free()
		
	## 如果看展示僵尸
	if game_para.look_show_zombie:
		## 创建展示僵尸，等待一秒移动相机
		zombie_manager.show_zombie_create()
		await get_tree().create_timer(1.0).timeout
		await start_game_move_camera()
		## 如果可以选卡
		if game_para.can_choosed_card:
			card_manager.move_card_bar(true)
			card_manager.move_card_chooser(true)
		else:
			await get_tree().create_timer(1.0).timeout
			no_cheeosed_card_start_game()
	else:
		card_appear()
		main_game_start()


#region 游戏关卡初始化
# 初始化游戏，本局游戏相关参数
func _init_main_game():
	if not is_test:
		_from_globel_get_level_para()
	_init_game_BG()
	_init_game_card_bar()
	
	if game_para.is_zombie_spawn:
		print("初始化僵尸管理器")
		## 初始化僵尸管理器
		zombie_manager.init_zombie_manager(zombies, game_para.max_wave, game_para.zombie_multy, game_para.zombie_refresh_types, game_para.create_tombston_in_flag_wave)

	## 初始化植物种植区域
	hand_manager.init_plant_cells()
	### 初始化玩家控制台
	#control_panel.init_control_panel()
		
	## 初始化小游戏场景相关物品
	if game_para.game_mode == game_para.GameMode.MiniGame:
		_init_minigame_item()
	
## 初始化小游戏的不同物品
func _init_minigame_item():

	match game_para.mini_game_level:
		game_para.MiniGameLevel.Bowling:
			wallnut_bowlingstripe = $Background/WallnutBowlingstripe
			wallnut_bowlingstripe.visible = true
			hand_manager.minigame_bowling_del_right_plant_cells()
		game_para.MiniGameLevel.HammerZombie:
			print("初始化锤子")
			hammer = load(hammer_scenes_path).instantiate()
			add_child(hammer)
			

## 从globel中获取当前关卡
func _from_globel_get_level_para():
	game_para = Global.game_para
	game_para.init_para()
	
## 初始化游戏背景,bgm
func _init_game_BG():
	print(game_para.game_BGM)
	var path_bgm_game = game_para.GameBGMMap[game_para.game_BGM]
	bgm_main_game = load(path_bgm_game) as AudioStream
	
	var texture: Texture2D = game_para.GameBgTextureMap[game_para.game_BG]
	background.texture = texture
	
	match game_para.game_BG:
		game_para.GameBg.FrontDay:
			$Background/Area2DHome/Door/DoorDown/Background1GameoverInteriorOverlay.visible=true
			$Background/Area2DHome/Door/DoorMask/Background1GameoverMask.visible=true
		
		game_para.GameBg.FrontNight:
			$Background/Area2DHome/Door/DoorDown/Background2GameoverInteriorOverlay.visible=true
			$Background/Area2DHome/Door/DoorMask/Background2GameoverMask.visible=true
		
		game_para.GameBg.Pool:
			$Background/Area2DHome/Door/DoorDown/Background3GameoverInteriorOverlay.visible=true
			$Background/Area2DHome/Door/DoorMask/Background3GameoverMask.visible=true
			
			$Background/Pool.init_pool(game_para.GameBg.Pool)
			
		game_para.GameBg.Fog:
			$Background/Area2DHome/Door/DoorDown/Background4GameoverInteriorOverlay.visible=true
			$Background/Area2DHome/Door/DoorMask/Background4GameoverMask.visible=true

			$Background/Pool.init_pool(game_para.GameBg.Fog)
	
	if game_para.is_fog:
		fog_node = get_node("Background/Fog")
		fog_node.visible = true

## 初始化卡槽参数
func _init_game_card_bar():
	SoundManager.play_bgm(bgm_choose_card)
	print("卡槽模式：", str(game_para.card_mode))
	match game_para.card_mode:
		## 卡槽模式
		game_para.CardMode.Norm:
			## 删除传送带
			conveyor_belt.queue_free()
			## 初始化待选卡槽
			card_manager.init_CardChooser()
			## 初始化出战卡槽格数
			card_manager.init_card_bar(game_para.max_choosed_card_num, game_para.start_sun)

			## 初始化预选卡
			if game_para.pre_choosed_card_list:
				card_manager.init_pre_choosed_card(game_para.pre_choosed_card_list, is_test)
		game_para.CardMode.ConveyorBelt:
			conveyor_belt.init_conveyor_belt_card_bar(game_para.card_type, game_para.card_type_probability, game_para.card_type_start_list)

#endregion

## 不用选择卡片进行的流程
func no_cheeosed_card_start_game():
	await get_tree().create_timer(2.0).timeout
	## 相机移动回游戏场景
	await camera_2d.move_to(Vector2(0, 0), 2)
	card_appear()
	main_game_start()

func card_appear():
	## 不选卡,但是卡槽出现
	if game_para.have_card_bar:
		if game_para.card_mode == game_para.CardMode.Norm:
			print("普通卡槽出现")
			## 普通卡槽出现
			card_manager.move_card_bar(true)
		elif game_para.card_mode == game_para.CardMode.ConveyorBelt:
			## 传送带卡槽出现
			print("卡片出现")
			conveyor_belt.move_card_chooser()
			

## 选择卡片完成
func cheeosed_card_start_game():
	## 隐藏多余卡槽
	card_manager.judge_disappear_add_card_bar() 
	## 断开原本的卡片信号连接
	card_manager.card_disconnect_card()
	## 隐藏待选卡槽
	await card_manager.move_card_chooser(false)
	
	## 相机移动回游戏场景
	await camera_2d.move_to(Vector2(0, 0), 2)
	
	main_game_start()


## 选卡结束，开始游戏
func main_game_start():
	## 主游戏进程阶段
	main_game_progress = MainGameProgress.MAIN_GAME
	if game_para.is_fog:
		fog_node.come_back_game(5.0)
	
	## 删除展示僵尸
	if game_para.look_show_zombie:
		zombie_manager.show_zombie_delete()
		
	## 开始天降阳光
	if game_para.is_day_sun:
		day_suns.start_day_sun()
		
	## 生成墓碑
	if game_para.init_tombstone_num > 0:
		hand_manager.create_tombstone(game_para.init_tombstone_num )	
	
	## 等待1秒红字出现
	await get_tree().create_timer(1.0).timeout
	await ui_remind_word.ready_set_plant()

	## 红字结束，可以种植,连接卡片和铲子种植信号
	match game_para.card_mode:
		game_para.CardMode.Norm:
			hand_manager.card_game_signal_connect(card_manager.cards, card_manager.shovel_bg)
			card_manager.card_signal_connect()
		
			
		game_para.CardMode.ConveyorBelt:
			## 开始放置植物
			conveyor_belt.start_plant()
	
	## 红字结束后一秒修改bgm
	await get_tree().create_timer(1.0).timeout
	SoundManager.play_bgm(bgm_main_game)
	
	if game_para.is_zombie_spawn:
		# 10秒后开始刷新僵尸		
		await get_tree().create_timer(10).timeout
		zombie_manager.start_first_wave()
		zombie_manager.flag_progress_bar.visible = true
		
	## 如果是锤僵尸模式
	if game_para.game_mode == game_para.GameMode.MiniGame and game_para.mini_game_level == game_para.MiniGameLevel.HammerZombie:
		zombie_manager.init_zombie_manager_in_mini_game_hammer_zombie(zombies, game_para.zombie_multy)
	

func start_game_move_camera():
	# 移动相机查看僵尸
	await camera_2d.move_to(Vector2(390, 0), 2)

#region 用户控制台相关
## 显示植物血量
func display_plant_HP_label():

	hand_manager.display_plant_HP_label()

## 显示僵尸血量
func display_zombie_HP_label():
	zombie_manager.display_zombie_HP_label()

## 植物卡槽取消置顶
func card_bar_and_shovel_z_index_100():
	card_manager.card_bar_and_shovel_z_index_100()
## 传送带卡槽
func conveyor_belt_card_bar_z_index_100():
	if conveyor_belt:
		conveyor_belt.z_index = 100
#endregion
