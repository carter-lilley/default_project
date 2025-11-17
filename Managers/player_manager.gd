@icon("res://Icons/TorusMesh.svg")
#player_manager.gd
class_name PlayerManager
extends Manager

var players : Dictionary[int, Player] #id, player
var can_join: bool = true

@onready var input_man = $"../InputManager"
@onready var settings_man = $"../SettingsManager"

signal player_registered(player: Player)

func _ready():
	#print("[PlayerManager]: initialized.")
	var p1 = Player.new()
	register_player(p1)
	get_tree().connect("node_added", _on_node_added)
	bind_existing_components()
	
func get_player(id : int):
	return players.get(id, null)

func get_player_by_device(device_id : int):
	for id in players.keys():
		if players[id].controller_id == device_id:
			return players[id]
	return null

func player_exists(player: Player):
	for id in players.keys():
		if players[id] == player:
			return players[id]
	return null

func _on_node_added(node: Node):
	if node is PlayerComponent:
		bind_component(node)
			
func bind_existing_components():
	for node in get_tree().get_nodes_in_group("player_controllers"):
		if node is PlayerComponent:
			bind_component(node)

func bind_component(component: Node):
	var id = component.player_id
	var player = get_player(id)
	if id <= 0 or not player:
		return # component is unassigned or player does not exist
	component.bind_player(player)

func register_player(player: Player):
	if player_exists(player):
		return # Player exists. 
	var id = players.size()+1
	player.id = id
	players[id] = player
	emit_signal("player_registered", player)
	print("[PlayerManager]: Player registered: (%d) " % [player.id])
