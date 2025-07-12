extends Control
class_name ChooseLevel

## 进入游戏关卡
func choose_level_start_game(game_scense:Global.MainScenes):
	get_tree().change_scene_to_file(Global.MainScenesMap[game_scense])

## 返回开始菜单
func back_start_menu():
	get_tree().change_scene_to_file(Global.MainScenesMap[Global.MainScenes.StartMenu])
