extends Node3D

var EnemyScene = preload("res://assets/models/enemy.tscn")
var TowerScene = preload("res://assets/models/tower.tscn")
var PathScene = preload("res://assets/models/path.tscn")
var CoreScene = preload("res://assets/models/core.tscn")
var PlayerScene = preload("res://assets/models/player.tscn")

var path_positions: Array = []
var spawn_time := 0.0
var spawn_interval := 2.0
var game_started := false
var available_slots := [
Vector3(-15, 0, 0),
Vector3(-10, 0, 5),
Vector3(-5, 0, 5),
Vector3(-5, 0, 0)
]
var next_slot := 0
var player

@onready var start_button = $CanvasLayer/Control/VBoxContainer/StartButton
@onready var hard_mode = $CanvasLayer/Control/VBoxContainer/HardMode

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
player = PlayerScene.instantiate()
player.position = Vector3(0, 0, -5)
add_child(player)
player.set_physics_process(false)
start_button.pressed.connect(start_game)
set_process(true)
set_process_input(true)

func start_game() -> void:
game_started = true
$CanvasLayer.hide()
if hard_mode.button_pressed:
spawn_interval = 1.0
else:
spawn_interval = 2.0
spawn_time = spawn_interval
player.set_physics_process(true)

func _input(event: InputEvent) -> void:
if not game_started:
return
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
if not game_started:
return
spawn_time -= delta
if spawn_time <= 0:
spawn_enemy()
spawn_time = spawn_interval

func spawn_enemy() -> void:
var enemy = EnemyScene.instantiate()
enemy.position = path_positions[0]
add_child(enemy)
enemy.add_to_group("enemies")
