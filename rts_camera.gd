extends Camera3D

@export var move_speed := 15.0
@export var fast_speed := 50.0
@export var pan_speed := 0.02
@export var zoom_speed := 2.0
@export var min_x := -30.0
@export var max_x := 30.0
@export var min_z := -30.0
@export var max_z := 30.0
@export var min_y := 5.0
@export var max_y := 30.0

var drag_panning := false
var target_height := 0.0

func _ready():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		target_height = position.y

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
				position.y = target_height
		_clamp_to_bounds()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			drag_panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			translate(-basis.z.normalized() * zoom_speed)
			target_height = position.y
			_clamp_to_bounds()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			translate(basis.z.normalized() * zoom_speed)
			target_height = position.y
			_clamp_to_bounds()
	elif event is InputEventMouseMotion and drag_panning:
		var right = Vector3(basis.x.x, 0, basis.x.z).normalized()
		var up = Vector3(basis.z.x, 0, basis.z.z).normalized()
		translate((-right * event.relative.x + -up * event.relative.y) * pan_speed)
		position.y = target_height
		_clamp_to_bounds()

func _clamp_to_bounds():
	position.x = clamp(position.x, min_x, max_x)
	position.z = clamp(position.z, min_z, max_z)
	target_height = clamp(target_height, min_y, max_y)
	position.y = target_height
