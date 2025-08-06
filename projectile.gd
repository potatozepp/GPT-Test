extends Node3D
class_name Projectile

@export var speed := 5.0
@export var damage := 1
@export var hitbox := 1.0
var direction := Vector3.ZERO
var target: Node3D
var lifetime := 5.0
var bulletsize := Vector3(0.3, 0.3, 0.3)

func _ready():
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.scale = bulletsize
	add_child(mesh_instance)

func setup(start: Vector3, target_node: Node3D, miss_radius: float) -> void:
	position = start
	target = target_node
	var aim = target_node.position
	direction = (aim - start).normalized()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if target and position.distance_to(target.position) < hitbox:
		if target.has_method("take_damage"):
			target.take_damage(damage)
		queue_free()
	elif lifetime <= 0:
		queue_free()
