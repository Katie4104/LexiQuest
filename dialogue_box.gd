extends CanvasLayer

@onready var label = $Panel/Label

var lines: Array[String] = []

func _ready():
	hide()  # hidden until dialogue starts

func start_dialogue(npc_lines: Array[String]):
	lines = npc_lines.duplicate()  # copy lines
	show()
	show_next_line()

func show_next_line():
	if lines.size() > 0:
		label.text = lines.pop_front()
	else:
		hide()  # dialogue finished

func _input(event):
	# Only advance dialogue if visible
	if visible and Input.is_action_just_pressed("ui_accept"):
		show_next_line()
