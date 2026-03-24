extends Control

# 在检查器中拖入你想要生成的动物场景
@export var animal_scenes: Array[PackedScene] = []
@onready var label: RichTextLabel = $Label
@onready var mystery_animal: Sprite2D = $MysteryAnimal
@onready var img: Sprite2D = $img

func _ready() -> void:
	mystery_animal.visible = true
	img.visible = false
	label.visible = false

func unlockNewAnimal():
	if animal_scenes.is_empty():
		print("没有可解锁的动物了！")
		return
	
	# 0. 准备工作：隐藏 img，显示神秘剪影，隐藏文字
	img.visible = false
	mystery_animal.visible = true
	label.visible = false
	mystery_animal.scale = Vector2(0.7, 0.7)
	
	_animation_for_mysImg()
	
	# 1. 获取要解锁的场景（列表第一个）
	var target_scene = animal_scenes[0]
	var temp_instance = target_scene.instantiate()
	
	# 2. 获取动物的真实 ID 
	# 假设你的动物脚本里有变量 animal_type = "Capybara_Golden"
	# 或者直接根据场景文件名来判断
	var animal_id = ""
	if "animal_type" in temp_instance:
		animal_id = temp_instance.animal_type
	else:
		# 如果脚本里没写，就通过场景文件名截取（例如 Capybara_GoldenPLB.tscn -> Capybara_Golden）
		animal_id = target_scene.resource_path.get_file().get_basename().replace("PLB", "")
	
	animal_id = animal_id.replace(" ", "_")
	# 3. --- 核心解锁逻辑 ---
	if GameManager.unlocked_animals.has(animal_id):
		# 修改字典里的状态
		GameManager.unlocked_animals[animal_id]["unlocked"] = true
		# 既然解锁了，别忘了保存一次存档，防止玩家刷新网页后又锁上了
		SaveManager.save_stats_only() 

	# 4. 提取图片并显示（根据你之前的逻辑）
	var img_node = temp_instance.get_node_or_null("img")
	if img_node:
		img.texture = img_node.texture
	_filp(2)
	
	# 清理内存
	temp_instance.queue_free()
	
	await get_tree().create_timer(2.5).timeout
	label.visible = true
	label.text = "[shake rate=20.0 level=10][u]" + animal_id.capitalize() + "[/u][/shake] Unlocked!"
	
	GameManager.daily_unlock = true

func _animation_for_mysImg():
	# --- 第一阶段：蓄力 (1.5s) ---
	var tween_prep = create_tween().set_parallel(true)
	# 变大
	tween_prep.tween_property(mystery_animal, "scale", Vector2(1.5, 1.5), 2.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT_IN)
	
	# 剧烈抖动 (手动用一个循环或者循环 Tween)
	var shake_tween = create_tween().set_loops(50)
	shake_tween.tween_property(mystery_animal, "position:x", mystery_animal.position.x + 10, 0.05)
	shake_tween.tween_property(mystery_animal, "position:x", mystery_animal.position.x - 10, 0.05)
	
	# 等待 1.5s 蓄力完成
	await get_tree().create_timer(2.5).timeout
	
	# --- 第二阶段：爆发 (砰！) ---
	shake_tween.kill() # 停止抖动
	mystery_animal.visible = false
	img.visible = true
	# 给 img 一个反弹效果
	img.scale = Vector2(0.5, 0.5)
	var tween_pop = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween_pop.tween_property(img, "scale", Vector2.ONE, 0.5)

func _filp(flip_speed: int):
	# 等待 2 到 4 秒
	var wait_time = randf_range(flip_speed, flip_speed * 2)
	await get_tree().create_timer(wait_time).timeout
	# 执行翻转
	img.flip_h = not img.flip_h
	img.scale.x *= -1
	
	#hop效果
	var tween = create_tween().set_parallel(true)
	# 挤压效果
	tween.tween_property(img, "scale", Vector2(0.8, 1.2), 0.15)
	var fall_tween = tween.chain().set_parallel(true)
	fall_tween.tween_property(img, "scale", Vector2(1.2, 0.8), 0.15)
	tween.chain().tween_property(img, "scale", Vector2.ONE, 0.1)
	# 递归调用，循环往复
	_filp(flip_speed)


func tmr_counter():
	img.visible = false
	mystery_animal.visible = true
	label.visible = true
	start_countdown()

# 循环更新倒计时的函数
func start_countdown():
	var remaining = get_seconds_until_midnight()
	print(remaining)
	if remaining > 0:
		var time_str = format_time(remaining)
		label.text = "[color=#69EAFF]%s[/color]\nCome back then for a new challenge!" % time_str
		
		# 每秒更新一次
		await get_tree().create_timer(1.0).timeout
		start_countdown()
	else:
		# 0 点刷新状态
		label.text = "New Animal Available Now! Refresh to Play."

# 计算距离明天 0 点还有多少秒
func get_seconds_until_midnight() -> int:
	var now = Time.get_datetime_dict_from_system()
	# 计算今天的总秒数
	var current_seconds = (now.hour * 3600) + (now.minute * 60) + now.second
	# 一天的总秒数是 86400
	return 86400 - current_seconds

# 格式化秒数为 HH:MM:SS
func format_time(seconds: int) -> String:
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]
