extends Node3D
class_name Projectile

@export var speed := 5.0
@export var damage := 1
var direction := Vector3.ZERO
var target: Node3D
var lifetime := 5.0

func _ready():
    var mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = SphereMesh.new()
    add_child(mesh_instance)

func setup(start: Vector3, target_node: Node3D, miss_radius: float) -> void:
    position = start
    target = target_node
    var aim = target_node.position + Vector3(randf_range(-miss_radius, miss_radius), 0, randf_range(-miss_radius, miss_radius))
    direction = (aim - start).normalized()

func _physics_process(delta: float) -> void:
    position += direction * speed * delta
    lifetime -= delta
    if target and position.distance_to(target.position) < 0.5:
        if target.has_method("take_damage"):
            target.take_damage(damage)
        queue_free()
    elif lifetime <= 0:
        queue_free()
