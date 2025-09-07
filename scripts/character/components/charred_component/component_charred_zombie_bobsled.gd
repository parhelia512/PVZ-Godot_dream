extends CharredComponent
class_name CharredComponentZombieBobsled

@onready var zombie_bobsled_1: Sprite2D = $"../ZombieBobsled1"

## 灰烬动画
@onready var zombie_charred: Array[Node2D] = [
	%ZombieCharred, %ZombieCharred2, %ZombieCharred3, %ZombieCharred4
]
@onready var all_anim_lib: Array[AnimationPlayer] = [
	$ZombieCharred/CharredCorrect/AnimLib,
	$ZombieCharred2/CharredCorrect/AnimLib,
	$ZombieCharred3/CharredCorrect/AnimLib,
	$ZombieCharred4/CharredCorrect/AnimLib,
]
@onready var all_body: Array[BodyCharacter] = [
	%Body2, %Body4, %Body3, %Body
]

## 播放灰烬动画
func play_charred_anim():
	zombie_bobsled_1.modulate = Color.BLACK
	for i in range(4):
		all_body[i].visible = false
		zombie_charred[i].visible = true
		all_anim_lib[i].play("ALL_ANIMS")
	await all_anim_lib[0].animation_finished

	owner_character.queue_free()
