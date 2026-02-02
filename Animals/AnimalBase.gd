extends RigidBody2D

# 使用 @export 关键字，让你在检查器面板就能直接修改这些值
@export var animal_type: String = "Capybara" # 用于判断是否可以消除
@export var score_value: int = 100            # 不同动物的分数
@export var hover_color: Color = Color.WHITE # 高亮颜色
@onready var default: Sprite2D = $Default
@onready var bathing: Sprite2D = $Bathing

var is_selected = false
# 0：默认  1：泡澡中
var state: int = 0

func _ready():
	# 随机水平翻转逻辑
	if randf() > 0.5:
		bathing.flip_h = true
		$CollisionShape2D.rotation *= -1
	
	_set_state_(state)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if !GameManager.game_over:
			selected()


func selected():
	# 所有的动物都共用这一套高亮和选中逻辑
	bathing.material.set_shader_parameter("active", true)
	bathing.material.set_shader_parameter("line_color", hover_color)
	
	if !is_selected:
		is_selected = true
		GameManager.add_to_selection(self)

func deselected():
	is_selected = false
	bathing.material.set_shader_parameter("active", false)


func _set_state_(s):
	match s:
		0:
			default.visible = true
			bathing.visible = false
		1:
			default.visible = false
			bathing.visible = true
