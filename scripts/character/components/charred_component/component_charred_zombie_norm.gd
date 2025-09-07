extends CharredComponent
class_name CharredComponent_zombie_norm
## 灰烬组件

## 灰烬动画
@onready var zombie_charred: Node2D = %ZombieCharred
@onready var anim_lib: AnimationPlayer = $ZombieCharred/CharredCorrect/AnimLib
@onready var body: BodyCharacter = %Body

## 播放灰烬动画
func play_charred_anim():
	body.visible = false
	zombie_charred.visible = true
	anim_lib.play("ALL_ANIMS")
	await anim_lib.animation_finished
	owner_character.queue_free()
