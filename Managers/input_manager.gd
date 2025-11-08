@icon("res://Icons/RibbonTrailMesh.svg")
#input_manager.gd
class_name InputManager
extends Manager
@onready var settings_man = $"../SettingsManager"
@onready var player_man = $"../PlayerManager"

# the general idea is that there are default actions
# and then behaviors layer new contextual actions
signal action_triggered(action: String, event: InputEvent)

#@export_tool_button("add_default_actions", "Callable") var callable_action = add_default_actions
func _ready() -> void:
	initialize_actions()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	print("InputManager initialized.")
	settings_man.connect("action_changed", _on_action_changed)

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

func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0, response: Curve = null) -> Vector2: #response: Curve
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

func _unhandled_input(event: InputEvent) -> void:
	for action_name in InputMap.get_actions():
		if InputMap.action_has_event(action_name, event):
			if event.is_action(action_name):
				emit_signal("action_triggered", action_name, event)
				#print("Action:", action_name)

func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		print("Controller %d connected" % device_id)
		for player in player_man.players:
			if not player.has_joypad:
				player.bind_controller(device_id)
				return
	else:
		print("Controller %d disconnected" % device_id)
		for player in player_man.players:
			if player.controller_id == device_id:
				player.unbind_controller(device_id)
				return
