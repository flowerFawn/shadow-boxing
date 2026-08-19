extends Node
class_name Stopwatch

var time_elapsed:float = 0
var ignores_timescale:bool = false
var paused:bool = true

func start() -> void:
	paused = false
	
func pause() -> void:
	paused = true


func _process(delta: float) -> void:
	if paused:
		return
	if ignores_timescale:
		time_elapsed += delta
	else:
		time_elapsed += delta / Engine.time_scale
	
