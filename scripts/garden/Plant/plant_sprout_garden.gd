extends PlantGarden
class_name PlantSproutGarden

var plant_cell:PlantCellGarden

## 更新状态
func update_growth_stage():
	match curr_growth_stage:
		GrowthStage.Sprout:
			pass
		GrowthStage.Small:
			print("发芽成长为新植物")
			plant_cell.sprout_up_new_plant()
			
		GrowthStage.Medium:
			print("发芽中级状态，不应出现")
			
		GrowthStage.Large:
			print("发芽高级状态，不应出现")
		
		GrowthStage.Perfect:
			print("发芽完美状态，不应出现")
	
	flower_pot.plant_change_profect(curr_growth_stage == GrowthStage.Perfect)

# 成长状态升级
func up_growth_stage():
	curr_growth_stage += 1
	curr_plant_type = Global.curr_plant.pick_random()
	direction_x = [-1.0,1.0].pick_random()

	
