extends Camera3D

@export var move_speed := 15.0
@export var fast_speed := 50.0
@export var rotation_speed := 0.005
@export var pan_speed := 0.02
@export var zoom_speed := 2.0
@export var edge_margin := 10
@export var edge_speed := 15.0
@export var bounds_min := Vector2(-25, -25)
@export var bounds_max := Vector2(25, 25)

var yaw := 0.0
var pitch := -0.3
var fixed_height := 0.0
var right_panning := false
var rotating := false

func _ready():
	yaw = rotation.y
	pitch = rotation.x
	fixed_height = global_position.y

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
	if dir != Vector3.ZERO:
		var forward = Vector3(0, 0, -1).rotated(Vector3.UP, yaw)
		var right = Vector3(1, 0, 0).rotated(Vector3.UP, yaw)
		var move_vec = (right * dir.x + forward * dir.z).normalized()
		translate(move_vec * speed * delta)
		_clamp_position()

	## Edge Movement

	var mouse_pos = get_viewport().get_mouse_position()
	var size = get_viewport().get_visible_rect().size
	var forward = Vector3(0, 0, -1).rotated(Vector3.UP, yaw)
	var right = Vector3(1, 0, 0).rotated(Vector3.UP, yaw)
	if mouse_pos.x <= edge_margin:
		translate(-right * edge_speed * delta)
	elif mouse_pos.x >= size.x - edge_margin:
		translate(right * edge_speed * delta)
	if mouse_pos.y <= edge_margin:
		translate(forward * edge_speed * delta)
	elif mouse_pos.y >= size.y - edge_margin:
		translate(-forward * edge_speed * delta)
	_clamp_position()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			rotating = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var forward = Vector3(0, 0, -1).rotated(Vector3.UP, yaw)
			translate(forward * zoom_speed)
			_clamp_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var forward = Vector3(0, 0, -1).rotated(Vector3.UP, yaw)
			translate(-forward * zoom_speed)
			_clamp_position()
	elif event is InputEventMouseMotion:
		if right_panning:
			var right = Vector3(1, 0, 0).rotated(Vector3.UP, yaw)
			var forward = Vector3(0, 0, -1).rotated(Vector3.UP, yaw)
			translate((-right * event.relative.x + forward * event.relative.y) * pan_speed)
			_clamp_position()
		elif rotating:
			yaw -= event.relative.x * rotation_speed
			rotation.y = yaw

func _clamp_position() -> void:
	global_position.y = fixed_height
	global_position.x = clamp(global_position.x, bounds_min.x, bounds_max.x)
	global_position.z = clamp(global_position.z, bounds_min.y, bounds_max.y)
