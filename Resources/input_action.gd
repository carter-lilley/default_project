# input_action.gd
extends Resource
class_name InputAction

@export var name: String
@export var deadzone: float = 0.5
@export var events: Array[InputEvent]
