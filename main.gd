extends Node3D

var EnemyScene = preload("res://assets/models/enemy.tscn")
var TowerScene = preload("res://assets/models/tower.tscn")
var PathScene = preload("res://assets/models/path.tscn")
var CoreScene = preload("res://assets/models/core.tscn")

var path_positions: Array = []
var spawn_time := 0.0
var available_slots := [
	Vector3(-15, 0, 0),
	Vector3(-10, 0, 5),
	Vector3(-5, 0, 5),
	Vector3(-5, 0, 0)
]
var next_slot := 0

func _ready() -> void:
	var core = CoreScene.instantiate()
	core.position = Vector3(0, 0, 0)
	add_child(core)
	path_positions = [Vector3(-20, 0, 0), core.position]
	var start_path = PathScene.instantiate()
	start_path.position = path_positions[0]
	start_path.add_to_group("paths")
	add_child(start_path)
	var tower = TowerScene.instantiate()
	tower.position = Vector3(-10, 0, 2)
	add_child(tower)
	set_process(true)
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("place_path"):
		if next_slot < available_slots.size():
			add_path_segment(available_slots[next_slot])
			next_slot += 1

func add_path_segment(pos: Vector3) -> void:
	path_positions.insert(path_positions.size() - 1, pos)
	var p = PathScene.instantiate()
	p.position = pos
	p.add_to_group("paths")
	add_child(p)

func _process(delta: float) -> void:
	spawn_time -= delta
	if spawn_time <= 0:
		spawn_enemy()
		spawn_time = 2.0

func spawn_enemy() -> void:
	var enemy = EnemyScene.instantiate()
	enemy.position = path_positions[0]
	add_child(enemy)
	enemy.add_to_group("enemies")
