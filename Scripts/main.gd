extends Node3D

@onready var player: CharacterBody3D = $Player

@onready var positions: Array[Marker3D] = [$Left, $Center, $Right]
@onready var timer: Timer = $Timer
@onready var ui: CanvasLayer = $UI

const JUMP_OBSTACLE = preload("res://Scenes/jump_obstacle.tscn")
const HORIZONTAL_OBSTACLE = preload("res://Scenes/horizontal_obstacle.tscn")
const PLATFORM = preload("res://Scenes/platform.tscn")

const HORIZONTAL_OB_Y: float = 2.5
const JUMP_OB_Y: float = 2
const SLIDE_OB_Y: float = 3.2



var current_player_pos: int
var current_platform_ref: Node3D

var is_next_spawned: bool
var current_z_distance: float

func _ready() -> void:
	ui.hide()
	initialize_player()

func _process(delta: float) -> void:
	current_z_distance = player.global_position.z - 30
	if current_platform_ref:
		check_distance_from_player()
	if get_tree().has_group("obstacle"):
		for i in get_tree().get_nodes_in_group("obstacle"):
			if i.global_position.z > player.global_position.z + 4:
				i.queue_free()
				print("freed")

# spawns the obstacle which forces player to turn.
func spawn_horizontal_obstacle() -> void:
	var o = HORIZONTAL_OBSTACLE.instantiate()
	add_child(o)
	o.global_position.y = HORIZONTAL_OB_Y
	o.global_position.x = positions.pick_random().global_position.x
	o.global_position.z = current_z_distance
	timer.wait_time = 1 + randf_range(1, 2)
	
# spawns the obstacle which forces player to turn.
func spawn_jump_obstacle() -> void:
	var o = JUMP_OBSTACLE.instantiate()
	add_child(o)
	o.global_position.y = JUMP_OB_Y
	o.global_position.x = positions[1].global_position.x
	o.global_position.z = current_z_distance
	timer.wait_time = 1 + randf_range(1, 2)

# spawns the obstacle which forces player to turn.
func spawn_slide_obstacle() -> void:
	var o = JUMP_OBSTACLE.instantiate()
	add_child(o)
	o.global_position.y = SLIDE_OB_Y
	o.global_position.x = positions[1].global_position.x
	o.global_position.z = current_z_distance
	timer.wait_time = 1 + randf_range(1, 2)
	
func check_distance_from_player() -> void:
	var distance: float = (current_platform_ref.end.global_position.distance_to(player.global_position))
	if distance <= 30 and not is_next_spawned:
		spawn_platform(current_platform_ref.end.global_position)
		is_next_spawned = true

func game_over() -> void:
	ui.show()
	player.velocity.z = 0
	
# sets the initial property of the player.
func initialize_player() -> void:
	player.global_position.x = positions[1].global_position.x
	current_player_pos = 1
	
# tweens the player's x position around three pivots.
func tween_player(new_pos: int) -> void:
	if not is_valid_move(new_pos):
		return
	
	current_player_pos = new_pos
	var t: Tween = create_tween()
	t.tween_property(player, "global_position:x", positions[new_pos].global_position.x, .1)
	t.play()
	

# spawns the platform at the given position.
func spawn_platform(pos: Vector3) -> void:
	var p: Node3D = PLATFORM.instantiate()
	add_child(p)
	p.global_position = pos
	
func is_valid_move(new_pos: int) -> bool:
	if new_pos > positions.size() - 1 or new_pos < 0:
		return false
	return true


func _on_timer_timeout() -> void:
	var pro: int = randi_range(0, 3)
	match pro:
		0:
			spawn_horizontal_obstacle()
		1:
			spawn_jump_obstacle()
		2:
			spawn_slide_obstacle()
			


func _on_retry_btn_pressed() -> void:
	get_tree().reload_current_scene()
