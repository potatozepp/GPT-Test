extends Node3D

var EnemyScene = preload("res://assets/models/enemy.tscn")
var TowerScene = preload("res://assets/models/tower.tscn")
var PathScene = preload("res://assets/models/path.tscn")
var CoreScene = preload("res://assets/models/core.tscn")

var path_positions: Array = []
var spawn_time := 0.0
var spawn_interval := 2.0
var game_loaded := false
var waves_running := false
var editing_mode := false
var placement_mode := "path"
const BOUNDS_MIN := Vector2(-25, -25)
const BOUNDS_MAX := Vector2(25, 25)

@onready var start_menu = $CanvasLayer/Control
@onready var start_button = $CanvasLayer/Control/VBoxContainer/StartButton
@onready var hard_mode = $CanvasLayer/Control/VBoxContainer/HardMode
@onready var edit_button = $CanvasLayer/EditButton
@onready var run_button = $CanvasLayer/RunButton
@onready var stop_button = $CanvasLayer/StopButton
@onready var path_button = $CanvasLayer/PathButton
@onready var turret_button = $CanvasLayer/TurretButton
@onready var camera = $Camera3D
var preview_path
var preview_tower
var selected_node: Node3D
var original_material: Material

func _ready() -> void:
	var core = CoreScene.instantiate()
	core.position = Vector3(0, 0, 0)
	add_child(core)

	path_positions = [Vector3(-20, 0, 0), core.position]

	var start_path = PathScene.instantiate()
	start_path.position = path_positions[0]
	start_path.add_to_group("paths")
	add_child(start_path)
	var sp_mesh = start_path.get_node("Mesh") as MeshInstance3D
	var sp_mat := StandardMaterial3D.new()
	sp_mat.albedo_color = Color(1, 0, 0)
	sp_mesh.set_surface_override_material(0, sp_mat)

	var tower = TowerScene.instantiate()
	tower.position = Vector3(-10, 0, 2)
	add_child(tower)
	tower.add_to_group("towers")

	preview_path = PathScene.instantiate()
	var mesh = preview_path.get_node("Mesh") as MeshInstance3D
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1, 1, 1, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	mesh.set_surface_override_material(0, material)
	preview_path.visible = false
	add_child(preview_path)
	preview_tower = TowerScene.instantiate()
	var tmesh = preview_tower.get_node("Mesh") as MeshInstance3D
	var tmat := StandardMaterial3D.new()
	tmat.albedo_color = Color(1, 1, 1, 0.5)
	tmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tmat.flags_transparent = true
	tmesh.set_surface_override_material(0, tmat)
	preview_tower.visible = false
	add_child(preview_tower)

	start_button.pressed.connect(start_game)
	edit_button.pressed.connect(toggle_edit)
	run_button.pressed.connect(start_waves)
	stop_button.pressed.connect(stop_waves)
	path_button.pressed.connect(set_mode_path)
	turret_button.pressed.connect(set_mode_turret)
	edit_button.visible = false
	run_button.visible = false
	stop_button.visible = false
	path_button.visible = false
	turret_button.visible = false
	set_process(true)
	set_process_unhandled_input(true)

func start_game() -> void:
	game_loaded = true
	start_menu.hide()
	edit_button.show()
	run_button.show()
	stop_button.hide()
	path_button.show()
	turret_button.show()
	editing_mode = false
	edit_button.text = "Edit"
	preview_path.hide()
	preview_tower.hide()
	path_button.disabled = true
	turret_button.disabled = true

	if hard_mode.button_pressed:
		spawn_interval = 1.0
	else:
		spawn_interval = 2.0

func toggle_edit() -> void:
	if waves_running:
		return
	editing_mode = not editing_mode
	edit_button.text = "Resume" if editing_mode else "Edit"
	if editing_mode:
		if placement_mode == "path":
			preview_path.show()
		else:
			preview_tower.show()
	else:
		preview_path.hide()
		preview_tower.hide()
	path_button.disabled = not editing_mode
	turret_button.disabled = not editing_mode
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		e.set_physics_process(not editing_mode)

func start_waves() -> void:
	if not game_loaded:
		return
	waves_running = true
	editing_mode = false
	edit_button.disabled = true
	edit_button.text = "Edit"
	run_button.hide()
	stop_button.show()
	preview_path.hide()
	preview_tower.hide()
	spawn_time = spawn_interval

