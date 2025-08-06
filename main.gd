extends Node3D

const MIN_X := -30.0
const MAX_X := 30.0
const MIN_Z := -30.0
const MAX_Z := 30.0
const PATH_HALF := Vector2(1, 1)
const TOWER_HALF := Vector2(0.5, 0.5)
const PATH_CONNECT_DISTANCE := 2.0
const TOWER_PATH_PADDING := 0.5

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
var placement_mode := ""

@onready var start_menu = $CanvasLayer/StartMenu
@onready var new_game_button = $CanvasLayer/StartMenu/VBoxContainer/NewGameButton
@onready var load_game_button = $CanvasLayer/StartMenu/VBoxContainer/LoadButton
@onready var settings_button = $CanvasLayer/StartMenu/VBoxContainer/SettingsButton
@onready var exit_button = $CanvasLayer/StartMenu/VBoxContainer/ExitButton
@onready var settings_menu = $CanvasLayer/SettingsMenu
@onready var settings_back = $CanvasLayer/SettingsMenu/VBoxContainer/BackButton
@onready var edit_button = $CanvasLayer/EditButton
@onready var run_button = $CanvasLayer/RunButton
@onready var stop_button = $CanvasLayer/StopButton
@onready var path_button = $CanvasLayer/PathButton
@onready var turret_button = $CanvasLayer/TurretButton
@onready var menu_button = $CanvasLayer/MenuButton
@onready var selection_panel = $CanvasLayer/SelectionPanel
@onready var sell_button = $CanvasLayer/SelectionPanel/VBoxContainer/SellButton
@onready var upgrade_button = $CanvasLayer/SelectionPanel/VBoxContainer/UpgradeButton
@onready var move_button = $CanvasLayer/SelectionPanel/VBoxContainer/MoveButton
@onready var delete_button = $CanvasLayer/SelectionPanel/VBoxContainer/DeleteButton
@onready var camera = $Camera3D
var preview_path
var preview_tower
var selected_node: Node3D
var original_material: Material
var moving_node: Node3D

func in_bounds(pos: Vector3) -> bool:
	return pos.x >= MIN_X and pos.x <= MAX_X and pos.z >= MIN_Z and pos.z <= MAX_Z

func intersects(a_pos: Vector3, a_half: Vector2, b_pos: Vector3, b_half: Vector2) -> bool:
	return abs(a_pos.x - b_pos.x) < a_half.x + b_half.x and abs(a_pos.z - b_pos.z) < a_half.y + b_half.y

