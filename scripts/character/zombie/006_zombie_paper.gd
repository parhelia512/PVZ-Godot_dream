extends ZombieBase
class_name ZombiePaper

@export var is_gasp := false

	
func arm2_drop():
	super.arm2_drop()
	is_gasp = true
	

func _gasp_end():
	$Body/Anim_head_look.visible = false
	$Body/Anim_head_pupils.visible = false
