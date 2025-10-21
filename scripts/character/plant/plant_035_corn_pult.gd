extends Plant000Base
class_name Plant035CornPult

@onready var attack_component: AttackComponentBulletBase = $AttackComponent


## 初始化正常出战角色信号连接
func init_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)
