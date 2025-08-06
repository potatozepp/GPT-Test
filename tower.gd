extends Node3D

@export var range := 10.0
@export var fire_rate := 1.0
@export var miss_radius := 0.0
@export var projectile_speed := 100.0
var _cooldown := 0.0
const Projectile = preload("res://projectile.gd")

func _physics_process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0:
		return
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if position.distance_to(e.position) <= range:
			var p = Projectile.new()
			p.speed = projectile_speed
			p.setup(position, e, miss_radius)
			get_parent().add_child(p)
			_cooldown = fire_rate
			break
