# GameManager.gd (设为 Autoload)
extends Node

signal score_changed(new_score) # 定义信号，用于更新 UI
signal entered_placement_mode

var current_score: int = 0
var daily_score: int = 0
var daily_stamina: int = 3
var current_selection = []
var game_over: bool = false

# 定义当前要放置的动物 ID
var current_placing_animal_id: String = ""
# 预加载该动物的场景资源
var placing_scene: PackedScene = null

var unlocked_animals = {
	"Capybara_Golden": {"unlocked": false, "count": 1, "scene": "res://Animals/Placeable/Capybara_GoldenPLB.tscn"},
	"Capybara": {"unlocked": true, "count": 1, "scene": "res://Animals/Placeable/CapybaraPLB.tscn"},
	"Bear": {"unlocked": true, "count": 1, "scene": "res://Animals/Placeable/BearPLB.tscn"},
	"Rabbit": {"unlocked": true, "count": 1, "scene": "res://Animals/Placeable/RabbitPLB.tscn"},
	"Cat": {"unlocked": true, "count": 1, "scene": "res://Animals/Placeable/CatPLB.tscn"},
	"Dog": {"unlocked": true, "count": 1, "scene": "res://Animals/Placeable/DogPLB.tscn"}
}


func add_to_selection(animal):                               #游戏失败后停止计算合集
	current_selection.append(animal)
	
	if current_selection.size() == 2:
		quick_match(animal)
	if current_selection.size() == 3:
		full_match(animal)
	

func quick_match(animal1):
	var first1 = current_selection[0]
	var second2 = current_selection[1]
	
	if first1.animal_type != second2.animal_type:
		print("类型不匹配，快速清空")
		clear_selection()
		current_selection.clear()
		
		animal1.selected() # 只保留最后一个动物


func full_match(animal2):
	var first = current_selection[0]
	var second = current_selection[1]
	var third = current_selection[2]
	
	# 比较 animal_type 属性
	if first.animal_type != null and second.animal_type != null and third.animal_type != null:
		if first.animal_type == second.animal_type and second.animal_type == third.animal_type:
			add_score(third.score_value)
			
			for item in current_selection:
				# 播放消失动画（这里可以用 Tween 让它缩小）
				var tween = create_tween()
				tween.tween_property(item, "scale", Vector2.ZERO, 0.2)
				tween.finished.connect(item.queue_free) 
			
			current_selection.clear()
		else:
			clear_selection()
			current_selection.clear()
			animal2.selected() # 只保留最后一个动物

# 待使用
func clear_selection():
	if current_selection.is_empty():
		return
		
	for item in current_selection:
		if is_instance_valid(item): # 确保动物还没被销毁
			item.deselected() # 取消选定

func add_score(points: int):
	current_score += points
	score_changed.emit(current_score) # 发射信号
	
func clear_score():
	current_score = 0
	score_changed.emit(current_score)
	current_selection.clear()
	
func new_day():
	daily_score = 0


func start_placement_mode(animal_id: String):
	current_placing_animal_id = animal_id
	placing_scene = load(unlocked_animals[animal_id]["scene"])
	
	# 发出信号，通知主场景生成预览
	emit_signal("entered_placement_mode")

# 返回动物数据名称 - Lobby.gb
func get_scene_by_type(type_name: String) -> PackedScene:
	if unlocked_animals.has(type_name):
		var scene_path = unlocked_animals[type_name]["scene"]
		return load(scene_path) as PackedScene
	else:
		print("警告：GameManager 找不到类型为 ", type_name, " 的场景！")
		return null
