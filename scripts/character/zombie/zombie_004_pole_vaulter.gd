extends Zombie000Base
class_name Zombie004PoleVaulter

@onready var jump_component: JumpComponent = $JumpComponent
@onready var attack_ray_component: AttackRayComponent = %AttackRayComponent

@export var is_jumping := false
var is_jump_stop := false
var jump_stop_postion :Vector2


func init_norm() -> void:
	super()
	attack_ray_component.disable_component(ComponentBase.E_IsEnableFactor.Jump)

## 初始化正常出战角色信号连接
func init_norm_signal_connect():
	super()
	jump_component.signal_jump_start.connect(jump_start)
	jump_component.signal_jump_end.connect(jump_end)
	jump_component.signal_jump_end_end.connect(jump_end_end)

	jump_component.signal_jump_end_end.connect(attack_ray_component.enable_component.bind(ComponentBase.E_IsEnableFactor.Jump))
	## 跳跃对移动影响
	jump_component.signal_jump_start.connect(move_component.update_move_factor.bind(true, MoveComponent.E_MoveFactor.IsJump))
	jump_component.signal_jump_end_end.connect(move_component.update_move_factor.bind(false, MoveComponent.E_MoveFactor.IsJump))


## 开始跳跃,跳跃组件信号发射调用
func jump_start():
	is_jumping = true
	curr_be_attack_status = E_BeAttackStatusZombie.IsJump
	signal_status_update.emit()

## 僵尸跳跃结束,跳跃组件信号发射调用
func jump_end():
	is_jumping = false
	jump_component.disable_component(ComponentBase.E_IsEnableFactor.Jump)

## 僵尸跳跃后摇结束
func jump_end_end():
	curr_be_attack_status = E_BeAttackStatusZombie.IsNorm
	signal_status_update.emit()
	is_trigger_squash_pos_judge = false
	is_trigger_tall_nut_stop_jump = false

## 跳跃被强行停止,高坚果调用
func jump_be_stop(plant:Plant000Base):
	jump_component.jump_be_stop(plant)
