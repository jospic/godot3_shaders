extends Sprite

func _ready():
    set_process(true)
    pass

func _process(delta):
	var mouse = get_node("../").get_global_mouse_position();
	var screen = get_viewport().get_visible_rect().size
	mouse.x /= screen.x
	mouse.y /= screen.y
	
	get_material().set_shader_param("mouse_position", mouse)