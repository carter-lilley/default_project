@icon("res://Icons/TorusMesh.svg")
#player_manager.gd
class_name PlayerManager
extends Manager

var players: Array[PlayerComponent] = []
var first_player:bool = false
var can_join: bool = true

@onready var input_man = $"../InputManager"
@onready var settings_man = $"../SettingsManager"
# signal for new player
signal player_registered(player: Node)

func _ready():
	print("[PlayerManager]: initialized.")
	_find_existing_players()

#This seems wildly inefficient every input frame
#How do "drop in" systems work without polling every frame?
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var device_id = event.device
		for player in players:
			if not player.has_joypad:
				print("[PlayerManager]: Player bound to controller %s (%d)" % [Input.get_joy_name(device_id), device_id])
				player.bind_controller(Input.get_joy_name(device_id), device_id)
				return

func _find_existing_players():
	for node in get_tree().get_nodes_in_group("player_components"):
		if node is PlayerComponent:
			register_player(node)

func get_player(id : int):
	for player in players:
		if player.player_id == id:
			return player
	return null

func register_player(player: PlayerComponent):
	if player in players:
		return # already registered
	players.append(player)
	player.is_connected = true
	emit_signal("player_registered", player)
	print("[PlayerManager]: Player registered ", player.player_id)
