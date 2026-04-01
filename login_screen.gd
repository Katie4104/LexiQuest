extends Control

const REGISTER_SCENE := "res://register_screen.tscn"
const MAIN_SCENE := "res://main.tscn"
const ACCOUNTS_FILE := "user://accounts.json"

@onready var username_edit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/UsernameEdit
@onready var password_edit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PasswordEdit
@onready var message_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/messageLabel
@onready var login_button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/LoginButton
@onready var register_button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/RegisterButton


func _ready() -> void:
	if not login_button.pressed.is_connected(login_pressed):
		login_button.pressed.connect(login_pressed)

	if not register_button.pressed.is_connected(go_to_register):
		register_button.pressed.connect(go_to_register)

	hide_message()


func login_pressed() -> void:
	var username = username_edit.text.strip_edges()
	var password = password_edit.text

	if username.is_empty() or password.is_empty():
		show_message("Please enter username and password.")
		return

	var accounts := load_accounts()

	if not accounts.has(username):
		show_message("Invalid username or password.")
		return

	if accounts[username] != password:
		show_message("Invalid username or password.")
		return

	hide_message()
	print("Login successful for: ", username)
	get_tree().change_scene_to_file(MAIN_SCENE)


func go_to_register() -> void:
	hide_message()
	get_tree().change_scene_to_file(REGISTER_SCENE)


func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true


func hide_message() -> void:
	message_label.text = ""
	message_label.visible = false


func load_accounts() -> Dictionary:
	if not FileAccess.file_exists(ACCOUNTS_FILE):
		return {}

	var file := FileAccess.open(ACCOUNTS_FILE, FileAccess.READ)
	if file == null:
		return {}

	var content := file.get_as_text()
	file.close()

	if content.strip_edges().is_empty():
		return {}

	var json := JSON.new()
	var result := json.parse(content)

	if result != OK:
		return {}

	var data = json.data
	if typeof(data) == TYPE_DICTIONARY:
		return data

	return {}
	
