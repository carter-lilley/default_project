@icon("res://Icons/RibbonTrailMesh.svg")
#input_manager.gd
class_name InputManager
extends Manager
@onready var settings_man = $"../SettingsManager"
@onready var player_man = $"../PlayerManager"
@export var DUMMY_ACTIONS : InputActionList

signal action_triggered(action: String, event: InputEvent)

#Alright so here's the deal. Keep the action map names as generic as possible.
#They can even overlap, if you like. "Primary_Action", "Secondary_Action" "Menu" etc.
#Then either the intents or behaviors will decide semantically what these actions mean to them.
#intent.actions["teleport"] = intent.actions_generic["action_secondary"], etc.
#Right now controlling components have intents. We just need to build those intents somewhere. 

#@export_tool_button("add_default_actions", "Callable") var callable_action = add_default_actions
func _ready() -> void:
	initialize_actions()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	#print("[InputManager]: initialized.")
	settings_man.connect("action_changed", _on_action_changed)
	player_man.connect("player_registered",_on_player_registered)

var unbound_players:Array[Player]
func _on_player_registered(player : Player):
	unbound_players.append(player)

#var actions_cache: InputActionList
func initialize_actions():
	var actions = settings_man.get_setting("actions").value as InputActionList
	for action in actions.list:
		realize_action(action) 

func realize_action(action: InputAction):
	if InputMap.has_action(action.name):
		InputMap.erase_action(action.name)
	InputMap.add_action(action.name)
	for event in action.events:
		InputMap.action_add_event(action.name, event)

func _on_action_changed(action: InputAction):
		realize_action(action)
		ControllerIcons.refresh()

# To make this more performant, use the local InputActionList to create a reverse scancode lookup of event -> action, updated with signals. 
func _unhandled_input(event: InputEvent) -> void:
	# If players can join, a player needs a joypad, and this is an unbound joypad: bind the first unbound player to this joypad. 
	# JOIN 
	if player_man.can_join:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			var device_id = event.device
			if not get_device_player(device_id) or unbound_players.size() > 0:
				var player = unbound_players.pop_front()
				player.bind_controller(Input.get_joy_name(device_id), device_id)
				devices[device_id]["player"] = player
				print("[InputManager]: %s [%d] bound to player (%d)" % [Input.get_joy_name(device_id), device_id, player.id])
	# ACTIONS
	for action in InputMap.get_actions():
		if InputMap.event_is_action(event,action):
			if event is InputEventKey or event is InputEventMouse: # Give KB&M to first player
				var first_player = player_man.players.get(1)
				if first_player:
					emit_signal("action_triggered", action, event)
					first_player.intent.actions[action] = event
					#print("[InputManager]: Sent action [", action, "] to player ", first_player.id)
			else: #Send the relevant device inputs to their respective players
				var player = get_device_player(event.device)
				if player:
					emit_signal("action_triggered", action, event)
					player.intent.actions[action] = event
					#print("[InputManager]: Sent action [", action, "] to player ", player.id)
				else: print("[InputManager]: No player found for this device.")

func get_device_player(device_id: int):
	var info = devices.get(device_id, null)
	if info:
		return info.get("player", null)
	return null
	 
var devices: Dictionary[int, Dictionary] = {} # device_id -> { "player": Player, "name": String }
func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		# Store the device name immediately, player may be null initially
		devices[device_id] = { "player": null, "name": Input.get_joy_name(device_id) }
		print("[InputManager]: %s [%d] connected" % [devices[device_id]["name"], device_id])
	else:
		var device_info = devices.get(device_id, {"name":"Unknown"})
		print("[InputManager]: Controller %s [%d] disconnected" % [device_info["name"], device_id])
		devices.erase(device_id)
		var player = player_man.get_player_by_device(device_id)
		if player:
			player.unbind_controller(device_info["name"], device_id)

func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = 0.0, response: Curve = null) -> Vector2: #response: Curve
	var vector: Vector2 = Vector2(Input.get_axis(negative_x, positive_x), Input.get_axis(negative_y, positive_y))
#If the response isn't specified, use a linear curve.
	if response == null:
		response = Curve.new()
		response.add_point(Vector2(0,0))
		response.add_point(Vector2(1,1))

#If the deadzone isn't specified, get it from the average of the actions.
	if deadzone < 0.0:
		deadzone = 0.25 * (
			InputMap.action_get_deadzone(positive_x) +
			InputMap.action_get_deadzone(negative_x) +
			InputMap.action_get_deadzone(positive_y) +
			InputMap.action_get_deadzone(negative_y)
		)
#Now, take the length & do circular limiting, deadzone, and response interpolation. 
	var length := vector.length()
	if length == 0:
		return Vector2.ZERO
	if length > 1.0:
		vector /= length
		length = 1.0
	var scaled_length : float = clamp((length - deadzone) / (1.0 - deadzone), 0.0, 1.0)
	var final_length : float = response.sample(scaled_length)
# Reapply the direction vector to the new magnitude
	return vector.normalized() * final_length
