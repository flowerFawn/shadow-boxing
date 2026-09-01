extends CharacterBody3D
class_name Boxer

@export var sprite:AnimatedSprite3D

const ACCELERATION:float = 2
const DECELERATION:float = 4
const MAX_SPEED:float = 1
const CAMERA_DISTANCE:float = 0.5
const STRONG_THRESHOLD:float = 0.4
const STRONG_DAMAGE:float = 2
const LIGHT_DAMAGE:float = 1
const STRONG_RANGE:float = 0.6
const LIGHT_RANGE:float = 1

enum ArmState {
	PASSIVE,
	CHARGING,
	BLOCKING,
}

enum Arm {
	BOTH,
	LEFT,
	RIGHT,
}

enum StrafeDirection {
	NONE,
	LEFT,
	RIGHT,
	BACK
}

enum BoxerState {
	BASE,
	STRAFING_LEFT,
	STRAFING_RIGHT,
	STRAFING_BACK,
	LIGHT_CHARGING,
	LIGHT_LEFT_CHARGING,
	LIGHT_RIGHT_CHARGING,
	STRONG_CHARGING,
	STRONG_LEFT_CHARGING,
	STRONG_RIGHT_CHARGING,
	LIGHT_PUNCHING,
	LIGHT_LEFT_PUNCHING,
	LIGHT_RIGHT_PUNCHING,
	STRONG_PUNCHING,
	STRONG_LEFT_PUNCHING,
	STRONG_RIGHT_PUNCHING,
	BLOCKING,
	HURTING,
}

@export var max_hp:float = 10
var hp:float

var boxer_state:BoxerState = BoxerState.BASE

func _ready() -> void:
	hp = max_hp
	
func set_state(new_state:BoxerState) -> void:
	boxer_state = new_state

func update_sprite():
	set_sprite_animation(BoxerState.keys()[boxer_state])
	
func set_sprite_animation(animation:StringName):
	if sprite.animation != animation:
		sprite.play(animation)
		
func get_state_string() -> String:
	return BoxerState.keys()[boxer_state]
