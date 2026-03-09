extends Node2D

var player_in_range = false
var dialogue_lines = ["Hello there!", "How are you?", "Nice weather today!"] # customize per NPC
var current_line = 0

func _ready():
	# Connect signals from Area2D
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_class("CharacterBody2D"):
		player_in_range = true
		
func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		# Call the DialogueBox node to show dialogue
		var dialogue_box = get_node("/root/main/DialogueBox")  # adjust path to your scene
		dialogue_box.start_dialogue(dialogue_lines)
