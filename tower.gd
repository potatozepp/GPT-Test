extends Node3D

@export var range := 10.0
@export var fire_rate := 1.0
var _cooldown := 0.0

func _physics_process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0:
		return
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if position.distance_to(e.position) <= range:
			e.take_damage(1)
			_cooldown = fire_rate
			break
