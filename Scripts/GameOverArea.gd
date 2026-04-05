extends Area2D

# 1. 定义一个自定义信号
signal overflow_occurred

@onready var check_timer = $CheckTimer
@onready var collision_shape = $CollisionShape2D # 修正变量名规范

func _ready():
	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	check_timer.timeout.connect(_on_game_over_triggered)

func _on_body_entered(body):
	if body is RigidBody2D:
		# 如果检测区域内没有计时在运行，就开始计时
		if check_timer.is_stopped():
			check_timer.start()

func _on_body_exited(_body):
	# 检查区域内是否还有其他动物
	var overlapping_bodies = get_overlapping_bodies()
	var has_animals = overlapping_bodies.any(func(b): return b is RigidBody2D)
	
	# 如果区域空了，停止计时
	if not has_animals:
		check_timer.stop()

func _on_game_over_triggered():
	# 获取区域内所有物体
	var overlapping_bodies = get_overlapping_bodies()
	var is_stable_overflow = false
	
	for body in overlapping_bodies:
		if body is RigidBody2D:
			# --- 核心判定逻辑 ---
			# 1. 检查线速度 (linear_velocity) 的长度
			# 2. 如果速度小于一个很小的值（例如 10 像素/秒），说明它堆积在这里了
			if body.linear_velocity.length() < 8.0:
				is_stable_overflow = true
				break
	
	if is_stable_overflow:
		# 情况 1：确实堆积了，触发失败
		_execute_game_over()
	else:
		# 情况 2：物体只是在经过，或者还在动。
		# 打印一个调试信息，重新开启计时器，给玩家一线生机
		print("⚠️ 检测到物体，但仍在移动中... 延长观察时间")
		check_timer.start()

# 提取出的失败执行函数
func _execute_game_over():
	print("❌❌❌ 游戏失败！物体稳定溢出！❌❌❌")
	collision_shape.set_deferred("disabled", true) # 使用 set_deferred 修改物理属性更安全
	
	overflow_occurred.emit()
	GameManager.game_over = true
	
	# 停止生成器
	var spawner = get_tree().root.find_child("AnimalSpawner", true, false)
	if spawner:
		spawner.stopSpawning = true
