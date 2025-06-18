extends Node2D
class_name HandManager

@onready var main_game: MainGameManager = $"../.."

var card_list:Array[Card]

## 卡片和铲子
@onready var shovel_real: Sprite2D = $Shovel		# 真实铲子

@onready var card_manager: CardManager = $"../../Camera2D/CardManager"

## 植物临时挂载节点
@onready var temporary_plants: Node = $"../../TemporaryPlants"

@export var curr_card:Card
@export var new_plant_static:Node2D
@export var new_plant_static_shadow:Node2D

@onready var plant_cells: Node2D = $"../../PlantCells"
@onready var plant_cells_array: Array

var new_plant_static_in_cell := false	# 植物是否在cell中
## 手上是否拿铲子
@export var is_shovel:bool = false
## 当前铲子选择植物
@export var plant_be_shovel_look:PlantBase

## 柱子模式 
var new_plant_static_shadow_colum : Array 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 植物种植区域信号，更新植物位置列号
	for plant_cells_row in plant_cells.get_children():
		var plant_cells_array_row = plant_cells_row.get_children()
		for i in range(plant_cells_array_row.size()):
			var plant_cell = plant_cells_array_row[i]
			plant_cell.click_cell.connect(_on_click_cell)
			plant_cell.cell_mouse_enter.connect(_on_cell_mouse_enter)
			plant_cell.cell_mouse_exit.connect(_on_cell_mouse_exit)
			plant_cell.col = i
			
		plant_cells_array.append(plant_cells_array_row)

## 卡片和铲子信号连接
func card_game_signal_connect(cards:Array[Card], shovel_bg):
	for card in cards:
		card.card_click.connect(_manage_new_plant_static)
	# 铲子
	shovel_bg.shovel_click.connect(_manage_shovel)
	

func _process(delta: float) -> void:
	if new_plant_static:
		new_plant_static.global_position = get_global_mouse_position()

	if is_shovel:
		shovel_real.global_position = get_global_mouse_position()
		

# 点击卡片
func _manage_new_plant_static(curr_card:Card) -> void:
	SoundManager.play_sfx("Card/Choose")
	if not new_plant_static:
		self.curr_card = curr_card

		new_plant_static = Global.StaticPlantTypeSceneMap.get(curr_card.card_type).instantiate()
		new_plant_static.scale = Vector2.ONE
		new_plant_static_shadow = new_plant_static.duplicate()
		new_plant_static_shadow.modulate.a = 0
		new_plant_static.z_index = 1
		
		temporary_plants.add_child(new_plant_static_shadow)
		temporary_plants.add_child(new_plant_static)
		
		# 如果是柱子模式
		if main_game.mode_column:
			for i in len(plant_cells_array):
				var new_node = new_plant_static_shadow.duplicate()
				new_plant_static_shadow.get_parent().add_child(new_node)
				new_node.modulate.a = 0
				new_plant_static_shadow_colum.append(new_node)
		
		

# 点击铲子
func _manage_shovel() -> void:
	if not is_shovel:
		SoundManager.play_sfx("Card/Shovel")
		is_shovel = true
		shovel_real.visible = true
		card_manager.shovel_ui.visible = false

