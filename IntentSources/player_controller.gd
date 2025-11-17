@icon("res://Icons/Joypad.svg")
#player_controller.gd
extends Controller
class_name PlayerComponent

@onready var input_man = $"../../GameManager/InputManager"
@export var player_id : int
var player : Player

func _init() -> void:
	add_to_group("player_controllers")

func bind_player(_player : Player):
	player = _player
	if not self in player.components:
		player.components.append(self)
	print("[%s]: Conencted to player (%d)" % [str(self), player.id])

func _process(delta: float) -> void:
	if player and not player.intent.actions.is_empty():
		print(player.intent.actions)
