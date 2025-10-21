extends Plant000Base
class_name Plant011FumeShroom

@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var attack_component: AttackComponentBulletBase = $AttackComponent


## 初始化正常出战角色信号连接
func init_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)


func _start_shoot():
	gpu_particles_2d.emitting = true

func _end_shoot():
	gpu_particles_2d.emitting = false

