extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Lobby.tscn")


func _on_guest_play_pressed() -> void:
	SaveManager.delete_save_placed_animals()
	get_tree().change_scene_to_file("res://Levels/Lobby.tscn")
