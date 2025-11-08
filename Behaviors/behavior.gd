#camera_behavior.gd
extends Resource
class_name Behavior

#@export var priority: int = 0  # Used for blending if needed
@export var input_exclusive:bool = false

func enter(owner): pass
func exit(owner): pass
func update(delta): pass
func handle_input(event): pass
