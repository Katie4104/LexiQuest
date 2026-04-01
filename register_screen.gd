extends Control

const LOGIN_SCENE := "res://login_screen.tscn"
const ACCOUNTS_FILE := "user://accounts.json"

@onready var user_edit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/UsernameEdit
@onready var password_edit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PasswordEdit
@onready var confirm_password_edit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ConfirmPasswordEdit
@onready var message_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/messageLabel
@onready var register_button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/registerButton
@onready var back_button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonRow/backButton


func _ready() -> void:
	if not register_button.pressed.is_connected(register_pressed):
		register_button.pressed.connect(register_pressed)

	if not back_button.pressed.is_connected(go_back):
		back_button.pressed.connect(go_back)

	hide_message()


func register_pressed() -> void:
	var username = user_edit.text.strip_edges()
	var password = password_edit.text
	var confirm_password = confirm_password_edit.text

	if username.is_empty() or password.is_empty() or confirm_password.is_empty():
		show_message("Please fill in all fields.")
		return

	if password != confirm_password:
		show_message("Passwords do not match.")
		return

	var accounts = load_accounts()

	if accounts.has(username):
		show_message("Username already exists.")
		return

	accounts[username] = password
	save_accounts(accounts)

	hide_message()
	print("Account created:", username)
	get_tree().change_scene_to_file(LOGIN_SCENE)


func go_back() -> void:
	hide_message()
	get_tree().change_scene_to_file(LOGIN_SCENE)


func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true


func hide_message() -> void:
	message_label.text = ""
	message_label.visible = false


func load_accounts() -> Dictionary:
	if not FileAccess.file_exists(ACCOUNTS_FILE):
		return {}

	var file = FileAccess.open(ACCOUNTS_FILE, FileAccess.READ)
	if file == null:
		return {}

	var content = file.get_as_text()
	file.close()

	if content.strip_edges().is_empty():
		return {}

	var json = JSON.new()
	var result = json.parse(content)

	if result != OK:
		return {}

	var data = json.data
	if typeof(data) == TYPE_DICTIONARY:
		return data

	return {}


func save_accounts(accounts: Dictionary) -> void:
	var file = FileAccess.open(ACCOUNTS_FILE, FileAccess.WRITE)
	if file == null:
		show_message("Could not save account data.")
		return

	file.store_string(JSON.stringify(accounts))
	file.close()
	


func _on_register_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
