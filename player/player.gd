extends CharacterBody3D

const ACCELERATION:float = 2
const MAX_SPEED:float = 1
@export var camera:Camera3D
@export var camera_rig:Node3D
@export var sprite:AnimatedSprite3D
@export var opponent:Opponent

var parallel_speed:float
var perpendicular_speed:float

func _physics_process(delta: float) -> void:
	handle_parallel_move()
	handle_perpendicular_move()
	handle_relative()
	face_opponent()
	move_and_collide(velocity * delta)
	
func handle_parallel_move() -> void:
	var parallel_acceleration:float
	parallel_acceleration = Input.get_axis("move_back", "move_forward") * ACCELERATION
	parallel_speed += parallel_acceleration
	if parallel_acceleration == 0:
		parallel_speed = 0
	parallel_speed = clamp(parallel_speed, -MAX_SPEED, MAX_SPEED)
	
func handle_perpendicular_move() -> void:
	var perpendicular_acceleration:float
	perpendicular_acceleration = Input.get_axis("move_left", "move_right") * ACCELERATION
	perpendicular_speed += perpendicular_acceleration
	if perpendicular_acceleration == 0:
		perpendicular_speed = 0
	perpendicular_speed = clamp(perpendicular_speed, -MAX_SPEED, MAX_SPEED)
	
func handle_relative() -> void:
	var parallel_velocity:Vector3
	var perpendicular_velocity:Vector3
	parallel_velocity = parallel_speed * global_position.direction_to(opponent.global_position)
	var perpendicular_direction:Vector3 = global_position.direction_to(opponent.global_position).rotated(Vector3(0, -1, 0), PI / 2)
	perpendicular_velocity = perpendicular_speed * perpendicular_direction
	velocity = parallel_velocity + perpendicular_velocity
	
func face_opponent() -> void:
	var x_dif:float = global_position.x - opponent.global_position.x
	var z_dif:float = global_position.z - opponent.global_position.z
	camera_rig.rotation.y = (atan(z_dif / x_dif) + (PI / 2))
	print("X: " + str(x_dif))
	print("Z: " + str(z_dif))
	print(camera_rig.rotation.y)
	print(camera_rig.global_position)
