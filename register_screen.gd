extends Control

const LOGIN_SCENE = "res://login_screen.tscn"
const ACCOUNTS_FILE = "user://accounts.json"

@onready var user_edit = $NinePatchRect/VBoxContainer/userEdit
@onready var password_edit = $NinePatchRect/VBoxContainer/PasswordEdit
@onready var confirm_password_edit = $NinePatchRect/VBoxContainer/ConfirmPasswordEdit

@onready var register_button = $NinePatchRect/VBoxContainer/CenterContainer/registerButton
@onready var back_button = $NinePatchRect/VBoxContainer/CenterContainer2/backButton


func _ready() -> void:
	# Connect buttons manually (no signal confusion)
	if not register_button.pressed.is_connected(register_pressed):
		register_button.pressed.connect(register_pressed)

	if not back_button.pressed.is_connected(go_back):
		back_button.pressed.connect(go_back)

	print("Register screen ready")


# =========================
# REGISTER BUTTON
# =========================
func register_pressed() -> void:
	print("REGISTER BUTTON CLICKED")

	var username = user_edit.text.strip_edges()
	var password = password_edit.text
	var confirm_password = confirm_password_edit.text

	# Validation
	if username == "" or password == "" or confirm_password == "":
		print("Please fill all fields")
		return

	if password != confirm_password:
		print("Passwords do not match")
		return

	var data = load_accounts()

	# Check if user already exists
	for user in data["users"]:
		if user["username"] == username:
			print("Username already exists")
			return

	# Add new user
	data["users"].append({
		"username": username,
		"password": password
	})

	save_accounts(data)

	print("Account created successfully")

	# Go back to login
	get_tree().change_scene_to_file(LOGIN_SCENE)


# =========================
# BACK BUTTON
# =========================
func go_back() -> void:
	print("BACK BUTTON CLICKED")
	get_tree().change_scene_to_file(LOGIN_SCENE)


# =========================
# LOAD ACCOUNTS
# =========================
func load_accounts() -> Dictionary:
	if not FileAccess.file_exists(ACCOUNTS_FILE):
		return {"users": []}

	var file = FileAccess.open(ACCOUNTS_FILE, FileAccess.READ)
	if file == null:
		return {"users": []}

	var content = file.get_as_text()
	file.close()

	if content.strip_edges() == "":
		return {"users": []}

	var json = JSON.new()
	var result = json.parse(content)

	if result != OK:
		print("Failed to parse JSON")
		return {"users": []}

	var data = json.data

	if typeof(data) != TYPE_DICTIONARY:
		return {"users": []}

	if not data.has("users"):
		data["users"] = []

	return data


# =========================
# SAVE ACCOUNTS
# =========================
func save_accounts(data: Dictionary) -> void:
	var file = FileAccess.open(ACCOUNTS_FILE, FileAccess.WRITE)
	if file == null:
		print("Failed to save accounts")
		return

	file.store_string(JSON.stringify(data))
	file.close()
	
	

func _on_register_button_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
