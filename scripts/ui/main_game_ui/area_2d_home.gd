extends Area2D
class_name Area2DHome

@onready var main_game: MainGameManager = $"../.."

@onready var camera_2d: MainGameCamera = $"../../Camera2D"
@onready var panel: Panel = $Door/DoorDown/Panel

func change_zombie_position(zombie:ZombieBase):
	## 要删除碰撞器，不然会闪退
	zombie.area2d.free()
	zombie.get_parent().remove_child(zombie) 
	panel.add_child(zombie)
	zombie.position = Vector2(75, 360)
	zombie.walking_status = ZombieBase.WalkingStatus.end

func _on_area_entered(area: Area2D) -> void:
	main_game.main_game_progress = main_game.MainGameProgress.GAME_OVER
	main_game.card_manager.visible = false
	# 游戏暂停
	get_tree().paused = true
	var zombie :ZombieBase = area.get_parent()
	change_zombie_position(zombie)
	zombie.walking_status = ZombieBase.WalkingStatus.start
	## 如果有锤子
	if main_game.hammer:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().create_timer(1).timeout
	zombie.walking_status = ZombieBase.WalkingStatus.start
	## 设置相机可以移动
	camera_2d.process_mode = Node.PROCESS_MODE_ALWAYS
	camera_2d.move_to(Vector2(-200, 0), 2)
	
	await get_tree().create_timer(3).timeout
	$SFX/Scream.play()
	var ui_remind_word: UIRemindWord = main_game.ui_remind_word
	ui_remind_word.zombie_won_word_appear()
	
	### 等待10秒重新开始
	#await get_tree().create_timer(10).timeout
	#resume_game()
## 重新开始
func resume_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	Global.time_scale = 1.0
	Engine.time_scale = Global.time_scale
	
