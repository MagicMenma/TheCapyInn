extends Control

@onready var bg: ColorRect = $ColorRect
@onready var highlight_1: Sprite2D = $Highlight1
@onready var highlight_2: Sprite2D = $Highlight2
@onready var speech: RichTextLabel = $Control/Speech

var is_tutorial_2_triggered: bool = false

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
	"These revenues will help us rebuild the hotel.",
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
	
	var duration = text_content.length() * 0.05
	var tween = create_tween()
	tween.tween_property(speech, "visible_ratio", 1.0, duration)
	
	tween.finished.connect(func():
		await get_tree().create_timer(2.0).timeout
		current_line_index += 1
		_start_next_line()
	)

# --- 这里是你的自定义逻辑控制区 ---

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
	GameManager.toturial_state = 1
	get_tree().call_deferred("change_scene_to_file", "res://Levels/Lobby.tscn")

func _end_tutorial():
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, 0.5)
	fade_tween.finished.connect(queue_free)
