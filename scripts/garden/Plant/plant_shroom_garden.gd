extends PlantGarden
class_name PlantShroomGarden

## is_idle永久为真
@export var is_idle := true
@export var is_sleep := false
@onready var sleep_shroom_garden: ShroomSleepGarden = $SleepShroomGarden


func _ready() -> void:
	## 先判断一次是否在睡觉
	sleep_shroom_garden.judge_sleep()
	## 初始化一些相关东西（create_coin_timer）,植物需求需要先判断是否在睡觉
	super()
	## 再判断一次是否在睡觉，更新（create_coin_timer），改变zzz大小
	sleep_shroom_garden.judge_sleep()

func stop_sleep():
	is_sleep = false
	activate_plant()


func start_sleep():
	is_sleep = true
	deactivate_plant()
	

func satisfy_need(item: NeedItem):
	## 如果当前正在睡觉
	if is_sleep:
		return
	else:
		super(item)
		

## 时间回调函数调用植物状态变化,触发该函数生成需求
func _on_need_timer_timeout():
	## 如果当前正在睡觉
	if is_sleep:
		return
	else:
		super()



## 激活当前植物生产金币
func activate_plant():
	if curr_growth_stage == GrowthStage.Perfect and not is_sleep:
		if create_coin_timer:
			create_coin_timer.start()
	
## 停止当前植物生产金币
func deactivate_plant():
	if create_coin_timer:
		create_coin_timer.stop()
	
