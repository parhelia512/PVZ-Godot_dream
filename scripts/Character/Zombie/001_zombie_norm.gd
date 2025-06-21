extends ZombieBase
class_name  ZombieNorm

@export var idle_status := 1
@export var walk_status := 1
@export var death_status := 1

# 舌头
@onready var anim_tongue: Sprite2D = $Body/Anim_tongue
# 头发
@onready var anim_hair: Sprite2D = $Body/Anim_hair

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

# 随机生成状态
func _rand_anim_status():
	idle_status = randi_range(1, idle_status_max)
	walk_status = randi_range(1, walk_status_max)
	death_status = randi_range(1, death_status_max)

func _rand_hair_tonge():
	anim_tongue.visible = randi() % 2 == 0
	anim_hair.visible = randi() % 2 == 0
