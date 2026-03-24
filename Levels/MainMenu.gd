extends Control
@onready var start_game: Button = $StartGame
@onready var guest_play: Button = $GuestPlay

func _ready() -> void:
	if(SaveManager.check_save()):
		start_game.text = "Continue"
		guest_play.visible = true
	else:
		start_game.text = "New Game"
		guest_play.visible = false

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Lobby.tscn")


func _on_guest_play_pressed() -> void:
	SaveManager.delete_save_placed_animals()
	get_tree().change_scene_to_file("res://Levels/Lobby.tscn")
