extends Control

@onready var stamina_label: Label = $ButtonSet/Stamina
@onready var progress_bar = $DailyProgress/ProgressBar
@onready var status_label: RichTextLabel = $DailyProgress/ProgressBar/StatusLabel
@onready var score_this_round: RichTextLabel = $DailyProgress/ProgressBar/ScoreThisRound
@onready var play_again: Button = $ButtonSet/PlayAgain
@onready var button_set: Control = $ButtonSet
@onready var daily_progress: Control = $DailyProgress
@onready var mystery_animal: Control = $DailyProgress/MysteryAnimal
@export var title: Label
@export var sub_title: Label


# 对局结束后总控制器
func update_interface():
	button_set.visible = false
	
	_play_score_animation()
	_check_total_score()
	
	_update_stamina_ui()
	SaveManager.save_stats_only()


func _play_score_animation():
	progress_bar.max_value = GameManager.daily_target_score
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
	
	# 让进度条的 value 属性在 3 秒内从当前值变到 end_val
	# .set_trans(Tween.TRANS_SINE) 可以让动画更平滑（先快后慢）
	tween.tween_property(progress_bar, "value", end_val, 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 4. 关键：同步更新文字
	# 我们利用每一个物理帧更新时，将进度条当前的实时数值同步给 Label
	tween.parallel().tween_method(_update_label_text, start_val, end_val, 3)
	
	# 5. 动画结束后更新 GameManager 的数据，为下次累加做准备
	tween.finished.connect(func(): 
		GameManager.clear_score()
		)

# 专门更新文字的辅助函数
func _update_label_text(current_animated_val: int):
	var format_string = "$$$ [shake rate=15.0 level=8][color=#69EAFF]%d[/color][/shake] / %d to Unlock\nToday's Mystery Animal"
	# 按顺序传入：当前动画数值、GameManager 中的目标分数
	status_label.text = format_string % [current_animated_val, GameManager.daily_target_score]
	# 每次数字变动，让整个 Label 稍微放大一点再缩回去
	var t = create_tween()
	t.tween_property(status_label, "scale", Vector2(1.3, 1.3), 0.05)
	t.tween_property(status_label, "scale", Vector2(1.0, 1.0), 0.05)

# 结算每日奖励
func _check_total_score():
	GameManager.daily_score = GameManager.daily_score + GameManager.current_score
	print(GameManager.daily_score)
	if(GameManager.daily_score >= GameManager.daily_target_score):
		if(!GameManager.daily_unlock):
			await get_tree().create_timer(4).timeout
			progress_bar.visible = false
			sub_title.visible = false
			title.text = String("Today's Special")
			_show_buttonset_and_cal_stamina(3)
		
			mystery_animal.unlockNewAnimal()
		else:
			title.text = String("Tomorrow's\nMystery Animal")
			progress_bar.visible = false
			sub_title.visible = false
			mystery_animal.tmr_counter()
			_show_buttonset_and_cal_stamina(1)

	else:
		_show_buttonset_and_cal_stamina(4)

# 控制“再玩一次”按钮显示 根据今日体力
func _show_buttonset_and_cal_stamina(delay_time: int):
	button_set.visible = false
		
	await get_tree().create_timer(delay_time).timeout
	button_set.visible = true
	play_again.visible = true

func _update_stamina_ui():
	var stamina = GameManager.daily_stamina
	match stamina:
		1:
			play_again.text = "Play Again"
			stamina_label.text = "Last Voucher: 🎫"
		0:
			play_again.text = "Watch Ads\nPlay Again"
			stamina_label.text = "More Free Vouchers 🎫 Tomorrow"
		_:
			play_again.text = "Play Again"
			# 默认情况，适用于体力超过2点
			stamina_label.text = "Vouchers Left: " + "🎫".repeat(stamina)

# Buttons
func _on_lobby_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Lobby.tscn")

func _on_play_again_pressed() -> void:
	if(GameManager.daily_stamina > 0):
		GameManager.daily_stamina -= 1;
		get_tree().change_scene_to_file("res://Levels/Board.tscn")
	else:
		get_tree().change_scene_to_file("res://Levels/Ads.tscn")
