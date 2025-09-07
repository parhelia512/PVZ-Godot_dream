extends Control
## 正常卡槽
class_name CardSlotNorm

## 临时卡片存放节点，避免卡片被挡住
@onready var temporary_card: Control = $TemporaryCard
## 待选卡槽
@onready var card_slot_candidate: CardSlotCandidate = $CardSlotCandidate
## 出战卡槽节点
@onready var card_slot_battle: CardSlotBattle = $CardSlotBattle

## 开始游戏按钮信号连接
signal signal_card_slot_norm_start_game_button

#endregion
## 初始化出战卡槽，管理器调用
func init_card_slot_norm(game_para:ResourceLevelData, is_test:bool):

	card_slot_battle.init_card_slot_battle(game_para.max_choosed_card_num, game_para.start_sun)

	for i in card_slot_candidate.all_card_candidate_containers_plant:
		var card:Card = card_slot_candidate.all_card_candidate_containers_plant[i].card
		card.signal_card_click.connect(_on_card_click.bind(card))
	for i in card_slot_candidate.all_card_candidate_containers_zombie:
		var card:Card = card_slot_candidate.all_card_candidate_containers_zombie[i].card
		card.signal_card_click.connect(_on_card_click.bind(card))

	## 初始化预选卡
	if game_para.pre_choosed_card_list or game_para.pre_choosed_card_list_zombie:
		init_pre_choosed_card(game_para.pre_choosed_card_list, game_para.pre_choosed_card_list_zombie,is_test)

## 重选上次卡片
func _on_re_card_button_pressed() -> void:
	Global.load_selected_cards()
	var plant_type_selected = Global.selected_cards.get("Plant", [])
	var zombie_type_selected = Global.selected_cards.get("Zombie", [])
	for plant_type:Global.PlantType in plant_type_selected:
		if card_slot_candidate.all_card_candidate_containers_plant[AllCards.plant_card_ids[plant_type]].card.is_choosed_pre_card:
			continue
		_on_card_click(card_slot_candidate.all_card_candidate_containers_plant[AllCards.plant_card_ids[plant_type]].card)
	for zombie_type:Global.ZombieType in zombie_type_selected:
		if card_slot_candidate.all_card_candidate_containers_zombie[AllCards.zombie_card_ids[zombie_type]].card.is_choosed_pre_card:
			continue
		_on_card_click(card_slot_candidate.all_card_candidate_containers_zombie[AllCards.zombie_card_ids[zombie_type]].card)

## 开始游戏按钮
func _on_texture_button_pressed() -> void:
	## 卡槽正常选卡结束开始游戏
	EventBus.push_event("card_slot_norm_start_game")
	card_disconnect_click_in_choose()
	## 保存上次选卡
	Global.selected_cards.clear()
	Global.selected_cards["Plant"] = []
	Global.selected_cards["Zombie"] = []
	for card:Card in card_slot_battle.curr_cards:
		if card.card_plant_type == 0:
			Global.selected_cards["Zombie"].append(card.card_zombie_type)
		else:
			Global.selected_cards["Plant"].append(card.card_plant_type)
	Global.save_selected_cards()

## 初始化系统预选卡
func init_pre_choosed_card(card_type_list:Array[Global.PlantType], card_type_list_zombie:Array[Global.ZombieType],is_test:=false):
	for i in card_type_list.size():
		var plant_type:Global.PlantType =  card_type_list[i]
		var card:Card
		if plant_type == 0:
			var zombie_type:Global.ZombieType = card_type_list_zombie[i]
			print("zonbietype:", zombie_type)
			card = card_slot_candidate.all_card_candidate_containers_zombie[AllCards.zombie_card_ids[zombie_type]].card
		else:
			card = card_slot_candidate.all_card_candidate_containers_plant[AllCards.plant_card_ids[plant_type]].card
		card.is_choosed_pre_card = true
		card_slot_battle.curr_cards.append(card)
		pre_choosed_card(card, card_slot_battle.cards_placeholder[len(card_slot_battle.curr_cards)-1], is_test)
	## 预选卡断开鼠标点击信号
	card_disconnect_click_in_choose()

## 游戏选卡阶段时，卡片被点击
func _on_card_click(card:Card):
	SoundManager.play_other_SFX("tap")
	# 如果card被选择，取消选取，后面的card向前移动
	if card.is_choosed_pre_card:
		card.is_choosed_pre_card = false
		var card_idx = card_slot_battle.curr_cards.find(card)
		card_slot_battle.curr_cards.erase(card)
		for i in range(card_idx, card_slot_battle.curr_cards.size()):
			move_card_to(card_slot_battle.curr_cards[i], card_slot_battle.cards_placeholder[i])
		move_card_to(card, card.card_candidate_container)

	## 如果没被选取，放在最后一位
	else:
		if card_slot_battle.curr_cards.size() >= card_slot_battle.cards_placeholder.size():
			SoundManager.play_other_SFX("buzzer")
			return
		else:
			card.is_choosed_pre_card = true
			card_slot_battle.curr_cards.append(card)
			move_card_to(card, card_slot_battle.cards_placeholder[card_slot_battle.curr_cards.size()-1])

## 移动card到目标点位置
func move_card_to(card:Card, target_parent):
	card.button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ori_global_position = card.global_position
	card.get_parent().remove_child(card)
	temporary_card.add_child(card)
	card.global_position = ori_global_position

	var tween = create_tween()
	tween.tween_property(card, "global_position", target_parent.global_position, 0.2) # 时间可以改短点

	await tween.finished

	card.get_parent().remove_child(card)
	target_parent.add_child(card)
	card.position = Vector2.ZERO

	card.button.mouse_filter = Control.MOUSE_FILTER_PASS

## 选卡结束后，卡片断开连接，游戏开始后修改点击信号连接
func card_disconnect_click_in_choose():
	for card in card_slot_battle.curr_cards:
		if card.signal_card_click.is_connected(_on_card_click.bind(card)):
			card.signal_card_click.disconnect(_on_card_click.bind(card))

## 系统预选卡
func pre_choosed_card(card:Card, target_parent, is_test:=false):
	card.get_parent().remove_child(card)
	target_parent.add_child(card)
	card.position = Vector2.ZERO
	if is_test:
		card.card_change_cool_time(0)

## 移动卡槽（出现或隐藏）
func move_card_slot_candidate(is_appeal:bool):
	var tween = create_tween()
	if is_appeal:
		tween.tween_property(card_slot_candidate, "position",Vector2(0, 89.0), 0.2) # 时间可以改短点
	else:
		tween.tween_property(card_slot_candidate, "position",Vector2(0, 615.0), 0.2) # 时间可以改短点

	await tween.finished

## 移动待选卡槽（出现或隐藏）
func move_card_slot_battle(is_appeal:bool, appeal_time:= 0.2):
	var tween = create_tween()
	if is_appeal:
		tween.tween_property(card_slot_battle, "position",Vector2(0, 0), appeal_time)
	else:
		tween.tween_property(card_slot_battle, "position",Vector2(0, -100.0), appeal_time)
	await tween.finished
