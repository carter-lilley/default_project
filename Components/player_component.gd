@icon("res://Icons/Joypad.svg")
#player_component.gd
extends Component
class_name PlayerComponent

@export var intent:Intent = Intent.new()
@export var player_id: int = 1               # Player 1, 2, 3...
@export var controller_id: int = -1   # Joystick ID
@export var is_connected:bool = false
@export var has_joypad:bool = false

@onready var input_man = $"../../GameManager/InputManager"

func _init() -> void:
	add_to_group("player_components")

func _process(delta: float) -> void:
	pass
	#print(intent.actions)

func unbind_controller(device_name : String, devID: int):
	controller_id = -1
	has_joypad = false
	print("[%s]: Controller - %s unbound" % [name, device_name])
	
func bind_controller(device_name : String, devID: int):
	controller_id = devID
	has_joypad = true
	print("[%s]: Controller - %s bound" % [name, device_name])
