extends Marker2D

var map
var raccoon
var rng = RandomNumberGenerator.new()
var spawn_timer = Timer.new()
@onready var enemy = preload("res://Scenes/enemy.tscn")

var id : int = 0

var enemy_health : float = 4.0
var enemy_walk : int = 300
var enemy_run : int = 400
var enemy_speedup : int = 10
var enemy_attack_strength : float = 1.0

var enemy_minimal_spawn_time : float = 2
var enemy_spawn_interval : float = 3
var enemies_to_spawn : int = 3
var enemies_left_to_spawn : int = 3
var enemies_killed : int = 0

func _ready():
	rng.randomize()
	spawn_timer.timeout.connect(spawn_enemy)
	add_child(spawn_timer)
	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	map = get_parent()
	raccoon = map.get_node("TileMap").get_node("Raccoon")

func start():
	configurar_por_dificuldade()
	spawn_timer.start(rng.randf_range(enemy_minimal_spawn_time, enemy_minimal_spawn_time + enemy_spawn_interval))

func spawn_enemy():
	var new_enemy = enemy.instantiate()
	new_enemy.global_position = global_position
	new_enemy.set_target(raccoon)
	new_enemy.set_data(enemy_health, enemy_walk, enemy_run, enemy_speedup)
	new_enemy.enemy_attack_strength = enemy_attack_strength
	add_child(new_enemy)
	enemies_left_to_spawn -= 1
	
	if enemies_left_to_spawn > 0:
		spawn_timer.start(rng.randf_range(enemy_minimal_spawn_time, enemy_minimal_spawn_time + enemy_spawn_interval))

func end():
	map.spawner_finished(id)

func enemy_killed():
	enemies_killed += 1
	map.add_points()
	
	if enemies_killed == enemies_to_spawn:
		enemies_killed = 0
		end()

func set_enemies_to_spawn(n_enemies : int):
	enemies_to_spawn = n_enemies
	enemies_left_to_spawn = n_enemies

func set_enemy_minimal_spawn_time(spawn_time : float):
	enemy_minimal_spawn_time = spawn_time

func set_enemy_spawn_interval(spawn_interval : float):
	enemy_spawn_interval = spawn_interval

func set_enemy_health(health : float):
	enemy_health = health

func set_enemy_attack_strength(strength: float):
	enemy_attack_strength = strength

func set_enemy_speed(i_min : int, i_max : int, i_speedup : int):
	enemy_walk = i_min
	enemy_run = i_max
	enemy_speedup = i_speedup

func set_id(num):
	id = num

func configurar_por_dificuldade():
	match Globals.dificuldade:
		"facil":
			set_enemies_to_spawn(2)
			set_enemy_minimal_spawn_time(3.0)
			set_enemy_spawn_interval(4.0)
			set_enemy_speed(60, 100, 2)
			set_enemy_health(3.0)
			set_enemy_attack_strength(0.5)
		"medio":
			set_enemies_to_spawn(4)
			set_enemy_minimal_spawn_time(2.0)
			set_enemy_spawn_interval(3.0)
			set_enemy_speed(100, 160, 6)
			set_enemy_health(4.0)
			set_enemy_attack_strength(1.0)
		"dificil":
			set_enemies_to_spawn(6)
			set_enemy_minimal_spawn_time(1.0)
			set_enemy_spawn_interval(2.0)
			set_enemy_speed(150, 220, 10)
			set_enemy_health(5.0)
			set_enemy_attack_strength(1.5)
