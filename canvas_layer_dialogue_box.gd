extends Node2D

var player_in_range = false
var dialogue_lines = ["Hello there!", "How are you?", "Nice weather today!"] # customize per NPC

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		get_node("/root/Main/DialogueBox").start_dialogue(dialogue_lines)  # adjust path

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
