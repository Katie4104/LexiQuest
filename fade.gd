extends Node2D
@onready var walker = $walker
@onready var fade = $fade
@onready var loading = $VBoxContainer/WelcomeLabel2

var speed = 100
var dots = 0

func _ready():
		walker.play("default")

func _process(delta):

		# walker moves
		walker.position.x += speed * delta

		# animate loading dots
		if int(Time.get_ticks_msec()/500) % 2 == 0:
				dots = (dots + 1) % 4
				loading.text = "Loading" + "." * dots

		# when walker reaches end
		if walker.position.x > 1100:
				fade.color.a += delta

				if fade.color.a >= 1:
						get_tree().change_scene_to_file("res://login_screen.tscn")
