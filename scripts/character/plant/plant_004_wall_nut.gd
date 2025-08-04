extends PlantBase
class_name WallNut

@export var face_damaged : Array[Texture2D]
@export var change_status_body: Sprite2D
@export var hp_status := 1


func judge_status():
	super.judge_status()

	if curr_Hp <= max_hp / 3 and hp_status < 3:
		change_status_body.texture = face_damaged[1]
		hp_status = 3
	elif curr_Hp <= max_hp * 2 / 3 and hp_status < 2:
		change_status_body.texture = face_damaged[0]
		hp_status = 2
