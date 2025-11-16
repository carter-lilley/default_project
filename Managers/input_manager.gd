@icon("res://Icons/RibbonTrailMesh.svg")
#input_manager.gd
class_name InputManager
extends Manager
@onready var settings_man = $"../SettingsManager"
@onready var player_man = $"../PlayerManager"
@export var DUMMY_ACTIONS : InputActionList
var connected_controllers: Dictionary = {} # device_id -> name
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
	print("[InputManager]: initialized.")
	settings_man.connect("action_changed", _on_action_changed)
	#player_man.connect("first_player_registered",_on_first_player)

func initialize_actions():
	var actions = settings_man.get_setting("actions").value as InputActionList
	for action in actions.list:
		add_action(action) 

func add_action(action: InputAction):
	if InputMap.has_action(action.name):
		InputMap.erase_action(action.name)
	InputMap.add_action(action.name)
	for event in action.events:
		InputMap.action_add_event(action.name, event)

func _on_action_changed(action: InputAction):
		add_action(action)
		ControllerIcons.refresh()

# You can make this more performant in a couple ways -
# Make a local copy of some sort of device to player lookup table to reference direcly - get player by device without looping, same as below
# Lastly, you can make a local duplicate of the action array when it's updated to look through...
# Though im skeptical it will be any more performant. 
var bound_devices := {} # device_id -> true
func _unhandled_input(event: InputEvent) -> void:
	if player_man.can_join:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			var device_id = event.device
			if bound_devices.has(device_id) or player_man.unbound_players.size() == 0:
				return # already bound
			# bind the first unbound player
			var player = player_man.unbound_players.pop_front()
			player.bind_controller(Input.get_joy_name(device_id), device_id)
			bound_devices[device_id] = true
			print("[PlayerManager]: Controller %s (%d) bound to player (%d)" % [Input.get_joy_name(device_id), device_id, player.id])
	for action_name in InputMap.get_actions():
		if InputMap.action_has_event(action_name, event):
			if event.is_action(action_name):
				if event is InputEventKey or event is InputEventMouse: # Give KB&M to first player
					var first_player = player_man.players[0]
					if first_player:    
						print("[InputManager]: Sent action [", action_name, "] to player ", first_player.id)
				else:
					for player in player_man.players:
						if player.controller_id != event.device:
							continue
						player.intent.actions[action_name] = event
						print("[InputManager]: Sent action [", action_name, "] to player ", player.id)
 
func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		var device_name = Input.get_joy_name(device_id)
		connected_controllers[device_id] = device_name
		print("[InputManager]: Controller %s - %d connected" % [device_name, device_id])
	else:
		var device_name = connected_controllers.get(device_id, "Unknown")
		print("[InputManager]: Controller %s - %d disconnected" % [device_name, device_id])
		connected_controllers.erase(device_id)
		for player in player_man.players:
			if player.controller_id == device_id:
				player.unbind_controller(device_name, device_id)
				return

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
