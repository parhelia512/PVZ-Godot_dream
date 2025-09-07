extends Node2D
class_name BombEffectBase

## 爆炸特效
func activate_bomb_effect():
	if self.is_inside_tree():
		var curr_scene = get_tree().current_scene
		if curr_scene is MainGameManager:
			var bombs = get_tree().current_scene.get_node("Bombs")
			GlobalUtils.child_node_change_parent(self, bombs)

