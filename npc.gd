extends CharacterBody2D

<<<<<<< HEAD
@export_enum("Talk", "Quiz") var interaction_mode: String = "Talk"
@export var character_name: String = "NPC"
@export var dialogue_lines: Array[String] = ["Hello!"]
=======
<<<<<<< HEAD
@export var npc_name: String = "Guard"
@export var question: String = "Translate 'Hola' to English:"
@export var choices: Array[String] = ["Goodbye", "Hello", "Apple"]
@export var correct_idx: int = 1
=======
# 1. These show up in the Inspector on the right!
@export var dialogue_lines : Array[String] = ["Hello there!", "How are you?"]
@export var initial_animation : String = "front_desk_idle"
>>>>>>> origin/main

@export var question: String = ""
@export var choices: Array[String] = []
@export var correct_idx: int = 0
@export var outro_dialogue: Array[String] = ["¡Buen viaje!"]

<<<<<<< HEAD
func _on_body_entered(body):
	if body.name == "Player":
		body.can_move = false 
		
		# Ensure your DB1 node is in the "dialogue" group
		var db = get_tree().get_first_node_in_group("dialogue")
		if not db: return

		db.start_dialogue(character_name, dialogue_lines)
		
		if interaction_mode == "Quiz":
			if not db.dialogue_finished.is_connected(_on_intro_finished):
				db.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)

func _on_intro_finished():
	var db = get_tree().get_first_node_in_group("dialogue")
	if db:
		db.start_quiz(character_name, question, choices, correct_idx)
=======
func _ready():
	var sprite = %AnimatedSprite2D
	var area = %Area2D
	
	if sprite:
		if name == "FrontDesk":
			sprite.play("front_desk_idle")
		elif name == "MetalDetectNPC":
			sprite.play("metal_security1_idle")
		elif name == "MetalDetectNPC2":
			sprite.play("metal_security2_idle")
		elif name == "DeskSecurityNPC":
			sprite.play("desk_security1_idle")
		elif name == "DeskSecurityNPC2":
			sprite.play("desk_security2_idle")
>>>>>>> origin/Testing

	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
		
func _on_body_entered(body):
	if body.name == "Player":
<<<<<<< HEAD
		trigger_quiz()

func trigger_quiz():
	var db = get_tree().get_first_node_in_group("dialogue")
	if db:
		db.start_quiz(npc_name, question, choices, correct_idx)
		
		# Connect the answer signal if not already connected
>>>>>>> origin/main
		if not db.answer_selected.is_connected(_on_answer_received):
			db.answer_selected.connect(_on_answer_received)

func _on_answer_received(is_correct: bool):
	var db = get_tree().get_first_node_in_group("dialogue")
<<<<<<< HEAD
	if not db: return
	
	if is_correct: 
		db.start_dialogue(character_name, outro_dialogue)
	else:
		db.start_dialogue(character_name, ["Lo siento, that isn't right."] as Array[String])
		# Loop back to the quiz after they read the error message
		db.dialogue_finished.connect(func(): _on_intro_finished(), CONNECT_ONE_SHOT)

func _on_body_exited(body):
	if body.name == "Player":
		body.can_move = true
		var db = get_tree().get_first_node_in_group("dialogue")
		if db: db.hide()
=======
	
	if is_correct:
		db.start_dialogue(npc_name, ["Correct! You are getting better at this."] as Array[String])
	else:
		db.start_dialogue(npc_name, ["Incorrect. Try again!"] as Array[String])
		# WAIT for the player to finish reading "Incorrect" before restarting
		if not db.dialogue_finished.is_connected(trigger_quiz):
			db.dialogue_finished.connect(trigger_quiz, CONNECT_ONE_SHOT)
=======
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play(initial_animation)
			
func _process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		var dialogue_box = get_node_or_null("/root/main/DialogueBox")
		if dialogue_box:
			# This sends the specific dialogue for THIS npc to the box
			dialogue_box.start_dialogue(dialogue_lines)
>>>>>>> origin/Testing
>>>>>>> origin/main
