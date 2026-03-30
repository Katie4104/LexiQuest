extends CharacterBody2D

@export var speed: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D # Get the camera child

var can_move : bool = true
var last_direction: String = "down"

func _ready():
	# 1. Find the Floor node
	var map = get_tree().current_scene.find_child("Floor")
	
	if map and camera:
		# 2. Get the area used by your tiles
		var map_limits = map.get_used_rect()
		var cell_size = map.tile_set.tile_size
		
		# 3. Apply the math to the camera limits
		camera.limit_left = map_limits.position.x * cell_size.x
		camera.limit_right = map_limits.end.x * cell_size.x
		camera.limit_top = map_limits.position.y * cell_size.y
		camera.limit_bottom = map_limits.end.y * cell_size.y

func _physics_process(delta):
	if can_move:
		var dir := Vector2.ZERO
		# Movement input
		if Input.is_action_pressed("ui_right"):
			dir.x += 1
		if Input.is_action_pressed("ui_left"):
			dir.x -= 1
		if Input.is_action_pressed("ui_down"):
			dir.y += 1
		if Input.is_action_pressed("ui_up"):
			dir.y -= 1

		dir = dir.normalized()
		velocity = dir * speed
		move_and_slide()
		update_animation(dir)
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func update_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		sprite.play("idle_" + last_direction)
		return

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
