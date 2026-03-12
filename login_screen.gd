extends Control

func _ready() -> void:
	print("login screen loaded")

func _on_guest_button_pressed() -> void:
	print("Guest pressed")
	var result = get_tree().change_scene_to_file("res://menu.tscn")
	print("Result: ", result)

func _on_login_button_pressed() -> void:
	print("Login pressed")
	var result = get_tree().change_scene_to_file("res://menu.tscn")
	print("Result: ", result)
	
