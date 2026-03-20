extends Control

@export var slot: PackedScene

@onready var collection_ui: Control = $"."
@onready var scroll_container = $ScrollContainer
@onready var grid_container = $ScrollContainer/GridContainer


@onready var frame: Control = $Frame
@onready var show_btn: Button = $Show
@onready var hide_btn: Button = $Hide

# 背景框参数
var full_height: float = 1080.0 # 全屏高度
var mini_height: float = 210.0  # 缩小后的高度
var anim_speed: float = 1     # 动画持续时间
# Container参数
var scr_full_height: float = 900.0 # 全屏高度
var scr_full_y: float = 100.0 # 全屏y高度
var scr_mini_height: float = 185.0 # 缩小后的高度
var scr_mini_y: float = 882.0 # 缩小后的y高度

var current_unlocked_list = GameManager.unlocked_animals.keys()

var min_menu = false


func _ready():
	# 设置初始状态：全屏
	frame.size.y = mini_height
	show_btn.visible = true
	hide_btn.visible = false
	
	# 模拟从 GameManager 获取已解锁的动物列表
	refresh_collection(current_unlocked_list)


func refresh_collection(animal_list: Array):
	# 先清空现有的所有格子，防止重复生成
	for child in grid_container.get_children():
		child.queue_free()
	
	for animal_name in animal_list:
		# --- 核心改进：检测是否解锁 ---
		# 从 GameManager 的字典中获取该动物的数据
		var animal_data = GameManager.unlocked_animals.get(animal_name)
		
		# 如果找不到该动物数据，或者 unlocked 为 false，则跳过本次循环
		if animal_data == null or animal_data.get("unlocked", false) == false:
			continue # 跳过，不生成这个 Slot
		
		# 3. 只有解锁了，才实例化新格子
		var new_slot = slot.instantiate()
		grid_container.add_child(new_slot)
		new_slot.display_animal(animal_name)
	
	# 水平放置滚动条
	grid_container.columns = current_unlocked_list.size()




func _on_hide_pressed() -> void:
	# 按钮状态切换
	hide_btn.visible = false
	
	grid_container.visible = false
	
	_mini_container() #最小化图标容器
	
	# 缩小动画：从 1080px 变到 190px
	var tween = create_tween().set_parallel(true)
	tween.tween_property(frame, "size:y", mini_height, anim_speed)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(anim_speed - 0.3).timeout
	grid_container.visible = true
	show_btn.visible = true

func _on_show_pressed() -> void:
	# 按钮状态切换
	show_btn.visible = false

	grid_container.visible = false
	
	_full_container() #最大化图标容器
	
	# 放大动画：从 190px 变回 1080px
	var tween = create_tween().set_parallel(true)
	tween.tween_property(frame, "size:y", full_height, anim_speed)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(anim_speed - 0.3).timeout
	grid_container.visible = true
	hide_btn.visible = true


func _full_container():
	scroll_container.size.y = scr_full_height
	scroll_container.position.y = scr_full_y
	
	grid_container.size_flags_vertical = SIZE_EXPAND
	
	grid_container.columns = 4

func _mini_container():
	scroll_container.size.y = scr_mini_height
	scroll_container.position.y = scr_mini_y
	
	grid_container.size_flags_vertical = SIZE_SHRINK_CENTER
	
	grid_container.columns = current_unlocked_list.size()


# 开始放置动物时 隐藏/显示菜单 动画
func hide_menu_smooth():
	var tween = create_tween().set_parallel(true)
	if show_btn.visible:
		min_menu = true
		show_btn.visible = false
		tween.tween_property(grid_container, "modulate:a", 0, anim_speed)
		tween.tween_property(collection_ui, "position:y", 200, anim_speed)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		hide_btn.visible = false
		tween.tween_property(grid_container, "modulate:a", 0, anim_speed)
		tween.tween_property(collection_ui, "position:y", 1080, anim_speed)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func show_menu_smooth():
	var tween = create_tween().set_parallel(true)
	if min_menu:
		show_btn.visible = true
		tween.tween_property(grid_container, "modulate:a", 1, anim_speed - 0.2)
		tween.tween_property(collection_ui, "position:y", 0, anim_speed)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		hide_btn.visible = true
		tween.tween_property(grid_container, "modulate:a", 1, anim_speed - 0.2)
		tween.tween_property(collection_ui, "position:y", 0, anim_speed)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
	await get_tree().create_timer(anim_speed - 0.8).timeout
	min_menu = false
