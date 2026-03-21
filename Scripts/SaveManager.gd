extends Node

const SAVE_PATH = "user://player_data.json" # user:// 是 Godot 专门存储存档的路径

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

# 加载功能：返回保存的原始数据（数组）
func load_placed_animals() -> Array:
	# 情况 A：如果存档文件存在，读取存档
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		var data = JSON.parse_string(json_string)
		if data is Array:
			return data
	# 情况 B：如果存档不存在（第一次进游戏或刚重置），返回“初始宾客”
	print("正在生成初始宾客...")
	var screen_rect = get_viewport().get_visible_rect() #获取屏幕宽度
	var sw = screen_rect.size.x  
	sw = (sw - 720) / 2  								#宽屏幕修正值
	var default_guests = [
		{ "type": "Bear", "pos_x": sw + 86, "pos_y": 547 },
		{ "type": "Capybara", "pos_x": sw + 487, "pos_y": 471 },
		{ "type": "Rabbit", "pos_x": sw + 317, "pos_y": 391 }
	]
	return default_guests

func delete_save_placed_animals():
	if FileAccess.file_exists(SAVE_PATH):
		# 使用 DirAccess 来删除物理文件
		var dir = DirAccess.open("user://")
		dir.remove("placed_animals.json")
		print("存档文件已物理删除")
	else:
		print("没有找到存档文件")
