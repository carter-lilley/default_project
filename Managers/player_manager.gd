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
	input_man.connect("action_triggered", _build_intent)
	print("[PlayerManager]: initialized.")
	_find_existing_players()

func _build_intent(action: String, event: InputEvent):
	for player in players:
		if player.controller_id != event.device:
			continue # Skip players that don't own this device
		match action:
			"jump":
				player.intent.jump = event.is_pressed()
			"crouch":
				player.intent.crouch = event.is_pressed()
			"sprint":
				player.intent.sprint = event.is_pressed()
		# Map analog movement
		player.intent.move = input_man.get_vector(
			"move_left", "move_right", "move_forward", "move_back")
			#settings_man.get_setting("lstick_dz").value,
			#settings_man.get_setting("lstick_response").value
		#)

func _find_existing_players():
	for node in get_tree().get_nodes_in_group("player_components"):
		if node is PlayerComponent:
			register_player(node)

func register_player(player: PlayerComponent):
	if player in players:
		return # already registered
	players.append(player)
	player.is_connected = true
	emit_signal("player_registered", player)
	print("[PlayerManager]: Player registered ", player.player_id)
