extends TextureButton

@onready var icon = $Icon
@onready var name_label = $NameLabel


func display_animal(animal_id: String):
	if not is_node_ready(): await ready
	
	name_label.text = animal_id.replace("_", " ")
	
	var texture_path = "res://Texture/Animals/" + animal_id + ".png"
	
	var tex = load(texture_path)
	icon.texture = tex


func _on_pressed() -> void:
	GameManager.start_placement_mode(name_label.text)
