extends Camera3D

@export var move_speed := 15.0
@export var fast_speed := 50.0
@export var rotation_speed := 0.005
@export var pan_speed := 0.02
@export var zoom_speed := 2.0
@export var edge_margin := 10
@export var edge_speed := 15.0
@export var min_x := -30.0
@export var max_x := 30.0
@export var min_z := -30.0
@export var max_z := 30.0

var yaw := 0.0
var drag_panning := false
var rotating := false
var start_height := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	yaw = rotation.y
	start_height = position.y

func _process(delta):
	var speed = move_speed
	if Input.is_action_pressed("ui_shift"):
		speed = fast_speed
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		dir.y += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if dir != Vector2.ZERO:
		var forward = Vector3(basis.z.x, 0, basis.z.z).normalized()
		var right = Vector3(basis.x.x, 0, basis.x.z).normalized()
		translate((right * dir.x + forward * dir.y) * speed * delta)
	_clamp_to_bounds()

## Edge Movement

	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		var mouse_pos = get_viewport().get_mouse_position()
		var size = get_viewport().get_visible_rect().size
		var forward = Vector3(basis.z.x, 0, basis.z.z).normalized()
		var right = Vector3(basis.x.x, 0, basis.x.z).normalized()
		if mouse_pos.x <= edge_margin:
			translate(-right * edge_speed * delta)
		elif mouse_pos.x >= size.x - edge_margin:
			translate(right * edge_speed * delta)
		if mouse_pos.y <= edge_margin:
			translate(-forward * edge_speed * delta)
		elif mouse_pos.y >= size.y - edge_margin:
			translate(forward * edge_speed * delta)
		_clamp_to_bounds()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			rotating = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			drag_panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var forward = Vector3(basis.z.x, 0, basis.z.z).normalized()
			translate(forward * zoom_speed)
			_clamp_to_bounds()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var forward = Vector3(basis.z.x, 0, basis.z.z).normalized()
			translate(-forward * zoom_speed)
			_clamp_to_bounds()
	elif event is InputEventMouseMotion:
		if rotating:
			yaw -= event.relative.x * rotation_speed
			rotation.y = yaw
		elif drag_panning:
			var right = Vector3(basis.x.x, 0, basis.x.z).normalized()
			var up = Vector3(basis.z.x, 0, basis.z.z).normalized()
			translate((-right * event.relative.x + -up * event.relative.y) * pan_speed)
			_clamp_to_bounds()

func _clamp_to_bounds():
	position.y = start_height
	position.x = clamp(position.x, min_x, max_x)
	position.z = clamp(position.z, min_z, max_z)
