extends Control

@onready var game_over_ui = $MainCanvas/GameOverInterface
@onready var score_label = $MainCanvas/ScoreLabel
@onready var noren: Panel = $Noren

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_over = false
	_update_score_display(GameManager.current_score)
	GameManager.score_changed.connect(_on_game_manager_score_changed)
	
	toggle_noren()


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
# 当信号触发时执行
func _on_game_manager_score_changed(new_score):
	_update_score_display(new_score)
