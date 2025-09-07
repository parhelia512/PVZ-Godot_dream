extends PVZButtonBase
class_name StoreEnterKey
## 商店入场钥匙

## 商店
func _on_pressed() -> void:
	SoundManager.play_other_SFX("tap")
	Global.enter_store(self)
	
