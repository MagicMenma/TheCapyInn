# TimeUtils.gd
extends Node

# 自定义回复时间（秒），比如 10 分钟 = 600
@export var REGEN_TIME: int = 100 
var current_timer: float = 0.0
var is_running: bool = false

func _process(delta):
	if is_running:
		current_timer -= delta
		if current_timer <= 0:
			_on_regen_complete()

# 外部调用此函数开始回复（例如在消耗体力后）
func start_regen():
	if not is_running:
		current_timer = REGEN_TIME
		is_running = true
		print("开始恢复体力倒计时...")

# 内部处理：回复体力并重置或停止
func _on_regen_complete():
	# 只有在体力不满时才增加（假设上限是 3）
	if GameManager.daily_stamina < 3:
		GameManager.daily_stamina += 1
		SaveManager.save_stats_only() # 别忘了存档
		
		# 如果还没满，继续下一轮计时
		if GameManager.daily_stamina < 3:
			current_timer = REGEN_TIME
		else:
			is_running = false
			current_timer = 0
	else:
		is_running = false

# 仅返回格式化后的时间字符串，例如 "09:45"
func get_countdown_text() -> String:
	if not is_running:
		return "FULL" # 或者返回 "00:00"
		
	var seconds = int(current_timer)
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]
