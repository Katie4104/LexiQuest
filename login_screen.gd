extends Control

@onready var username_input = $LoginBox/UserNameInput
@onready var password_input = $LoginBox/PasswordInput
@onready var message_label = $MessageLabel

func _on_LoginButton_pressed():

		var username = username_input.text.strip_edges()
		var password = password_input.text.strip_edges()

		if username == "" or password == "":
				message_label.text = "Please enter a username and password."
				return

		get_tree().change_scene_to_file("res://menu.tscn")


func _on_GuestButton_pressed():

		get_tree().change_scene_to_file("res://menu.tscn")
