extends Control
class_name ChooseLevel

@onready var all_page: Control = $AllPage
@onready var label_page: Label = get_node_or_null("LabelPage")


var all_pages : Array[GridContainer]
@export var curr_page := 0

func _ready() -> void:
	for page in all_page.get_children():
		all_pages.append(page)
		page.visible = false
	if curr_page > all_pages.size():
		curr_page = 0
	all_pages[curr_page].visible = true
	if is_instance_valid(label_page):
		_update_page(curr_page)


## 进入游戏关卡
func choose_level_start_game(game_scense:Global.MainScenes):
	get_tree().change_scene_to_file(Global.MainScenesMap[game_scense])

## 返回开始菜单
func back_start_menu():
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.StartMenu])


func _on_last_pressed() -> void:
	_update_page(curr_page - 1)

func _on_next_pressed() -> void:
	_update_page(curr_page + 1)


func _update_page(new_page:int):
	new_page = posmod(new_page, all_pages.size())
	all_pages[curr_page].visible = false
	curr_page = new_page
	all_pages[curr_page].visible = true
	label_page.text = "当前页数:" + str(curr_page + 1) + "/" + str(all_pages.size())
