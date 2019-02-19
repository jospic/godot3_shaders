extends Position3D

var angle_x = -25;
var angle_y = 50;

func _update_rotation():
	var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(angle_y))
	basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(angle_x))
	transform.basis = basis

func _ready():
	_update_rotation()

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_key_pressed(KEY_ALT):
			# rotate by motion
			angle_x -= event.relative.y;
			angle_y -= event.relative.x;
			
			if angle_x > 35:
				angle_x = 35
			elif angle_x < -85:
				angle_x = -85
			
			_update_rotation()
		elif Input.is_key_pressed(KEY_SHIFT):
			var left_right = transform.basis.x
			left_right.y = 0.0
			left_right = left_right.normalized()
			
			transform.origin += left_right * event.relative.x * -0.1
			
			var front_back = transform.basis.z
			front_back.y = 0.0
			front_back = front_back.normalized()
			
			transform.origin += front_back * event.relative.y * -0.1
		elif Input.is_key_pressed(KEY_CONTROL):
			var cam_origin = $Camera.transform.origin
			cam_origin.z = clamp(cam_origin.z + (event.relative.y * 0.1), 2.0, 1000.0)
			$Camera.transform.origin = cam_origin

