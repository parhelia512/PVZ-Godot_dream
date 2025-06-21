extends Node2D
class_name MainGameManager


#region 游戏管理器
@onready var manager: Node2D = $Manager
@onready var hamd_manager: HandManager = $Manager/HamdManager
@onready var zombie_manager: ZombieManager = $Manager/ZombieManager
@onready var card_manager: CardManager = $Camera2D/CardManager
#endregion


#region UI元素、相机
@onready var ui_remind_word: UIRemindWord = $UIRemindWord
@onready var flag_progress_bar: FlagProgressBar = $FlagProgressBar
@onready var camera_2d: MainGameCamera = $Camera2D

#endregion

#region 游戏主元素
@onready var plant_cells: Node2D = $PlantCells
@onready var temporary_plants: Node2D = $TemporaryPlants
@onready var zombies: Node2D = $Zombies
@onready var temporary_zombies: Node2D = $TemporaryZombies
@onready var bullets: Node2D = $Bullets
@onready var day_suns: DaySuns = $DaySuns
#endregion

#region bgm
@export var bgm_choose_card: AudioStream
@export var bgm_main_game: AudioStream
#endregion

#region 设置
@export_group("游戏设置")
@export var mode_column := true
#endregion

var start_game:=false


@export_group("是否为测试场景")
@export var is_test := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_test:
		SoundManager.play_bgm(bgm_choose_card)
		zombie_manager.show_zombie_create()
		
		await get_tree().create_timer(1.0).timeout
		await start_game_move_camera()
		card_manager.move_card_bar(true)
		card_manager.move_card_chooser(true)
	
	else:
		# TODO： 修改这部分代码
		await get_tree().create_timer(0.1).timeout
		# 设置信号连接
		SoundManager.play_bgm(bgm_main_game)
		hamd_manager.card_game_signal_connect(card_manager.cards, card_manager.shovel_bg)

	
	
func cheeosed_card_start_game():
	if not start_game:
		start_game = true
		## 隐藏多余卡槽
		card_manager.judge_disappear_add_card_bar() 
		# 设置信号连接
		card_manager.card_disconnect_card()

		# 隐藏待选卡槽
		await card_manager.move_card_chooser(false)
		card_manager.change_z_index(100)
		
		# 相机移动回来
		await camera_2d.move_to(Vector2(0, 0), 2)
		# 删除展示僵尸
		zombie_manager.show_zombie_delete()
		
		
		await get_tree().create_timer(1.0).timeout
		await ui_remind_word.ready_set_plant()
		# 红字结束，可以种植
		hamd_manager.card_game_signal_connect(card_manager.cards, card_manager.shovel_bg)

		
		await get_tree().create_timer(1.0).timeout
		
		SoundManager.play_bgm(bgm_main_game)
		# 开始天降阳光
		day_suns.start_day_sun()
		# 开始刷新僵尸		
		await get_tree().create_timer(10).timeout
		zombie_manager.start_first_wave()
		flag_progress_bar.visible = true
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start_game_move_camera():
	# 移动相机查看僵尸
	await camera_2d.move_to(Vector2(390, 0), 2)
	
	
