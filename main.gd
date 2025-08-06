extends Node3D

var EnemyScene = preload("res://assets/models/enemy.tscn")
var TowerScene = preload("res://assets/models/tower.tscn")
var PathScene = preload("res://assets/models/path.tscn")
var CoreScene = preload("res://assets/models/core.tscn")

@export var camera_speed := 5.0

var path_positions: Array = []
var spawn_time := 0.0
var spawn_interval := 2.0
var game_started := false
var editing_mode := false

@onready var start_menu = $CanvasLayer/Control
@onready var start_button = $CanvasLayer/Control/VBoxContainer/StartButton
@onready var hard_mode = $CanvasLayer/Control/VBoxContainer/HardMode
@onready var edit_button = $CanvasLayer/EditButton
@onready var camera = $Camera3D
var preview_path

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

		preview_path = PathScene.instantiate()
		var mesh = preview_path.get_node("Mesh") as MeshInstance3D
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(1, 1, 1, 0.5)  # semi-transparent white
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.flags_transparent = true  # Enable transparency

		mesh.set_surface_override_material(0, material)

		preview_path.visible = false
		add_child(preview_path)

		start_button.pressed.connect(start_game)
		edit_button.pressed.connect(toggle_edit)
		edit_button.visible = false
		set_process(true)
		set_process_input(true)
		set_physics_process(true)

func start_game() -> void:
		game_started = true
		start_menu.hide()
		edit_button.show()

		if hard_mode.button_pressed:
				spawn_interval = 1.0
		else:
				spawn_interval = 2.0

		spawn_time = spawn_interval

func toggle_edit() -> void:
		editing_mode = not editing_mode
		edit_button.text = "Resume" if editing_mode else "Edit Paths"
		var enemies = get_tree().get_nodes_in_group("enemies")
		for e in enemies:
				e.set_physics_process(not editing_mode)

func _input(event: InputEvent) -> void:
		if not game_started:
				return

		if event.is_action_pressed("place_path"):
				add_path_segment(preview_path.position)

func add_path_segment(pos: Vector3) -> void:
		pos.y = 0
		path_positions.insert(path_positions.size() - 1, pos)
		var p = PathScene.instantiate()
		p.position = pos
		p.add_to_group("paths")
		add_child(p)

func _physics_process(delta: float) -> void:
		if not game_started:
				return

		var input_dir := Vector3.ZERO
		if Input.is_action_pressed("move_forward"):
				input_dir.z -= 1
		if Input.is_action_pressed("move_backward"):
				input_dir.z += 1
		if Input.is_action_pressed("move_left"):
				input_dir.x -= 1
		if Input.is_action_pressed("move_right"):
				input_dir.x += 1
		if input_dir != Vector3.ZERO:
				input_dir = input_dir.normalized()
				camera.translate(input_dir * camera_speed * delta)

func _process(delta: float) -> void:
		if game_started:
				update_preview()

		if not game_started or editing_mode:
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
				return
		var t = -origin.y / dir.y
		var pos = origin + dir * t
		preview_path.position = pos
		preview_path.show()

func spawn_enemy() -> void:
		var enemy = EnemyScene.instantiate()
		enemy.position = path_positions[0]
		add_child(enemy)
		enemy.add_to_group("enemies")
