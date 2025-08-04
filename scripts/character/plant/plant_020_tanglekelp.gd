extends PlantBase
class_name TangleKelp

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var grap: GrapTanglekelp = $grap

@export var is_attack: bool = false


func _ready():
	super._ready()


func _process(delta):
	# 每帧检查射线是否碰到僵尸
	if ray_cast_2d.get_collider():
		if not is_attack:
			## 目标僵尸
			var target_zombie:ZombieBase = ray_cast_2d.get_collider().get_parent()
			if target_zombie.lane == row_col.x:
				is_attack = true
				start_grap_zombie(target_zombie)
			
## 开始攻击
func start_grap_zombie(target_zombie:ZombieBase):
	
	area_2d.queue_free()
	#tween.tween_property(self, "global_position", target_position_x, 0.3).set_ease(Tween.EASE_IN)
	grap_in_pool(target_zombie)
	
	
## 拖入水中
func grap_in_pool(target_zombie:ZombieBase):
	grap.activate_it_to_grap_zombie(target_zombie)
	await get_tree().create_timer(0.3).timeout
	# 水花
	var splash:Splash = Global.splash_pool_scenes.instantiate()
	plant_cell.add_child(splash)
	splash.global_position = global_position + Vector2(0, 10)

	var tween:Tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 10), 0.5)
	await tween.finished

	_plant_free()
		
