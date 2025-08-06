extends Node2D

@export var speed := 50
var path: Array = []
var _current_point := 0
var hp := 3

func _process(delta: float) -> void:
    if _current_point >= path.size():
        queue_free()
        return
    var target: Vector2 = path[_current_point]
    var direction := (target - position).normalized()
    var distance := speed * delta
    if position.distance_to(target) <= distance:
        position = target
        _current_point += 1
    else:
        position += direction * distance

func take_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        queue_free()
