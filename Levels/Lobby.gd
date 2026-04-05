extends Control

@export var CollectionOfPlayer: Collection
@onready var lobby: Control = $Lobby
@onready var edit: Control = $Edit
@onready var build: Button = $Lobby/Build
@onready var shop: Button = $Lobby/Shop
@onready var collection_ui: Control = $Edit/CollectionUi
@onready var stamina: Label = $Lobby/TopPlayerInfo/Stamina
@onready var stamina_counter: Label = $Lobby/TopPlayerInfo/StaminaCounter
@onready var player_money: RichTextLabel = $Lobby/TopPlayerInfo/PlayerMoney
@onready var back: Button = $Edit/Back
@onready var tutorial_overlay: Control = $TutorialOverlay


@onready var placement_layer: Control = $PlacementLayer # 用于接收点击
var mouse_ghost: TextureButton = null # 存储预览实例


func _ready() -> void:
	_check_toturial_state()
	
		# 从独立脚本获取数据并生成
	var saved_animals = SaveManager.load_placed_animals()
	for data in saved_animals:
		_spawn_saved_animal(data)
	
	GameManager.entered_placement_mode.connect(_on_placement_started)
	
	player_money.text = str(GameManager.player_money)
	
	#if GameManager.toturial_state == 1:
		#tutorial_overlay.visible = true


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
			if is_over_bin():
				mouse_ghost._on_bin()
			else:
				mouse_ghost._no_placeable()
	
	# 实时更新体力UI
	_update_stamina_ui()

func _check_toturial_state():
	if GameManager.toturial_state == 0:
		build.visible = false
		shop.visible = false
	if GameManager.toturial_state == 1:
		build.visible = true
		shop.visible = false
	if GameManager.toturial_state == 2:
		build.visible = true
		shop.visible = true

func _on_placement_started():
	# 1. 关闭 CollectionUI
	collection_ui.hide_menu_smooth()
	back.visible = false
	
	# 2. 生成动物预览
	mouse_ghost = GameManager.placing_scene.instantiate()
	# 设置为半透明
	mouse_ghost.modulate.a = 0.5 
	
	add_child(mouse_ghost)
	# 开启放置层的输入接收
	placement_layer.visible = true

# 从存档生成可放置的动物
func _spawn_saved_animal(data: Dictionary):
	var animal_scene = GameManager.get_scene_by_type(data["type"])
	if animal_scene:
		var new_animal = animal_scene.instantiate()
		# --- 先添加到层级 ---
		placement_layer.add_child(new_animal)
		# --- 此时节点已在场景树中，可以安全地赋值全局坐标 ---
		new_animal.global_position = Vector2(data["pos_x"], data["pos_y"])
		
		new_animal.add_to_group("animalsPLB")
		if lobby.visible:
			new_animal.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event):
	# 监听点击逻辑
	if mouse_ghost == null: return
	
	# A. 确定放置 (左键)
	if event.is_action_released("mouse_left"):
		if is_over_bin():
			_cancel_placement()
			return
		if is_position_valid():
			_confirm_placement()
			return
		
	# B. 取消放置 (右键)
	if event.is_action_released("mouse_right"):
		_cancel_placement()


func is_position_valid() -> bool:
	if mouse_ghost == null: return false
	
	var area = mouse_ghost.get_node("Area2D")
	var overlaps = area.get_overlapping_areas()
	for overlap in overlaps:
		if overlap.collision_layer == 32: # 碰到垃圾桶
			return false # 不合法
	if overlaps.size() > 0: # 碰到其他动物
		return false
	return true

func is_over_bin() -> bool:
	if mouse_ghost == null: return false
	var area = mouse_ghost.get_node("Area2D")
	for overlap in area.get_overlapping_areas():
		if overlap.collision_layer == 32:
			return true
	return false

func _confirm_placement():
	if is_position_valid():
		# 1. 获取当前预览的位置
		var final_global_pos = mouse_ghost.global_position
		# 2. 彻底删除预览 (Ghost)
		mouse_ghost.free()
		mouse_ghost = null
		# 3. 实例化一个全新的“实体”动物
		var new_animal = GameManager.placing_scene.instantiate()
		# 4. 设置属性
		placement_layer.add_child(new_animal)
		new_animal.global_position = final_global_pos
		# 5. 添加到场景树
		new_animal.add_to_group("animalsPLB")
		# 6. 更新库存并结束放置模式
		GameManager.unlocked_animals[GameManager.current_placing_animal_id]["count"] -= 1
		SaveManager.save_animals_only()
		
		collection_ui.show_menu_smooth()
		back.visible = true

func _cancel_placement():
	if mouse_ghost:
		mouse_ghost.free()
		mouse_ghost = null
		
		collection_ui.show_menu_smooth()
		back.visible = true


# 辅助函数：统一控制动物的可点击性
func _set_animals_interactive(active: bool):
	# 获取场景中所有属于该组的动物
	var animals = get_tree().get_nodes_in_group("animalsPLB")
	for animal in animals:
		if active:
			# MOUSE_FILTER_STOP 代表接收并停止点击事件传递
			animal.mouse_filter = Control.MOUSE_FILTER_STOP 
		else:
			# MOUSE_FILTER_IGNORE 代表完全忽略鼠标，点击会穿透到下方
			animal.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _update_stamina_ui():
	stamina.text = str(GameManager.daily_stamina)
	if GameManager.daily_stamina == 3:
		stamina_counter.text = "FULL"
	if GameManager.daily_stamina != 3:
		stamina_counter.text = TimeUtils.get_countdown_text()

#各个主要功能视图设置
func _lobby():
	lobby.visible = true
	edit.visible = false
	_set_animals_interactive(false)

func _edit():
	lobby.visible = false
	edit.visible = true
	_set_animals_interactive(true)

func _on_back_pressed() -> void:
	if mouse_ghost:
		mouse_ghost.queue_free()
		mouse_ghost = null
	_lobby()

func _on_edit_pressed() -> void:
	_edit()

func _on_start_game_pressed() -> void:
	if(GameManager.daily_stamina > 0):
		if GameManager.toturial_state == 0:
			get_tree().change_scene_to_file("res://Levels/BoardTutorial.tscn")
		else:
			GameManager.daily_stamina -= 1;
			# 消耗后立即触发恢复计时
			TimeUtils.start_regen()
			get_tree().change_scene_to_file("res://Levels/Board.tscn")
	else:
		get_tree().change_scene_to_file("res://Levels/Ads.tscn")


func _on_shop_pressed() -> void:
	pass # Replace with function body.
