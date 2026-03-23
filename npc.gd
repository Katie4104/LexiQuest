extends Node2D

@export var npc_name: String = "Guard"
@export var question: String = "Translate 'Hola' to English:"
@export var choices: Array[String] = ["Goodbye", "Hello", "Apple"]
@export var correct_idx: int = 1

func _on_body_entered(body):
	if body.name == "Player":
		trigger_quiz()

func trigger_quiz():
	var db = get_tree().get_first_node_in_group("dialogue")
	if db:
		db.start_quiz(npc_name, question, choices, correct_idx)
		
		# Connect the answer signal if not already connected
		if not db.answer_selected.is_connected(_on_answer_received):
			db.answer_selected.connect(_on_answer_received)

func _on_answer_received(is_correct: bool):
	var db = get_tree().get_first_node_in_group("dialogue")
	
	if is_correct:
		db.start_dialogue(npc_name, ["Correct! You are getting better at this."] as Array[String])
	else:
		db.start_dialogue(npc_name, ["Incorrect. Try again!"] as Array[String])
		# WAIT for the player to finish reading "Incorrect" before restarting
		if not db.dialogue_finished.is_connected(trigger_quiz):
			db.dialogue_finished.connect(trigger_quiz, CONNECT_ONE_SHOT)
