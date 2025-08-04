extends Node
## 散落的加载场景

## 花园植物格子
var PLANT_CELL_GARDEN:PackedScene= load("res://scenes/garden/plant_cell_garden.tscn")

## 戴夫
var CRAZY_DAVE:PackedScene = load("res://scenes/crazy_dave/crazy_dave.tscn")

## 提示信息
const REMINDER_INFORMATION:PackedScene = preload("res://scenes/ui/reminder_information.tscn")

## 钻石、金币、银币、
const COIN_DIAMOND:PackedScene = preload("res://scenes/item/game_scenes_item/drop/coin_diamond.tscn")
const COIN_GOLD:PackedScene = preload("res://scenes/item/game_scenes_item/drop/coin_gold.tscn")
const COIN_SILVER:PackedScene = preload("res://scenes/item/game_scenes_item/drop/coin_silver.tscn")
const PRESENT:PackedScene = preload("res://scenes/item/game_scenes_item/drop/present.tscn")
