extends Control

@onready var game_over_ui = $MainCanvas/GameOverInterface
@onready var score_label = $MainCanvas/ScoreLabel
@onready var noren: Panel = $Noren
@onready var tutorial_overlay: Control = $TutorialOverlay

const CAPYBARA_SCENE = preload("res://Animals/Bathing/Capybara.tscn") # 确认你的路径

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_over = false
	_update_score_display(GameManager.current_score)
	GameManager.score_changed.connect(_on_game_manager_score_changed)
	
	toggle_noren()
	_generate_capybara()

func _generate_capybara():
	var screen_rect = get_viewport().get_visible_rect()
	var sw = (screen_rect.size.x - 720) / 2 # 宽屏幕修正值
	var sh = (screen_rect.size.y - 1080) / 2 # 宽高幕修正值
	var default_capybara = [
		{ "type": "Capybara", "pos_x": sw + 227, "pos_y": sh + 385 },
		{ "type": "Capybara", "pos_x": sw + 482, "pos_y": sh + 524 },
		{ "type": "Capybara", "pos_x": sw + 435, "pos_y": sh + 241 }
	]
	for data in default_capybara:
		# 1. 实例化
		var new_capy = CAPYBARA_SCENE.instantiate()
		# 2. 将它添加到场景树中
		$CapybaraLayer.add_child(new_capy)
		new_capy.freeze = true
		# 3. 设置位置
		# 必须在 add_child 之后或同时设置坐标
		new_capy.global_position = Vector2(data["pos_x"], data["pos_y"])


func toggle_noren():
	noren.visible = true
	noren.modulate.a = 0 # 初始透明
	noren.position.y = -80 # 初始位置稍高
	var tween = create_tween().set_parallel(true)
	tween.tween_property(noren, "modulate:a", 1.0, 1)
	tween.tween_property(noren, "position:y", 0.0, 2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_noren():
	noren.modulate.a = 1 # 初始透明
	noren.position.y = 0 # 初始位置稍高
	var tween = create_tween().set_parallel(true)
	tween.tween_property(noren, "position:y", -150, 2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(noren, "modulate:a", 0, 2)

func _on_game_over_area_overflow_occurred() -> void:
	# 显示 UI + 更新 GameOverInterface
	game_over_ui.visible = true
	game_over_ui.update_interface()
	_close_noren()
	
# 处理分数区域
# 这是一个内部处理函数，专门负责更新文字
func _update_score_display(new_score):
	if score_label:
		score_label.text = "$$$: " + str(new_score)

		var tween = create_tween()
		# 按顺序执行tween
		tween.set_parallel(false)
		tween.tween_property(score_label, "scale", Vector2(1.5, 1.5), 0.05)\
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.15)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	
# 当信号触发时执行
func _on_game_manager_score_changed(new_score):
	_update_score_display(new_score)
