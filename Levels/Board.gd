extends Control

@onready var game_over_ui = $MainCanvas/GameOverInterface
@onready var score_label = $MainCanvas/ScoreLabel
@onready var noren: Panel = $Noren

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_over = false
	_update_score_display(GameManager.current_score)
	GameManager.score_changed.connect(_on_game_manager_score_changed)
	
	# 1. 初始检测
	_check_and_toggle_noren()
	# 2. 监听窗口大小变化（防止玩家在网页端手动调整浏览器窗口大小）
	get_tree().root.size_changed.connect(_check_and_toggle_noren)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _check_and_toggle_noren():
	# 获取视口的实际尺寸
	var view_size = get_viewport().get_visible_rect().size
	# 计算纵横比 (高 / 宽)
	# 手机通常是长条状，所以比值会大于 1.5 (16:9 约等于 1.77)
	var aspect_ratio = view_size.y / view_size.x
	# 如果比值大于 1.3，通常意味着是竖屏模式（手机或窄窗口）
	if aspect_ratio > 1.3:
		noren.visible = true
		print("检测到移动端比例，暖帘已开启")
		noren.visible = true
		noren.modulate.a = 0 # 初始透明
		noren.position.y = -50 # 初始位置稍高
		var tween = create_tween().set_parallel(true)
		tween.tween_property(noren, "modulate:a", 1.0, 1)
		tween.tween_property(noren, "position:y", 0.0, 2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		noren.visible = false
		print("检测到宽屏/网页比例，暖帘已隐藏")




func _on_game_over_area_overflow_occurred() -> void:
	# 显示 UI + 更新 GameOverInterface
	game_over_ui.visible = true
	game_over_ui.update_interface()
	
# 处理分数区域
# 这是一个内部处理函数，专门负责更新文字
func _update_score_display(new_score):
	if score_label:
		score_label.text = "$$$: " + str(new_score)
# 当信号触发时执行
func _on_game_manager_score_changed(new_score):
	_update_score_display(new_score)
