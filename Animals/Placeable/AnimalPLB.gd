extends TextureButton

@export var animal_type: String = ""
@export var hover_color: Color = Color.WHITE # 高亮颜色
@export_enum("Quick:2", "Mid:4", "Slow:6") var flip_speed: int = 4 # 反转间隔时间

@onready var animal_plb: TextureButton = $"."
@onready var img: Sprite2D = $img
@onready var area_2d: Area2D = $Area2D

var is_ready_to_pick: bool = false

func _ready():
	_filp()
	
	is_ready_to_pick = false
	# 延迟0.5 秒，等玩家的手指抬起后，再开启“可拿起”状态
	await get_tree().create_timer(1).timeout
	is_ready_to_pick = true
	

func _filp():
	# 随机等待 2 到 5 秒
	var wait_time = randf_range(flip_speed, flip_speed * 2)
	await get_tree().create_timer(wait_time).timeout
	# 执行翻转
	img.flip_h = not img.flip_h
	area_2d.scale.x *= -1
	_hop()
	# 递归调用，循环往复
	_filp()

func _hop():
	# 创建一个补间动画
	var tween = create_tween().set_parallel(true)
	
	# 挤压效果
	tween.tween_property(img, "scale", Vector2(0.4, 0.8), 0.15)
	
	var fall_tween = tween.chain().set_parallel(true)
	fall_tween.tween_property(img, "scale", Vector2(0.8, 0.4), 0.15)
	
	tween.chain().tween_property(img, "scale", Vector2(0.616, 0.616), 0.1)

# 碰撞检测 - 边框颜色
func _placeable():
	img.material.set_shader_parameter("active", true)
	img.material.set_shader_parameter("line_color", Color(0.434, 0.836, 0.372, 1.0))

func _no_placeable():
	img.material.set_shader_parameter("active", true)
	img.material.set_shader_parameter("line_color", Color(0.836, 0.372, 0.372, 1.0))

func _is_placed():
	img.material.set_shader_parameter("active", false)

# 鼠标进入检测
func _on_mouse_entered():
	# 悬停时稍微变大，给玩家“我可以被点”的反馈
	create_tween().tween_property(animal_plb, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited():
	create_tween().tween_property(animal_plb, "scale", Vector2.ONE, 0.1)


func _on_pressed() -> void:
	if not is_ready_to_pick: 
		return
	GameManager.start_placement_mode(animal_type)
	queue_free()
