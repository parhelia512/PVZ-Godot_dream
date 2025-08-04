extends CanvasLayer
class_name ConfirmGoods
## 确认是否购买商品

## 当前商品节点
var curr_goods_node:Goods

## 出现该界面确认购买商品
func appear_canvas_layer(curr_goods:Goods):
	print(curr_goods.name)
	curr_goods_node = curr_goods
	visible = true
	

## 确认购买
func _on_pvz_button_pressed() -> void:
	curr_goods_node.comfirm_get_this_goods()
	curr_goods_node = null
	visible = false
	
## 取消购买
func _on_pvz_button_2_pressed() -> void:
	curr_goods_node = null
	visible = false
