extends TextureButton
class_name ChooseLevelButton

@export var curr_sences := Global.MainScenes.MainGameFront
@export var curr_level_data_game_para :ResourceLevelData

@onready var choose_level: ChooseLevel = $"../../../.."


func _on_pressed() -> void:
	Global.game_para = curr_level_data_game_para
	choose_level.choose_level_start_game(curr_sences)
	
