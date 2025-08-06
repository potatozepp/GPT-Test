extends Node3D

@export var speed := 5.0
var hp := 3
var path: Array = []
var target: Vector3
var last_path_hash := 0

func _ready() -> void:
	var main = _get_main()
	last_path_hash = hash(main.path_positions)
	_update_path()

func _physics_process(delta: float) -> void:
	var main = _get_main()
	var current_hash = hash(main.path_positions)
	if current_hash != last_path_hash:
		last_path_hash = current_hash
		_update_path()

	var direction := (target - position).normalized()
	var distance := speed * delta

	if position.distance_to(target) <= distance:
		position = target
		if target == main.path_positions[-1]:
			print("Game Over")
			get_tree().quit()
			return
		_update_path()
	else:
		position += direction * distance

func _update_path() -> void:
	var main = _get_main()
	var positions: Array = main.path_positions
	var goal: Vector3 = positions[-1]
	var start := _find_nearest(position, positions)
	path = _find_path(start, goal, positions, main.PATH_CONNECT_DISTANCE)
	if path.size() >= 2:
		target = path[1]
	else:
		target = goal

func _find_path(start: Vector3, goal: Vector3, positions: Array, dist: float) -> Array:
	var queue: Array = [start]
	var came_from := {}
	came_from[start] = null
	while queue.size() > 0:
		var current: Vector3 = queue.pop_front()
		if current == goal:
			break
		for next in _get_neighbors(current, positions, dist):
			if not came_from.has(next):
				queue.append(next)
				came_from[next] = current
	var result: Array = []
	if came_from.has(goal):
		var node := goal
		while node != null:
			result.insert(0, node)
			node = came_from[node]
	else:
		result = [start, goal]
	return result

func _get_neighbors(pos: Vector3, positions: Array, dist: float) -> Array:
	var neighbors: Array = []
	for p in positions:
		if p == pos:
			continue
		if abs(p.x - pos.x) + abs(p.z - pos.z) == dist:
			neighbors.append(p)
	return neighbors

func _find_nearest(pos: Vector3, positions: Array) -> Vector3:
	var nearest: Vector3 = positions[0]
	var min_dist := pos.distance_to(nearest)
	for p in positions:
		var d := pos.distance_to(p)
		if d < min_dist:
			min_dist = d
			nearest = p
	return nearest

func _get_main() -> Node:
	return get_tree().get_root().get_node("Main")

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
