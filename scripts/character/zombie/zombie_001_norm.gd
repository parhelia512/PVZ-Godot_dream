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

@export_group("水草精灵节点")
@export var is_sea_weed_zombie := false
@export var sea_weed_sprites :Array[Sprite2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# 随机动画状态
	_rand_anim_status()
	_rand_hair_tonge()
	
	if curr_zombie_row_type == ZombieRow.ZombieRowType.Land:
		for sprite in swim_zombie_appear_start:
			sprite.visible = false
	elif curr_zombie_row_type == ZombieRow.ZombieRowType.Pool:
		for sprite in swim_zombie_appear_start:
			sprite.visible = true

# 随机生成状态
func _rand_anim_status():
	idle_status = randi_range(1, idle_status_max)
	walk_status = randi_range(1, walk_status_max)
	death_status = randi_range(1, death_status_max)

func _rand_hair_tonge():
	
	anim_tongue.visible = randi() % 2 == 0
	anim_hair.visible = randi() % 2 == 0


func sea_weed_init():
	for sea_weed in sea_weed_sprites:
		sea_weed.visible = true

	
## 碰撞到泳池
func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_sea_weed_zombie:
		start_swim()
	#else:
		#sea_weed_appear()

## 从泳池下面出现
func sea_weed_appear():
	
	# 水花
	var splash:Splash = Global.splash_pool_scenes.instantiate()
	add_child(splash)
	
	for sprite in swimming_fade:
		sprite.visible = false
	for sprite in swimming_appear:
		sprite.visible = true
	var y_in_swim = body.position.y + 30
	body.position.y += 100
	
	var tween = create_tween()
	# 仅移动y轴，在1.5秒内下移200像素
	tween.tween_property(body, "position:y", y_in_swim, 0.5)
	await tween.finished
	is_swimming = true
	
	
