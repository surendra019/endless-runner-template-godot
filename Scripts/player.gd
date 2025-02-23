extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var SPEED = 5.0
const JUMP_VELOCITY = 10

var is_sliding: bool
var direction_changed: bool
var vertical_action_performed: bool

func _ready() -> void:
	velocity.z = -SPEED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2



	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	var collision: KinematicCollision3D = get_last_slide_collision()
	if collision:
		var collider: Node3D = collision.get_collider()
		if collider.is_in_group("platform"):
			if get_parent().current_platform_ref != collider:
				if get_parent().current_platform_ref:
					get_parent().current_platform_ref.queue_free()
				get_parent().is_next_spawned = false
				get_parent().current_platform_ref = collider
				
	move_and_slide()
	handle_animations()
	
func jump() -> void:
	# Handle jump.
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func slide() -> void:
	SPEED = 10
	is_sliding = true
	collision_shape_3d.shape.height = .7
	collision_shape_3d.position.y = .644
	await get_tree().create_timer(1.5).timeout
	collision_shape_3d.shape.height = 1.63
	collision_shape_3d.position.y = 1.39
	is_sliding = false
	SPEED = 5

func handle_animations() -> void:
	animation_tree.set("parameters/conditions/run", is_on_floor() and not is_sliding)
	animation_tree.set("parameters/conditions/jump", not is_on_floor())
	animation_tree.set("parameters/conditions/slide", is_on_floor() and is_sliding)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var drag: Vector2 = event.relative
		if not direction_changed:
			if abs(drag.x) > abs(drag.y):
				var direction: int = sign(event.relative.x)
				if get_parent().is_valid_move(get_parent().current_player_pos + direction):
					direction_changed = true
					get_parent().tween_player(get_parent().current_player_pos + direction)
			else:
				var direction: int = sign(event.relative.y)
				if not vertical_action_performed:
					if direction == -1:
						jump()
					else:
						slide()
	if event is InputEventScreenTouch:
		if !event.pressed:
			direction_changed = false
			
