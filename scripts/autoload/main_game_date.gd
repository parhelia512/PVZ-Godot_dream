extends Node
## 自动加载,用于保存主游戏场景,对应管理器初始化的一些全局数据

## 主游戏管理器
var main_game_manager:MainGameManager = null

## 主游戏运行阶段
var main_game_progress:MainGameManager.E_MainGameProgress = MainGameManager.E_MainGameProgress.NONE

## 主游戏物品根节点
var bullets:Node2D
var bombs:Node2D
var suns:Node2D

## 阳光收集位置节点
var marker_2d_sun_target:Marker2D

## 主游戏背景
var fog_node:Fog

## ZombieManager初始化
## 僵尸管理器,全局创建僵尸时使用
var zombie_manager:ZombieManager = null
## 所有僵尸行
var all_zombie_rows:Array[ZombieRow] = []
## 冰道,按行保存每行的冰道
var all_ice_roads:Array[Array] = []

## PlantCellManager初始化
## 二维数组，保存每个植物格子节点
var all_plant_cells: Array[Array] = []
## 植物格子的行和列
var row_col:Vector2i = Vector2i.ZERO

## TombStoneManager(PlantCellManager子节点)初始化
## 生成的墓碑列表(一维)
var tombstone_list :Array[TombStone] = []
