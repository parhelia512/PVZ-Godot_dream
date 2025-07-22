extends Node2D
class_name GrapTanglekelp

@onready var anim_tanglekelp_grab: AnimationPlayer = $Anim_Tanglekelp_grab

func activate_it_to_grap_zombie(zombie:ZombieBase):
	get_parent().remove_child(self)
	zombie.body.add_child(self)
	visible = true
	## 如果在潜水层
	if zombie.area2d.collision_layer & 1024:
		position = Vector2(20, 115)
	else:
		position = Vector2(40, 60)
	
	zombie.be_grap_in_pool()
	anim_tanglekelp_grab.play("Tanglekelp_grab")
	await anim_tanglekelp_grab.animation_finished
	
	## 水花
	var splash:Splash = Global.splash_pool_scenes.instantiate()
	zombie.add_child(splash)
	splash.global_position = global_position 
	splash.z_index += 5 
	
	var tween:Tween = create_tween()
	tween.tween_property(zombie.body, "position", zombie.body.position + Vector2(0, 100), 1)
	tween.tween_property(zombie.body, "position", zombie.body.position + Vector2(0, 100), 0.5)
	await tween.finished
	
	
	# 减少当前所有血量
	zombie.disappear_death(true)
	zombie.delete_zombie()
	
