extends PVZButtonBase
class_name MainGameMenuAppearButton
## 主游戏菜单出现按钮
@onready var main_game: MainGameManager = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	button_down.connect(SoundManager.play_sfx.bind("MainGameUI/ButtonDown"))


func _on_mouse_entered() -> void:
	## 如果有锤子
	if main_game.hammer:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
