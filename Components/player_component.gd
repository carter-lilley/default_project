@icon("res://Icons/Joypad.svg")
#player_component.gd
extends Component
class_name PlayerComponent

@export var player_id: int = 1               # Player 1, 2, 3...
@export var controller_id: int = -1   # Joystick ID
@export var is_connected:bool = false
@export var has_joypad:bool = false

func _init() -> void:
	add_to_group("player_components")

func unbind_controller(devID: int):
	controller_id = -1
	has_joypad = false
	print(self, " unbound joy.", devID)
	
func bind_controller(devID: int):
	controller_id = devID
	has_joypad = true
	print(self, " bound to new joy ID ", devID)
