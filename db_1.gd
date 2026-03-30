extends PanelContainer

signal answer_selected(is_correct: bool)
signal dialogue_finished 

@onready var npc_name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var d_label: RichTextLabel = $MarginContainer/VBoxContainer/DLabel
@onready var choice_container: VBoxContainer = $MarginContainer/VBoxContainer/ChoiceContainer
@onready var translation_popup: Label = $Translation

var current_lines: Array = []
var active_correct_idx: int = 0
var is_dialogue_active: bool = false # Guard variable

func _ready():
	hide()
	choice_container.hide()
	if translation_popup:
		translation_popup.hide()
	
	# Connects the hover signals for the Spanish translations
	d_label.meta_hover_started.connect(_on_meta_hover_started)
	d_label.meta_hover_ended.connect(_on_meta_hover_ended)

func start_dialogue(speaker: String, lines: Array): 
	npc_name_label.text = speaker
	current_lines = lines.duplicate()
	is_dialogue_active = true
	choice_container.hide()
	show()
	show_next_line()
	
func show_next_line():
	if current_lines.size() > 0:
		d_label.text = current_lines.pop_front()
	else:
		is_dialogue_active = false
		dialogue_finished.emit()
		# Only hide if we aren't waiting for a quiz answer
		if not choice_container.visible:
			hide()
			unfreeze_player()

func unfreeze_player():
	# Finds the player in the scene to restore movement
	var player = get_tree().current_scene.find_child("Player")
	if player:
		player.can_move = true

func start_quiz(speaker: String, question: String, options: Array, correct_idx: int):
	npc_name_label.text = speaker
	d_label.text = question
	active_correct_idx = correct_idx
	is_dialogue_active = true
	show()
	
	# Clear old buttons
	for child in choice_container.get_children():
		child.queue_free()
	
	choice_container.show()
	
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = options[i]
		choice_container.add_child(btn)
		# Using a callable for cleaner connection
		btn.pressed.connect(_on_choice_pressed.bind(i))
		
	# Focus the first button for controller/keyboard support
	if choice_container.get_child_count() > 0:
		choice_container.get_child(0).grab_focus()

func _on_choice_pressed(idx: int):
	choice_container.hide()
	var is_correct = (idx == active_correct_idx or active_correct_idx == -1)
	answer_selected.emit(is_correct)
	

func _input(event):
	# Only progress if the box is visible AND we aren't in the middle of a quiz
	if is_dialogue_active and not choice_container.visible:
		if event.is_action_pressed("ui_accept"):
			# Stop the input from bubbling up to other systems
			get_viewport().set_input_as_handled()
			show_next_line()

func _on_meta_hover_started(meta):
	translation_popup.text = str(meta)
	translation_popup.reset_size() 
	translation_popup.show()
	
func _on_meta_hover_ended(_meta):
	translation_popup.hide()

func _process(_delta):
	# This keeps the translation box glued to your mouse cursor
	if translation_popup and translation_popup.visible:
		var mouse_pos = get_global_mouse_position()
		var screen_size = get_viewport_rect().size
		var padding = 10 
		
		# Initial desired position (offset from mouse)
		var target_pos = mouse_pos + Vector2(15, -25)
		
		# Get the actual size of the translation box
		var popup_size = translation_popup.get_combined_minimum_size()
		
		# 1. Clamp Horizontal (X) - keeps it on screen
		if target_pos.x + popup_size.x > screen_size.x - padding:
			target_pos.x = mouse_pos.x - popup_size.x - 15
			
		# 2. Clamp Vertical (Y)
		if target_pos.y < padding:
			target_pos.y = mouse_pos.y + 25
			
		translation_popup.global_position = target_pos
