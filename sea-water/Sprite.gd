extends Sprite

var mouse 
var screen
	
func _ready():
	screen = get_viewport().get_visible_rect().size	
	get_material().set_shader_param("screen_size", screen)
	
func _input(event):
	if event is InputEventMouseMotion and event.is_pressed():
		mouse = get_node("../").get_global_mouse_position();
		mouse.x = mouse.x / screen.x * 100
		get_material().set_shader_param("mouse_position", mouse)

		
