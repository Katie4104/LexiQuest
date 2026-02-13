extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(delta):
		var dir := Vector2.ZERO
#Godot 4 uses "ui_*" by default
		if Input.is_action_pressed("ui_right"):
				dir.x += 1
		if Input.is_action_pressed("ui_left"):
				dir.x -= 1
		if Input.is_action_pressed("ui_down"):
				dir.y += 1
		if Input.is_action_pressed("ui_up"):
				dir.y -= 1

		velocity = dir.normalized() * speed
		move_and_slide()
		
