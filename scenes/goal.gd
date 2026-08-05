extends Area3D


# Called when the node enters the scene tree for the first time.
func _process(delta):
	rotate_y(0.01)



func _on_body_entered(body: CharacterBody3D) -> void:
	get_tree().change_scene_to_file("res://scenes/level_2.tscn")
