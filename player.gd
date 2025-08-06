extends Node3D

@export var speed := 5.0

func _physics_process(delta: float) -> void:
    var input_dir := Vector3.ZERO
    if Input.is_action_pressed("move_forward"):
        input_dir.z -= 1
    if Input.is_action_pressed("move_backward"):
        input_dir.z += 1
    if Input.is_action_pressed("move_left"):
        input_dir.x -= 1
    if Input.is_action_pressed("move_right"):
        input_dir.x += 1
    if input_dir != Vector3.ZERO:
        input_dir = input_dir.normalized()
        translate(input_dir * speed * delta)
