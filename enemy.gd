extends Node3D

@export var speed := 5.0
@export var detection_radius := 2.0
var current_index := -1
var hp := 3

func _physics_process(delta: float) -> void:
	var main = get_tree().get_root().get_node("Main")
	var positions: Array = main.path_positions
	var core_pos: Vector3 = positions[positions.size() - 1]

	var found_path := false
	for i in range(positions.size()):
		if position.distance_to(positions[i]) <= detection_radius:
			current_index = i
			found_path = true
			break
	if not found_path:
		current_index = -1

	var target: Vector3 = core_pos
	if current_index != -1:
		var next_index := current_index + 1
		if next_index >= positions.size():
			print("Game Over")
			get_tree().quit()
			return
		var next_target: Vector3 = positions[next_index]
		if position.distance_to(core_pos) < position.distance_to(next_target):
			target = core_pos
		else:
			target = next_target

	var direction := (target - position).normalized()
	var distance := speed * delta
	if position.distance_to(target) <= distance:
		position = target
		if current_index != -1 and target != core_pos:
			current_index += 1
	else:
		position += direction * distance

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
