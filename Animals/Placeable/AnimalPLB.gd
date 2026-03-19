extends TextureButton

@export var animal_type: String = ""
@export var hover_color: Color = Color.WHITE # 高亮颜色
@export_enum("Quick:2", "Mid:4", "Slow:6") var flip_speed: int = 4 # 反转间隔时间

@onready var img: Sprite2D = $img

func _ready():
	_filp()

func _filp():
	# 随机等待 2 到 5 秒
	var wait_time = randf_range(flip_speed, flip_speed * 2)
	await get_tree().create_timer(wait_time).timeout
	# 执行翻转
	img.flip_h = not img.flip_h
	# 递归调用，循环往复
	_filp()
