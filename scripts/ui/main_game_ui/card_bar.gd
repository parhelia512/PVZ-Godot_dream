extends PanelContainer
class_name UICardBar

@onready var main_game: MainGameManager = $"../../../.."

func _on_mouse_entered():
	
	if Global.display_plant_card_bar_follow_mouse:
		# 鼠标进入时，提高z_index，保证在前面显示
		get_parent().z_index = 900
	
	## 如果有锤子
	if main_game.hammer:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	
func _on_mouse_exited():
	if Global.display_plant_card_bar_follow_mouse:
		# 鼠标离开时，恢复原始z_index
		get_parent().z_index = 100

	## 如果有锤子
	if main_game.hammer:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