# 点击种植或铲掉植物
func _on_click_cell(plant_cell:PlantCell):
	if new_plant_static and not plant_cell.is_plant:
		
		SoundManager.play_sfx("PlantCreate/Plant1")
		
		if main_game.mode_column:
			for i in len(plant_cells_array):
				var plant_cell_row_col = plant_cells_array[i][plant_cell.col]
				## 如果当前cell已有植物
				if plant_cell_row_col.is_plant:
					continue
				# 创建植物
				var new_plant = Global.PlantTypeSceneMap.get(curr_card.card_type).instantiate()
				
				plant_cell_row_col.add_child(new_plant)
				new_plant.global_position = plant_cell_row_col.plant_position.global_position
				
				plant_cell_row_col.is_plant = true
				plant_cell_row_col.plant = new_plant
		
				
		else:
			# 创建植物
			var new_plant = Global.PlantTypeSceneMap.get(curr_card.card_type).instantiate()
			plant_cell.add_child(new_plant)
			new_plant.global_position = plant_cell.plant_position.global_position
			
			plant_cell.is_plant = true
			plant_cell.plant = new_plant
		
		
		# 减少阳光，卡片冷却
		card_manager.sun = card_manager.sun - curr_card.sun_cost
		curr_card.card_cool()
		
		new_plant_static_in_cell = false
		_cancel_plant_or_end()
		
	# 手拿铲子并且当前存在被铲子威胁的植物
	if is_shovel and plant_be_shovel_look:
		SoundManager.play_sfx("PlantCreate/Plant2")
		plant_be_shovel_look.be_shovel_kill()
		_cance_shovel_or_end()
		
# 鼠标进入cell
func _on_cell_mouse_enter(plant_cell:PlantCell):
	
	if new_plant_static and not plant_cell.is_plant:
		
		new_plant_static_in_cell = true
		
		if main_game.mode_column:
			# 当前cell的列
			var curr_col = plant_cell.col
			#对每一行cell变量，获取当前列的所有cell
			for i in len(plant_cells_array):
				var plant_cell_row_col:PlantCell = plant_cells_array[i][curr_col]
				var new_node = new_plant_static_shadow_colum[i]
				## 如果当前cell已有植物
				if plant_cell_row_col.is_plant:
					continue
				new_node.global_position = plant_cell_row_col.plant_position.global_position
				new_node.modulate.a = 0.5
				
			
		else:
			new_plant_static_shadow.global_position = plant_cell.plant_position.global_position
			new_plant_static_shadow.modulate.a = 0.5

	
	# 如果手拿铲子
	if is_shovel and plant_cell.plant:
		plant_be_shovel_look = plant_cell.plant
		plant_be_shovel_look.be_shovel_look()

# 鼠标移出cell
func _on_cell_mouse_exit(plant_cell:PlantCell):
	if new_plant_static and not plant_cell.is_plant:
		if main_game.mode_column:
			# 当前cell的列
			#对每一行new_node变量，获取当前new_plant_static_shadow_colum的所有new_node
			for new_node in new_plant_static_shadow_colum:
				new_node.modulate.a = 0
				new_plant_static_in_cell = false
				
				
		else:
			new_plant_static_shadow.modulate.a = 0
			new_plant_static_in_cell = false
		
	# 如果手拿铲子
	if is_shovel and plant_be_shovel_look:
		plant_be_shovel_look.be_shovel_look_end()
		plant_be_shovel_look = null

# 右键点击
func _input(event):
	if event is InputEventMouseButton:
		if new_plant_static:
			#右键点击
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				SoundManager.play_sfx("Card/Back")
				_cancel_plant_or_end()

			#左键点击空白
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not new_plant_static_in_cell:
				SoundManager.play_sfx("Card/Back")
				_cancel_plant_or_end()
		
		if is_shovel:
			#右键点击
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				SoundManager.play_sfx("Card/Back")
				if plant_be_shovel_look:
					plant_be_shovel_look.be_shovel_look_end()
					plant_be_shovel_look = null
				_cance_shovel_or_end()
			
			#左键点击空白
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not plant_be_shovel_look:
				SoundManager.play_sfx("Card/Back")
				_cance_shovel_or_end()
		

# 取消种植或者种植完成后
func _cancel_plant_or_end():
	curr_card = null
	new_plant_static.queue_free()
	new_plant_static_shadow.queue_free()
	
	# 如果是柱子模式
	if main_game.mode_column:
		for new_node in new_plant_static_shadow_colum:
			new_node.queue_free()
		new_plant_static_shadow_colum.clear()
		
# 取消铲子或者铲子完成后
func _cance_shovel_or_end():
	is_shovel = false
	shovel_real.visible = false
	card_manager.shovel_ui.visible = true
	
