extends CharacterBody2D

@export_enum("Talk", "Quiz") var interaction_mode: String = "Talk"
@export var character_name: String = "NPC"
@export var dialogue_lines: Array[String] = ["Hello!"]

@export var question: String = ""
@export var choices: Array[String] = []
@export var correct_idx: int = 0
@export var outro_dialogue: Array[String] = ["¡Buen viaje!"]

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
		if not db.answer_selected.is_connected(_on_answer_received):
			db.answer_selected.connect(_on_answer_received)

func _on_answer_received(is_correct: bool):
	var db = get_tree().get_first_node_in_group("dialogue")
	if not db: return
	
	if is_correct: 
		db.start_dialogue(character_name, outro_dialogue)
	else:
		db.start_dialogue(character_name, ["Lo siento, that isn't right."] as Array[String])
		# Loop back to the quiz after they read the error message
		db.dialogue_finished.connect(func(): _on_intro_finished(), CONNECT_ONE_SHOT)

func _on_body_exited(body):
	if body.name == "Player":
<<<<<<< Updated upstream
		body.can_move = true
		var db = get_tree().get_first_node_in_group("dialogue")
		if db: db.hide()
=======
		$CanvasLayer.visible = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		# Call the DialogueBox node to show dialogue
		var dialogue_box = get_node("/root/main/DialogueBox")  
		dialogue_box.start_dialogue(dialogue_lines)
>>>>>>> Stashed changes
