extends Control

const SAVE_PATH = "user://accounts.json"

@onready var user_edit = $NinePatchRect/VBoxContainer/userEdit
@onready var password_edit = $NinePatchRect/VBoxContainer/PasswordEdit
@onready var confirm_password_edit = $NinePatchRect/VBoxContainer/ConfirmPasswordEdit

func _on_register_button_pressed():
	var username = user_edit.text.strip_edges()
	var password = password_edit.text
	var confirm_password = confirm_password_edit.text

	print("Register button clicked")

	if username == "":
		print("Username cannot be empty")
		return

	if password == "":
		print("Password cannot be empty")
		return

	if confirm_password == "":
		print("Please confirm your password")
		return

	if password != confirm_password:
		print("Passwords do not match")
		return

	var data = load_accounts()

	for user in data["users"]:
		if user["username"] == username:
			print("Username already exists")
			return

	data["users"].append({
		"username": username,
		"password": password
	})

	save_accounts(data)

	print("Account created for: ", username)
	get_tree().change_scene_to_file("res://login_screen.tscn")


func _on_back_button_pressed():
	print("Back button clicked")
	get_tree().change_scene_to_file("res://login_screen.tscn")


func load_accounts() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"users": []}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	if content.is_empty():
		return {"users": []}

	var json = JSON.new()
	var result = json.parse(content)

	if result != OK:
		print("Failed to parse accounts file")
		return {"users": []}

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return {"users": []}

	if not data.has("users"):
		data["users"] = []

	return data
func save_accounts(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
