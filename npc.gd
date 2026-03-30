extends CharacterBody2D

@export_enum("Talk", "Quiz") var interaction_mode: String = "Talk"
@export var character_name: String = "NPC"
@export var dialogue_lines: Array[String] = ["Hello!"]
@export var initial_animation: String = "front_desk_idle"

# Quiz Variables
@export var question: String = ""
@export var choices: Array[String] = []
@export var correct_idx: int = 0
@export var outro_dialogue: Array[String] = ["¡Buen viaje!"]

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

		# SECURITY GUARD SPECIAL LOGIC
		if character_name == "Airport Security":
			if not GameManager.has_validated_ticket:
				fail_sfx.play()
				db.start_dialogue(character_name, ["Stop! You must go to the [url=check-in]mostrador[/url] first and get a [url=blue stamp]sello azul[/url]."] as Array[String])
			else:
				success_sfx.play()
				db.start_dialogue(character_name, ["[url=Very good!]¡Muy bien![/url] You can now [url=pass]pasar[/url]. Have a [url=safe flight]buen vuelo[/url]."] as Array[String])
			return 

		# NORMAL NPC FLOW
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
	
	if is_correct: 
		# --- PLAY SUCCESS FOR EVERYONE ---
		success_sfx.play() 
		
		if character_name == "Check In Agent":
			GameManager.has_validated_ticket = true
			
		db.start_dialogue(character_name, outro_dialogue)
	else:
		# --- PLAY FAIL FOR EVERYONE ---
		fail_sfx.play()
		db.start_dialogue(character_name, ["Lo siento, that isn't right."] as Array[String])
		db.dialogue_finished.connect(func(): _on_intro_finished(), CONNECT_ONE_SHOT)
		
func _on_body_exited(body):
	if body.name == "Player":
		body.can_move = true
		var db = get_tree().get_first_node_in_group("dialogue")
		if db: db.hide()
