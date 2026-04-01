extends AnimatedSprite2D
var speed = 80.0

func _ready():
	play("walk")
func _process(delta):
	position.x += speed * delta
