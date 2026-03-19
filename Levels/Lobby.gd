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
		mouse_ghost.global_position = get_global_mouse_position()

func _input(event):
	# 监听点击逻辑
	if mouse_ghost == null: return
	
	# A. 确定放置 (左键)
	if event.is_action_pressed("mouse_left"):
		_confirm_placement()
		
	# B. 取消放置 (右键)
	if event.is_action_pressed("mouse_right"):
		_cancel_placement()


func _confirm_placement():
	# TODO: 这里需要加入合法性检测（比如是否碰撞到墙壁）
	
	# 1. 实体化
	mouse_ghost.modulate.a = 1.0

	# 2. 从“手中”销毁引用
	mouse_ghost = null
	# 3. 扣除库存
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
