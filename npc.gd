extends Node2D

# 1. These show up in the Inspector on the right!
@export var dialogue_lines : Array[String] = ["Hello there!", "How are you?"]
@export var initial_animation : String = "front_desk_idle"

var player_in_range = false

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

	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
		
func _on_body_entered(body):
	if body.name == "Player":
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
