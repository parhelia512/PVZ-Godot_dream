extends Node2D
class_name ItemBase

var item_button:UiItemButton
var is_activate := false

var is_clone := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	is_activate = false

func _process(_delta):
	if is_activate:
		global_position = get_global_mouse_position()


func use_it():
	pass

## 克隆自己
func clone_self():
	var parent = get_parent()
	if parent:
		var clone:ItemBase = duplicate(4)
		parent.add_child(clone)
		clone.global_position = global_position
		return clone

## 鼠标点击ui图标按钮，激活该物品
func activete_it():
	visible = true
	is_activate = true

## 取消激活
func deactivate_it(is_play_sfx:=true):
	item_button.item_texture.visible = true
	visible = false
	is_activate = false
	
	global_position = Vector2(0,0)
	if is_play_sfx:
		SoundManager.play_other_SFX("tap2")
