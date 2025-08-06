extends Camera3D

@export var move_speed := 15.0
@export var fast_speed := 50.0
@export var rotation_speed := 0.005
@export var pan_speed := 0.02
@export var zoom_speed := 2.0
@export var edge_margin := 10
@export var edge_speed := 15.0

var yaw := 0.0
var pitch := -0.3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	yaw = rotation.y
	pitch = rotation.x

func _process(delta):
	var speed = move_speed
	if Input.is_action_pressed("ui_shift"):
		speed = fast_speed
	var dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		dir.z += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y += 1
	if Input.is_action_pressed("move_down"):
		dir.y -= 1
	if dir != Vector3.ZERO:
		translate(basis * dir.normalized() * speed * delta)

## Edge Movement

	# if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
	# 	var mouse_pos = get_viewport().get_mouse_position()
	# 	var size = get_viewport().get_visible_rect().size
	# 	if mouse_pos.x <= edge_margin:
	# 		translate(-basis.x * edge_speed * delta)
	# 	elif mouse_pos.x >= size.x - edge_margin:
	# 		translate(basis.x * edge_speed * delta)
	# 	if mouse_pos.y <= edge_margin:
	# 		translate(-basis.z * edge_speed * delta)
	# 	elif mouse_pos.y >= size.y - edge_margin:
	# 		translate(basis.z * edge_speed * delta)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			translate(-basis.z * zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			translate(basis.z * zoom_speed)
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			yaw -= event.relative.x * rotation_speed
			pitch = clamp(pitch - event.relative.y * rotation_speed, -1.2, 0.2)
			rotation.y = yaw
			rotation.x = pitch
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			translate((basis.x * event.relative.x + basis.z * event.relative.y) * pan_speed)
