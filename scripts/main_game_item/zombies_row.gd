extends CanvasItem
class_name ZombieRow


enum ZombieRowType{
	Land,
	Pool,
	Both,
}
## 当前行类型
@export var zombie_row_type:ZombieRowType = ZombieRowType.Land
## 是否有钉耙
@export var have_rake := false
