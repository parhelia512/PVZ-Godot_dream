extends ZombieJackson
class_name ZombieDancer

@onready var mask: Panel = $Mask
@onready var dirt: DirtNewZombie = $Dirt

func _ready():
	super._ready()
	
	_init_dance()


func game_init_zombie_jackson():
	pass


## 重写舞王初始方法
func _init_dance():
	animation_player.set_blend_time('armraise', 'walk', 0.1)
	zombie_appear_from_ground()
	is_start_enter = false
	dirt.start_dirt()

## 随机初始化动画播放速度(重写父类方法)伴舞僵尸不需要
func _init_anim_speed():
	# 获取动画初始速度
	pass
	
## 初始化时重置动画播放速度, 舞王管理器调用
func init_anim_speed_dance(animation_origin_speed, curr_speed):
	# 获取动画初始速度
	self.animation_origin_speed = animation_origin_speed
	#animation_player.speed_scale = animation_origin_speed
	animation_player.speed_scale = curr_speed
	

## 僵尸子类重写该方法，获取ground，部分僵尸修改body位置在panel节点下
func _get_some_node():
	body = $Mask/Body
	_ground = $Mask/Body/_ground
	animation_player = $AnimationPlayer
	shadow =  $Mask/Body/shadow


## 伴舞僵尸从地下出现
func zombie_appear_from_ground():
	body.position.y = 180.0
	var tween = create_tween()
	tween.tween_property(body, "position", Vector2(body.position.x, 20), 1.0)
	
	await tween.finished
	
	mask.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	mask.remove_theme_stylebox_override("panel")
	mask.add_theme_stylebox_override("panel", StyleBoxEmpty.new())


#被召唤的伴舞被魅惑
func be_hypnotized():
	super.be_hypnotized()
	## -1为舞王
	dancer_manager.zombie_dancers[-1] = false
	dancer_manager.zombie_dancers[0] = self
	
	
## 被魅惑召唤的伴舞
func call_be_hypnotized():
	be_hypnotized_base()
	direction_scale = Vector2(-1, 1)
