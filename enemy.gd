extends Node3D

@export var speed := 5.0
var current_index := 0
var hp := 3

func _physics_process(delta: float) -> void:
        var main = get_tree().get_root().get_node("Main")
        var positions: Array = main.path_positions
        if current_index >= positions.size() - 1:
                print("Game Over")
                get_tree().quit()
                return
        var target: Vector3 = positions[current_index + 1]
        var direction := (target - position).normalized()
        var distance := speed * delta
        if position.distance_to(target) <= distance:
                position = target
                current_index += 1
        else:
                position += direction * distance

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
