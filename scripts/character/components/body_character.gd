extends ComponentBase
## 角色身体属性，用于管理body变换（发亮、颜色）
class_name BodyCharacter

const BODY_MASK = preload("res://shader_material/body_mask.tres")
var hit_tween: Tween = null  # 发光动画

# modulate 状态颜色变量
var base_color := Color(1, 1, 1)

var change_color:Dictionary[E_ChangeColors, Color] = {
}
enum E_ChangeColors{
	HitColor,
	IceColor,	## 冰冻和减速使用一个
	BeShovelLookColor,
	HypnoColor,
	CreateSunColor,
}


func owner_be_hypno():
	set_other_color(E_ChangeColors.HypnoColor, Color(1,0.5,1))


func set_other_color(change_name:E_ChangeColors, value: Color) -> void:
	change_color[change_name] = value
	_update_modulate()


# 更新最终 modulate 的合成颜色
func _update_modulate():
	var final_color = base_color
	for change_color_value in change_color.values():
		final_color *= change_color_value
	modulate = final_color


## 发光动画函数
func body_light():
	## 先直接变亮
	set_other_color(E_ChangeColors.HitColor, Color(2, 2, 2))

	if hit_tween and hit_tween.is_running():
		hit_tween.kill()

	hit_tween = create_tween()
	hit_tween.tween_method(
		func(val): set_other_color(E_ChangeColors.HitColor, val), # 传匿名函数包一层，保证有 change_name
		change_color[E_ChangeColors.HitColor],
		Color(1, 1, 1),
		0.5
	)

## 僵尸从地下出来
func zombie_body_up_from_ground():
	body_mask_start()
	## 泥土特效
	var dirt_rise_effect:DirtRiseEffect = SceneRegistry.DIRT_RISE_EFFECT.instantiate()
	owner.add_child(dirt_rise_effect)
	dirt_rise_effect.start_dirt()

	position.y += 100
	var tween :Tween = create_tween()
	tween.tween_property(self, "position:y", position.y-100, 1)
	await tween.finished
	body_mask_end()

## 僵尸从水下出来(珊瑚僵尸)
func zombie_body_up_from_pool():
	body_mask_start()
	position.y += 100
	var tween :Tween = create_tween()
	tween.tween_property(self, "position:y", position.y-100, 1)
	await tween.finished
	body_mask_end()

## 身体在当前body节点以上的显示,以下透明,需要转为画布坐标
func body_mask_start():
	material = BODY_MASK.duplicate()
	material.set_shader_parameter(&"cutoff_y", GlobalUtils.world_to_screen(owner.global_position).y)
	for child in get_children():
		_node_use_parent_material(child)


## 结束身体在当前body节点以上的显示,以下透明
func body_mask_end():
	material = null

## 递归让子节点使用父节点shader材质
func _node_use_parent_material(node: Node2D) -> void:
	node.use_parent_material = true
	## 遍历所有子节点
	for child in node.get_children():
		_node_use_parent_material(child)
