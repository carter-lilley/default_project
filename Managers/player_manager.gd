@icon("res://Icons/TorusMesh.svg")
#player_manager.gd
class_name PlayerManager
extends Manager

var players: Array[PlayerComponent] = []
var first_player:bool = false
var can_join: bool = true

# signal for new player
signal player_registered(player: Node)

func _ready():
	print("PlayerManager initialized.")
	_find_existing_players()

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
	print("Player registered:", player.player_id)
