extends Spatial

onready var camera = get_node("Camera")
onready var eagle = get_node("Eagle")
onready var backscreen = get_node("BackgroundScreen")
onready var rect = get_node("Viewport/ColorRect")

const ROT_SPEED = 0.5

const TRUST_INCR = 0.01
const TRUST_MAX = 2.0

var rot_x = 0
var trust = 0

func _ready():
	var backscreen_size = backscreen.get_mesh().get_size()
	var screen_size_x = backscreen_size.x * 256
	var screen_size_y = backscreen_size.y * 200
	rect.get_material().set_shader_param("screen_size", Vector2(screen_size_x, screen_size_y))  # pass screen size on shader script
	
func _process(delta):
		
	if Input.is_action_pressed("ui_left"):
		eagle.rotate(Vector3(0, 1, 0), deg2rad(ROT_SPEED))
		eagle.rotate(Vector3(0, 0, 1), deg2rad(-ROT_SPEED)*2)		
		
	if Input.is_action_pressed("ui_right"):
		eagle.rotate(Vector3(0, 1, 0), deg2rad(-ROT_SPEED))
		eagle.rotate(Vector3(0, 0, 1), deg2rad(ROT_SPEED)*2)

#	if Input.is_action_pressed("ui_select"):
#		if camera.is_current()!=true:
#			camera.make_current()
#		eagle.translate(Vector3(1, 0, 0) * TRANS_SPEED)

	if (Input.is_action_pressed("ui_down") and trust >= TRUST_INCR):
		#eagle.translate(Vector3(0, 1, 0) * -TRANS_SPEED)
		trust = trust - TRUST_INCR
		
		
	if (Input.is_action_pressed("ui_up") and trust <= TRUST_MAX):
        #eagle.translate(Vector3(0, 1, 0) * TRANS_SPEED)
		trust = trust + TRUST_INCR
		rect.get_material().set_shader_param("trust", trust)  # pass trust on shader script
		
		
