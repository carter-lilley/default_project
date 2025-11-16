@icon("res://Icons/TorusMesh.svg")
#player_manager.gd
class_name PlayerManager
extends Manager

var players: Array[Player]
var unbound_players:Array[Player]
var can_join: bool = true

@onready var input_man = $"../InputManager"
@onready var settings_man = $"../SettingsManager"

signal player_registered(player: Node)
signal first_player_registered()

func _ready():
	print("[PlayerManager]: initialized.")
	var p1 = Player.new()
	register_player(p1)
	get_tree().connect("node_added", _on_node_added)
	bind_existing_components()
	
func get_player(id : int):
	for player in players:
		if player.id == id:
			return player
	return null

func _on_node_added(node: Node):
	if node is PlayerComponent:
		bind_component(node)
			
func bind_existing_components():
	for node in get_tree().get_nodes_in_group("player_components"):
		if node is PlayerComponent:
			bind_component(node)

func bind_component(component: Node):
	var id = component.player_id
	var player = get_player(id)
	if id <= 0 or not player:
		return # component is unassigned or player does not exist
	component.bind_player(player)

func register_player(player: Player):
	if player in players:
		return # Player is already registered. 
	var id = players.size()+1
	if id == 1:
		emit_signal("first_player_registered")
	player.id = id
	players.append(player)
	unbound_players.append(player)
	emit_signal("player_registered", player)
	print("[PlayerManager]: Player registered ", player.id)
