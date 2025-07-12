extends BulletLineraBase
class_name BulletWallNutBowlingBomb

var rotation_speed = 5.0  # 旋转速度
@onready var bullet_body: Node2D = $BulletBody

## 爆炸音效
@export var SFX_bomb :AudioStreamPlayer
@onready var area_2d_2: Area2D = $Area2D2

func _ready() -> void:
	super._ready()
	$SFX/Bowling.play()

func _process(delta: float) -> void:
	super._process(delta)
	bullet_body.rotation += rotation_speed * delta
	

## 子弹击中僵尸
func _on_area_2d_area_entered(area: Area2D) -> void:
	##等待一帧，不然直接爆炸会没有伤害
	await get_tree().process_frame
	if not is_attack:
		is_attack = true
		## 爆炸炸死所有僵尸
		_bomb_all_area_zombie()
		queue_free()


# 爆炸效果
func _bomb_particle():
	if SFX_bomb:
		# SFX 爆炸植物死亡后销毁，将音效节点移至soundmanager
		SFX_bomb.get_parent().remove_child(SFX_bomb)
		SoundManager.add_child(SFX_bomb)
		SFX_bomb.play()
	
	bullet_effect_change_parent(bullet_effect)
	bullet_effect.activate_bomb_effect()

func _bomb_all_area_zombie():
	var areas = area_2d_2.get_overlapping_areas()
	for area in areas:
		area.get_parent().be_bomb_death()
	
	_bomb_particle()
	
