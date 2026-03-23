extends Control

const NEXT_SCENE = "res://main.tscn"
const ACCOUNTS_FILE = "user://accounts.json"

@onready var user_edit = $NinePatchRect/VBoxContainer/userEdit
@onready var password_edit = $NinePatchRect/VBoxContainer/PasswordEdit
@onready var login_button = $NinePatchRect/VBoxContainer/CenterContainer/loginButton
@onready var create_account_button = $NinePatchRect/VBoxContainer/CenterContainer2/createAccountButton

func _ready() -> void:
	# Connect buttons in code so we avoid duplicate signal-function problems.
	if not login_button.pressed.is_connected(login_pressed):
		login_button.pressed.connect(login_pressed)

	if not create_account_button.pressed.is_connected(create_account_pressed):
		create_account_button.pressed.connect(create_account_pressed)

	print("Login screen ready")

func login_pressed() -> void:
	print("LOGIN BUTTON CLICKED")

	var username = user_edit.text.strip_edges()
	var password = password_edit.text

	if username == "" or password == "":
		print("Please enter username and password")
		return

	var data = load_accounts()

	for user in data["users"]:
		if user["username"] == username and user["password"] == password:
			print("Login successful")
			get_tree().change_scene_to_file(NEXT_SCENE)
			return

	print("Invalid username or password")

func create_account_pressed() -> void:
	print("CREATE ACCOUNT BUTTON CLICKED")
	get_tree().change_scene_to_file("res://register_screen.tscn")


func load_accounts() -> Dictionary:
	if not FileAccess.file_exists(ACCOUNTS_FILE):
		return {"users": []}

	var file = FileAccess.open(ACCOUNTS_FILE, FileAccess.READ)
	if file == null:
		print("Could not open accounts file for reading")
		return {"users": []}

	var content = file.get_as_text()
	file.close()

	if content.strip_edges() == "":
		return {"users": []}

	var json = JSON.new()
	var result = json.parse(content)

	if result != OK:
		print("Failed to parse accounts.json")
		return {"users": []}

	var data = json.data

	if typeof(data) != TYPE_DICTIONARY:
		return {"users": []}

	if not data.has("users"):
		data["users"] = []

	return data
	
func _on_login_button_pressed() -> void:
	pass # Replace with function body.

func _on_create_account_button_pressed() -> void:
	pass # Replace with function body.
