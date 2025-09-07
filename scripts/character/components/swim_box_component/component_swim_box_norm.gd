extends SwimBoxComponent
class_name SwimBoxComponentNorm
## 普通僵尸游泳组件


## 检测到泳池
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner is Pool:
		if body_change_swim:
			for sprite_path in body_change_swim.sprite_disappear:
				var sprite = get_node(sprite_path)
				sprite.visible = false

			for sprite_path in body_change_swim.sprite_appear:
				var sprite = get_node(sprite_path)
				sprite.visible = true
		## 水花
		appear_splash()

		var tween = create_tween()
		# 仅移动y轴，在1.5秒内下移200像素
		tween.tween_property(body, "position:y", body.position.y + 30, 0.5)
		tween.set_parallel()
		tween.tween_property(node_drop, "position:y", node_drop.position.y + 30, 0.5)
		await tween.finished
		signal_change_is_swimming.emit(true)

## 离开泳池
func _on_area_2d_area_exited(area: Area2D) -> void:
	if not owner_is_death:
		if area.owner is Pool:
			## 水花
			appear_splash()

			if body_change_swim:
				for sprite_path in body_change_swim.sprite_disappear:
					var sprite = get_node(sprite_path)
					sprite.visible = true

				for sprite_path in body_change_swim.sprite_appear:
					var sprite = get_node(sprite_path)
					sprite.visible = false

			var tween = create_tween()
			# 仅移动y轴，在1.5秒上升30像素
			tween.tween_property(body, "position:y", body.position.y - 30, 0.5)
			tween.set_parallel()
			tween.tween_property(node_drop, "position:y", node_drop.position.y - 30, 0.5)
			signal_change_is_swimming.emit(false)

