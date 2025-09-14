extends Plant000Base
class_name Plant023TorchWood

## 当前升级的子弹
var curr_bullet_up :Array[Bullet000Base] = []
## 子弹根节点
var bullets:Node2D

func init_norm() -> void:
	super()
	var main_game:MainGameManager = get_tree().current_scene
	bullets = main_game.bullets

## 子弹进入升级区域
func _on_area_2d_up_bullet_area_entered(area: Area2D) -> void:
	var bullet:Bullet000Base = area.owner
	if bullet.is_can_up:
		if bullet.bullet_up_plant_type == plant_type:
			_up_bullet(bullet)

## 子弹离开当前区域
func _on_area_2d_up_bullet_area_exited(area: Area2D) -> void:
	var bullet:Bullet000Base = area.owner
	if bullet in curr_bullet_up:
		curr_bullet_up.erase(bullet)

## 升级子弹
func _up_bullet(curr_bullet:Bullet000Base):
	if curr_bullet not in curr_bullet_up:
		var new_bullet_up = curr_bullet.create_new_bullet_up()

		curr_bullet_up.append(new_bullet_up)

		bullets.call_deferred("add_child", new_bullet_up)
		curr_bullet.queue_free()

