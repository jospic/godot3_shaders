extends Sprite

var mouse 
var screen

var mouse_in = false
var dragging = false
	
func _ready():
	screen = get_viewport().get_visible_rect().size	
	set_process(true)
	
func _process(_delta):
	if (mouse_in && Input.is_action_pressed("left_click")):
		dragging = true
				
	if (dragging && Input.is_action_pressed("left_click")):
		mouse = get_global_mouse_position();
		mouse = mouse / screen * 200
		get_material().set_shader_param("mouse_position", mouse) # pass mouse position on shader script
		
	else:
		dragging = false
		

func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false

