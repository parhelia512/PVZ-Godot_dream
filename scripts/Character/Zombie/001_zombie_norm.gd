extends ZombieBase
class_name  ZombieNorm

@export var idle_status := 1
@export var walk_status := 1
@export var death_status := 1

@onready var _head_sprite:= [
	$Body/Anim_head1, $Body/Anim_head2, $Body/Anim_tongue, $Body/Anim_hair
]
@onready var hand_sprite:= [
	$Body/Zombie_outerarm_hand, $Body/Zombie_outerarm_lower
]
# 舌头
@onready var anim_tongue: Sprite2D = $Body/Anim_tongue
# 头发
@onready var anim_hair: Sprite2D = $Body/Anim_hair

# 掉落的手和头
@onready var head_drop: Node2D = $Node2D_Head_Drop
@onready var hand_drop: Node2D = $Node2D_Hand_Drop

# 断手图片
@export var outerarm_upper2 : Texture2D

@export_group("最大动画状态")
@export var idle_status_max := 2
@export var walk_status_max := 2
@export var death_status_max := 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# 随机动画状态
	_rand_anim_status()
	_rand_hair_tonge()
	

func _hp_3_stage():
	_head_fade()
	
# 头消失，
func _head_fade():
	# SFX 僵尸头掉落
	$SFX/Shoop.play()
	for head_part in _head_sprite:
		head_part.visible = false
	head_drop.acitvate_it()
	
	
func _hp_2_stage():
	_hand_fade()
	
# 下半胳膊消失
func _hand_fade():
	for arm_hand_part in hand_sprite:
		arm_hand_part.visible = false
	$Body/Zombie_outerarm_upper.texture = outerarm_upper2

	hand_drop.acitvate_it()

# 随机生成状态
func _rand_anim_status():
	idle_status = randi_range(1, idle_status_max)
	walk_status = randi_range(1, walk_status_max)
	death_status = randi_range(1, death_status_max)

func _rand_hair_tonge():
	anim_tongue.visible = randi() % 2 == 0
	anim_hair.visible = randi() % 2 == 0
