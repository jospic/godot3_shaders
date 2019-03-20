extends Sprite

var mouse 

var mouse_in = false
var dragging = false
var texture_sprite 
	
func _ready():
	texture_sprite = self.texture
	get_material().set_shader_param("texture_sprite", texture_sprite) # pass texture sprite to shader script
	set_process(true)
	
func _process(delta):
	if (mouse_in && Input.is_action_pressed("left_click")):
		dragging = true
				
	if (dragging && Input.is_action_pressed("left_click")):
		mouse = get_node("../").get_global_mouse_position();
		mouse.x = mouse.x / 10
		get_material().set_shader_param("mouse", mouse) # pass mouse position to shader script
		
	else:
		dragging = false
		

func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false

