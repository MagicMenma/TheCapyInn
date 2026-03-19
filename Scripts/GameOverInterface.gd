extends Control

@onready var stamina_label: Label = $ButtonSet/PlayAgain/Stamina
@onready var progress_bar = $ProgressBar
@onready var status_label: RichTextLabel = $ProgressBar/StatusLabel
@onready var ads_again: Button = $ButtonSet/AdsAgain
@onready var play_again: Button = $ButtonSet/PlayAgain
@onready var button_set: Control = $ButtonSet
@onready var score_this_round: RichTextLabel = $ProgressBar/ScoreThisRound


# 对局结束后总控制器
func update_interface():
	calculate_daily_stamina()
	update_stamina_ui()
	play_score_animation()


func play_score_animation():
	# 1. 初始状态设置
	var start_val = GameManager.daily_score
	var added_val = GameManager.current_score
	var end_val = start_val + added_val
	
	score_this_round.text = "+ $" + str(added_val)
	
	# 先把进度条和文字设为起始状态
	progress_bar.value = start_val
	_update_label_text(start_val)
	
	# 2. 延迟 0.5s 开始
	await get_tree().create_timer(0.8).timeout
	
	# 3. 创建 Tween 动画
	var tween = create_tween()
	
	# 让进度条的 value 属性在 1.5 秒内从当前值变到 end_val
	# .set_trans(Tween.TRANS_SINE) 可以让动画更平滑（先快后慢）
	tween.tween_property(progress_bar, "value", end_val, 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 4. 关键：同步更新文字
	# 我们利用每一个物理帧更新时，将进度条当前的实时数值同步给 Label
	tween.parallel().tween_method(_update_label_text, start_val, end_val, 3)
	
	# 5. 动画结束后更新 GameManager 的数据，为下次累加做准备
	tween.finished.connect(func(): 
		GameManager.daily_score = end_val
		GameManager.clear_score()
		)

# 专门更新文字的辅助函数
func _update_label_text(current_animated_val: int):
	var format_string = "$$$ [shake rate=15.0 level=8][color=#69EAFF]%d[/color][/shake] / %d to Unlock\nToday's Mystery Animal"
	status_label.text = format_string % [current_animated_val, progress_bar.max_value]
	# 每次数字变动，让整个 Label 稍微放大一点再缩回去
	var t = create_tween()
	t.tween_property(status_label, "scale", Vector2(1.3, 1.3), 0.05)
	t.tween_property(status_label, "scale", Vector2(1.0, 1.0), 0.05)


# 控制“再玩一次”按钮显示 根据今日体力
func calculate_daily_stamina():
	button_set.visible = false
		
	await get_tree().create_timer(4).timeout
	button_set.visible = true
	if GameManager.daily_stamina > 0:
		play_again.visible = true
		ads_again.visible = false
	else:
		play_again.visible = false
		ads_again.visible = true

func update_stamina_ui():
	var stamina = GameManager.daily_stamina
	match stamina:
		1:
			stamina_label.text = "Last Voucher: 🎫"
		0:
			stamina_label.text = ""
		_:
			# 这里的 _ 是默认情况，以防体力超过2点
			stamina_label.text = "Vouchers Left: " + "🎫".repeat(stamina)

# Buttons
func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Lobby.tscn")

func _on_ads_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Board.tscn")

func _on_play_again_pressed() -> void:
	GameManager.daily_stamina -= 1;
	get_tree().change_scene_to_file("res://Levels/Board.tscn")
