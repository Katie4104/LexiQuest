extends CharacterBody2D

@export_enum("Talk", "Quiz") var interaction_mode: String = "Talk"
@export var character_name: String = "NPC"
@export var dialogue_lines: Array[String] = []
@export var initial_animation: String = "front_desk_idle"

# Quiz Variables
@export var question: String = ""
@export var choices: Array[String] = []
@export var correct_idx: int = 0
@export var outro_dialogue: Array[String] = []

@onready var success_sfx = $SuccessPlayer
@onready var fail_sfx = $FailPlayer

func _ready():
	var sprite = %AnimatedSprite2D
	if sprite:
		sprite.play(initial_animation)

func _on_body_entered(body):
	if body.name == "Player":
		body.can_move = false 
		var db = get_tree().get_first_node_in_group("dialogue")
		if not db: return

		# --- SECURITY GUARD ---
		if character_name == "Airport Security":
			if not GameManager.has_validated_ticket:
				fail_sfx.play()
				db.start_dialogue(character_name, dialogue_lines) #fix this?
				_connect_quiz_signal(db)
			else:
				success_sfx.play()
				db.start_dialogue(character_name, [outro_dialogue[1]] as Array[String])
			return 

		# --- CHECK IN AGENT ---
		if character_name == "Check In Agent":
			if not GameManager.has_blue_ink:
				GameManager.has_met_check_in = true
				db.start_dialogue(character_name, dialogue_lines)
				# No quiz yet, they need to go find the ink first
			elif GameManager.has_blue_ink and not GameManager.has_validated_ticket:
				db.start_dialogue(character_name, ["Oh, you found the ink! Let me stamp your ticket."] as Array[String])
				_connect_quiz_signal(db)
			return

		# --- GIFT SHOP CLERK ---
		if character_name == "Gift Shop Clerk":
			if GameManager.has_met_check_in and not GameManager.has_blue_ink:
				# Start the 'Welcome' lines, then trigger the quiz
				db.start_dialogue(character_name, dialogue_lines)
				if interaction_mode == "Quiz":
					_connect_quiz_signal(db)
			else:
				# If they don't need ink or already have it
				db.start_dialogue(character_name, outro_dialogue)
			return

		# --- NORMAL NPC FLOW ---
		db.start_dialogue(character_name, dialogue_lines)
		if interaction_mode == "Quiz":
			_connect_quiz_signal(db)

# Helper function to trigger the transition to the Quiz
func _connect_quiz_signal(db):
	if not db.dialogue_finished.is_connected(_on_intro_finished):
		db.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)

func _on_intro_finished():
	var db = get_tree().get_first_node_in_group("dialogue")
	if db:
		db.start_quiz(character_name, question, choices, correct_idx)
		if not db.answer_selected.is_connected(_on_answer_received):
			db.answer_selected.connect(_on_answer_received)
			
func _on_answer_received(is_correct: bool):
	var db = get_tree().get_first_node_in_group("dialogue")
	if not db: return
	
	if is_correct: 
		success_sfx.play() 
		
		match character_name:
			"Check In Agent":
				GameManager.has_validated_ticket = true
				db.start_dialogue(character_name, [outro_dialogue[1]] as Array[String])
			
			"Airport Security":
				# "Wait—before you go, get a stamp."
				db.start_dialogue(character_name, [outro_dialogue[0]] as Array[String])
				
			"Gift Shop Clerk":
				# Pass the quiz -> Get the ink
				GameManager.has_blue_ink = true
				db.start_dialogue(character_name, [outro_dialogue[0]] as Array[String])
				
			_:
				db.start_dialogue(character_name, outro_dialogue)
	else:
		fail_sfx.play()
		db.start_dialogue(character_name, ["Lo siento, that isn't right. Try again!"] as Array[String])
		db.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
			
func _on_body_exited(body):
	if body.name == "Player":
		body.can_move = true
		var db = get_tree().get_first_node_in_group("dialogue")
		if db: db.hide()
