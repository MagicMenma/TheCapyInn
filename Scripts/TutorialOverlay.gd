extends Control

@onready var bg: ColorRect = $ColorRect
@onready var highlight_1: Sprite2D = $Highlight1
@onready var highlight_2: Sprite2D = $Highlight2
@onready var speech: RichTextLabel = $Control/Speech
@onready var auto_toggle_text: RichTextLabel = $AutoToggle/AutoToggleText


var is_tutorial_2_triggered: bool = false

var is_auto_mode: bool = false # 默认为手动点击模式
var is_typing: bool = false
var current_tween: Tween = null

# 1. 教程对话内容列表
var tutorial_1: Array[String] = [
	"Hello, boss! Since you bought this hot spring inn, this must be your first visit, right?",
	"Don't worry. I'll help you get familiar with how to handle it.",
	"Do you see that pool? Now there are 3 customers taking a bath.",
	"But the hot spring pool can't be overcrowded with customers. You need to 'ask' them to leave.",
	"Now, try to click on the [shake rate=20.0 level=10][color=RED]3 SAME TYPE[/color][/shake] of customer to complete the checkout."
]

var tutorial_2: Array[String] = [
	"Well done! Boss.",
	"You may have noticed that after you have settled a group of guests, your income will be displayed below."
	]

var tutorial_3: Array[String] = [
	"These [shake rate=20.0 level=10]$$$[/shake] will help us rebuild the hotel.",
	"Today's business hours have come to an end. Let's return to the lobby."
	]

var current_line_index: int = 0
var current_tutorial_data: Array[String] = []
var on_tutorial_finished: Callable # 用来存储结束时要执行的函数

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	# 初始启动：播放第一段，结束后“等待玩家操作”
	run_tutorial_sequence(tutorial_1, _on_tutorial_1_finished)

func _process(_delta):
	if GameManager.current_score != 0 and not is_tutorial_2_triggered:
		is_tutorial_2_triggered = true
		self.mouse_filter = Control.MOUSE_FILTER_STOP
		highlight_1.visible = false
		bg.visible = true
		run_tutorial_sequence(tutorial_2, _on_tutorial_2_finished)

# 新增：通用的启动函数
func run_tutorial_sequence(lines: Array[String], callback: Callable):
	current_line_index = 0
	current_tutorial_data = lines
	on_tutorial_finished = callback
	self.modulate.a = 1 # 确保可见
	_start_next_line()

func _start_next_line():
	if current_line_index < current_tutorial_data.size():
		_display_line(current_tutorial_data[current_line_index])
	else:
		# 这段话播完了，执行回调
		if on_tutorial_finished.is_valid():
			on_tutorial_finished.call()

func _display_line(text_content: String):
	speech.text = text_content
	speech.visible_ratio = 0
	is_typing = true
	
	if current_tween: current_tween.kill() # 清除旧动画
	current_tween = create_tween()
	
	var duration = text_content.length() * 0.05
	current_tween.tween_property(speech, "visible_ratio", 1.0, duration)
	
	current_tween.finished.connect(func():
		is_typing = false
		# 如果是自动模式，等待后自动下一行
		if is_auto_mode:
			await get_tree().create_timer(2.0).timeout
			# 再次检查模式，防止等待期间玩家切换了模式
			if is_auto_mode: _next_step()
	)

# 处理“下一步”
func _next_step():
	if is_typing:
		# 状态 1：正在打字 -> 瞬间显示全文
		if current_tween: current_tween.kill()
		speech.visible_ratio = 1.0
		is_typing = false
	else:
		# 状态 2：已经显示全文 -> 播下一句
		current_line_index += 1
		_start_next_line()

func _input(event):
	# 只有在教程激活且不是自动模式时，才响应点击（或者自动模式下允许手动加速）
	if event.is_action_pressed("mouse_left"):
		# 如果当前正在播放动画，或者等待下一句，点击都会触发 _next_step
		_next_step()


# --- 自定义逻辑控制区 ---

func _on_tutorial_1_finished():
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	bg.visible = false
	highlight_1.visible = true

func _on_tutorial_2_finished():
	bg.visible = false
	highlight_2.visible = true
	await get_tree().create_timer(2).timeout
	run_tutorial_sequence(tutorial_3, _on_tutorial_3_finished)

func _on_tutorial_3_finished():
	GameManager.toturial_state = 2
	GameManager.player_money = 100
	GameManager.current_score = 0
	get_tree().call_deferred("change_scene_to_file", "res://Levels/Lobby.tscn")

func _end_tutorial():
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, 0.5)
	fade_tween.finished.connect(queue_free)


func _on_auto_toggle_toggled(toggled_on: bool) -> void:
	is_auto_mode = toggled_on
	if is_auto_mode:
		auto_toggle_text.text = "Playing"
		if not is_typing:
			_next_step()
	else:
		auto_toggle_text.text = "Auto"
