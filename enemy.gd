extends Node3D

@export var speed := 5.0
@export var detection_radius := 2.0
var current_index := -1
var hp := 3

func _physics_process(delta: float) -> void:
    var main = get_tree().get_root().get_node("Main")
    var positions: Array = main.path_positions
    for i in range(positions.size()):
        if position.distance_to(positions[i]) <= detection_radius:
            current_index = i
            break
    if current_index == -1:
        return
    var next_index := current_index + 1
    if next_index >= positions.size():
        print("Game Over")
        get_tree().quit()
        return
    var target: Vector3 = positions[next_index]
    var direction := (target - position).normalized()
    var distance := speed * delta
    if position.distance_to(target) <= distance:
        position = target
        current_index = next_index
    else:
        position += direction * distance

func take_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        queue_free()