func _ready() -> void:
	new_game_button.pressed.connect(start_game)
	load_game_button.pressed.connect(start_game)
	settings_button.pressed.connect(show_settings)
	exit_button.pressed.connect(exit_game)
	settings_back.pressed.connect(hide_settings)
	edit_button.pressed.connect(toggle_edit)
	run_button.pressed.connect(start_waves)
	stop_button.pressed.connect(stop_waves)
	path_button.pressed.connect(set_mode_path)
	turret_button.pressed.connect(set_mode_turret)
	sell_button.pressed.connect(_on_sell_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	move_button.pressed.connect(_on_move_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	edit_button.visible = false
	run_button.visible = false
	stop_button.visible = false
	path_button.visible = false
	turret_button.visible = false
	menu_button.visible = false
	selection_panel.visible = false
	settings_menu.hide()
	set_process(true)
	set_process_unhandled_input(true)

func setup_world() -> void:
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

func start_game() -> void:
	if game_loaded:
		return
	setup_world()
	game_loaded = true
	start_menu.hide()
	settings_menu.hide()
	edit_button.show()
	run_button.show()
	stop_button.hide()
	path_button.show()
	turret_button.show()
	menu_button.show()
	editing_mode = false
	edit_button.text = "Edit"
	path_button.disabled = true
	turret_button.disabled = true
	menu_button.disabled = false
	path_button.text = "Place Path"
	turret_button.text = "Place Turret"
	preview_path.hide()
	preview_tower.hide()

func show_settings() -> void:
	start_menu.hide()
	settings_menu.show()

func hide_settings() -> void:
	settings_menu.hide()
	start_menu.show()

func exit_game() -> void:
	get_tree().quit()

func toggle_edit() -> void:
	if waves_running:
		return
	editing_mode = not editing_mode
	edit_button.text = "Resume" if editing_mode else "Edit"
	if not editing_mode:
		placement_mode = ""
		preview_path.hide()
		preview_tower.hide()
		path_button.text = "Place Path"
		turret_button.text = "Place Turret"
		clear_selection()
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
	run_button.hide()
	stop_button.show()
	placement_mode = ""
	edit_button.hide()
	preview_path.hide()
	preview_tower.hide()
	path_button.hide()
	turret_button.hide()
	spawn_time = spawn_interval

func stop_waves() -> void:
	if not waves_running:
		return
	spawn_time = spawn_interval
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		e.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if not game_loaded:
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_DELETE and selected_node and editing_mode:
		if selected_node.is_in_group("paths"):
			path_positions.erase(selected_node.position)
		selected_node.queue_free()
		clear_selection()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if editing_mode and placement_mode != "":
			if placement_mode == "path":
				add_path_segment(preview_path.position)
			elif placement_mode == "turret":
				place_turret(preview_tower.position)
			elif placement_mode == "path_move" and moving_node:
				move_path_segment(preview_path.position)
			elif placement_mode == "turret_move" and moving_node:
				move_turret(preview_tower.position)
			return
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

func add_path_segment(pos: Vector3) -> void:
	pos.y = 0
	if not in_bounds(pos):
		return
	var connected := false
	for p in path_positions:
		if abs(p.x - pos.x) + abs(p.z - pos.z) == PATH_CONNECT_DISTANCE:
			connected = true
			break
	if not connected:
		return
	for n in get_tree().get_nodes_in_group("paths"):
		if intersects(pos, PATH_HALF, n.position, PATH_HALF):
			return
	for t in get_tree().get_nodes_in_group("towers"):
		if intersects(pos, PATH_HALF, t.position, TOWER_HALF):
			return
	path_positions.insert(path_positions.size() - 1, pos)
	var p = PathScene.instantiate()
	p.position = pos
	p.add_to_group("paths")
	add_child(p)

func place_turret(pos: Vector3) -> void:
	pos.y = 0
	if not in_bounds(pos):
		return
	for n in get_tree().get_nodes_in_group("paths"):
		if intersects(pos, TOWER_HALF + Vector2(TOWER_PATH_PADDING, TOWER_PATH_PADDING), n.position, PATH_HALF):
			return
	for tt in get_tree().get_nodes_in_group("towers"):
		if intersects(pos, TOWER_HALF, tt.position, TOWER_HALF):
			return
	var t = TowerScene.instantiate()
	t.position = pos
	t.add_to_group("towers")
	add_child(t)

func move_turret(pos: Vector3) -> void:
	if not moving_node:
		return
	pos.y = 0
	if not in_bounds(pos):
		return
	for n in get_tree().get_nodes_in_group("paths"):
		if intersects(pos, TOWER_HALF + Vector2(TOWER_PATH_PADDING, TOWER_PATH_PADDING), n.position, PATH_HALF):
			return
	for tt in get_tree().get_nodes_in_group("towers"):
		if tt != moving_node and intersects(pos, TOWER_HALF, tt.position, TOWER_HALF):
			return
	moving_node.position = pos
	moving_node = null
	placement_mode = ""
	preview_tower.hide()

func move_path_segment(pos: Vector3) -> void:
	if not moving_node:
		return
	pos.y = 0
	if not in_bounds(pos):
		return
	for n in get_tree().get_nodes_in_group("paths"):
		if n != moving_node and intersects(pos, PATH_HALF, n.position, PATH_HALF):
			return
	for t in get_tree().get_nodes_in_group("towers"):
		if intersects(pos, PATH_HALF, t.position, TOWER_HALF):
			return
	var idx = path_positions.find(moving_node.position)
	if idx != -1:
		path_positions[idx] = pos
	moving_node.position = pos
	moving_node = null
	placement_mode = ""
	preview_path.hide()

func select_node(node: Node3D) -> void:
	clear_selection()
	selected_node = node
	var mesh = node.get_node_or_null("Mesh") as MeshInstance3D
	if mesh:
		original_material = mesh.get_active_material(0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1, 0, 0)
		mesh.set_surface_override_material(0, mat)
	if node.is_in_group("towers"):
		sell_button.show()
		upgrade_button.show()
		move_button.show()
		delete_button.hide()
	elif node.is_in_group("paths"):
		sell_button.hide()
		upgrade_button.hide()
		move_button.show()
		delete_button.show()
		selection_panel.show()

func clear_selection() -> void:
	if selected_node:
		var mesh = selected_node.get_node_or_null("Mesh") as MeshInstance3D
		if mesh and original_material:
			mesh.set_surface_override_material(0, original_material)
	selected_node = null
	original_material = null
	selection_panel.hide()

func _on_sell_pressed() -> void:
	if selected_node and selected_node.is_in_group("towers"):
		selected_node.queue_free()
		clear_selection()

func _on_upgrade_pressed() -> void:
	if selected_node and selected_node.is_in_group("towers"):
		print("Upgrade not implemented")

func _on_move_pressed() -> void:
	if not selected_node:
		return
	moving_node = selected_node
	if selected_node.is_in_group("paths"):
		placement_mode = "path_move"
		preview_path.position = selected_node.position
		preview_path.show()
		preview_tower.hide()
	elif selected_node.is_in_group("towers"):
		placement_mode = "turret_move"
		preview_tower.position = selected_node.position
		preview_tower.show()
		preview_path.hide()
	clear_selection()

func _on_delete_pressed() -> void:
	if selected_node and selected_node.is_in_group("paths"):
		path_positions.erase(selected_node.position)
		selected_node.queue_free()
		clear_selection()

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
	pos.x = clamp(pos.x, MIN_X, MAX_X)
	pos.z = clamp(pos.z, MIN_Z, MAX_Z)
	if placement_mode == "path" or placement_mode == "path_move":
		preview_path.position = pos
		preview_path.show()
		preview_tower.hide()
	elif placement_mode == "turret" or placement_mode == "turret_move":
		preview_tower.position = pos
		preview_tower.show()
		preview_path.hide()
	else:
		preview_path.hide()
		preview_tower.hide()

func set_mode_path() -> void:
	if placement_mode == "path":
		placement_mode = ""
		preview_path.hide()
		path_button.text = "Place Path"
	else:
		placement_mode = "path"
		path_button.text = "Cancel"
		turret_button.text = "Place Turret"
		preview_tower.hide()
		if editing_mode:
			preview_path.show()
		clear_selection()

func set_mode_turret() -> void:
	if placement_mode == "turret":
		placement_mode = ""
		preview_tower.hide()
		turret_button.text = "Place Turret"
	else:
		placement_mode = "turret"
		turret_button.text = "Cancel"
		path_button.text = "Place Path"
		preview_path.hide()
		if editing_mode:
			preview_tower.show()
		clear_selection()

func _on_menu_pressed() -> void:
	get_tree().reload_current_scene()

func spawn_enemy() -> void:
	var enemy = EnemyScene.instantiate()
	enemy.position = path_positions[0]
	add_child(enemy)
	enemy.add_to_group("enemies")
