extends Control

@export var CollectionOfPlayer: Collection
@onready var lobby: Control = $Lobby
@onready var edit: Control = $Edit



@onready var placement_layer: Control = $PlacementLayer # 用于接收点击
var mouse_ghost: TextureButton = null # 存储预览实例


func _ready() -> void:
	
	GameManager.entered_placement_mode.connect(_on_placement_started)


#各个主要功能视图设置
func _lobby():
	lobby.visible = true
	edit.visible = false

func _edit():
	lobby.visible = false
	edit.visible = true

func _on_placement_started():
	# 1. 关闭 CollectionUI
	#$CollectionUI.hide_menu_smooth() 
	
	# 2. 生成动物预览
	mouse_ghost = GameManager.placing_scene.instantiate()
	# 设置为半透明
	mouse_ghost.modulate.a = 0.5 
	
	add_child(mouse_ghost)
	# 开启放置层的输入接收
	placement_layer.visible = true


func _process(_delta):
	# 让预览跟随鼠标
	if mouse_ghost:
		# 让预览跟随鼠标
		mouse_ghost.global_position = get_global_mouse_position()
		
		var touch_pos = get_global_mouse_position()
		var offset = Vector2(-75, -150) 
		mouse_ghost.global_position = touch_pos + offset
		
		# 检测碰撞
		if is_position_valid():
			mouse_ghost._placeable()
		else:
			mouse_ghost._no_placeable()

func is_position_valid() -> bool:
	# 获取 mouse_ghost 下面的 Area2D 节点
	var area = mouse_ghost.get_node("Area2D")
	# 检查当前是否有重叠的其他 Area
	var overlaps = area.get_overlapping_areas()
	# 如果重叠列表不为空，说明撞到其他动物了，返回 false
	return overlaps.size() == 0

func _input(event):
	# 监听点击逻辑
	if mouse_ghost == null: return
	
	# A. 确定放置 (左键)
	if event.is_action_released("mouse_left"):
		_confirm_placement()
		
	# B. 取消放置 (右键)
	if event.is_action_released("mouse_right"):
		_cancel_placement()


func _confirm_placement():
	# TODO: 这里需要加入合法性检测（比如是否碰撞到墙壁）
	
	if is_position_valid():
		# 1. 获取当前预览的位置
		var final_position = mouse_ghost.global_position
		# 2. 彻底删除预览 (Ghost)
		mouse_ghost.free()
		mouse_ghost = null
		# 3. 实例化一个全新的“实体”动物
		# 这里使用 GameManager 存储的当前选中的场景资源
		var new_animal = GameManager.placing_scene.instantiate()
		# 4. 设置属性
		new_animal.global_position = final_position
		# 5. 添加到场景树
		add_child(new_animal)
		# 6. 更新库存并结束放置模式
		GameManager.unlocked_animals[GameManager.current_placing_animal_id]["count"] -= 1
	

func _cancel_placement():
	if mouse_ghost:
		mouse_ghost.queue_free()
		mouse_ghost = null
	# 重新打开菜单
	#$CollectionUI.show_menu_smooth()


func _on_back_pressed() -> void:
	_lobby()

func _on_edit_pressed() -> void:
	_edit()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Board.tscn")
