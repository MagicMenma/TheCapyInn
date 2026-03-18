extends Control

@export var slot: PackedScene
@onready var scroll_container = $ScrollContainer
@onready var grid_container = $ScrollContainer/GridContainer


@onready var frame: Control = $Frame
@onready var show_btn: Button = $Show
@onready var hide_btn: Button = $Hide

# 背景框参数
var full_height: float = 1080.0 # 全屏高度
var mini_height: float = 190.0  # 缩小后的高度
var anim_speed: float = 1     # 动画持续时间
# Container参数
var scr_full_height: float = 900.0 # 全屏高度
var scr_full_y: float = 100.0 # 全屏y高度
var scr_mini_height: float = 174.0 # 缩小后的高度
var scr_mini_y: float = 900.0 # 缩小后的y高度

var current_unlocked_list = GameManager.unlocked_animals.keys()

func _ready():
	# 设置初始状态：全屏
	frame.size.y = mini_height
	show_btn.visible = true
	hide_btn.visible = false
	
	# 模拟从 GameManager 获取已解锁的动物列表
	refresh_collection(current_unlocked_list)
	# 水平放置滚动条
	grid_container.columns = current_unlocked_list.size()


func refresh_collection(animal_list: Array):
	# 先清空现有的所有格子，防止重复生成
	for child in grid_container.get_children():
		child.queue_free()
	
	# 2. 根据数组长度，灵活生成 Slot
	for animal_name in animal_list:
		# 实例化一个新格子
		var new_slot = slot.instantiate()
		
		# 将格子添加到 GridContainer
		grid_container.add_child(new_slot)
		
		new_slot.display_animal(animal_name)




func _on_hide_pressed() -> void:
	# 按钮状态切换
	hide_btn.visible = false
	
	grid_container.visible = false
	
	_mini_container() #最小化图标容器
	
	# 缩小动画：从 1080px 变到 190px
	var tween = create_tween()
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
	var tween = create_tween()
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
