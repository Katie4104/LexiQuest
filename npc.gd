extends CharacterBody2D

@export_enum("Talk", "Quiz") var interaction_mode: String = "Talk"
@export var character_name: String = "NPC"
@export var dialogue_lines: Array[String] = ["Hello"]

@export var npc_name: String = "Guard"
@export var question: String = ""
@export var choices: Array[String] = []
@export var correct_idx: int = 0
@export var outro_dialogue: Array[String] = ["¡Buen viaje!"]
@export var initial_animation: String = "front_desk_idle"

func _ready():
	var sprite = $AnimatedSprite2D
	var area = $Area2D

	if sprite:
		if name == "FrontDeskNPC":
			sprite.play("front_desk_idle")
		elif name == "MetalDetectNPC":
			sprite.play("metal_security1_idle")
		elif name == "MetalDetectNPC2":
			sprite.play("metal_security2_idle")
		elif name == "DeskSecurityNPC":
			sprite.play("desk_security1_idle")
		elif name == "DeskSecurityNPC2":
			sprite.play("desk_security2_idle")

	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player":
		body.can_move = false

		var db = get_tree().get_first_node_in_group("dialogue")
		if not db:
			return

		if interaction_mode == "Talk":
			db.start_dialogue(character_name, dialogue_lines)
		elif interaction_mode == "Quiz":
			if not db.dialogue_finished.is_connected(_on_intro_finished):
				db.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)

func _on_intro_finished():
	var db = get_tree().get_first_node_in_group("dialogue")
	if not db:
		return

	db.start_quiz(character_name, question, choices, correct_idx)

	if not db.answer_selected.is_connected(_on_answer_received):
		db.answer_selected.connect(_on_answer_received)

func _on_answer_received(is_correct: bool):
	var db = get_tree().get_first_node_in_group("dialogue")
	if not db:
		return

	if is_correct:
		db.start_dialogue(character_name, outro_dialogue)
	else:
		db.start_dialogue(character_name, ["Lo siento, that isn't right."] as Array[String])
		db.dialogue_finished.connect(func(): _on_intro_finished(), CONNECT_ONE_SHOT)

func _on_body_exited(body):
	if body.name == "Player":
		body.can_move = true
		var db = get_tree().get_first_node_in_group("dialogue")
		if db:
			db.hide()