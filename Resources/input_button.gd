# input_button.gd
extends BaseButton
class_name InputButtons

@export var state_popup : bool = false
#Using a library addon for controller textures. I'd like to make my own. 
@export var input_tex : TextureRect = TextureRect.new()
var key_icon =  ControllerIconTexture.new()
var joy_icon =  ControllerIconTexture.new()

# Input Buttons
var joy_button : Button = Button.new()
var key_button : Button = Button.new()

# Input switching countdown
var countdown_timer : Timer = Timer.new()
var countdown_label : Label = Label.new()
var countdown_message : Label = Label.new()
var countdown_panel : PopupPanel = PopupPanel.new()
var countdown_vbox : VBoxContainer = VBoxContainer.new()

signal action_changed(value: InputAction)

func initilize_tex():
	input_tex.ignore_texture_size = true
	input_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	input_tex.set_anchor_and_offset(SIDE_LEFT,0,0)
	input_tex.set_anchor_and_offset(SIDE_TOP,0,0)
	input_tex.set_anchor_and_offset(SIDE_RIGHT,1,0)
	input_tex.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	# Initialize Joy Icon
	joy_icon.force_type = ControllerIconTexture.ForceType.CONTROLLER
	joy_icon.path = action.name
	input_tex.texture = joy_icon
	joy_button.add_child(input_tex)
	# Initialize Key Icon
	var input_tex_2 = input_tex.duplicate()
	key_icon.force_type = ControllerIconTexture.ForceType.KEYBOARD_MOUSE
	key_icon.path = action.name
	input_tex_2.texture = key_icon
	key_button.add_child(input_tex_2)

func initilize_buttons():
	joy_button.size_flags_horizontal = SIZE_EXPAND_FILL
	joy_button.size_flags_vertical = SIZE_FILL
	key_button.size_flags_horizontal = SIZE_EXPAND_FILL
	key_button.size_flags_vertical = SIZE_FILL
	key_button.connect("pressed", _on_pressed.bind(InputTypes.KEY))
	joy_button.connect("pressed", _on_pressed.bind(InputTypes.JOY))

func initilize_countdown():
# Initialize the PopupPanel
	countdown_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_message.text = "Press input button:"
	countdown_vbox.add_child(countdown_message)
	countdown_vbox.add_child(countdown_label)
	countdown_panel.connect("window_input",_on_window_input_event)
	countdown_panel.set_exclusive(true)
	countdown_panel.add_child(countdown_vbox)
	countdown_timer.connect("timeout", _close_popup)
	countdown_timer.wait_time = 3.0  # 3 seconds
	countdown_timer.one_shot = true  # Timer will only run once
	add_child(countdown_timer)
	add_child(countdown_panel)

@export var action : InputAction
func _init(_action : InputAction) -> void:
	action = _action
	initilize_tex()
	initilize_buttons()
	initilize_countdown()

func _ready() -> void:
	get_parent().add_child.call_deferred(joy_button)
	get_parent().add_child.call_deferred(key_button)

func _process(delta: float) -> void:
	if state_popup:
		countdown_label.text = str(round(countdown_timer.time_left)) + "..."  

enum InputTypes { JOY, KEY }
@export var input_type: InputTypes = InputTypes.JOY
func _on_pressed(type : InputTypes):
	input_type = type
	state_popup = true
	countdown_panel.show()
	countdown_panel.popup_centered()
	countdown_timer.start()

func _close_popup():
	state_popup = false
	countdown_panel.hide()

##	Override default popup left click behavior
#func _unhandled_input(event: InputEvent) -> void:
	#if state_popup:
		#match my_type:
			#InputType.KEY:
				#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and my_type == InputType.KEY:
					#set_input(event)
					#_close_popup()

func _on_window_input_event(event: InputEvent) -> void:
	if state_popup:
		match input_type:
			InputTypes.JOY:
				if event is InputEventJoypadButton or event is InputEventJoypadMotion:
					replace_event(event)
					_close_popup()
			InputTypes.KEY:
				if event is InputEventKey or event is InputEventMouseButton:
					replace_event(event)
					_close_popup()

func replace_event(new_event:InputEvent):
	var new_action : InputAction = action.duplicate(true)
	for i in range(action.events.size()):
		match input_type:
			InputTypes.JOY:
				if action.events[i] is InputEventJoypadButton or action.events[i] is InputEventJoypadMotion:
					new_action.events[i] = new_event
					emit_signal("action_changed", new_action)
			InputTypes.KEY:
				if action.events[i] is InputEventKey or action.events[i] is InputEventMouseButton:
					new_action.events[i] = new_event
					emit_signal("action_changed", new_action)
