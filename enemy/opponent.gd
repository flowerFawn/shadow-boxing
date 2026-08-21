extends CharacterBody3D
class_name Opponent

@export var player:Player

@export var front_sprite:Sprite3D

@export var turn_speed:float = PI / 2

@export var max_hp:float = 10
var hp:float

func _ready() -> void:
	hp = max_hp

func _physics_process(delta: float) -> void:
	face_player(delta)
	move_and_collide(global_position.direction_to(player.global_position) * 0.1 * delta)

func face_player(delta:float) -> void:
	var desired_rotation:float
	var x_dif:float = global_position.x - player.global_position.x
	var z_dif:float = global_position.z - player.global_position.z
	desired_rotation = (atan2(x_dif, z_dif)) + PI
	rotation.y = lerp_angle(rotation.y, desired_rotation, turn_speed * delta)

func take_damage(damage:float) -> void:
	front_sprite.flip_v = true
	hp -= damage
	print("owie by " + str(damage))
	await get_tree().create_timer(0.3).timeout
	front_sprite.flip_v = false
