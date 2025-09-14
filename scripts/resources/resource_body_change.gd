extends Resource
class_name ResourceBodyChange
## body变化时使用的资源文件

## 改变纹理的精灵节点
@export var sprite_change:Array[NodePath]

## 改变纹理的精灵节点对应的纹理
@export var sprite_change_texture:Array[Texture2D]

## 出现的精灵节点
@export var sprite_appear:Array[NodePath]
## 消失的精灵节点
@export var sprite_disappear:Array[NodePath]
## 掉落的节点
@export_node_path("ZombieDropBase") var node_drop:NodePath
