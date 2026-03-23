extends PanelContainer

signal answer_selected(is_correct: bool)
signal dialogue_finished # The NPC listens for this to restart the quiz

@onready var npc_name_label: Label = $VBoxContainer/Name
@onready var d_label: RichTextLabel = $VBoxContainer/DLabel
@onready var choice_container = $VBoxContainer/ChoiceContainer 

var current_lines: Array[String] = []

func _ready():
	hide()
	choice_container.hide()

# --- NEW: Function for regular feedback text ---
func start_dialogue(speaker: String, lines: Array[String]):
	npc_name_label.text = speaker
	current_lines = lines.duplicate()
	choice_container.hide() # Ensure buttons are hidden during normal text
	show()
	show_next_line()

func show_next_line():
	if current_lines.size() > 0:
		d_label.text = current_lines.pop_front()
		# Insert your Typewriter Tween here if you want it!
	else:
		hide()
		dialogue_finished.emit() # Tell the NPC we are done talking

# --- QUIZ LOGIC ---
func start_quiz(speaker: String, question: String, options: Array, correct_idx: int):
	npc_name_label.text = speaker
	d_label.text = question
	show()
	
	for child in choice_container.get_children():
		child.queue_free()
	
	choice_container.show()
	
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = options[i]
		choice_container.add_child(btn)
		btn.pressed.connect(_on_choice_pressed.bind(i == correct_idx))

func _on_choice_pressed(is_correct: bool):
	choice_container.hide()
	hide()
	answer_selected.emit(is_correct)

# Handle clicking through the "Wrong/Correct" messages
func _input(event):
	if visible and not choice_container.visible and event.is_action_pressed("ui_accept"):
		show_next_line()
