extends TextureRect
class_name ChooseLevelButton

@export var curr_sences := Global.MainScenes.MainGameFront
@export var curr_level_data_game_para :ResourceLevelData

@onready var choose_level: ChooseLevel = $"../../.."
@onready var texture_button: TextureButton = get_node_or_null("TextureButton")


func _ready() -> void:
	if curr_level_data_game_para != null:
		texture_button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	Global.game_para = curr_level_data_game_para
	choose_level.choose_level_start_game(curr_sences)

