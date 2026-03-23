extends CharacterBody2D

@export var speed: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: String = "down"

func _physics_process(delta):

	var dir := Vector2.ZERO
	
	var db = get_node_or_null("/root/main/DialogueBox")
	if db and db.visible:
		sprite.play("idle_" + last_direction)
		return
		
	# Movement input
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1

	# Normalize movement so diagonals aren't faster
	dir = dir.normalized()

	# Apply movement
	velocity = dir * speed
	move_and_slide()

	# Handle animations
	update_animation(dir)


func update_animation(dir: Vector2):

	# If not moving → play idle animation
	if dir == Vector2.ZERO:
		sprite.play("idle_" + last_direction)
		return

	# Determine if movement is mostly horizontal or vertical
	if abs(dir.x) > abs(dir.y):

		if dir.x > 0:
			sprite.play("walk_right")
			last_direction = "right"
		else:
			sprite.play("walk_left")
			last_direction = "left"

	else:

		if dir.y > 0:
			sprite.play("walk_down")
			last_direction = "down"
		else:
			sprite.play("walk_up")
			last_direction = "up"
