extends Button


func _gui_input(event):
	if disabled and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 播放点击音效，即使按钮被禁用
		SoundManager.play_sfx("Card/Error")
