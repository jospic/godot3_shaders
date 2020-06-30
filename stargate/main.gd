extends Node2D

onready var image = $front
enum shape {
	RECTANGLE, 
	SQUARE, 
	TRIANGLE, 
	CIRCULAR,
	HEXAGON,
	OCTAGON
	}

var setShape = 0

func _ready():
	pass

func _process(_delta):
	image.get_material().set_shader_param("shape", setShape) # pass diamond shape diamond 

func _on_btn_rect_toggled(button_pressed):
	if (button_pressed):
		setShape = shape.RECTANGLE

func _on_btn_square_toggled(button_pressed):
	if (button_pressed):
		setShape = shape.SQUARE

func _on_btn_triang_toggled(button_pressed):
	if (button_pressed):
		setShape = shape.TRIANGLE

func _on_btn_circ_toggled(button_pressed):
	if (button_pressed):
		setShape = shape.CIRCULAR

func _on_btn_hex_toggled(button_pressed):
	if (button_pressed):
			setShape = shape.HEXAGON

func _on_btn_oct_toggled(button_pressed):
	if (button_pressed):
		setShape = shape.OCTAGON
