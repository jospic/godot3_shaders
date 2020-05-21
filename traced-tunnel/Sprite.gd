extends Sprite

var mouse 

var mouse_in = false
var dragging = false
var iChannel0
var iChannel1 
	
func _ready():
	iChannel0 = self.texture
	iChannel1 = get_node("../iChannel1").texture
	get_material().set_shader_param("iChannel0", iChannel0) # pass texture sprite to shader script
	get_material().set_shader_param("iChannel1", iChannel1) # pass texture sprite to shader script
	
