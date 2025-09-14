extends Node2D
class_name ZombieManagerInMiniGameHammerZombie

""" 
参考：https://www.bilibili.com/video/BV12e4y1J7hH/
共计11大组僵尸、每大组结束后会停顿较长时间，并生成一次墓碑
每大组僵尸有11-15小组僵尸

游戏开始后，墓碑可能出现普通僵尸
第2次停顿后，2个墓碑可能同时召唤同一种僵尸
第4次停顿后，可能出现路障僵尸
第6次停顿后，可能出现铁桶僵尸
第8次停顿后，3个墓碑可能同时召唤同一种僵尸
最后1波时，所有墓碑同时召唤铁桶或路障，但是不超过20只


游戏开始时，长9个墓碑
每次长墓碑时，如果墓碑数量<5，则把墓碑数量长至5
每次长墓碑时，如果墓碑数量=>5，则长1个墓碑
墓碑只长第4列~第9列，如果都被占满则不长墓碑，只有停顿
"""
## handmanager 直接控制墓碑相关内容
@onready var hand_manager: HandManager = $"../../HandManager"
@onready var zombie_manager: ZombieManager = $".."
@onready var hammer_zombie_timer: Timer = $HammerZombieTimer
@onready var flag_progress_bar: FlagProgressBar = $"../FlagProgressBar"
## 最多大组数
@export var max_group_big = 11
## 当前大组的最大小组数
var max_group_min :int
var curr_group_big := 0		#当前大组数
var curr_group_min := 0		#当前小组数

## 每一大组的进度条的占比（%）
var progress_bar_segment_every_groud_big :float
## 每一小组的进度条占比（%）
var progress_bar_segment_every_groud_min :float

## 当前可以生成的僵尸类型
var curr_zombie_type_candidate :Array[Global.ZombieType] = [Global.ZombieType.ZombieNorm]
## 当前每小组可以生成的僵尸数量
var curr_num_new_zombie_every_group := 1
## 当前每小波间隔时间（从1s开始，每大组减速0.05秒，真正使用时增加0.1秒波动）
var interval_every_group := 1.0
## 是否为最后一波
var end_wave := false
## 每一大组的动画倍率,每一大组更新增加0.15
var anim_multiply := 1.0

func init_manager():
	max_group_min = randi_range(11, 15)
	hammer_zombie_timer.one_shot = true
	## 生成一个旗帜
	flag_progress_bar.init_flag_from_wave(10)
	progress_bar_segment_every_groud_big = 100.0/max_group_big
	progress_bar_segment_every_groud_min = progress_bar_segment_every_groud_big / max_group_min
	
	start_first_wave()
	
func start_first_wave():
	_on_hammer_zombie_timer_timeout()


## 生成一小组僵尸
func create_one_group_min_zombie():
	var new_zombie_type = curr_zombie_type_candidate.pick_random()
	## 如果当前没有墓碑
	if hand_manager.tombstone_list.size() == 0:
		hand_manager.create_tombstone(randi()%3+1)
		await get_tree().create_timer(2).timeout
		
	## 真正生成的僵尸数量
	var real_zombie_num = min(randi_range(1, curr_num_new_zombie_every_group) * zombie_manager.zombie_multy, hand_manager.tombstone_list.size())
	if end_wave:
		real_zombie_num = hand_manager.tombstone_list.size()
		for i in range(real_zombie_num):
			new_zombie_type = curr_zombie_type_candidate.pick_random()
			hand_manager.tombstone_list[i].create_new_zombie(new_zombie_type, anim_multiply)
	else:
		hand_manager.tombstone_list.shuffle()
		for i in range(real_zombie_num):
			hand_manager.tombstone_list[i].create_new_zombie(new_zombie_type, anim_multiply)


## 计算当前进度并更新进度条
func set_progress_bar():
	var curr_progress :float= curr_group_big * progress_bar_segment_every_groud_big + (curr_group_min+1) * progress_bar_segment_every_groud_min
	flag_progress_bar.set_progress(curr_progress, int(end_wave) - 1)

func _on_hammer_zombie_timer_timeout() -> void:
	## 如果是最后一波
	if curr_group_min == max_group_min - 1 and curr_group_big == max_group_big - 1:
		end_wave = true
		await get_tree().create_timer(3).timeout
	set_progress_bar()
	
	## 先生成一小组僵尸
	create_one_group_min_zombie()
	
	## 如果是小组的最后一组（从0开始计数）
	if curr_group_min == max_group_min - 1:
		curr_group_min = 0
		## 如果是最后一大组
		if curr_group_big == max_group_big - 1:
			## 生成僵尸之后，更新zombie_manager的end_wave,使其管理最后一波僵尸死亡后奖杯
			zombie_manager.end_wave = true
			return 
		else:
			curr_group_big += 1
			match curr_group_big:
				2:
					curr_num_new_zombie_every_group = 2
				4:
					curr_zombie_type_candidate.append(Global.ZombieType.ZombieCone)
				6:
					curr_zombie_type_candidate.append(Global.ZombieType.ZombieBucket)
				8:
					curr_num_new_zombie_every_group = 3
			## 更新每大组的小组数量
			max_group_min = randi_range(11, 15)
			progress_bar_segment_every_groud_min = progress_bar_segment_every_groud_big / max_group_min
			## 更新僵尸动画速度和小组间隔
			anim_multiply += 0.15
			interval_every_group -= 0.05
			
			## 等待2秒创建墓碑后再等待两秒
			await get_tree().create_timer(3).timeout
			if hand_manager.tombstone_list.size() >= 5:
				hand_manager.create_tombstone(1)
			else:
				hand_manager.create_tombstone(5 - hand_manager.tombstone_list.size())
				
			await get_tree().create_timer(2).timeout
			hammer_zombie_timer.wait_time = interval_every_group + randf_range(-0.1, 0.1)
		
	else:
		curr_group_min += 1
		hammer_zombie_timer.wait_time = interval_every_group + randf_range(-0.1, 0.1)
	hammer_zombie_timer.start()
	
