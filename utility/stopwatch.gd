extends Node
class_name Stopwatch

var time_elapsed:float = 0
var ignores_timescale:bool = false
var paused:bool = true

func start(reset_on_start:bool = true) -> void:
	if reset_on_start:
		reset(false)
	paused = false
	
func pause() -> void:
	paused = true
	
func reset(pause:bool = true) -> void:
	time_elapsed = 0
	paused = true


func _process(delta: float) -> void:
	if paused:
		return
	if ignores_timescale:
		time_elapsed += delta
	else:
		time_elapsed += delta / Engine.time_scale
	
