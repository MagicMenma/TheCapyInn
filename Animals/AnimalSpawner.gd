extends Node2D

# 在检查器中拖入你想要生成的动物场景
@export var animal_scenes: Array[PackedScene] = []
# 生成间隔（秒）
@export var spawn_interval: float = 0.75
@export var min_interval: float = 0.1
# 左右随机生成的范围（相对于生成器中心）
@export var spawn_width: float = 300.0

var timer: Timer
var stopSpawning = false

func _ready():
	# 对局开始前的等待时间
	await get_tree().create_timer(3).timeout
	
	# 1. 创建并配置计时器
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.autostart = true
	# 2. 连接信号：当计时器到时间时，执行生成函数
	timer.timeout.connect(_spawn_animal)
	timer.start()

func _spawn_animal():
	if animal_scenes.size() == 0 || stopSpawning == true:
		return
	
	# 3. 随机选择一种动物
	var random_index = randi() % animal_scenes.size()
	var animal_instance = animal_scenes[random_index].instantiate()
	
	# 4. 计算随机位置
	var random_x = randf_range(-spawn_width / 2, spawn_width / 2)
	animal_instance.position = Vector2(random_x, -50) # 这里的坐标是相对于 Spawner 的
	
	# 5. 将动物添加到场景树中
	add_child(animal_instance)


func _on_difficulty_timer_timeout() -> void:
	# 每 5 秒提升一次难度
	if spawn_interval > min_interval:
		spawn_interval -= 0.05
		timer.wait_time = spawn_interval
		print("难度提升！当前间隔：", spawn_interval)
