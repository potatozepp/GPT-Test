extends Node2D

var Enemy = preload("res://enemy.gd")
var Tower = preload("res://tower.gd")

var path := [
    Vector2(0, 0),
    Vector2(400, 0),
    Vector2(400, 400)
]

var spawn_time := 0.0

func _ready() -> void:
    var tower = Tower.new()
    tower.position = Vector2(200, 200)
    add_child(tower)
    set_process(true)

func _process(delta: float) -> void:
    spawn_time -= delta
    if spawn_time <= 0:
        spawn_enemy()
        spawn_time = 2

func spawn_enemy() -> void:
    var enemy = Enemy.new()
    enemy.position = path[0]
    enemy.path = path
    add_child(enemy)
    enemy.add_to_group("enemies")