func stop_waves() -> void:
	if not waves_running:
		return
	waves_running = false
	editing_mode = true
	edit_button.disabled = false
	edit_button.text = "Resume"
	run_button.show()
	stop_button.hide()
	if placement_mode == "path":
		preview_path.show()
		preview_tower.hide()
	else:
		preview_tower.show()
		preview_path.hide()
	spawn_time = spawn_interval
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		e.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if not game_loaded:
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_DELETE and selected_node:
		if selected_node.is_in_group("paths"):
			path_positions.erase(selected_node.position)
		selected_node.queue_free()
		selected_node = null
		original_material = null
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = event.position
		var origin = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, origin + dir * 1000)
		var result = space.intersect_ray(query)
		if result:
			var node = result.collider
			if node.is_in_group("paths") or node.is_in_group("towers"):
				select_node(node)
				return
			elif node.get_parent() and (node.get_parent().is_in_group("paths") or node.get_parent().is_in_group("towers")):
				select_node(node.get_parent())
				return
		clear_selection()
		if editing_mode:
			if placement_mode == "path":
				add_path_segment(preview_path.position)
			else:
				place_turret(preview_tower.position)

func add_path_segment(pos: Vector3) -> void:
	pos.y = 0
	if not _within_bounds(pos):
		return
	var shape := BoxShape3D.new()
	shape.size = Vector3(2, 0.25, 2)
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis(), pos)
	var space = get_world_3d().direct_space_state
	if space.intersect_shape(params).size() > 0:
		return
	path_positions.insert(path_positions.size() - 1, pos)
	var p = PathScene.instantiate()
	p.position = pos
	p.add_to_group("paths")
	add_child(p)

func place_turret(pos: Vector3) -> void:
	pos.y = 0
	if not _within_bounds(pos):
		return
	var shape := BoxShape3D.new()
	shape.size = Vector3(1, 1, 1)
	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis(), pos)
	var space = get_world_3d().direct_space_state
	if space.intersect_shape(params).size() > 0:
		return
	var t = TowerScene.instantiate()
	t.position = pos
	t.add_to_group("towers")
	add_child(t)

func select_node(node: Node3D) -> void:
	clear_selection()
	selected_node = node
	var mesh = node.get_node_or_null("Mesh") as MeshInstance3D
	if mesh:
		original_material = mesh.get_active_material(0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1, 0, 0)
		mesh.set_surface_override_material(0, mat)

func clear_selection() -> void:
	if selected_node:
		var mesh = selected_node.get_node_or_null("Mesh") as MeshInstance3D
		if mesh and original_material:
			mesh.set_surface_override_material(0, original_material)
	selected_node = null
	original_material = null

func _process(delta: float) -> void:
	if editing_mode:
		update_preview()

	if not waves_running:
		return

	spawn_time -= delta
	if spawn_time <= 0:
		spawn_enemy()
		spawn_time = spawn_interval

func update_preview() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	if dir.y == 0:
		preview_path.hide()
		preview_tower.hide()
		return
	var t = -origin.y / dir.y
	var pos = origin + dir * t
	pos = pos.snapped(Vector3.ONE)
	if placement_mode == "path":
		preview_path.position = pos
		var shape := BoxShape3D.new()
		shape.size = Vector3(2, 0.25, 2)
		var params := PhysicsShapeQueryParameters3D.new()
		params.shape = shape
		params.transform = Transform3D(Basis(), pos)
		var space = get_world_3d().direct_space_state
		if _within_bounds(pos) and space.intersect_shape(params).size() == 0:
			preview_path.show()
		else:
			preview_path.hide()
		preview_tower.hide()
	else:
		preview_tower.position = pos
		var shape_t := BoxShape3D.new()
		shape_t.size = Vector3(1, 1, 1)
		var params_t := PhysicsShapeQueryParameters3D.new()
		params_t.shape = shape_t
		params_t.transform = Transform3D(Basis(), pos)
		var space_t = get_world_3d().direct_space_state
		if _within_bounds(pos) and space_t.intersect_shape(params_t).size() == 0:
			preview_tower.show()
		else:
			preview_tower.hide()
		preview_path.hide()

func set_mode_path() -> void:
	placement_mode = "path"
	preview_tower.hide()
	if editing_mode:
		preview_path.show()

func set_mode_turret() -> void:
	placement_mode = "turret"
	preview_path.hide()
	if editing_mode:
		preview_tower.show()

func spawn_enemy() -> void:
	var enemy = EnemyScene.instantiate()
	enemy.position = path_positions[0]
	add_child(enemy)
	enemy.add_to_group("enemies")

func _within_bounds(pos: Vector3) -> bool:
	return pos.x >= BOUNDS_MIN.x and pos.x <= BOUNDS_MAX.x and pos.z >= BOUNDS_MIN.y and pos.z <= BOUNDS_MAX.y
