extends ComponentBase
## 角色身体属性，用于管理body变换（发亮、颜色）
class_name BodyCharacter

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
