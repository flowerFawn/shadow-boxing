extends CharacterBody3D
class_name Player

enum ArmState {
	PASSIVE,
	CHARGING,
	BLOCKING,
}

enum Arm {
	LEFT,
	RIGHT,
	BOTH,
}

const ACCELERATION:float = 2
const DECELERATION:float = 4
const MAX_SPEED:float = 1
const CAMERA_DISTANCE:float = 0.5
const STRONG_THRESHOLD:float = 0.4
const STRONG_DAMAGE:float = 2
const LIGHT_DAMAGE:float = 1
const STRONG_RANGE:float = 0.6
const LIGHT_RANGE:float = 1


@export var camera:Camera3D
@export var sprite:AnimatedSprite3D
@export var opponent:Opponent

@export var parallel_buffer_timer:Timer
@export var perpendicular_buffer_timer:Timer
@export var arm_buffer_timer:Timer

@export var left_stopwatch:Stopwatch
@export var right_stopwatch:Stopwatch

var parallel_speed:float
var perpendicular_speed:float

var parallel_buffer:String:
	set(value):
		parallel_buffer = value
		parallel_buffer_timer.start()
var perpendicular_buffer:String:
	set(value):
		perpendicular_buffer = value
		perpendicular_buffer_timer.start()
var arm_buffer:String:
	set(value):
		arm_buffer = value
		arm_buffer_timer.start()


var left_arm_state:ArmState
var right_arm_state:ArmState

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_strafing()
	handle_attacking()
	move_and_collide(velocity * delta)
	
#region movement

func handle_movement(delta:float) -> void:
	handle_parallel_move(delta)
	handle_perpendicular_move(delta)
	handle_relative()
	face_opponent()


func handle_parallel_move(delta:float) -> void:
	var parallel_acceleration:float
	parallel_acceleration = Input.get_axis("move_back", "move_forward") * ACCELERATION
	if (parallel_acceleration == 0 and parallel_speed != 0) or abs(parallel_speed) > MAX_SPEED:
		var deceleration_direction:float = -(parallel_speed / abs(parallel_speed))
		parallel_acceleration = deceleration_direction * DECELERATION
	parallel_speed += parallel_acceleration * delta
	#parallel_speed = clamp(parallel_speed, -MAX_SPEED, MAX_SPEED)
	
func handle_perpendicular_move(delta:float) -> void:
	var perpendicular_acceleration:float
	perpendicular_acceleration = Input.get_axis("move_left", "move_right") * ACCELERATION
	if (perpendicular_acceleration == 0 and perpendicular_speed != 0) or abs(perpendicular_speed) > MAX_SPEED:
		var deceleration_direction:float = -(perpendicular_speed / abs(perpendicular_speed))
		perpendicular_acceleration = deceleration_direction * DECELERATION
	perpendicular_speed += perpendicular_acceleration * delta
	#perpendicular_speed = clamp(perpendicular_speed, -MAX_SPEED, MAX_SPEED)
	
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
	var difference_vector:Vector2
	difference_vector.x = x_dif
	difference_vector.y = z_dif
	difference_vector = difference_vector.normalized() * CAMERA_DISTANCE
	camera.position.x = difference_vector.x
	camera.position.z = difference_vector.y
	camera.rotation.y = atan2(camera.position.x, camera.position.z)

#endregion

#region strafing
func handle_strafing() -> void:
	if Input.is_action_just_pressed("move_left"):
		if perpendicular_buffer == "move_left":
			strafe_perpendicular(-1)
		perpendicular_buffer = "move_left"
	elif Input.is_action_just_pressed("move_right"):
		if perpendicular_buffer == "move_right":
			strafe_perpendicular(1)
		perpendicular_buffer = "move_right"
		
	if Input.is_action_just_pressed("move_back"):
		if perpendicular_buffer == "move_back":
			strafe_parallel(-1)
		perpendicular_buffer = "move_back"
		
		
func strafe_perpendicular(direction:float) -> void:
	perpendicular_buffer = ""
	perpendicular_speed = MAX_SPEED * direction * 2

func strafe_parallel(direction:float) -> void:
	parallel_buffer = ""
	parallel_speed = MAX_SPEED * direction * 1.5
		
#endregion

#region attacking

func handle_attacking() -> void:
	if Input.is_action_just_pressed("right_arm") and Input.is_action_just_pressed("left_arm"):
		block()
	elif Input.is_action_just_pressed("left_arm"):
		if Input.is_action_pressed("right_arm"):
			block()
		else:
			charge_arm(Arm.LEFT)
	elif Input.is_action_just_pressed("right_arm"):
		if Input.is_action_pressed("left_arm"):
			block()
		else:
			charge_arm(Arm.RIGHT)
			
	if Input.is_action_just_released("left_arm") and left_arm_state == ArmState.CHARGING:
		release_arm(Arm.LEFT)
	elif Input.is_action_just_pressed("right_arm") and right_arm_state == ArmState.CHARGING:
		release_arm(Arm.RIGHT)


func block():
	left_stopwatch.reset()
	right_stopwatch.reset()
	left_arm_state = ArmState.BLOCKING
	right_arm_state = ArmState.BLOCKING
	
func charge_arm(arm:Arm) -> void:
	if arm == Arm.LEFT:
		left_stopwatch.start()
		left_arm_state = ArmState.CHARGING
	elif arm == Arm.RIGHT:
		right_stopwatch.start()
		right_arm_state = ArmState.CHARGING
	
func release_arm(arm:Arm) -> void:
	if is_strafing():
		end_punch(arm)
	if arm == Arm.LEFT:
		if left_stopwatch.time_elapsed >= STRONG_THRESHOLD:
			strong_punch(arm)
		else:
			light_punch(arm)
	elif arm == Arm.RIGHT:
		if right_stopwatch.time_elapsed >= STRONG_THRESHOLD:
			strong_punch(arm)
		else:
			light_punch(arm)
			
#includes cancelling
func end_punch(arm:Arm):
	if arm == Arm.LEFT:
		left_stopwatch.pause()
		left_arm_state = ArmState.PASSIVE
	elif arm == Arm.RIGHT:
		left_stopwatch.pause()
		left_arm_state = ArmState.PASSIVE
		
func light_punch(arm:Arm):
	if not is_in_distance(LIGHT_RANGE):
		print("too_far")
		return
	opponent.take_damage(LIGHT_DAMAGE)
	end_punch(arm)
	
func strong_punch(arm:Arm):
	if not is_in_distance(STRONG_RANGE):
		print("too_far")
		return
	opponent.take_damage(STRONG_DAMAGE)
	end_punch(arm)
	
func is_in_distance(distance:float) -> bool:
	print(distance ** 2)
	print(global_position.distance_squared_to(opponent.global_position))
	return global_position.distance_squared_to(opponent.global_position) <= distance ** 2
	
	
#endregion

func is_strafing() -> bool:
	return parallel_speed > MAX_SPEED or perpendicular_speed > MAX_SPEED


func _on_parallel_buffer_timer_timeout() -> void:
	parallel_buffer = ""


func _on_perpendicular_buffer_timer_timeout() -> void:
	perpendicular_buffer = ""


func _on_arm_buffer_timer_timeout() -> void:
	arm_buffer = ""
