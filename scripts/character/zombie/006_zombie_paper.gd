extends ZombieBase
class_name ZombiePaper

@export var is_gasp := false
@export var paper_rarrgh_SFX :Array[AudioStreamPlayer]= []

func arm2_drop():
	super.arm2_drop()
	is_gasp = true
	$SFX/Paper/NewspaperRip.play()

func _gasp_end():
	_curr_damage_per_second = damage_per_second * 2
	$Body/Anim_head_look.visible = false
	$Body/Anim_head_pupils.visible = false
	paper_rarrgh_SFX[randi_range(0,1)].play()
	
