extends Control

@onready var back_btn: TextureButton = $BackBtn
@onready var mute: TextureButton = $Mute
@onready var label: RichTextLabel = $Label
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

@onready var ad_timer: Timer = Timer.new() 

var current_time: int = 15

func _ready():
	# 初始化 Timer
	add_child(ad_timer)
	ad_timer.wait_time = 1.0
	ad_timer.timeout.connect(_on_tick) # 每秒触发一次
	
	play_ads()

func play_ads():
	current_time = 15
	back_btn.visible = false
	_update_label()
	video_stream_player.play()
	ad_timer.start() # 开始倒计时

func _on_tick():
	current_time -= 1
	_update_label()
	if current_time <= 0:
		ad_timer.stop()
		_on_ad_finished()

func _update_label():
	# 使用格式化字符串，安全且整洁
	label.text = "[center]%d s Remain[/center]" % current_time

func _on_ad_finished():
	back_btn.visible = true
	label.visible = false

func _on_mute_toggled(is_pressed: bool):
	if is_pressed:
		video_stream_player.volume = 0
	else:
		video_stream_player.volume = 1

func _on_back_btn_pressed() -> void:
	# 在切换场景前最好确保停止播放
	video_stream_player.stop()
	get_tree().change_scene_to_file("res://Levels/Board.tscn")
