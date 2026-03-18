extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	GameManager.daily_stamina -= 1
	get_tree().change_scene_to_file("res://Levels/Board.tscn")


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/GuestLounge.tscn")
