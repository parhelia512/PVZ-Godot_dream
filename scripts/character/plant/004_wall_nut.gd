extends PlantBase
class_name WallNut

@export var face_damaged : Array[Texture2D]

@onready var anim_face: Sprite2D = $Body/Anim_face
@export var hp_status = 1


func judge_status():
	super.judge_status()
	
	if curr_Hp <= max_hp / 3 and hp_status < 3:
		anim_face.texture = face_damaged[1]
		hp_status = 3
	elif curr_Hp <= max_hp * 2 / 3 and hp_status < 2:
		anim_face.texture = face_damaged[0]
		hp_status = 2
