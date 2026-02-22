extends Camera3D

@export var pan_speed := 0.03
@export var zoom_speed := 2.0
@export var min_x := -12.0
@export var max_x := 12.0
@export var min_z := -24.0
@export var max_z := 24.0
@export var min_y := 12.0
@export var max_y := 36.0

var drag_panning := false
var target_height := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	target_height = position.y

func _unhandled_input(event: InputEvent) -> void:
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
		var right := Vector3(basis.x.x, 0, basis.x.z).normalized()
		var forward := Vector3(basis.z.x, 0, basis.z.z).normalized()
		translate((-right * event.relative.x + -forward * event.relative.y) * pan_speed)
		position.y = target_height
		_clamp_to_bounds()

func _clamp_to_bounds() -> void:
	position.x = clamp(position.x, min_x, max_x)
	position.z = clamp(position.z, min_z, max_z)
	target_height = clamp(target_height, min_y, max_y)
	position.y = target_height
