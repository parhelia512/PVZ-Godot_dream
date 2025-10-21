extends Node2D
class_name IronNodeBase
## 铁器节点分为两类: IronNodeOri(body上的原始铁器)和IronNodeCopy(复制的铁器)

## 是否已经被吸走
var is_be_magnet := false

## 被吸走预处理
func preprocessing_be_magnet():
	pass
