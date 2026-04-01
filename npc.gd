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
		if not db: 
			return

		# --- SECURITY GUARD ---
		if character_name == "Airport Security":
			# If player hasn't even talked to the Agent yet
			if not GameManager.has_met_check_in:
				fail_sfx.play()
				db.start_dialogue(character_name, dialogue_lines) 
				_connect_quiz_signal(db)
			# If they talked to Agent but don't have the stamp (validated ticket) yet
			elif GameManager.has_met_check_in and not GameManager.has_validated_ticket:
				fail_sfx.play()
				db.start_dialogue(character_name, [outro_dialogue[1]]) 
			# Success
			elif GameManager.has_validated_ticket:
				success_sfx.play()
				db.start_dialogue(character_name, [outro_dialogue[2]]) 
			return 


		# --- CHECK IN AGENT ---
		if character_name == "Check In Agent":
			# 1. Returning Player (No ink yet) -> "Still need that ink!"
			if GameManager.has_met_check_in and not GameManager.has_blue_ink:
				fail_sfx.play()
				db.start_dialogue(character_name, [outro_dialogue[1]])
				
			# 2. First Time Meeting -> Intro + "Dialogue Choice" Quiz
			elif not GameManager.has_met_check_in:
				db.start_dialogue(character_name, dialogue_lines) # "You need ink from the shop."
				_connect_quiz_signal(db) # This triggers the "I'll go to the shop" button
				GameManager.has_met_check_in = true
				
			# 3. Mission Success (Has ink, needs the REAL quiz for the stamp)
			elif GameManager.has_blue_ink and not GameManager.has_validated_ticket:
				success_sfx.play()
				db.start_dialogue(character_name, [outro_dialogue[0]]) 
				_connect_quiz_signal(db)
				GameManager.has_validated_ticket = true
			
			# 4. Already Validated
			else:
				success_sfx.play()
				db.start_dialogue(character_name, [outro_dialogue[2]])
			return
			
		# --- GIFT SHOP CLERK ---
		if character_name == "Gift Shop Clerk":
			# 1. Player just wandering in (Hasn't seen the Check-in Agent yet)
			if not GameManager.has_met_check_in:
				db.start_dialogue(character_name, dialogue_lines) # "Welcome to the shop!"
				
			# 2. Player needs the ink (Met agent, no ink yet)
			elif GameManager.has_met_check_in and not GameManager.has_blue_ink:
				db.start_dialogue(character_name, dialogue_lines)
				_connect_quiz_signal(db)
				GameManager.has_blue_ink = true
				
			# 3. Already got the ink
			else:
				db.start_dialogue(character_name, [outro_dialogue[0]])
			return 
			
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
				db.start_dialogue(character_name, [outro_dialogue[0]])
			
			"Airport Security":
				db.start_dialogue(character_name, [outro_dialogue[0]])
				
			"Gift Shop Clerk":
				GameManager.has_blue_ink = true
				db.start_dialogue(character_name, [outro_dialogue[0]])
				
			_:
				db.start_dialogue(character_name, outro_dialogue)
	else:
		fail_sfx.play()
		db.start_dialogue(character_name, ["Lo siento, that isn't right. Try again!"])
		db.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
			
func _on_body_exited(body):
	if body.name == "Player":
		body.can_move = true
		var db = get_tree().get_first_node_in_group("dialogue")
		if db: 
			db.hide()
