extends Node

const SAVE_PATH = "user://player_data.json" # user:// 是 Godot 专门存储存档的路径

func check_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# --- 通用的全量写入函数 (内部使用) ---
func _write_to_disk(full_data: Dictionary):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(full_data))
	file.close()

# --- 仅保存统计数据 (在结算页面调用) ---
func save_stats_only():
	# 1. 先读取现有存档（防止覆盖动物数据）
	var current_data = load_full_data() 
	# 2. 更新统计部分
	current_data["stats"] = {
		"daily_score": GameManager.daily_score,
		"daily_stamina": GameManager.daily_stamina
	}
	# 3. 写回磁盘
	_write_to_disk(current_data)
	print("统计数据已更新，动物数据已保留")

# --- 仅保存动物数据 (在 Lobby 编辑模式调用) ---
func save_animals_only():
	var current_data = load_full_data()
	
	var animals_data = []
	var animals = get_tree().get_nodes_in_group("animalsPLB")
	for animal in animals:
		animals_data.append({
			"type": animal.animal_type,
			"pos_x": animal.global_position.x,
			"pos_y": animal.global_position.y
		})
	
	# 更新动物部分，保留 stats 部分
	current_data["placed_animals"] = animals_data
	
	_write_to_disk(current_data)
	print("动物布局已更新，统计数据已保留")


# 保存功能：需要传入当前所有动物的数组
func save_placed_animals(animals_array: Array):
	var save_data = []
	for animal in animals_array:
		var data = {
			"type": animal.animal_type,
			"pos_x": animal.global_position.x,
			"pos_y": animal.global_position.y
		}
		save_data.append(data)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("数据已保存至本地")
	

# --- 辅助函数：读取完整字典 ---
func load_full_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		# 如果没存档，返回一个基础结构的空字典
		return {"stats": {}, "placed_animals": []}
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data if data is Dictionary else {"stats": {}, "placed_animals": []}


func load_placed_animals() -> Array:
	# 情况 A：如果存档文件存在，读取并解析
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(json_string)
		
		# --- 关键修改点：判断数据类型 ---
		if data is Dictionary and data.has("placed_animals"):
			# 如果是新格式（字典），返回里面的动物列表
			return data["placed_animals"]
		elif data is Array:
			# 为了兼容你之前的旧存档格式（如果是纯数组），也能读出来
			return data
	
	# 情况 B：如果存档不存在，返回“初始宾客”
	print("正在生成初始宾客...")
	var screen_rect = get_viewport().get_visible_rect()
	var sw = (screen_rect.size.x - 720) / 2 # 宽屏幕修正值
	
	var default_guests = [
		{ "type": "Bear", "pos_x": sw + 86, "pos_y": 547 },
		{ "type": "Capybara", "pos_x": sw + 487, "pos_y": 471 },
		{ "type": "Rabbit", "pos_x": sw + 317, "pos_y": 391 }
	]
	save_animals_only()
	return default_guests


func delete_save_placed_animals():
	if FileAccess.file_exists(SAVE_PATH):
		# 使用 DirAccess 来删除物理文件
		var dir = DirAccess.open("user://")
		dir.remove("player_data.json")
		print("存档文件已物理删除")
	else:
		print("没有找到存档文件")
