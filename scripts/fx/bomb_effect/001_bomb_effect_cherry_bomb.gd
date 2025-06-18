extends BombEffectBase
class_name CherryBombBombEffect

@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2

# 樱桃炸弹爆炸特效
func activate_bomb_effect():
	gpu_particles_2d_2.emitting = true
	super.activate_bomb_effect()
